import SwiftUI

/// Position of the active workout bar
enum WorkoutBarPosition: String, Codable {
    case top
    case middle
    case bottom
}

/// Global state manager for active workout session
/// Allows workout to persist across tab navigation and app restarts
@Observable @MainActor
final class ActiveWorkoutManager {
    // MARK: - Properties

    /// UserDefaults key for persistence
    private static let activeWorkoutKey = "activeWorkoutSession"
    private static let barPositionKey = "workoutBarPosition"

    /// Currently active workout (nil if no active workout)
    var activeWorkout: Workout?

    /// Active workout's view model (nil if no active workout)
    var activeViewModel: LiftingSessionViewModel?

    /// Whether there is an active workout session
    var isActive: Bool {
        activeWorkout != nil && activeViewModel != nil
    }

    /// Whether to show the full screen workout view
    var showFullScreen = false

    /// Pending template to load when starting a new workout
    var pendingTemplate: WorkoutTemplate?

    /// Pending program day when starting a workout from a program
    var pendingProgramDay: ProgramDay?

    /// Current position of the workout bar
    var barPosition: WorkoutBarPosition {
        didSet {
            saveBarPosition()
        }
    }

    // MARK: - Init

    init() {
        // Load saved bar position
        if let savedPosition = UserDefaults.standard.string(forKey: Self.barPositionKey),
           let position = WorkoutBarPosition(rawValue: savedPosition) {
            self.barPosition = position
        } else {
            self.barPosition = .bottom // Default to bottom
        }
    }

    /// Active exercise name for display
    var activeExerciseName: String? {
        guard let viewModel = activeViewModel else { return nil }
        return viewModel.exercises.last?.exercise?.name
    }

    /// Completed set count
    var completedSets: Int {
        guard let viewModel = activeViewModel else { return 0 }
        return viewModel.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count }
    }

    /// Total set count
    var totalSets: Int {
        guard let viewModel = activeViewModel else { return 0 }
        return viewModel.exercises.reduce(0) { $0 + $1.sets.count }
    }

    // MARK: - Methods

    /// Start a new workout session
    func startWorkout(workout: Workout, viewModel: LiftingSessionViewModel) {
        self.activeWorkout = workout
        self.activeViewModel = viewModel
        self.showFullScreen = true
        saveState()
    }

    /// Start a new workout from a template
    func startWorkoutFromTemplate(_ template: WorkoutTemplate) {
        self.pendingTemplate = template
        self.showFullScreen = true
    }

    /// Start a new workout from a training program
    func startWorkoutFromProgram(_ template: WorkoutTemplate, programDay: ProgramDay) {
        self.pendingTemplate = template
        self.pendingProgramDay = programDay
        self.showFullScreen = true
    }

    /// Resume workout (show full screen)
    func resumeWorkout() {
        guard isActive else { return }
        showFullScreen = true
    }

    /// Minimize workout (hide full screen, show bar)
    func minimizeWorkout() {
        guard isActive else { return }
        showFullScreen = false
        saveState()
    }

    /// Finish workout and clear state
    func finishWorkout() {
        activeWorkout = nil
        activeViewModel = nil
        pendingTemplate = nil
        pendingProgramDay = nil
        showFullScreen = false
        clearState()
    }

    /// Cancel workout and clear state
    func cancelWorkout() {
        activeWorkout = nil
        activeViewModel = nil
        pendingTemplate = nil
        pendingProgramDay = nil
        showFullScreen = false
        clearState()
    }

    // MARK: - Persistence

    /// Save current workout state to UserDefaults
    private func saveState() {
        guard let viewModel = activeViewModel,
              let workout = activeWorkout else {
            clearState()
            return
        }

        // Convert to codable data
        let exercises = viewModel.exercises.map { workoutExercise -> WorkoutSessionData.ExerciseData in
            let sets = workoutExercise.sets.map { set -> WorkoutSessionData.SetData in
                WorkoutSessionData.SetData(
                    id: set.id,
                    reps: set.reps,
                    weight: set.weight,
                    isCompleted: set.isCompleted,
                    notes: set.notes
                )
            }

            return WorkoutSessionData.ExerciseData(
                id: workoutExercise.id,
                exerciseName: workoutExercise.exercise?.name ?? "Unknown",
                orderIndex: workoutExercise.orderIndex,
                sets: sets
            )
        }

        let sessionData = WorkoutSessionData(
            workoutId: workout.id,
            startDate: workout.date,
            exercises: exercises
        )

        sessionData.save()
    }

    /// Clear saved state from UserDefaults
    private func clearState() {
        WorkoutSessionData.clear()
    }

    /// Save bar position to UserDefaults
    private func saveBarPosition() {
        UserDefaults.standard.set(barPosition.rawValue, forKey: Self.barPositionKey)
    }

    /// Restore workout session from UserDefaults
    /// Returns true if restoration was successful
    func restoreState(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        prDetectionService: PRDetectionService,
        progressiveOverloadService: ProgressiveOverloadService,
        userProfileRepository: UserProfileRepositoryProtocol
    ) async -> Bool {
        guard let sessionData = WorkoutSessionData.load() else {
            return false
        }

        // Create new workout
        let workout = Workout(
            date: sessionData.startDate,
            type: .lifting
        )

        // Create view model with all dependencies
        let viewModel = LiftingSessionViewModel(
            workoutRepository: workoutRepository,
            exerciseRepository: exerciseRepository,
            prDetectionService: prDetectionService,
            progressiveOverloadService: progressiveOverloadService,
            userProfileRepository: userProfileRepository
        )

        // Restore exercises
        for exerciseData in sessionData.exercises {
            // Find exercise from repository
            let exercises = try? await exerciseRepository.fetchAll()
            guard let exercise = exercises?.first(where: { $0.name == exerciseData.exerciseName }) else {
                continue
            }

            let workoutExercise = WorkoutExercise(
                exercise: exercise,
                orderIndex: exerciseData.orderIndex
            )

            // Restore sets
            for setData in exerciseData.sets {
                let set = WorkoutSet(
                    reps: setData.reps,
                    weight: setData.weight,
                    isCompleted: setData.isCompleted
                )
                set.notes = setData.notes
                workoutExercise.sets.append(set)
            }

            viewModel.exercises.append(workoutExercise)
        }

        // Set as active
        self.activeWorkout = workout
        self.activeViewModel = viewModel
        self.showFullScreen = false // Start minimized

        return true
    }
}
