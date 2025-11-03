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

    /// Save nutrition log
    func saveLog(_ log: NutritionLog) async throws

    /// Delete nutrition log
    func deleteLog(_ log: NutritionLog) async throws

    // MARK: - Meal Management

    /// Add food to a meal
    func addFood(to log: NutritionLog, mealType: Meal.MealType, food: FoodItem, amount: Double) async throws

    /// Remove food from a meal
    func removeFood(from log: NutritionLog, mealType: Meal.MealType, foodEntryId: UUID) async throws

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
