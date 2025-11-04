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
    var servingAmount: Double  // DEPRECATED: Use amount instead (kept for migration)

    // Relationships
    var foodItem: FoodItem?  // FoodItem silinirse nil olur
    var selectedUnit: ServingUnit?  // Selected serving unit

    init(
        foodItem: FoodItem,
        amount: Double,
        selectedUnit: ServingUnit? = nil
    ) {
        self.id = UUID()
        self.foodItem = foodItem
        self.amount = amount
        self.servingAmount = amount  // For backward compatibility
        self.selectedUnit = selectedUnit
    }

    // DEPRECATED: Old initializer for migration compatibility
    init(
        foodItem: FoodItem,
        servingAmount: Double
    ) {
        self.id = UUID()
        self.foodItem = foodItem
        self.amount = servingAmount
        self.servingAmount = servingAmount
        self.selectedUnit = nil
    }
}

// MARK: - Computed Properties

extension FoodEntry {
    /// Convert amount to grams based on selected unit
    var servingAmountInGrams: Double {
        guard let unit = selectedUnit else {
            // Fallback to amount if no unit selected (backward compatibility)
            return amount
        }
        return amount * unit.gramsPerUnit
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
        if let unit = selectedUnit {
            let amountText = amount.truncatingRemainder(dividingBy: 1) == 0 ?
                "\(Int(amount))" : String(format: "%.1f", amount)
            return "\(amountText) \(unit.shortDisplay)"
        }
        // Fallback to grams
        return "\(Int(amount))g"
    }
}
