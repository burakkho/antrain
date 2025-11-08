//
//  DailyNutritionViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation
import SwiftUI

/// Manages daily nutrition tracking state
@Observable @MainActor
final class DailyNutritionViewModel {
    // MARK: - Dependencies
    private let nutritionRepository: NutritionRepositoryProtocol
    let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State
    var currentDate: Date = Date()
    var nutritionLog: NutritionLog?
    var userProfile: UserProfile?
    var isLoading = true  // Start as loading
    var errorMessage: String?  // Screen-level errors (loading failures)

    // Toast notifications
    var showToast = false
    var toastMessage: LocalizedStringKey = ""
    var toastType: DSToast.ToastType = .error

    // Daily macro goals (loaded from UserProfile)
    var dailyCaloriesGoal: Double = 2000
    var dailyProteinGoal: Double = 150
    var dailyCarbsGoal: Double = 200
    var dailyFatsGoal: Double = 65

    // MARK: - Computed Properties
    var totalCalories: Double {
        nutritionLog?.totalCalories ?? 0
    }

    var totalProtein: Double {
        nutritionLog?.totalProtein ?? 0
    }

    var totalCarbs: Double {
        nutritionLog?.totalCarbs ?? 0
    }

    var totalFats: Double {
        nutritionLog?.totalFats ?? 0
    }

    var caloriesProgress: Double {
        min(totalCalories / dailyCaloriesGoal, 1.0)
    }

    var proteinProgress: Double {
        guard dailyProteinGoal > 0 else { return 0 }
        return min(totalProtein / dailyProteinGoal, 1.0)
    }

    var carbsProgress: Double {
        guard dailyCarbsGoal > 0 else { return 0 }
        return min(totalCarbs / dailyCarbsGoal, 1.0)
    }

    var fatsProgress: Double {
        guard dailyFatsGoal > 0 else { return 0 }
        return min(totalFats / dailyFatsGoal, 1.0)
    }

    // MARK: - Initialization
    init(nutritionRepository: NutritionRepositoryProtocol, userProfileRepository: UserProfileRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Actions

    /// Load nutrition goals from UserProfile
    func loadGoals() async {
        do {
            let profile = try await userProfileRepository.fetchOrCreateProfile()
            userProfile = profile
            dailyCaloriesGoal = profile.dailyCalorieGoal
            dailyProteinGoal = profile.dailyProteinGoal
            dailyCarbsGoal = profile.dailyCarbsGoal
            dailyFatsGoal = profile.dailyFatsGoal
        } catch {
            print("Failed to load nutrition goals: \(error.localizedDescription)")
            // Keep default values if loading fails
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
        await loadGoals()
    }

    func loadTodayLog() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load goals from profile
            await loadGoals()

            // Load nutrition log for today
            nutritionLog = try await nutritionRepository.fetchOrCreateLog(for: currentDate)
            isLoading = false
        } catch {
            errorMessage = "Failed to load nutrition log: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func addFood(to mealType: Meal.MealType, food: FoodItem, amount: Double, unit: ServingUnit) async {
        guard let log = nutritionLog else {
            showToastMessage("No nutrition log available", type: .error)
            return
        }

        // Extract IDs to avoid Sendable warnings (SwiftData models crossing async boundary)
        let foodId = food.id
        let unitId = unit.id
        let logId = log.id

        do {
            try await nutritionRepository.addFoodById(
                logId: logId,
                mealType: mealType,
                foodId: foodId,
                amount: amount,
                unitId: unitId
            )

            // Refresh log
            await loadTodayLog()
        } catch {
            showToastMessage("Failed to add food", type: .error)
        }
    }

    func removeFood(from mealType: Meal.MealType, foodEntryId: UUID) async {
        guard let log = nutritionLog else { return }

        do {
            try await nutritionRepository.removeFood(from: log, mealType: mealType, foodEntryId: foodEntryId)
            await loadTodayLog()
        } catch {
            showToastMessage("Failed to remove food", type: .error)
        }
    }

    // MARK: - Toast Helper

    private func showToastMessage(_ message: LocalizedStringKey, type: DSToast.ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
    }

    func getMeal(for type: Meal.MealType) -> Meal {
        guard let log = nutritionLog else {
            // Return empty meal if log hasn't loaded yet
            return Meal.create(type: type)
        }
        return log.getMeal(type: type)
    }

    func changeDate(to newDate: Date) async {
        currentDate = newDate
        await loadTodayLog()
    }
}
