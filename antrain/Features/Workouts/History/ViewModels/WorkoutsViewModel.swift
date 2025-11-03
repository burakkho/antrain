import Foundation
import Observation

/// Workouts view model
/// Manages workout list and delete operations
@Observable @MainActor
final class WorkoutsViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - State

    var workouts: [Workout] = []
    var isLoading = true  // Start as loading to prevent white screen
    var errorMessage: String?

    // MARK: - Initialization

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Methods

    /// Load all workouts (recent first)
    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil

        do {
            workouts = try await workoutRepository.fetchAll()
        } catch {
            errorMessage = String(localized: "Failed to load workouts. Please try again.")
        }

        isLoading = false
    }

    /// Delete workout
    func deleteWorkout(_ workout: Workout) async {
        do {
            try await workoutRepository.delete(workout)
            workouts.removeAll { $0.id == workout.id }
        } catch {
            errorMessage = String(localized: "Failed to delete workout.")
        }
    }
}
