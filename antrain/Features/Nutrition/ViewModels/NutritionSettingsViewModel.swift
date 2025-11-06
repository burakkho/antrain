//
//  NutritionSettingsViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation
import SwiftUI

/// Nutrition settings view model
/// Manages nutrition goals and bodyweight tracking
@Observable @MainActor
final class NutritionSettingsViewModel {
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

    /// Update nutrition goals
    func updateNutritionGoals(
        calories: Double,
        protein: Double,
        carbs: Double,
        fats: Double
    ) async throws {
        guard let profile = userProfile else { return }
        profile.update(
            dailyCalorieGoal: calories,
            dailyProteinGoal: protein,
            dailyCarbsGoal: carbs,
            dailyFatsGoal: fats
        )
        await loadProfile()
    }

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

    // MARK: - BMI Calculations

    /// Calculate BMI based on current weight and height
    /// Returns nil if height or weight is not available
    func calculateBMI() -> Double? {
        guard let height = userProfile?.height,
              let weight = userProfile?.currentBodyweight?.weight,
              height > 0 else {
            return nil
        }

        // BMI = weight (kg) / (height (m))^2
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }

    /// Get BMI category
    func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return String(localized: "Underweight")
        case 18.5..<25:
            return String(localized: "Normal")
        case 25..<30:
            return String(localized: "Overweight")
        default:
            return String(localized: "Obese")
        }
    }

    /// Get color for BMI category
    func bmiCategoryColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5:
            return .orange
        case 18.5..<25:
            return DSColors.success
        case 25..<30:
            return .orange
        default:
            return DSColors.error
        }
    }
}
