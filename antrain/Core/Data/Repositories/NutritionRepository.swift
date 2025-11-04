//
//  NutritionRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Nutrition repository implementation
@ModelActor
actor NutritionRepository: NutritionRepositoryProtocol {
    // MARK: - Nutrition Log

    func fetchOrCreateLog(for date: Date) async throws -> NutritionLog {
        let startOfDay = Calendar.current.startOfDay(for: date)

        let predicate = #Predicate<NutritionLog> { log in
            log.date == startOfDay
        }

        let descriptor = FetchDescriptor<NutritionLog>(predicate: predicate)
        let logs = try modelContext.fetch(descriptor)

        if let existing = logs.first {
            return existing
        } else {
            let newLog = NutritionLog(date: startOfDay)

            // Create all 4 meals upfront
            let breakfast = Meal.create(type: .breakfast)
            let lunch = Meal.create(type: .lunch)
            let dinner = Meal.create(type: .dinner)
            let snack = Meal.create(type: .snack)

            newLog.meals.append(contentsOf: [breakfast, lunch, dinner, snack])

            modelContext.insert(newLog)
            try modelContext.save()
            return newLog
        }
    }

    func fetchAllLogs() async throws -> [NutritionLog] {
        let descriptor = FetchDescriptor<NutritionLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func saveLog(_ log: NutritionLog) async throws {
        modelContext.insert(log)
        try modelContext.save()
    }

    func deleteLog(_ log: NutritionLog) async throws {
        modelContext.delete(log)
        try modelContext.save()
    }

    // MARK: - Meal Management

    func addFood(to log: NutritionLog, mealType: Meal.MealType, food: FoodItem, amount: Double) async throws {
        let meal = log.getMeal(type: mealType)
        let foodEntry = FoodEntry(foodItem: food, servingAmount: amount)
        meal.foodEntries.append(foodEntry)
        try modelContext.save()
    }

    func removeFood(from log: NutritionLog, mealType: Meal.MealType, foodEntryId: UUID) async throws {
        if let meal = log.meals.first(where: { $0.name == mealType.rawValue }) {
            meal.foodEntries.removeAll { $0.id == foodEntryId }
            try modelContext.save()
        }
    }

    // MARK: - Food Items

    func fetchAllFoods() async throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func searchFoods(query: String) async throws -> [FoodItem] {
        if query.isEmpty {
            return try await fetchAllFoods()
        }

        let predicate = #Predicate<FoodItem> { food in
            food.name.localizedStandardContains(query)
        }

        let descriptor = FetchDescriptor<FoodItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )

        return try modelContext.fetch(descriptor)
    }

    func saveFood(_ foodItem: FoodItem) async throws {
        modelContext.insert(foodItem)
        try modelContext.save()
    }

    func deleteFood(_ foodItem: FoodItem) async throws {
        guard foodItem.isCustom else {
            throw RepositoryError.cannotDeletePreset
        }
        modelContext.delete(foodItem)
        try modelContext.save()
    }
}
