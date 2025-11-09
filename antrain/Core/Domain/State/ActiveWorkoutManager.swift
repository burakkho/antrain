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
    
    /// Live Activity service (injected)
    private let liveActivityService: LiveActivityServiceProtocol?

    /// Debounce task for Live Activity updates (Apple WWDC 2025 best practice)
    /// Prevents excessive updates when user is rapidly toggling sets
    private var liveActivityUpdateTask: Task<Void, Never>?

    // MARK: - Init

    init(liveActivityService: LiveActivityServiceProtocol? = nil) {
        self.liveActivityService = liveActivityService
        
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
        
        // Connect Live Activity updates
        viewModel.onStateChanged = { [weak self] in
            self?.updateLiveActivity()
        }
        
        saveState()

        // Start Live Activity (use immediate update for critical startup)
        let workoutName = viewModel.workoutTitle ?? "Workout"
        liveActivityService?.startActivity(workoutName: workoutName)
        updateLiveActivityImmediately()
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
        // End Live Activity
        liveActivityService?.endActivity()
        
        activeWorkout = nil
        activeViewModel = nil
        pendingTemplate = nil
        pendingProgramDay = nil
        showFullScreen = false
        clearState()
    }

    /// Cancel workout and clear state
    func cancelWorkout() {
        // End Live Activity
        liveActivityService?.endActivity()
        
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
    
    /// Update Live Activity with debouncing (Apple WWDC 2025 best practice)
    /// Prevents excessive updates when user rapidly toggles multiple sets
    /// Updates are debounced by 0.3 seconds
    func updateLiveActivity() {
        // Cancel previous pending update
        liveActivityUpdateTask?.cancel()

        // Schedule new update with debounce delay
        liveActivityUpdateTask = Task { @MainActor in
            // Wait 0.3 seconds - if another update comes, this task will be cancelled
            try? await Task.sleep(for: .milliseconds(300))

            // If we weren't cancelled, perform the update
            guard !Task.isCancelled else { return }
            _performLiveActivityUpdate()
        }
    }

    /// Immediate Live Activity update (no debouncing)
    /// Use this for critical updates like starting/finishing workout
    func updateLiveActivityImmediately() {
        liveActivityUpdateTask?.cancel()
        _performLiveActivityUpdate()
    }

    /// Internal method that performs the actual Live Activity update
    private func _performLiveActivityUpdate() {
        guard let viewModel = activeViewModel,
              let _ = activeWorkout else { return }

        // Get current exercise info
        let currentExercise = viewModel.exercises.last
        let currentExerciseName = currentExercise?.exercise?.name ?? "Starting..."
        let currentSetNumber = currentExercise?.sets.filter(\.isCompleted).count ?? 0
        let totalSetsForExercise = currentExercise?.sets.count ?? 0

        // Get last set info
        let lastSet = currentExercise?.sets.last
        let currentWeight = lastSet?.weight ?? 0
        let currentReps = lastSet?.reps ?? 0

        // Calculate stats (now using cached values from ViewModel - another optimization!)
        let completedSets = self.completedSets
        let totalVolume = viewModel.totalVolume
        let exerciseCount = viewModel.exercises.count

        // Note: Duration is no longer sent to Live Activity
        // Widget now uses Apple's native Text(timerInterval:) for automatic duration display
        liveActivityService?.updateActivity(
            currentExerciseName: currentExerciseName,
            currentSetNumber: currentSetNumber + 1,
            totalSets: totalSetsForExercise,
            currentWeight: currentWeight,
            currentReps: currentReps,
            isResting: false, // Rest timer disabled - Phase 2 feature
            restTimeRemaining: 0,
            completedSets: completedSets,
            totalVolume: totalVolume,
            exerciseCount: exerciseCount
        )
    }

    /// Restore workout session from UserDefaults
    /// Returns true if restoration was successful
    func restoreState(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        prDetectionService: PRDetectionService,
        progressiveOverloadService: ProgressiveOverloadService,
        userProfileRepository: UserProfileRepositoryProtocol,
        liveActivityManager: LiveActivityManager,
        widgetUpdateService: WidgetUpdateService
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
            userProfileRepository: userProfileRepository,
            liveActivityManager: liveActivityManager,
            widgetUpdateService: widgetUpdateService
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
        
        // Connect Live Activity updates
        viewModel.onStateChanged = { [weak self] in
            self?.updateLiveActivity()
        }
        
        // Restart Live Activity (use immediate update for critical restore)
        let workoutName = viewModel.workoutTitle ?? "Workout"
        liveActivityService?.startActivity(workoutName: workoutName)
        updateLiveActivityImmediately()

        return true
    }
}
