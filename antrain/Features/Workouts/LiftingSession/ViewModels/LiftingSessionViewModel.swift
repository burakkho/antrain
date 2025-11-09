import Foundation
import Observation
import SwiftUI

/// Lifting session view model
/// Manages workout state, exercises, sets, and save logic
@Observable @MainActor
final class LiftingSessionViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol
    private let prDetectionService: PRDetectionService
    private let progressiveOverloadService: ProgressiveOverloadService
    private let userProfileRepository: UserProfileRepositoryProtocol
    internal let liveActivityManager: LiveActivityManager
    private let widgetUpdateService: WidgetUpdateService

    // MARK: - State

    var workout: Workout
    var exercises: [WorkoutExercise] = []
    var workoutTitle: String?
    var isLoading = false
    var errorMessage: String?
    var showExerciseSelection = false
    var showSummary = false
    var currentSuggestion: SuggestedWorkout?

    // Program context (if starting from program)
    var programDay: ProgramDay?
    var programWeek: ProgramWeek?

    // MARK: - Performance Cache (Apple WWDC 2025 best practice)

    /// Cached total volume to avoid recalculating on every render
    private var _cachedTotalVolume: Double?

    /// Cached completed exercises count to avoid filtering on every render
    private var _cachedCompletedExercisesCount: Int?

    /// Invalidate all computed property caches
    /// Call this whenever exercises or sets change
    private func invalidateCache() {
        _cachedTotalVolume = nil
        _cachedCompletedExercisesCount = nil
    }

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        prDetectionService: PRDetectionService,
        progressiveOverloadService: ProgressiveOverloadService,
        userProfileRepository: UserProfileRepositoryProtocol,
        liveActivityManager: LiveActivityManager,
        widgetUpdateService: WidgetUpdateService
    ) {
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
        self.prDetectionService = prDetectionService
        self.progressiveOverloadService = progressiveOverloadService
        self.userProfileRepository = userProfileRepository
        self.liveActivityManager = liveActivityManager
        self.widgetUpdateService = widgetUpdateService
        self.workout = Workout(date: Date(), type: .lifting)
    }

    // MARK: - Template Integration

    /// Load workout from template
    /// Converts template exercises to workout exercises with pre-populated sets
    /// - Parameters:
    ///   - template: The workout template to load
    ///   - templateRepository: Template repository
    ///   - programDay: Optional program day context (for program-based workouts)
    func loadFromTemplate(
        _ template: WorkoutTemplate,
        templateRepository: WorkoutTemplateRepositoryProtocol,
        programDay: ProgramDay? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        // Store program context
        self.programDay = programDay
        self.programWeek = programDay?.week

        do {
            // Save template name as workout title
            workoutTitle = template.name

            // Clear existing exercises
            exercises.removeAll()
            workout.exercises = []

            // Get week modifier from program context or active program
            let userProfile = try await userProfileRepository.fetchOrCreateProfile()
            var weekModifier = 1.0
            var previousWorkouts: [Workout] = []

            // Priority: Use programWeek if provided, otherwise fall back to active program
            if let week = programWeek {
                weekModifier = week.intensityModifier
            } else if let activeProgram = userProfile.activeProgram,
                      let currentWeek = userProfile.currentWeekNumber,
                      let week = activeProgram.weeks.first(where: { $0.weekNumber == currentWeek }) {
                weekModifier = week.intensityModifier
            }

            // Fetch previous workouts for this template (last 5 for RPE analysis)
            // Using fetchRecent() for database-level optimization (Apple best practice)
            let recentWorkouts = try await workoutRepository.fetchRecent(limit: 5)
            previousWorkouts = recentWorkouts.filter { workout in
                // Match workouts that used this template
                workout.exercises.contains { workoutEx in
                    template.exercises.contains { templateEx in
                        workoutEx.exercise?.id == templateEx.exerciseId
                    }
                }
            }

            // Get workout suggestions
            currentSuggestion = await progressiveOverloadService.suggestWorkout(
                for: template,
                weekModifier: weekModifier,
                previousWorkouts: previousWorkouts
            )

            // Convert each template exercise to workout exercise
            for templateExercise in template.exercises.sorted(by: TemplateExercise.compare) {
                // Fetch the actual exercise from repository
                guard let exercise = try await exerciseRepository.fetchExercise(by: templateExercise.exerciseId) else {
                    print("⚠️ Exercise not found: \(templateExercise.exerciseName)")
                    continue
                }

                // Create workout exercise
                let workoutExercise = WorkoutExercise(
                    exercise: exercise,
                    orderIndex: templateExercise.order
                )

                // Find suggestion for this exercise
                let suggestion = currentSuggestion?.exercises.first { $0.exerciseId == templateExercise.exerciseId }

                // Pre-populate sets based on template configuration and suggestions
                for _ in 0..<templateExercise.setCount {
                    let set = WorkoutSet(
                        reps: suggestion?.suggestedReps ?? templateExercise.repRangeMin,
                        weight: suggestion?.suggestedWeight ?? 0,
                        isCompleted: false
                    )
                    workoutExercise.sets.append(set)
                }

                exercises.append(workoutExercise)
            }

            workout.exercises = exercises

            // Mark template as used
            try await templateRepository.markTemplateUsed(template)

            // Invalidate cache after loading template
            invalidateCache()

            print("✅ Loaded \(exercises.count) exercises from template: \(template.name)")
            if currentSuggestion != nil {
                print("💡 Applied progressive overload suggestions with week modifier: \(weekModifier)")
            }
        } catch {
            errorMessage = "Failed to load template: \(error.localizedDescription)"
            print("❌ Template load error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Exercise Management

    /// Add exercise to workout
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            orderIndex: exercises.count
        )
        exercises.append(workoutExercise)
        workout.exercises = exercises

        // Invalidate cache
        invalidateCache()

        // Update Live Activity
        liveActivityManager.notifyStateChanged()
    }

    /// Remove exercise from workout
    func removeExercise(_ workoutExercise: WorkoutExercise) {
        exercises.removeAll { $0.id == workoutExercise.id }
        workout.exercises = exercises
        reorderExercises()

        // Invalidate cache
        invalidateCache()
    }

    /// Reorder exercises
    func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        reorderExercises()
    }

    private func reorderExercises() {
        for (index, exercise) in exercises.enumerated() {
            exercise.orderIndex = index
        }
        workout.exercises = exercises
    }

    // MARK: - Set Management

    /// Add set to exercise (auto-fill from last set)
    func addSet(to workoutExercise: WorkoutExercise) {
        let newSet: WorkoutSet

        if let lastSet = workoutExercise.sets.last {
            // Auto-fill from last set
            newSet = WorkoutSet(
                reps: lastSet.reps,
                weight: lastSet.weight,
                isCompleted: false
            )
        } else {
            // First set - default values
            newSet = WorkoutSet(
                reps: 10,
                weight: 0,
                isCompleted: false
            )
        }

        workoutExercise.sets.append(newSet)
    }

    /// Mark set as completed
    func completeSet(_ set: WorkoutSet) {
        set.isCompleted = true
    }

    /// Toggle set completion state
    func toggleSetCompletion(_ set: WorkoutSet) {
        set.toggleCompletion()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Invalidate cache (completion affects volume and completed exercises count)
        invalidateCache()

        // Update Live Activity
        liveActivityManager.notifyStateChanged()
    }

    /// Complete all sets for an exercise
    func completeAllSetsForExercise(_ workoutExercise: WorkoutExercise) {
        workoutExercise.completeAllSets()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Invalidate cache
        invalidateCache()
    }

    /// Update set values
    func updateSet(_ set: WorkoutSet, reps: Int, weight: Double) {
        set.reps = reps
        set.weight = weight

        // Invalidate cache (weight/reps affect volume if set is completed)
        invalidateCache()
    }

    /// Remove set from exercise
    func removeSet(_ set: WorkoutSet, from workoutExercise: WorkoutExercise) {
        workoutExercise.sets.removeAll { $0.id == set.id }

        // Invalidate cache
        invalidateCache()
    }

    // MARK: - Save & Cancel

    /// Save workout
    /// Creates a fresh workout with all exercises and sets to ensure proper SwiftData persistence
    /// - Parameters:
    ///   - notes: Optional workout notes
    func saveWorkout(notes: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            // Create a FRESH workout (fixes transient object issue)
            let newWorkout = Workout(
                date: workout.date,
                type: .lifting,
                duration: Date().timeIntervalSince(workout.date),
                notes: notes
            )

            // Rebuild exercise hierarchy properly
            for existingExercise in exercises {
                // Skip if exercise is nil (shouldn't happen, but safety check)
                guard let exercise = existingExercise.exercise else { continue }

                let newWorkoutExercise = WorkoutExercise(
                    exercise: exercise,
                    orderIndex: existingExercise.orderIndex
                )

                // Add all sets
                for existingSet in existingExercise.sets {
                    let newSet = WorkoutSet(
                        reps: existingSet.reps,
                        weight: existingSet.weight,
                        isCompleted: existingSet.isCompleted
                    )
                    newWorkoutExercise.sets.append(newSet)
                }

                // Use model's relationship method for proper SwiftData tracking
                newWorkout.addExercise(newWorkoutExercise)
            }

            // Validate and save
            try newWorkout.validate()
            try await workoutRepository.save(newWorkout)

            // Detect and save new PRs
            let newPRs = try await prDetectionService.detectAndSavePRs(from: newWorkout)
            if !newPRs.isEmpty {
                print("🏆 New PRs detected: \(newPRs.count)")
                for pr in newPRs {
                    print("  - \(pr.exerciseName): \(pr.estimated1RM)kg")
                }
            }

            // Update program progress if workout was from a program
            if let programDay = programDay {
                let userProfile = try await userProfileRepository.fetchOrCreateProfile()

                // Check if this is the last day of the current week
                if let programWeek = programWeek,
                   let _ = userProfile.activeProgram,
                   let currentWeekNumber = userProfile.currentWeekNumber,
                   programWeek.weekNumber == currentWeekNumber {

                    // Count completed days in this week
                    let completedDaysThisWeek = programWeek.days.filter { day in
                        // Check if there's a workout for this day
                        // (This is a simplified check - in production you might want more robust tracking)
                        day.dayOfWeek <= programDay.dayOfWeek
                    }.count

                    // If this was the last scheduled day of the week, advance to next week
                    if completedDaysThisWeek == programWeek.days.count {
                        userProfile.progressToNextWeek()
                        // Save the updated profile
                        _ = try await userProfileRepository.updateProfile(
                            name: userProfile.name,
                            dailyCalorieGoal: userProfile.dailyCalorieGoal,
                            dailyProteinGoal: userProfile.dailyProteinGoal,
                            dailyCarbsGoal: userProfile.dailyCarbsGoal,
                            dailyFatsGoal: userProfile.dailyFatsGoal
                        )
                        print("📅 Advanced to week \(userProfile.currentWeekNumber ?? 0)")
                    }
                }
            }

            // Success - notify views to refresh
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutSaved"), object: nil)

            // Update widget data
            await widgetUpdateService.updateWidgetData()
        } catch {
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
            print("❌ Workout save error: \(error)")
        }

        isLoading = false
    }

    /// Check if workout can be saved
    var canSave: Bool {
        !exercises.isEmpty && exercises.contains { !$0.sets.isEmpty }
    }

    /// Check if workout has data (for cancel confirmation)
    var hasData: Bool {
        !exercises.isEmpty
    }

    // MARK: - Workout Statistics

    /// Current workout duration
    var duration: TimeInterval {
        Date().timeIntervalSince(workout.date)
    }

    /// Total volume (sum of all completed sets' weight × reps)
    /// Cached for performance - Apple WWDC 2025 best practice
    var totalVolume: Double {
        if let cached = _cachedTotalVolume {
            return cached
        }

        let volume = exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.reduce(0) { setTotal, set in
                setTotal + (set.weight * Double(set.reps))
            }
        }

        _cachedTotalVolume = volume
        return volume
    }

    /// Number of exercises with at least one completed set
    /// Cached for performance - Apple WWDC 2025 best practice
    var completedExercisesCount: Int {
        if let cached = _cachedCompletedExercisesCount {
            return cached
        }

        let count = exercises.filter { exercise in
            exercise.sets.contains { $0.isCompleted }
        }.count

        _cachedCompletedExercisesCount = count
        return count
    }

    /// Total number of exercises in workout
    var totalExercisesCount: Int {
        exercises.count
    }

    // MARK: - Live Activity Management

    /// Access to LiveActivityManager for external state change callbacks
    var onStateChanged: (() -> Void)? {
        get { liveActivityManager.onStateChanged }
        set { liveActivityManager.onStateChanged = newValue }
    }

    // MARK: - Exercise Suggestions

    /// Get suggestion for a specific exercise
    func getSuggestion(for exerciseId: UUID) -> ExerciseSuggestion? {
        currentSuggestion?.exercises.first { $0.exerciseId == exerciseId }
    }
}
