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
    var amount: Double  // Amount in selected unit

    // Relationships
    var foodItem: FoodItem?  // FoodItem silinirse nil olur
    var selectedUnit: ServingUnit  // Selected serving unit (never nil)

    init(
        foodItem: FoodItem,
        amount: Double,
        selectedUnit: ServingUnit
    ) {
        self.id = UUID()
        self.foodItem = foodItem
        self.amount = amount
        // Auto-select unit if not provided: gram unit or first available
        self.selectedUnit = selectedUnit
    }
}

// MARK: - Computed Properties

extension FoodEntry {
    /// Convert amount to grams based on selected unit
    var servingAmountInGrams: Double {
        return amount * selectedUnit.gramsPerUnit
    }

    /// Calculated calories for this serving
    var calories: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmountInGrams / 100.0
        return foodItem.calories * multiplier
    }

    /// Calculated protein for this serving
    var protein: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmountInGrams / 100.0
        return foodItem.protein * multiplier
    }

    /// Calculated carbs for this serving
    var carbs: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmountInGrams / 100.0
        return foodItem.carbs * multiplier
    }

    /// Calculated fats for this serving
    var fats: Double {
        guard let foodItem else { return 0 }
        let multiplier = servingAmountInGrams / 100.0
        return foodItem.fats * multiplier
    }

    /// Display amount with unit (for UI)
    var displayAmount: String {
        let amountText = amount.truncatingRemainder(dividingBy: 1) == 0 ?
            "\(Int(amount))" : String(format: "%.1f", amount)
        return "\(amountText) \(selectedUnit.shortDisplay)"
    }
}
