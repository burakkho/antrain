//
//  SettingsViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Settings view model
/// Manages user profile data and preferences
@Observable @MainActor
final class SettingsViewModel {
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
        await loadProfile()
    }

    /// Update height
    func updateHeight(_ height: Double) async throws {
        guard let profile = userProfile else { return }
        profile.update(height: height)
        await loadProfile()
    }

    /// Update gender
    func updateGender(_ gender: UserProfile.Gender) async throws {
        guard let profile = userProfile else { return }
        profile.update(gender: gender)
        await loadProfile()
    }

    // MARK: - Bodyweight Tracking

    /// Add bodyweight entry
    func addBodyweightEntry(weight: Double, date: Date, notes: String?) async throws {
        _ = try await userProfileRepository.addBodyweightEntry(
            weight: weight,
            date: date,
            notes: notes
        )
        await loadProfile()
    }

    /// Delete bodyweight entry
    func deleteBodyweightEntry(_ entry: BodyweightEntry) async throws {
        try await userProfileRepository.deleteBodyweightEntry(entry)
        await loadProfile()
    }

    /// Get bodyweight history
    func getBodyweightHistory() async throws -> [BodyweightEntry] {
        return try await userProfileRepository.fetchBodyweightHistory()
    }
}
