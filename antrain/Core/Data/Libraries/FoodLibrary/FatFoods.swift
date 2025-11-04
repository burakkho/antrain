//
//  FatFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Fat-rich foods (per 100g)
struct FatFoods {
    static let all: [FoodDTO] = [
        // Nuts
        FoodDTO(
            name: String(localized: "Almonds"),
            calories: 579, protein: 21, carbs: 22, fats: 50,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 1, description: String(localized: "1 almond"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Walnuts"),
            calories: 654, protein: 15, carbs: 14, fats: 65,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 7, description: String(localized: "1 walnut half"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cashews"),
            calories: 553, protein: 18, carbs: 30, fats: 44,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 1.5, description: String(localized: "1 cashew"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Peanuts"),
            calories: 567, protein: 26, carbs: 16, fats: 49,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pistachios"),
            calories: 560, protein: 20, carbs: 28, fats: 45,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 1, description: String(localized: "1 pistachio"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),

        // Nut Butters
        FoodDTO(
            name: String(localized: "Peanut Butter"),
            calories: 588, protein: 25, carbs: 20, fats: 50,
            servingSize: 16,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 16, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 32, description: String(localized: "2 tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Almond Butter"),
            calories: 614, protein: 21, carbs: 19, fats: 56,
            servingSize: 16,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 16, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 32, description: String(localized: "2 tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),

        // Seeds
        FoodDTO(
            name: String(localized: "Chia Seeds"),
            calories: 486, protein: 17, carbs: 42, fats: 31,
            servingSize: 15,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Flax Seeds"),
            calories: 534, protein: 18, carbs: 29, fats: 42,
            servingSize: 15,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sunflower Seeds"),
            calories: 584, protein: 21, carbs: 20, fats: 51,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pumpkin Seeds"),
            calories: 559, protein: 30, carbs: 14, fats: 49,
            servingSize: 28,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 28, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Oils
        FoodDTO(
            name: String(localized: "Olive Oil"),
            calories: 884, protein: 0, carbs: 0, fats: 100,
            servingSize: 14,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 14, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Coconut Oil"),
            calories: 892, protein: 0, carbs: 0, fats: 100,
            servingSize: 14,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 14, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Avocado Oil"),
            calories: 884, protein: 0, carbs: 0, fats: 100,
            servingSize: 14,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 14, description: String(localized: "1 tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "1 tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Other
        FoodDTO(
            name: String(localized: "Avocado"),
            calories: 160, protein: 2, carbs: 9, fats: 15,
            servingSize: 150,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 130, description: String(localized: "1 cup cubed"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Dark Chocolate (70%)"),
            calories: 598, protein: 8, carbs: 46, fats: 43,
            servingSize: 30,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 30, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 5, description: String(localized: "1 square"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Coconut (Fresh)"),
            calories: 354, protein: 3.3, carbs: 15, fats: 33,
            servingSize: 80,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 80, description: String(localized: "1 cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 80, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        )
    ]
}
