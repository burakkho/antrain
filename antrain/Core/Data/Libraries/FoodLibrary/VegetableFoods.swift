//
//  VegetableFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Vegetables and fruits (per 100g)
struct VegetableFoods {
    static let all: [FoodDTO] = [
        // Leafy Greens
        FoodDTO(
            name: String(localized: "Spinach"),
            calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 30, description: String(localized: "1 cup raw"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kale"),
            calories: 49, protein: 4.3, carbs: 9, fats: 0.9,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 67, description: String(localized: "1 cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lettuce"),
            calories: 15, protein: 1.4, carbs: 2.9, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 47, description: String(localized: "1 cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Arugula"),
            calories: 25, protein: 2.6, carbs: 3.7, fats: 0.7,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 20, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Cruciferous
        FoodDTO(
            name: String(localized: "Broccoli"),
            calories: 34, protein: 2.8, carbs: 7, fats: 0.4,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 91, description: String(localized: "1 cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cauliflower"),
            calories: 25, protein: 1.9, carbs: 5, fats: 0.3,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "1 cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Brussels Sprouts"),
            calories: 43, protein: 3.4, carbs: 9, fats: 0.3,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 88, description: String(localized: "1 cup halved"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 19, description: String(localized: "1 sprout"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cabbage"),
            calories: 25, protein: 1.3, carbs: 6, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 89, description: String(localized: "1 cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Root Vegetables
        FoodDTO(
            name: String(localized: "Carrot"),
            calories: 41, protein: 0.9, carbs: 10, fats: 0.2,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 61, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 128, description: String(localized: "1 cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 120, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Beet"),
            calories: 43, protein: 1.6, carbs: 10, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 82, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 136, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Radish"),
            calories: 16, protein: 0.7, carbs: 3.4, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 12, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 116, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),

        // Other Vegetables
        FoodDTO(
            name: String(localized: "Bell Pepper (Red)"),
            calories: 31, protein: 1, carbs: 6, fats: 0.3,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 119, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 149, description: String(localized: "1 cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 120, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cucumber"),
            calories: 16, protein: 0.7, carbs: 3.6, fats: 0.1,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 301, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 104, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 120, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tomato"),
            calories: 18, protein: 0.9, carbs: 3.9, fats: 0.2,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 123, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 149, description: String(localized: "1 cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Zucchini"),
            calories: 17, protein: 1.2, carbs: 3.1, fats: 0.3,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 196, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 124, description: String(localized: "1 cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eggplant"),
            calories: 25, protein: 1, carbs: 6, fats: 0.2,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 82, description: String(localized: "1 cup cubed"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mushrooms"),
            calories: 22, protein: 3.1, carbs: 3.3, fats: 0.3,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 70, description: String(localized: "1 cup sliced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 18, description: String(localized: "1 medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Asparagus"),
            calories: 20, protein: 2.2, carbs: 3.9, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 18, description: String(localized: "1 spear"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 134, description: String(localized: "1 cup"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Green Beans"),
            calories: 31, protein: 1.8, carbs: 7, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Fruits
        FoodDTO(
            name: String(localized: "Apple"),
            calories: 52, protein: 0.3, carbs: 14, fats: 0.2,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 182, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 125, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Banana"),
            calories: 89, protein: 1.1, carbs: 23, fats: 0.3,
            servingSize: 120,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 118, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 120, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Orange"),
            calories: 47, protein: 0.9, carbs: 12, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 131, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 180, description: String(localized: "1 cup sections"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Strawberry"),
            calories: 32, protein: 0.7, carbs: 7.7, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 152, description: String(localized: "1 cup whole"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 12, description: String(localized: "1 medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Blueberry"),
            calories: 57, protein: 0.7, carbs: 14, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 148, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Grape"),
            calories: 69, protein: 0.7, carbs: 18, fats: 0.2,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 151, description: String(localized: "1 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 5, description: String(localized: "1 grape"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Watermelon"),
            calories: 30, protein: 0.6, carbs: 8, fats: 0.2,
            servingSize: 200,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 152, description: String(localized: "1 cup diced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 286, description: String(localized: "1 wedge"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 200, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pineapple"),
            calories: 50, protein: 0.5, carbs: 13, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 165, description: String(localized: "1 cup chunks"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 84, description: String(localized: "1 slice"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mango"),
            calories: 60, protein: 0.8, carbs: 15, fats: 0.4,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 165, description: String(localized: "1 cup sliced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 336, description: String(localized: "1 medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Peach"),
            calories: 39, protein: 0.9, carbs: 10, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 154, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pear"),
            calories: 57, protein: 0.4, carbs: 15, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 178, description: String(localized: "1 medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "1 cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "1 serving"), isDefault: false, orderIndex: 2),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 3)
            ]
        )
    ]
}
