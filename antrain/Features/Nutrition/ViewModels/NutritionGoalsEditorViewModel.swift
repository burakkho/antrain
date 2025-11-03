//
//  NutritionGoalsEditorViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Manages nutrition goals editing business logic
@Observable @MainActor
final class NutritionGoalsEditorViewModel {
    // MARK: - Dependencies
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State
    var calories: String = ""
    var protein: String = ""
    var carbs: String = ""
    var fats: String = ""
    var isSaving = false
    var errorMessage: String?
    var userProfile: UserProfile?

    // Track which field user is editing
    var lastEditedField: EditedField? = nil
    // Prevent circular updates when programmatically changing values
    var isUpdating = false

    // Calculation mode
    var calculationMode: CalculationMode = .macroToCalorie

    // TDEE Calculator
    var showTDEECalculator = false
    var selectedGoalType: TDEECalculator.GoalType = .maintain

    // Original goals for difference indicator
    var originalGoals: (calories: Double, protein: Double, carbs: Double, fats: Double)?

    // Onboarding wizard
    var showOnboarding = false

    enum EditedField {
        case calories, protein, carbs, fats
    }

    enum CalculationMode: String, CaseIterable {
        case macroToCalorie = "Macros → Calories"
        case calorieToMacro = "Calories → Macros"
    }

    // MARK: - Computed Properties

    var isValid: Bool {
        guard let cal = Double(calories),
              let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return false
        }
        return cal > 0 && pro > 0 && car > 0 && fat > 0
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

            let cal = profile.dailyCalorieGoal
            let pro = profile.dailyProteinGoal
            let car = profile.dailyCarbsGoal
            let fat = profile.dailyFatsGoal

            calories = String(Int(cal))
            protein = String(Int(pro))
            carbs = String(Int(car))
            fats = String(Int(fat))

            // Store original goals for difference indicator
            originalGoals = (cal, pro, car, fat)

            // Check if should show onboarding wizard
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedNutritionOnboarding")
            if !hasCompletedOnboarding && hasMissingData {
                showOnboarding = true
            }
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
        }
    }

    /// When user changes macros, calculate calories automatically
    func handleMacroChange() {
        guard let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return
        }

        // Calculate calories from macros using MacroCalculator
        let calculatedCalories = MacroCalculator.calculateCalories(
            protein: pro,
            carbs: car,
            fats: fat
        )
        calories = String(Int(calculatedCalories))
    }

    /// When user changes calories, scale macros proportionally
    func handleCalorieChange(_ newCalorieString: String) {
        guard let newCalories = Double(newCalorieString),
              let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return
        }

        // Scale macros using MacroCalculator
        guard let scaled = MacroCalculator.scaleMacrosToCalories(
            currentProtein: pro,
            currentCarbs: car,
            currentFats: fat,
            targetCalories: newCalories
        ) else {
            return
        }

        protein = String(Int(scaled.protein))
        carbs = String(Int(scaled.carbs))
        fats = String(Int(scaled.fats))
    }

    /// Apply TDEE recommendation
    func applyTDEERecommendation(
        calories: Double,
        macros: (protein: Double, carbs: Double, fats: Double)
    ) {
        isUpdating = true
        defer { isUpdating = false }

        self.calories = String(Int(calories))
        self.protein = String(Int(macros.protein))
        self.carbs = String(Int(macros.carbs))
        self.fats = String(Int(macros.fats))
    }

    /// Apply preset macro ratio
    func applyPreset(protein: Double, carbs: Double, fats: Double) {
        isUpdating = true
        defer { isUpdating = false }

        self.protein = String(Int(protein))
        self.carbs = String(Int(carbs))
        self.fats = String(Int(fats))

        // Recalculate calories using MacroCalculator
        let calculatedCalories = MacroCalculator.calculateCalories(
            protein: protein,
            carbs: carbs,
            fats: fats
        )
        self.calories = String(Int(calculatedCalories))
    }

    /// Save goals to profile
    func saveGoals() async throws {
        guard let cal = Double(calories),
              let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            errorMessage = "Please enter valid numbers for all fields"
            throw NSError(domain: "NutritionGoalsEditor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }

        isSaving = true
        errorMessage = nil

        do {
            guard let profile = userProfile else {
                throw NSError(domain: "NutritionGoalsEditor", code: 2, userInfo: [NSLocalizedDescriptionKey: "No profile found"])
            }

            profile.update(
                dailyCalorieGoal: cal,
                dailyProteinGoal: pro,
                dailyCarbsGoal: car,
                dailyFatsGoal: fat
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
