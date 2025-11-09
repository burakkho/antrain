//
//  PackagedFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Packaged and branded foods (per 100g unless specified)
struct PackagedFoods {
    static let all: [FoodDTO] = [
        // Turkish Brands - Chocolate & Sweets
        FoodDTO(
            name: String(localized: "Ülker Çikolata (Milk Chocolate)"),
            calories: 535, protein: 7, carbs: 57, fats: 30,
            servingSize: 60,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eti Browni"),
            calories: 467, protein: 6.5, carbs: 61, fats: 22,
            servingSize: 45,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 45, description: String(localized: "cake"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eti Burçak"),
            calories: 528, protein: 9.5, carbs: 55, fats: 30,
            servingSize: 32,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 32, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eti Karam"),
            calories: 546, protein: 9, carbs: 54, fats: 32,
            servingSize: 35,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 35, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Albeni"),
            calories: 527, protein: 7.2, carbs: 59, fats: 29,
            servingSize: 36,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 36, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Brands - Biscuits
        FoodDTO(
            name: String(localized: "Ülker Halley"),
            calories: 489, protein: 6.2, carbs: 66, fats: 22,
            servingSize: 40,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 13, description: String(localized: "biscuit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ülker Petit Beurre"),
            calories: 450, protein: 7.5, carbs: 70, fats: 15,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 10, description: String(localized: "biscuit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ülker Tea Biscuit"),
            calories: 463, protein: 7, carbs: 68, fats: 18,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 8, description: String(localized: "biscuit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Eti Cin"),
            calories: 488, protein: 6.5, carbs: 67, fats: 21,
            servingSize: 40,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 13, description: String(localized: "biscuit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Brands - Chips & Snacks
        FoodDTO(
            name: String(localized: "Lays Classic (Turkey)"),
            calories: 536, protein: 6.5, carbs: 53, fats: 33,
            servingSize: 35,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 35, description: String(localized: "small bag"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ruffles"),
            calories: 528, protein: 6.8, carbs: 54, fats: 31,
            servingSize: 35,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 35, description: String(localized: "small bag"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Doritos Nacho Cheese"),
            calories: 498, protein: 7, carbs: 63, fats: 24,
            servingSize: 40,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 40, description: String(localized: "small bag"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Çerezza Leblebi"),
            calories: 375, protein: 20, carbs: 54, fats: 6,
            servingSize: 40,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 40, description: String(localized: "bag"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Brands - Dairy
        FoodDTO(
            name: String(localized: "Pınar Süt (Milk)"),
            calories: 61, protein: 3.2, carbs: 4.8, fats: 3.3,
            servingSize: 200,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "glass"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sütaş Yogurt"),
            calories: 65, protein: 3.5, carbs: 4.5, fats: 3.8,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 150, description: String(localized: "container"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Danone Activia"),
            calories: 73, protein: 4, carbs: 9.5, fats: 2.2,
            servingSize: 115,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 115, description: String(localized: "container"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Soft Drinks
        FoodDTO(
            name: String(localized: "Coca Cola"),
            calories: 42, protein: 0, carbs: 10.6, fats: 0,
            servingSize: 330,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 330, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Coca Cola Zero"),
            calories: 0, protein: 0, carbs: 0, fats: 0,
            servingSize: 330,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 330, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Fanta"),
            calories: 45, protein: 0, carbs: 11.2, fats: 0,
            servingSize: 330,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 330, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sprite"),
            calories: 38, protein: 0, carbs: 9.5, fats: 0,
            servingSize: 330,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 330, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pepsi"),
            calories: 43, protein: 0, carbs: 10.8, fats: 0,
            servingSize: 330,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 330, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Red Bull"),
            calories: 45, protein: 0, carbs: 11, fats: 0,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 250, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // International Chocolate Bars
        FoodDTO(
            name: String(localized: "Snickers"),
            calories: 488, protein: 9, carbs: 54, fats: 26,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mars Bar"),
            calories: 449, protein: 4.3, carbs: 68, fats: 17,
            servingSize: 51,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 51, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Twix"),
            calories: 502, protein: 4.9, carbs: 63, fats: 25,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kit Kat"),
            calories: 518, protein: 7.3, carbs: 59, fats: 28,
            servingSize: 45,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 45, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Bounty"),
            calories: 471, protein: 3.9, carbs: 57, fats: 25,
            servingSize: 57,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 57, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Milka Chocolate"),
            calories: 529, protein: 6.3, carbs: 59, fats: 29,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Nutella"),
            calories: 539, protein: 6.3, carbs: 57, fats: 30.9,
            servingSize: 15,
            category: .fat,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 15, description: String(localized: "tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // International Snacks
        FoodDTO(
            name: String(localized: "Pringles Original"),
            calories: 536, protein: 4, carbs: 53, fats: 33,
            servingSize: 53,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 30, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cheetos"),
            calories: 570, protein: 6, carbs: 53, fats: 37,
            servingSize: 28,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 28, description: String(localized: "small bag"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Oreo"),
            calories: 478, protein: 5.3, carbs: 68, fats: 20,
            servingSize: 44,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 11, description: String(localized: "cookie"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Protein Products
        FoodDTO(
            name: String(localized: "Quest Protein Bar"),
            calories: 180, protein: 21, carbs: 22, fats: 8,
            servingSize: 60,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Optimum Nutrition Whey"),
            calories: 403, protein: 78, carbs: 12, fats: 5,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .scoop, gramsPerUnit: 30, description: String(localized: "scoop"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Ice Cream
        FoodDTO(
            name: String(localized: "Algida Magnum Classic"),
            calories: 276, protein: 3.5, carbs: 27, fats: 17,
            servingSize: 110,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 110, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Algida Cornetto"),
            calories: 223, protein: 3, carbs: 30, fats: 10,
            servingSize: 120,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 120, description: String(localized: "cone"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ben & Jerry's (Average)"),
            calories: 250, protein: 4, carbs: 28, fats: 14,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "1/2 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        )
    ]
}
