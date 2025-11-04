//
//  FoodItem.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Food item from library (preset + custom)
/// All nutrition values per 100g
@Model
final class FoodItem: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String?

    // Nutrition values per 100g
    var calories: Double
    var protein: Double  // grams
    var carbs: Double    // grams
    var fats: Double     // grams

    var servingSize: Double  // default serving in grams
    var category: FoodCategory
    var isCustom: Bool
    var isFavorite: Bool
    var version: Int

    // Relationships
    @Relationship(deleteRule: .cascade)
    var servingUnits: [ServingUnit] = []

    init(
        name: String,
        brand: String? = nil,
        calories: Double,
        protein: Double,
        carbs: Double,
        fats: Double,
        servingSize: Double,
        category: FoodCategory,
        isCustom: Bool = false,
        isFavorite: Bool = false,
        version: Int = 1
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.servingSize = servingSize
        self.category = category
        self.isCustom = isCustom
        self.isFavorite = isFavorite
        self.version = version
    }
}

// MARK: - Computed Properties

extension FoodItem {
    /// Calculate nutrition for specific serving amount
    func nutritionFor(amount: Double) -> (calories: Double, protein: Double, carbs: Double, fats: Double) {
        let multiplier = amount / 100.0
        return (
            calories: calories * multiplier,
            protein: protein * multiplier,
            carbs: carbs * multiplier,
            fats: fats * multiplier
        )
    }

    /// Get default serving unit
    func getDefaultUnit() -> ServingUnit {
        servingUnits.first(where: { $0.isDefault })
            ?? ServingUnit(unitType: .gram, gramsPerUnit: 1.0, description: "g", isDefault: true)
    }

    /// Get serving units sorted by order index
    func getSortedUnits() -> [ServingUnit] {
        servingUnits.sorted { $0.orderIndex < $1.orderIndex }
    }
}
