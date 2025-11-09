//
//  SettingsViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftUI
import Observation

/// Settings view model
/// Manages user profile data, preferences, and data management operations
@Observable @MainActor
final class SettingsViewModel {
    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol
    private let workoutRepository: WorkoutRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol

    // MARK: - State

    var userProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    // Data Management State
    var loadingMessage = ""
    var toastMessage: LocalizedStringKey = ""
    var toastType: DSToast.ToastType = .info
    var showToast = false
    var exportFileURL: URL?

    // MARK: - Initialization

    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
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

    /// Update date of birth
    func updateDateOfBirth(_ dateOfBirth: Date) async throws {
        guard let profile = userProfile else { return }
        profile.update(dateOfBirth: dateOfBirth)
        await loadProfile()
    }

    /// Update activity level
    func updateActivityLevel(_ activityLevel: UserProfile.ActivityLevel) async throws {
        guard let profile = userProfile else { return }
        profile.update(activityLevel: activityLevel)
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

    // MARK: - Toast Management

    /// Show toast message
    func showToastMessage(_ message: LocalizedStringKey, type: DSToast.ToastType) {
        toastMessage = message
        toastType = type
        withAnimation {
            showToast = true
        }
    }

    // MARK: - Data Management

    /// Export all workouts to CSV
    func exportWorkouts() async {
        do {
            // Fetch all workouts
            let workouts = try await workoutRepository.fetchAll()

            guard !workouts.isEmpty else {
                showToastMessage("No workouts to export", type: .info)
                return
            }

            // Export to CSV
            let exportService = CSVExportService()
            let csvContent = exportService.exportWorkouts(workouts)
            let fileURL = try exportService.saveToFile(csvContent)

            // Show share sheet
            exportFileURL = fileURL
            showToastMessage("Exported \(workouts.count) workouts", type: .success)
        } catch {
            showToastMessage("Export failed: \(error.localizedDescription)", type: .error)
        }
    }
}
