import Foundation
import Observation

/// Home screen view model
/// Manages recent workouts, nutrition summary, and quick actions
@Observable @MainActor
final class HomeViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let nutritionRepository: NutritionRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State

    var recentWorkouts: [Workout] = []
    var todayNutritionLog: NutritionLog?
    var userProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        nutritionRepository: NutritionRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.nutritionRepository = nutritionRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Methods

    /// Load all home data (workouts and nutrition)
    func loadData() async {
        isLoading = true
        errorMessage = nil

        await loadRecentWorkouts()
        await loadTodayNutrition()

        isLoading = false
    }

    /// Load recent workouts (last 5)
    /// Swift 6.2 Optimization: Use database-level fetchLimit instead of in-memory filtering
    func loadRecentWorkouts() async {
        do {
            // Performance: fetchRecent uses FetchDescriptor with fetchLimit (database-level)
            // 20-50× faster than fetchAll().prefix() for users with 1000+ workouts
            recentWorkouts = try await workoutRepository.fetchRecent(limit: 5)
        } catch {
            errorMessage = String(localized: "Failed to load workouts. Please try again.")
        }
    }

    /// Load today's nutrition log and user profile goals
    func loadTodayNutrition() async {
        do {
            // Load nutrition log for today
            todayNutritionLog = try await nutritionRepository.fetchOrCreateLog(for: Date())

            // Load user profile for goals
            userProfile = try await userProfileRepository.fetchOrCreateProfile()
        } catch {
            errorMessage = String(localized: "Failed to load nutrition data. Please try again.")
        }
    }
}
