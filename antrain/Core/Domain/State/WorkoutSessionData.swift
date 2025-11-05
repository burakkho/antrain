import Foundation

/// Codable model for persisting active workout session
/// Allows workout state to survive app restarts
struct WorkoutSessionData: Codable {
    let workoutId: UUID
    let startDate: Date
    let exercises: [ExerciseData]

    struct ExerciseData: Codable {
        let id: UUID
        let exerciseName: String
        let orderIndex: Int
        let sets: [SetData]
    }

    struct SetData: Codable {
        let id: UUID
        let reps: Int
        let weight: Double
        let isCompleted: Bool
        let notes: String?
    }
}

// MARK: - Persistence Helper

extension WorkoutSessionData {
    /// UserDefaults key for active workout session
    private static let storageKey = "activeWorkoutSessionData"

    /// Save workout session data to UserDefaults
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
            print("Failed to save workout session: \(error)")
        }
    }

    /// Load workout session data from UserDefaults
    static func load() -> WorkoutSessionData? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(WorkoutSessionData.self, from: data)
        } catch {
            print("Failed to load workout session: \(error)")
            return nil
        }
    }

    /// Clear saved workout session
    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
