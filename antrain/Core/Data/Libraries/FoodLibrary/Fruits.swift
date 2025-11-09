//
//  Fruits.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Fruits (per 100g)
struct Fruits {
    static let all: [FoodDTO] = [
        // Common Fruits
        FoodDTO(
            name: String(localized: "Apple"),
            calories: 52, protein: 0.3, carbs: 14, fats: 0.2,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 182, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 125, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Banana"),
            calories: 89, protein: 1.1, carbs: 23, fats: 0.3,
            servingSize: 120,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 118, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Orange"),
            calories: 47, protein: 0.9, carbs: 12, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 131, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 180, description: String(localized: "cup sections"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pear"),
            calories: 57, protein: 0.4, carbs: 15, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 178, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Peach"),
            calories: 39, protein: 0.9, carbs: 10, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 154, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Plum"),
            calories: 46, protein: 0.7, carbs: 11, fats: 0.3,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 66, description: String(localized: "plum"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 165, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Apricot"),
            calories: 48, protein: 1.4, carbs: 11, fats: 0.4,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 35, description: String(localized: "apricot"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 155, description: String(localized: "cup halves"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Berries
        FoodDTO(
            name: String(localized: "Strawberry"),
            calories: 32, protein: 0.7, carbs: 7.7, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 152, description: String(localized: "cup whole"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 12, description: String(localized: "medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Blueberry"),
            calories: 57, protein: 0.7, carbs: 14, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 148, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Raspberry"),
            calories: 52, protein: 1.2, carbs: 12, fats: 0.7,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 123, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Blackberry"),
            calories: 43, protein: 1.4, carbs: 10, fats: 0.5,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 144, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cherry"),
            calories: 63, protein: 1.1, carbs: 16, fats: 0.2,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 138, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 8, description: String(localized: "cherry"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Grapes and Vine Fruits
        FoodDTO(
            name: String(localized: "Grape"),
            calories: 69, protein: 0.7, carbs: 18, fats: 0.2,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 151, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 5, description: String(localized: "grape"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kiwi"),
            calories: 61, protein: 1.1, carbs: 15, fats: 0.5,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 69, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 177, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Citrus
        FoodDTO(
            name: String(localized: "Lemon"),
            calories: 29, protein: 1.1, carbs: 9, fats: 0.3,
            servingSize: 60,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 58, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "tbsp juice"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lime"),
            calories: 30, protein: 0.7, carbs: 11, fats: 0.2,
            servingSize: 50,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 67, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "tbsp juice"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Grapefruit"),
            calories: 42, protein: 0.8, carbs: 11, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 246, description: String(localized: "1/2 fruit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 230, description: String(localized: "cup sections"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mandarin"),
            calories: 53, protein: 0.8, carbs: 13, fats: 0.3,
            servingSize: 88,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 88, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 195, description: String(localized: "cup sections"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pomegranate"),
            calories: 83, protein: 1.7, carbs: 19, fats: 1.2,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 174, description: String(localized: "cup arils"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 282, description: String(localized: "medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Melons
        FoodDTO(
            name: String(localized: "Watermelon"),
            calories: 30, protein: 0.6, carbs: 8, fats: 0.2,
            servingSize: 200,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 152, description: String(localized: "cup diced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 286, description: String(localized: "wedge"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Melon"),
            calories: 34, protein: 0.8, carbs: 8, fats: 0.2,
            servingSize: 200,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 160, description: String(localized: "cup diced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 200, description: String(localized: "wedge"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Tropical
        FoodDTO(
            name: String(localized: "Mango"),
            calories: 60, protein: 0.8, carbs: 15, fats: 0.4,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 165, description: String(localized: "cup sliced"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 336, description: String(localized: "medium"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pineapple"),
            calories: 50, protein: 0.5, carbs: 13, fats: 0.1,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 165, description: String(localized: "cup chunks"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 84, description: String(localized: "slice"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Papaya"),
            calories: 43, protein: 0.5, carbs: 11, fats: 0.3,
            servingSize: 150,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 140, description: String(localized: "cup cubed"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 304, description: String(localized: "small"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Avocado"),
            calories: 160, protein: 2, carbs: 9, fats: 15,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 136, description: String(localized: "1/2 avocado"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "cup sliced"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Coconut (Fresh)"),
            calories: 354, protein: 3.3, carbs: 15, fats: 33,
            servingSize: 50,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 80, description: String(localized: "cup shredded"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 45, description: String(localized: "piece"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Passion Fruit"),
            calories: 97, protein: 2.2, carbs: 23, fats: 0.7,
            servingSize: 50,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 18, description: String(localized: "fruit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 236, description: String(localized: "cup pulp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Other Fruits
        FoodDTO(
            name: String(localized: "Fig"),
            calories: 74, protein: 0.8, carbs: 19, fats: 0.3,
            servingSize: 100,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "fig"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 149, description: String(localized: "cup"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Dried Fruits
        FoodDTO(
            name: String(localized: "Dates"),
            calories: 282, protein: 2.5, carbs: 75, fats: 0.4,
            servingSize: 40,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 7.1, description: String(localized: "date"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 178, description: String(localized: "cup pitted"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Raisins"),
            calories: 299, protein: 3.1, carbs: 79, fats: 0.5,
            servingSize: 40,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 145, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 14, description: String(localized: "tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Dried Apricot"),
            calories: 241, protein: 3.4, carbs: 63, fats: 0.5,
            servingSize: 40,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 7.5, description: String(localized: "apricot"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 130, description: String(localized: "cup"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Prunes"),
            calories: 240, protein: 2.2, carbs: 64, fats: 0.4,
            servingSize: 40,
            category: .fruit,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 9.5, description: String(localized: "prune"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 174, description: String(localized: "cup pitted"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        )
    ]
}
