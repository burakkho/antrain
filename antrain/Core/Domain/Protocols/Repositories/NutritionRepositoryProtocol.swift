//
//  NutritionRepositoryProtocol.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Nutrition repository protocol
/// Manages nutrition logs, meals, and food entries
protocol NutritionRepositoryProtocol: Actor {
    // MARK: - Nutrition Log

    /// Fetch nutrition log for a specific date (creates if doesn't exist)
    func fetchOrCreateLog(for date: Date) async throws -> NutritionLog

    /// Fetch all nutrition logs
    func fetchAllLogs() async throws -> [NutritionLog]

    /// Fetch nutrition logs since a specific date (database-level filtering)
    /// - Parameter startDate: Start date (inclusive)
    /// - Returns: Nutrition logs since startDate, sorted by date (most recent first)
    func fetchLogs(since startDate: Date) async throws -> [NutritionLog]

    /// Save nutrition log
    func saveLog(_ log: NutritionLog) async throws

    /// Delete nutrition log
    func deleteLog(_ log: NutritionLog) async throws

    // MARK: - Meal Management

    /// Add food to a meal
    func addFood(to log: NutritionLog, mealType: Meal.MealType, food: FoodItem, amount: Double, unit: ServingUnit) async throws

    /// Add food to a meal by IDs (avoids Sendable warnings)
    func addFoodById(logId: UUID, mealType: Meal.MealType, foodId: UUID, amount: Double, unitId: UUID) async throws

    /// Remove food from a meal
    func removeFood(from log: NutritionLog, mealType: Meal.MealType, foodEntryId: UUID) async throws

    /// Edit food entry (amount and unit)
    func editFoodEntry(in log: NutritionLog, mealType: Meal.MealType, foodEntryId: UUID, newAmount: Double, newUnit: ServingUnit) async throws

    /// Edit food entry by IDs (avoids Sendable warnings)
    func editFoodEntryById(logId: UUID, mealType: Meal.MealType, foodEntryId: UUID, newAmount: Double, unitId: UUID) async throws

    /// Move food entry to a different meal
    func moveFoodEntryToMeal(in log: NutritionLog, foodEntryId: UUID, fromMealType: Meal.MealType, toMealType: Meal.MealType) async throws

    /// Reorder food entries within a meal
    func reorderFoodEntries(in log: NutritionLog, mealType: Meal.MealType, fromIndex: Int, toIndex: Int) async throws

    // MARK: - Food Items

    /// Fetch all food items
    func fetchAllFoods() async throws -> [FoodItem]

    /// Search food items by name
    func searchFoods(query: String) async throws -> [FoodItem]

    /// Save food item (for custom foods)
    func saveFood(_ foodItem: FoodItem) async throws

    /// Delete food item (only custom foods)
    func deleteFood(_ foodItem: FoodItem) async throws
}
