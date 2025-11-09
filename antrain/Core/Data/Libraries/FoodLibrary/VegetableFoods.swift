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
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 30, description: String(localized: "cup raw"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kale"),
            calories: 49, protein: 4.3, carbs: 9, fats: 0.9,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 67, description: String(localized: "cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lettuce"),
            calories: 15, protein: 1.4, carbs: 2.9, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 47, description: String(localized: "cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Arugula"),
            calories: 25, protein: 2.6, carbs: 3.7, fats: 0.7,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 20, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Cruciferous
        FoodDTO(
            name: String(localized: "Broccoli"),
            calories: 34, protein: 2.8, carbs: 7, fats: 0.4,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 91, description: String(localized: "cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cauliflower"),
            calories: 25, protein: 1.9, carbs: 5, fats: 0.3,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "cup chopped"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Brussels Sprouts"),
            calories: 43, protein: 3.4, carbs: 9, fats: 0.3,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 88, description: String(localized: "cup halved"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 19, description: String(localized: "sprout"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cabbage"),
            calories: 25, protein: 1.3, carbs: 6, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 89, description: String(localized: "cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Root Vegetables
        FoodDTO(
            name: String(localized: "Carrot"),
            calories: 41, protein: 0.9, carbs: 10, fats: 0.2,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 61, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 128, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Beet"),
            calories: 43, protein: 1.6, carbs: 10, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 82, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 136, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Radish"),
            calories: 16, protein: 0.7, carbs: 3.4, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 12, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 116, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Other Vegetables
        FoodDTO(
            name: String(localized: "Bell Pepper (Red)"),
            calories: 31, protein: 1, carbs: 6, fats: 0.3,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 119, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 149, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cucumber"),
            calories: 16, protein: 0.7, carbs: 3.6, fats: 0.1,
            servingSize: 120,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 301, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 104, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tomato"),
            calories: 18, protein: 0.9, carbs: 3.9, fats: 0.2,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 123, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 149, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Zucchini"),
            calories: 17, protein: 1.2, carbs: 3.1, fats: 0.3,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 196, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 124, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eggplant"),
            calories: 25, protein: 1, carbs: 6, fats: 0.2,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 82, description: String(localized: "cup cubed"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mushrooms"),
            calories: 22, protein: 3.1, carbs: 3.3, fats: 0.3,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 70, description: String(localized: "cup sliced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 18, description: String(localized: "medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Asparagus"),
            calories: 20, protein: 2.2, carbs: 3.9, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 18, description: String(localized: "spear"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 134, description: String(localized: "cup"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Green Beans"),
            calories: 31, protein: 1.8, carbs: 7, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Additional Vegetables
        FoodDTO(
            name: String(localized: "Okra"),
            calories: 33, protein: 1.9, carbs: 7, fats: 0.2,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 12, description: String(localized: "pod"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Peas (Fresh)"),
            calories: 81, protein: 5.4, carbs: 14, fats: 0.4,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 145, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Corn (Fresh)"),
            calories: 86, protein: 3.3, carbs: 19, fats: 1.4,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 90, description: String(localized: "ear"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 145, description: String(localized: "cup kernels"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Onion"),
            calories: 40, protein: 1.1, carbs: 9, fats: 0.1,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 110, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 160, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Garlic"),
            calories: 149, protein: 6.4, carbs: 33, fats: 0.5,
            servingSize: 10,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 3, description: String(localized: "clove"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .teaspoon, gramsPerUnit: 5, description: String(localized: "tsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Leek"),
            calories: 61, protein: 1.5, carbs: 14, fats: 0.3,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 89, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 89, description: String(localized: "cup chopped"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        )
    ]
}
