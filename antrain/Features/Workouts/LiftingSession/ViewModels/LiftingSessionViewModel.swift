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

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        prDetectionService: PRDetectionService,
        progressiveOverloadService: ProgressiveOverloadService,
        userProfileRepository: UserProfileRepositoryProtocol,
        widgetUpdateService: WidgetUpdateService
    ) {
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
        self.prDetectionService = prDetectionService
        self.progressiveOverloadService = progressiveOverloadService
        self.userProfileRepository = userProfileRepository
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

            // Parallel fetch: user profile and recent workouts (optimization to prevent sequential blocking)
            async let userProfileTask = userProfileRepository.fetchOrCreateProfile()
            async let recentWorkoutsTask = workoutRepository.fetchRecent(limit: 5)

            let (userProfile, recentWorkouts) = try await (userProfileTask, recentWorkoutsTask)

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

            // Filter workouts for this template
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

            // Parallel exercise fetch: fetch all exercises at once (optimization to prevent sequential blocking)
            let sortedTemplateExercises = template.exercises.sorted(by: TemplateExercise.compare)
            let fetchedExercises = try await withThrowingTaskGroup(of: (TemplateExercise, Exercise?).self) { group in
                // Create fetch tasks for all exercises in parallel
                for templateExercise in sortedTemplateExercises {
                    group.addTask {
                        let exercise = try await self.exerciseRepository.fetchExercise(by: templateExercise.exerciseId)
                        return (templateExercise, exercise)
                    }
                }

                // Collect results
                var results: [(TemplateExercise, Exercise?)] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }

            // Convert each template exercise to workout exercise (now with pre-fetched data)
            for (templateExercise, exercise) in fetchedExercises {
                guard let exercise = exercise else {
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
    }

    /// Remove exercise from workout
    func removeExercise(_ workoutExercise: WorkoutExercise) {
        exercises.removeAll { $0.id == workoutExercise.id }
        workout.exercises = exercises
        reorderExercises()
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
        HapticManager.shared.light()
    }

    /// Complete all sets for an exercise
    func completeAllSetsForExercise(_ workoutExercise: WorkoutExercise) {
        workoutExercise.completeAllSets()
        HapticManager.shared.exerciseCompleted()
    }

    /// Update set values
    func updateSet(_ set: WorkoutSet, reps: Int, weight: Double) {
        set.reps = reps
        set.weight = weight
    }

    /// Remove set from exercise
    func removeSet(_ set: WorkoutSet, from workoutExercise: WorkoutExercise) {
        workoutExercise.sets.removeAll { $0.id == set.id }
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

                // Celebratory haptic for PR achievement! 🎉
                HapticManager.shared.prAchieved()

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

    // MARK: - Computed Properties

    /// Current workout duration
    var duration: TimeInterval {
        Date().timeIntervalSince(workout.date)
    }

    /// Total volume (sum of all completed sets' weight × reps)
    var totalVolume: Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.reduce(0) { setTotal, set in
                setTotal + (set.weight * Double(set.reps))
            }
        }
    }

    /// Number of exercises with at least one completed set
    var completedExercisesCount: Int {
        exercises.filter { exercise in
            exercise.sets.contains { $0.isCompleted }
        }.count
    }

    /// Total number of exercises in workout
    var totalExercisesCount: Int {
        exercises.count
    }

    // MARK: - Exercise Suggestions

    /// Get suggestion for a specific exercise
    func getSuggestion(for exerciseId: UUID) -> ExerciseSuggestion? {
        currentSuggestion?.exercises.first { $0.exerciseId == exerciseId }
    }
}
