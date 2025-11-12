//
//  ProfileViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Profile view model
/// Manages user profile data and bodyweight tracking
@Observable @MainActor
final class ProfileViewModel {
    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State

    var userProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Initialization

    init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Actions

    /// Load user profile
    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            userProfile = try await userProfileRepository.fetchOrCreateProfile()
            isLoading = false
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Update user name
    func updateName(_ name: String) async throws {
        guard let profile = userProfile else { return }
        profile.update(name: name)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update height
    func updateHeight(_ height: Double) async throws {
        guard let profile = userProfile else { return }
        profile.update(height: height)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update gender
    func updateGender(_ gender: UserProfile.Gender) async throws {
        guard let profile = userProfile else { return }
        profile.update(gender: gender)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update date of birth
    func updateDateOfBirth(_ dateOfBirth: Date) async throws {
        guard let profile = userProfile else { return }
        profile.update(dateOfBirth: dateOfBirth)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update activity level
    func updateActivityLevel(_ activityLevel: UserProfile.ActivityLevel) async throws {
        guard let profile = userProfile else { return }
        profile.update(activityLevel: activityLevel)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update fitness level
    func updateFitnessLevel(_ fitnessLevel: UserProfile.FitnessLevel) async throws {
        guard let profile = userProfile else { return }
        profile.update(fitnessLevel: fitnessLevel)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update fitness goals
    func updateFitnessGoals(_ fitnessGoals: [UserProfile.FitnessGoal]) async throws {
        guard let profile = userProfile else { return }
        profile.update(fitnessGoals: fitnessGoals)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update weekly workout frequency
    func updateWeeklyWorkoutFrequency(_ frequency: Int) async throws {
        guard let profile = userProfile else { return }
        profile.update(weeklyWorkoutFrequency: frequency)
        // Profile updates are automatically saved via SwiftData
    }

    /// Update available equipment
    func updateAvailableEquipment(_ equipment: UserProfile.Equipment) async throws {
        guard let profile = userProfile else { return }
        profile.update(availableEquipment: equipment)
        // Profile updates are automatically saved via SwiftData
    }

    // MARK: - Bodyweight Tracking

    /// Add bodyweight entry
    func addBodyweightEntry(weight: Double, date: Date, notes: String?) async throws {
        guard let profile = userProfile else { return }
        let entry = try await userProfileRepository.addBodyweightEntry(
            weight: weight,
            date: date,
            notes: notes
        )
        // Update local profile (SwiftData automatically syncs)
        profile.bodyweightEntries.append(entry)
    }

    /// Delete bodyweight entry
    func deleteBodyweightEntry(_ entry: BodyweightEntry) async throws {
        guard let profile = userProfile else { return }
        try await userProfileRepository.deleteBodyweightEntry(entry)
        // Remove from local profile (SwiftData automatically syncs)
        profile.bodyweightEntries.removeAll { $0.id == entry.id }
    }

    /// Get bodyweight history
    func getBodyweightHistory() async throws -> [BodyweightEntry] {
        return try await userProfileRepository.fetchBodyweightHistory()
    }
}
