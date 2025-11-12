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

    func fetchLogs(since startDate: Date) async throws -> [NutritionLog] {
        let predicate = #Predicate<NutritionLog> { log in
            log.date >= startDate
        }
        let descriptor = FetchDescriptor<NutritionLog>(
            predicate: predicate,
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

    func addFood(
        to log: NutritionLog,
        mealType: Meal.MealType,
        food: FoodItem,
        amount: Double,
        unit: ServingUnit
    ) async throws {
        let meal = log.getMeal(type: mealType)
        let foodEntry = FoodEntry(foodItem: food, amount: amount, selectedUnit: unit)
        meal.foodEntries.append(foodEntry)
        try modelContext.save()
    }

    func addFoodById(
        logId: UUID,
        mealType: Meal.MealType,
        foodId: UUID,
        amount: Double,
        unitId: UUID
    ) async throws {
        // Fetch log, food, and unit from context
        let logDescriptor = FetchDescriptor<NutritionLog>(
            predicate: #Predicate { $0.id == logId }
        )
        guard let log = try modelContext.fetch(logDescriptor).first else {
            throw RepositoryError.notFound
        }

        let foodDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.id == foodId }
        )
        guard let food = try modelContext.fetch(foodDescriptor).first else {
            throw RepositoryError.notFound
        }

        let unitDescriptor = FetchDescriptor<ServingUnit>(
            predicate: #Predicate { $0.id == unitId }
        )
        guard let unit = try modelContext.fetch(unitDescriptor).first else {
            throw RepositoryError.notFound
        }

        // Add food
        let meal = log.getMeal(type: mealType)
        let foodEntry = FoodEntry(foodItem: food, amount: amount, selectedUnit: unit)
        meal.foodEntries.append(foodEntry)
        try modelContext.save()
    }

    func removeFood(from log: NutritionLog, mealType: Meal.MealType, foodEntryId: UUID) async throws {
        if let meal = log.meals.first(where: { $0.name == mealType.rawValue }) {
            meal.foodEntries.removeAll { $0.id == foodEntryId }
            try modelContext.save()
        }
    }

    func editFoodEntry(
        in log: NutritionLog,
        mealType: Meal.MealType,
        foodEntryId: UUID,
        newAmount: Double,
        newUnit: ServingUnit
    ) async throws {
        guard let meal = log.meals.first(where: { $0.name == mealType.rawValue }),
              let foodEntry = meal.foodEntries.first(where: { $0.id == foodEntryId }) else {
            throw RepositoryError.notFound
        }

        foodEntry.amount = newAmount
        foodEntry.selectedUnit = newUnit
        try modelContext.save()
    }

    func editFoodEntryById(
        logId: UUID,
        mealType: Meal.MealType,
        foodEntryId: UUID,
        newAmount: Double,
        unitId: UUID
    ) async throws {
        // Fetch log
        let logDescriptor = FetchDescriptor<NutritionLog>(
            predicate: #Predicate { $0.id == logId }
        )
        guard let log = try modelContext.fetch(logDescriptor).first else {
            throw RepositoryError.notFound
        }

        // Fetch unit
        let unitDescriptor = FetchDescriptor<ServingUnit>(
            predicate: #Predicate { $0.id == unitId }
        )
        guard let unit = try modelContext.fetch(unitDescriptor).first else {
            throw RepositoryError.notFound
        }

        // Update food entry
        guard let meal = log.meals.first(where: { $0.name == mealType.rawValue }),
              let foodEntry = meal.foodEntries.first(where: { $0.id == foodEntryId }) else {
            throw RepositoryError.notFound
        }

        foodEntry.amount = newAmount
        foodEntry.selectedUnit = unit
        try modelContext.save()
    }

    func moveFoodEntryToMeal(
        in log: NutritionLog,
        foodEntryId: UUID,
        fromMealType: Meal.MealType,
        toMealType: Meal.MealType
    ) async throws {
        guard let fromMeal = log.meals.first(where: { $0.name == fromMealType.rawValue }),
              let toMeal = log.meals.first(where: { $0.name == toMealType.rawValue }),
              let entryIndex = fromMeal.foodEntries.firstIndex(where: { $0.id == foodEntryId }) else {
            throw RepositoryError.notFound
        }

        // Remove from source meal
        let foodEntry = fromMeal.foodEntries.remove(at: entryIndex)

        // Add to destination meal with updated order index
        foodEntry.orderIndex = toMeal.foodEntries.count
        toMeal.foodEntries.append(foodEntry)

        try modelContext.save()
    }

    func reorderFoodEntries(
        in log: NutritionLog,
        mealType: Meal.MealType,
        fromIndex: Int,
        toIndex: Int
    ) async throws {
        guard let meal = log.meals.first(where: { $0.name == mealType.rawValue }) else {
            throw RepositoryError.notFound
        }

        guard fromIndex >= 0, fromIndex < meal.foodEntries.count,
              toIndex >= 0, toIndex < meal.foodEntries.count else {
            throw RepositoryError.invalidOperation
        }

        // Move the entry
        let movedEntry = meal.foodEntries.remove(at: fromIndex)
        meal.foodEntries.insert(movedEntry, at: toIndex)

        // Update order indices
        for (index, entry) in meal.foodEntries.enumerated() {
            entry.orderIndex = index
        }

        try modelContext.save()
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
