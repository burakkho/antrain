//
//  NutritionGoalsEditorViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Refactored: Simplified state management with direct macro→calorie calculation
//

import Foundation
import Observation

/// Manages nutrition goals editing business logic
/// Simplified design: Macros drive calories (one-way)
@Observable @MainActor
final class NutritionGoalsEditorViewModel {
    // MARK: - Dependencies
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State
    /// Direct numeric values (no string conversion needed!)
    var protein: Double = 150
    var carbs: Double = 200
    var fats: Double = 65

    var isSaving = false
    var errorMessage: String?
    var userProfile: UserProfile?

    // TDEE Calculator
    var showTDEECalculator = false
    var selectedGoalType: TDEECalculator.GoalType = .maintain

    // Original goals for difference indicator
    var originalGoals: (calories: Double, protein: Double, carbs: Double, fats: Double)?

    // Onboarding wizard
    var showOnboarding = false

    // MARK: - Computed Properties

    /// Calories are automatically calculated from macros
    /// Protein: 4 cal/g, Carbs: 4 cal/g, Fats: 9 cal/g
    var calories: Double {
        MacroCalculator.calculateCalories(
            protein: protein,
            carbs: carbs,
            fats: fats
        )
    }

    var isValid: Bool {
        protein > 0 && carbs > 0 && fats > 0
    }

    /// Check if user has required data for TDEE calculation
    var canCalculateTDEE: Bool {
        guard let profile = userProfile else { return false }
        return profile.age != nil &&
               profile.height != nil &&
               profile.gender != nil &&
               profile.activityLevel != nil &&
               profile.currentBodyweight != nil
    }

    /// Check if user has any missing profile data
    var hasMissingData: Bool {
        guard let profile = userProfile else { return true }
        return profile.age == nil ||
               profile.height == nil ||
               profile.gender == nil ||
               profile.activityLevel == nil ||
               profile.currentBodyweight == nil
    }

    // MARK: - Initialization

    init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Actions

    /// Load current goals from profile
    func loadCurrentGoals() async {
        do {
            let profile = try await userProfileRepository.fetchOrCreateProfile()
            self.userProfile = profile

            // Load current values
            protein = profile.dailyProteinGoal
            carbs = profile.dailyCarbsGoal
            fats = profile.dailyFatsGoal

            // Store original goals for difference indicator
            originalGoals = (
                profile.dailyCalorieGoal,
                profile.dailyProteinGoal,
                profile.dailyCarbsGoal,
                profile.dailyFatsGoal
            )

            // Check if should show onboarding wizard
            // Only show wizard for first-time users who need profile setup
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedNutritionOnboarding")

            if !hasCompletedOnboarding {
                // First-time user
                if hasMissingData {
                    // Missing profile data → show full wizard
                    showOnboarding = true
                } else {
                    // Profile complete but flag not set (edge case)
                    // Set flag to prevent wizard in future
                    UserDefaults.standard.set(true, forKey: "hasCompletedNutritionOnboarding")
                    showOnboarding = false
                }
            }
            // If hasCompletedOnboarding = true, NEVER show wizard again
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
        }
    }

    /// Apply TDEE recommendation
    func applyTDEERecommendation(
        calories: Double,
        macros: (protein: Double, carbs: Double, fats: Double)
    ) {
        self.protein = macros.protein
        self.carbs = macros.carbs
        self.fats = macros.fats
    }

    /// Apply preset macro ratio
    func applyPreset(protein: Double, carbs: Double, fats: Double) {
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
    }

    /// Save goals to profile
    func saveGoals() async throws {
        guard isValid else {
            errorMessage = "Please enter valid values for all macros"
            throw NSError(domain: "NutritionGoalsEditor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }

        isSaving = true
        errorMessage = nil

        do {
            guard let profile = userProfile else {
                throw NSError(domain: "NutritionGoalsEditor", code: 2, userInfo: [NSLocalizedDescriptionKey: "No profile found"])
            }

            // Save with calculated calories
            profile.update(
                dailyCalorieGoal: calories,
                dailyProteinGoal: protein,
                dailyCarbsGoal: carbs,
                dailyFatsGoal: fats
            )

            isSaving = false
        } catch {
            errorMessage = "Failed to save goals: \(error.localizedDescription)"
            isSaving = false
            throw error
        }
    }

    /// Get TDEE calculation data
    func getTDEECalculationData() -> (
        age: Int,
        height: Double,
        gender: UserProfile.Gender,
        activityLevel: TDEECalculator.ActivityLevel,
        weight: Double
    )? {
        guard let profile = userProfile,
              let age = profile.age,
              let height = profile.height,
              let gender = profile.gender,
              let activityLevel = profile.activityLevel,
              let weight = profile.currentBodyweight?.weight else {
            return nil
        }

        // Convert UserProfile.ActivityLevel to TDEECalculator.ActivityLevel
        let tdeeActivityLevel = TDEECalculator.ActivityLevel(
            rawValue: activityLevel.rawValue
        ) ?? .moderatelyActive

        return (age, height, gender, tdeeActivityLevel, weight)
    }
}
