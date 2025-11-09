//
//  InternationalFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// International restaurant and fast food items (per 100g unless specified)
struct InternationalFoods {
    static let all: [FoodDTO] = [
        // McDonald's
        FoodDTO(
            name: String(localized: "Big Mac"),
            calories: 257, protein: 13, carbs: 24, fats: 12,
            servingSize: 220,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 220, description: String(localized: "burger"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "McChicken"),
            calories: 229, protein: 11, carbs: 23, fats: 10,
            servingSize: 185,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 185, description: String(localized: "burger"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Chicken McNuggets"),
            calories: 302, protein: 15, carbs: 20, fats: 18,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 16, description: String(localized: "nugget"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "McDonald's Fries (Medium)"),
            calories: 312, protein: 3.4, carbs: 41, fats: 15,
            servingSize: 117,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 117, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Burger King
        FoodDTO(
            name: String(localized: "Whopper"),
            calories: 271, protein: 12, carbs: 24, fats: 14,
            servingSize: 291,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 291, description: String(localized: "burger"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Chicken Royale"),
            calories: 243, protein: 11, carbs: 26, fats: 10,
            servingSize: 223,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 223, description: String(localized: "burger"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "BK Onion Rings"),
            calories: 357, protein: 4.5, carbs: 46, fats: 17,
            servingSize: 91,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 91, description: String(localized: "medium"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // KFC
        FoodDTO(
            name: String(localized: "KFC Original Recipe Chicken"),
            calories: 260, protein: 22, carbs: 8, fats: 16,
            servingSize: 120,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 120, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "KFC Popcorn Chicken"),
            calories: 315, protein: 17, carbs: 19, fats: 19,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "KFC Coleslaw"),
            calories: 103, protein: 1.2, carbs: 11, fats: 6,
            servingSize: 130,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 130, description: String(localized: "regular"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Pizza
        FoodDTO(
            name: String(localized: "Margherita Pizza"),
            calories: 266, protein: 11, carbs: 33, fats: 10,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 100, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pepperoni Pizza"),
            calories: 298, protein: 12, carbs: 33, fats: 13,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 100, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Hawaiian Pizza"),
            calories: 245, protein: 10, carbs: 32, fats: 9,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 100, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "BBQ Chicken Pizza"),
            calories: 268, protein: 13, carbs: 34, fats: 9,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 100, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Asian Food
        FoodDTO(
            name: String(localized: "Sushi (Salmon Roll)"),
            calories: 145, protein: 7, carbs: 24, fats: 2.5,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 30, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "California Roll"),
            calories: 129, protein: 3.8, carbs: 22, fats: 2.5,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 30, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pad Thai"),
            calories: 166, protein: 5.5, carbs: 27, fats: 4.5,
            servingSize: 300,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 300, description: String(localized: "plate"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Fried Rice (Chicken)"),
            calories: 163, protein: 7, carbs: 24, fats: 4.5,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Spring Rolls"),
            calories: 195, protein: 5, carbs: 24, fats: 9,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "roll"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ramen"),
            calories: 138, protein: 6, carbs: 19, fats: 4,
            servingSize: 300,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 300, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Italian
        FoodDTO(
            name: String(localized: "Spaghetti Bolognese"),
            calories: 151, protein: 7.5, carbs: 21, fats: 4,
            servingSize: 300,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 300, description: String(localized: "plate"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Carbonara Pasta"),
            calories: 195, protein: 9, carbs: 22, fats: 8,
            servingSize: 300,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 300, description: String(localized: "plate"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lasagna"),
            calories: 168, protein: 10, carbs: 15, fats: 8,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 250, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Risotto"),
            calories: 142, protein: 4, carbs: 24, fats: 3.5,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Mexican
        FoodDTO(
            name: String(localized: "Beef Taco"),
            calories: 226, protein: 11, carbs: 18, fats: 12,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "taco"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Chicken Burrito"),
            calories: 206, protein: 10, carbs: 27, fats: 6,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 200, description: String(localized: "burrito"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Nachos with Cheese"),
            calories: 346, protein: 9, carbs: 36, fats: 19,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Quesadilla"),
            calories: 234, protein: 10, carbs: 24, fats: 11,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "quesadilla"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Guacamole"),
            calories: 160, protein: 2, carbs: 9, fats: 15,
            servingSize: 50,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // American Classics
        FoodDTO(
            name: String(localized: "Cheeseburger"),
            calories: 264, protein: 14, carbs: 24, fats: 12,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "burger"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Hot Dog"),
            calories: 290, protein: 10, carbs: 23, fats: 17,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "hot dog"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Caesar Salad"),
            calories: 87, protein: 7, carbs: 5, fats: 5,
            servingSize: 200,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mac and Cheese"),
            calories: 164, protein: 7, carbs: 20, fats: 6,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Sandwiches
        FoodDTO(
            name: String(localized: "Club Sandwich"),
            calories: 223, protein: 13, carbs: 24, fats: 8,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 200, description: String(localized: "sandwich"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "BLT Sandwich"),
            calories: 245, protein: 11, carbs: 25, fats: 12,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "sandwich"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tuna Sandwich"),
            calories: 198, protein: 14, carbs: 22, fats: 6,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "sandwich"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        )
    ]
}
