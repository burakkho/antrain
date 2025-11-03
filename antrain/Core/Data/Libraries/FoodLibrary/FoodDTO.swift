//
//  FoodDTO.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Food Data Transfer Object
/// Used for library data, converted to FoodItem model
struct FoodDTO {
    let name: String
    let brand: String?
    let calories: Double      // per 100g
    let protein: Double       // per 100g (grams)
    let carbs: Double         // per 100g (grams)
    let fats: Double          // per 100g (grams)
    let servingSize: Double   // default serving (grams)
    let category: FoodCategory
    let version: Int

    init(
        name: String,
        brand: String? = nil,
        calories: Double,
        protein: Double,
        carbs: Double,
        fats: Double,
        servingSize: Double,
        category: FoodCategory,
        version: Int = 1
    ) {
        self.name = name
        self.brand = brand
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.servingSize = servingSize
        self.category = category
        self.version = version
    }

    /// Convert DTO to FoodItem model
    func toModel() -> FoodItem {
        FoodItem(
            name: name,
            brand: brand,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats,
            servingSize: servingSize,
            category: category,
            isCustom: false,
            isFavorite: false,
            version: version
        )
    }
}
