//
//  ProteinFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Protein-rich foods (per 100g)
struct ProteinFoods {
    static let all: [FoodDTO] = [
        // Poultry
        FoodDTO(
            name: String(localized: "Chicken Breast"),
            calories: 165, protein: 31, carbs: 0, fats: 3.6,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Chicken Thigh"),
            calories: 209, protein: 26, carbs: 0, fats: 11,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Turkey Breast"),
            calories: 135, protein: 30, carbs: 0, fats: 0.7,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ground Turkey"),
            calories: 149, protein: 21, carbs: 0, fats: 6.6,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Meat
        FoodDTO(
            name: String(localized: "Lean Beef (95%)"),
            calories: 137, protein: 21, carbs: 0, fats: 5,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ground Beef (85%)"),
            calories: 215, protein: 18, carbs: 0, fats: 15,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pork Tenderloin"),
            calories: 143, protein: 26, carbs: 0, fats: 3.5,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lamb"),
            calories: 258, protein: 25, carbs: 0, fats: 17,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Seafood
        FoodDTO(
            name: String(localized: "Salmon"),
            calories: 208, protein: 20, carbs: 0, fats: 13,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tuna"),
            calories: 130, protein: 29, carbs: 0, fats: 0.9,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 80, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tilapia"),
            calories: 129, protein: 26, carbs: 0, fats: 2.7,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cod"),
            calories: 82, protein: 18, carbs: 0, fats: 0.7,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Shrimp"),
            calories: 99, protein: 24, carbs: 0.2, fats: 0.3,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 10, description: String(localized: "large shrimp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sardines"),
            calories: 208, protein: 25, carbs: 0, fats: 11,
            servingSize: 80,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 80, description: String(localized: "can"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Eggs & Dairy
        FoodDTO(
            name: String(localized: "Whole Egg"),
            calories: 155, protein: 13, carbs: 1.1, fats: 11,
            servingSize: 50,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "egg"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Egg Whites"),
            calories: 52, protein: 11, carbs: 0.7, fats: 0.2,
            servingSize: 60,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 30, description: String(localized: "egg white"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Greek Yogurt (Plain)"),
            calories: 59, protein: 10, carbs: 3.6, fats: 0.4,
            servingSize: 170,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .container, gramsPerUnit: 170, description: String(localized: "container"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cottage Cheese (Low Fat)"),
            calories: 72, protein: 12, carbs: 3.4, fats: 1,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 125, description: String(localized: "1/2 cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cheddar Cheese"),
            calories: 403, protein: 25, carbs: 1.3, fats: 33,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mozzarella Cheese"),
            calories: 280, protein: 28, carbs: 2.2, fats: 17,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Legumes
        FoodDTO(
            name: String(localized: "Lentils (Cooked)"),
            calories: 116, protein: 9, carbs: 20, fats: 0.4,
            servingSize: 200,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Chickpeas (Cooked)"),
            calories: 164, protein: 9, carbs: 27, fats: 2.6,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Black Beans (Cooked)"),
            calories: 132, protein: 9, carbs: 24, fats: 0.5,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kidney Beans (Cooked)"),
            calories: 127, protein: 9, carbs: 23, fats: 0.5,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Edamame"),
            calories: 122, protein: 11, carbs: 10, fats: 5,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Tofu & Tempeh
        FoodDTO(
            name: String(localized: "Tofu (Firm)"),
            calories: 144, protein: 17, carbs: 2.3, fats: 9,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "block"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tempeh"),
            calories: 193, protein: 20, carbs: 9, fats: 11,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "block"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Seitan"),
            calories: 370, protein: 75, carbs: 14, fats: 1.9,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Protein Powder
        FoodDTO(
            name: String(localized: "Whey Protein Powder"),
            calories: 400, protein: 80, carbs: 8, fats: 5,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .scoop, gramsPerUnit: 30, description: String(localized: "scoop"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Casein Protein Powder"),
            calories: 380, protein: 78, carbs: 8, fats: 3,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .scoop, gramsPerUnit: 30, description: String(localized: "scoop"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pea Protein Powder"),
            calories: 380, protein: 80, carbs: 7, fats: 5,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .scoop, gramsPerUnit: 30, description: String(localized: "scoop"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 10, description: String(localized: "tbsp"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Additional Seafood
        FoodDTO(
            name: String(localized: "Trout"),
            calories: 141, protein: 20, carbs: 0, fats: 6.6,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sea Bass"),
            calories: 97, protein: 18, carbs: 0, fats: 2,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mackerel"),
            calories: 205, protein: 19, carbs: 0, fats: 14,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "fillet"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Anchovy"),
            calories: 131, protein: 20, carbs: 0, fats: 4.8,
            servingSize: 80,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 5, description: String(localized: "anchovy"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Additional Meat Products
        FoodDTO(
            name: String(localized: "Beef Tenderloin"),
            calories: 188, protein: 24, carbs: 0, fats: 10,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "steak"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Meatballs"),
            calories: 197, protein: 19, carbs: 7, fats: 10,
            servingSize: 60,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "meatball"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Processed Meats
        FoodDTO(
            name: String(localized: "Turkey Salami"),
            calories: 172, protein: 16, carbs: 3, fats: 11,
            servingSize: 50,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 10, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Turkish Sausage (Sucuk)"),
            calories: 467, protein: 18, carbs: 2, fats: 43,
            servingSize: 50,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 10, description: String(localized: "slice"), isDefault: false, orderIndex: 1),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 2)
            ]
        ),

        // Additional Cheese
        FoodDTO(
            name: String(localized: "Lor Cheese"),
            calories: 173, protein: 13, carbs: 5, fats: 11,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 20, description: String(localized: "tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kashar Cheese"),
            calories: 375, protein: 25, carbs: 2, fats: 30,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Protein Bars
        FoodDTO(
            name: String(localized: "Protein Bar"),
            calories: 350, protein: 20, carbs: 40, fats: 10,
            servingSize: 60,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "bar"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        )
    ]
}
