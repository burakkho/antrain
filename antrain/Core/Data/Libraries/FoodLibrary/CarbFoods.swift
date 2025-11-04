//
//  CarbFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Carbohydrate-rich foods (per 100g)
struct CarbFoods {
    static let all: [FoodDTO] = [
        // Rice & Grains
        FoodDTO(
            name: String(localized: "White Rice (Cooked)"),
            calories: 130, protein: 2.7, carbs: 28, fats: 0.3,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Brown Rice (Cooked)"),
            calories: 112, protein: 2.6, carbs: 24, fats: 0.9,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Basmati Rice (Cooked)"),
            calories: 121, protein: 3, carbs: 25, fats: 0.4,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Quinoa (Cooked)"),
            calories: 120, protein: 4.4, carbs: 21, fats: 1.9,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Oats (Dry)"),
            calories: 389, protein: 17, carbs: 66, fats: 6.9,
            servingSize: 40,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 80, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 40, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Bulgur (Cooked)"),
            calories: 83, protein: 3.1, carbs: 19, fats: 0.2,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Pasta & Noodles
        FoodDTO(
            name: String(localized: "Whole Wheat Pasta (Cooked)"),
            calories: 124, protein: 5.3, carbs: 26, fats: 0.5,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "White Pasta (Cooked)"),
            calories: 131, protein: 5.1, carbs: 25, fats: 1.1,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Rice Noodles (Cooked)"),
            calories: 109, protein: 1.8, carbs: 24, fats: 0.2,
            servingSize: 140,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Bread
        FoodDTO(
            name: String(localized: "Whole Wheat Bread"),
            calories: 247, protein: 13, carbs: 41, fats: 3.4,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "1 slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 50, description: String(localized: "2 slices"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "White Bread"),
            calories: 265, protein: 9, carbs: 49, fats: 3.2,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "1 slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 50, description: String(localized: "2 slices"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sourdough Bread"),
            calories: 289, protein: 11, carbs: 56, fats: 1.1,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "1 slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 50, description: String(localized: "2 slices"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pita Bread"),
            calories: 275, protein: 9.1, carbs: 55, fats: 1.2,
            servingSize: 60,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "1 pita"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Bagel"),
            calories: 257, protein: 10, carbs: 50, fats: 1.4,
            servingSize: 90,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 90, description: String(localized: "1 bagel"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Potatoes
        FoodDTO(
            name: String(localized: "Sweet Potato (Baked)"),
            calories: 90, protein: 2, carbs: 21, fats: 0.2,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 130, description: String(localized: "1 cup cubed"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "White Potato (Baked)"),
            calories: 93, protein: 2.5, carbs: 21, fats: 0.1,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 130, description: String(localized: "1 cup cubed"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Red Potato (Boiled)"),
            calories: 87, protein: 1.9, carbs: 20, fats: 0.1,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 130, description: String(localized: "1 cup cubed"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Cereals
        FoodDTO(
            name: String(localized: "Corn Flakes"),
            calories: 357, protein: 7, carbs: 84, fats: 0.4,
            servingSize: 30,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 30, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 30, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Granola"),
            calories: 471, protein: 10, carbs: 61, fats: 20,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 50, description: String(localized: "1/2 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 50, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Muesli"),
            calories: 352, protein: 10, carbs: 65, fats: 5,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 50, description: String(localized: "1/2 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 50, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "1 tbsp"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),

        // Other
        FoodDTO(
            name: String(localized: "Couscous (Cooked)"),
            calories: 112, protein: 3.8, carbs: 23, fats: 0.2,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tortilla (Corn)"),
            calories: 218, protein: 5.7, carbs: 45, fats: 2.9,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "1 tortilla"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tortilla (Flour)"),
            calories: 304, protein: 8.2, carbs: 51, fats: 7.3,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "1 tortilla"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Crackers"),
            calories: 502, protein: 8.5, carbs: 61, fats: 25,
            servingSize: 30,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 30, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 5, description: String(localized: "1 cracker"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pretzels"),
            calories: 380, protein: 9, carbs: 80, fats: 2.6,
            servingSize: 30,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 30, description: String(localized: "1 serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 10, description: String(localized: "1 pretzel"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        )
    ]
}
