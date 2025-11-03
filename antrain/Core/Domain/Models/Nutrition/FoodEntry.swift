//
//  FoodEntry.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Food entry in a meal (FoodItem + serving amount)
@Model
final class FoodEntry {
    @Attribute(.unique) var id: UUID
    var servingAmount: Double  // grams

    // Relationships
    var foodItem: FoodItem?  // FoodItem silinirse nil olur

    init(
        foodItem: FoodItem,
        servingAmount: Double
    ) {
        self.id = UUID()
        self.foodItem = foodItem
        self.servingAmount = servingAmount
    }
}

// MARK: - Computed Properties

extension FoodEntry {
    /// Calculated calories for this serving
    var calories: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmount / 100.0
        return foodItem.calories * multiplier
    }

    /// Calculated protein for this serving
    var protein: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmount / 100.0
        return foodItem.protein * multiplier
    }

    /// Calculated carbs for this serving
    var carbs: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmount / 100.0
        return foodItem.carbs * multiplier
    }

    /// Calculated fats for this serving
    var fats: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmount / 100.0
        return foodItem.fats * multiplier
    }
}
