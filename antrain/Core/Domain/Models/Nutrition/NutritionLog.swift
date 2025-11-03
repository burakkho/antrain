//
//  NutritionLog.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Daily nutrition log
/// One per day, contains all meals
@Model
final class NutritionLog: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var date: Date  // Day only (time component ignored)

    // Relationships
    @Relationship(deleteRule: .cascade)
    var meals: [Meal] = []

    init(date: Date = Date()) {
        self.id = UUID()
        // Strip time component, keep only date
        self.date = Calendar.current.startOfDay(for: date)
    }
}

// MARK: - Computed Properties

extension NutritionLog {
    /// Total calories for the day
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    /// Total protein for the day
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.totalProtein }
    }

    /// Total carbs for the day
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.totalCarbs }
    }

    /// Total fats for the day
    var totalFats: Double {
        meals.reduce(0) { $0 + $1.totalFats }
    }

    /// Get meal by type, create if doesn't exist
    func getMeal(type: Meal.MealType) -> Meal {
        if let existing = meals.first(where: { $0.name == type.rawValue }) {
            return existing
        } else {
            let newMeal = Meal.create(type: type)
            meals.append(newMeal)
            return newMeal
        }
    }
}
