//
//  Meal.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// A meal within a nutrition log (Breakfast, Lunch, Dinner, Snack)
@Model
final class Meal {
    @Attribute(.unique) var id: UUID
    var name: String  // "Breakfast", "Lunch", "Dinner", "Snack"
    var timestamp: Date

    // Relationships
    @Relationship(deleteRule: .cascade)
    var foodEntries: [FoodEntry] = []

    init(
        name: String,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
    }
}

// MARK: - Computed Properties

extension Meal {
    /// Total calories for this meal
    var totalCalories: Double {
        foodEntries.reduce(0) { $0 + $1.calories }
    }

    /// Total protein for this meal
    var totalProtein: Double {
        foodEntries.reduce(0) { $0 + $1.protein }
    }

    /// Total carbs for this meal
    var totalCarbs: Double {
        foodEntries.reduce(0) { $0 + $1.carbs }
    }

    /// Total fats for this meal
    var totalFats: Double {
        foodEntries.reduce(0) { $0 + $1.fats }
    }
}

// MARK: - Predefined Meal Types

extension Meal {
    enum MealType: String, CaseIterable, Identifiable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"

        var id: String { rawValue }
    }

    static func create(type: MealType) -> Meal {
        Meal(name: type.rawValue)
    }
}
