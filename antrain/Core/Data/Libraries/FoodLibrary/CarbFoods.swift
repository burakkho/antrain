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
        FoodDTO(name: "White Rice (Cooked)", calories: 130, protein: 2.7, carbs: 28, fats: 0.3, servingSize: 150, category: .carb),
        FoodDTO(name: "Brown Rice (Cooked)", calories: 112, protein: 2.6, carbs: 24, fats: 0.9, servingSize: 150, category: .carb),
        FoodDTO(name: "Basmati Rice (Cooked)", calories: 121, protein: 3, carbs: 25, fats: 0.4, servingSize: 150, category: .carb),
        FoodDTO(name: "Quinoa (Cooked)", calories: 120, protein: 4.4, carbs: 21, fats: 1.9, servingSize: 150, category: .carb),
        FoodDTO(name: "Oats (Dry)", calories: 389, protein: 17, carbs: 66, fats: 6.9, servingSize: 40, category: .carb),
        FoodDTO(name: "Bulgur (Cooked)", calories: 83, protein: 3.1, carbs: 19, fats: 0.2, servingSize: 150, category: .carb),

        // Pasta & Noodles
        FoodDTO(name: "Whole Wheat Pasta (Cooked)", calories: 124, protein: 5.3, carbs: 26, fats: 0.5, servingSize: 150, category: .carb),
        FoodDTO(name: "White Pasta (Cooked)", calories: 131, protein: 5.1, carbs: 25, fats: 1.1, servingSize: 150, category: .carb),
        FoodDTO(name: "Rice Noodles (Cooked)", calories: 109, protein: 1.8, carbs: 24, fats: 0.2, servingSize: 140, category: .carb),

        // Bread
        FoodDTO(name: "Whole Wheat Bread", calories: 247, protein: 13, carbs: 41, fats: 3.4, servingSize: 50, category: .carb),
        FoodDTO(name: "White Bread", calories: 265, protein: 9, carbs: 49, fats: 3.2, servingSize: 50, category: .carb),
        FoodDTO(name: "Sourdough Bread", calories: 289, protein: 11, carbs: 56, fats: 1.1, servingSize: 50, category: .carb),
        FoodDTO(name: "Pita Bread", calories: 275, protein: 9.1, carbs: 55, fats: 1.2, servingSize: 60, category: .carb),
        FoodDTO(name: "Bagel", calories: 257, protein: 10, carbs: 50, fats: 1.4, servingSize: 90, category: .carb),

        // Potatoes
        FoodDTO(name: "Sweet Potato (Baked)", calories: 90, protein: 2, carbs: 21, fats: 0.2, servingSize: 150, category: .carb),
        FoodDTO(name: "White Potato (Baked)", calories: 93, protein: 2.5, carbs: 21, fats: 0.1, servingSize: 150, category: .carb),
        FoodDTO(name: "Red Potato (Boiled)", calories: 87, protein: 1.9, carbs: 20, fats: 0.1, servingSize: 150, category: .carb),

        // Cereals
        FoodDTO(name: "Corn Flakes", calories: 357, protein: 7, carbs: 84, fats: 0.4, servingSize: 30, category: .carb),
        FoodDTO(name: "Granola", calories: 471, protein: 10, carbs: 61, fats: 20, servingSize: 50, category: .carb),
        FoodDTO(name: "Muesli", calories: 352, protein: 10, carbs: 65, fats: 5, servingSize: 50, category: .carb),

        // Other
        FoodDTO(name: "Couscous (Cooked)", calories: 112, protein: 3.8, carbs: 23, fats: 0.2, servingSize: 150, category: .carb),
        FoodDTO(name: "Tortilla (Corn)", calories: 218, protein: 5.7, carbs: 45, fats: 2.9, servingSize: 50, category: .carb),
        FoodDTO(name: "Tortilla (Flour)", calories: 304, protein: 8.2, carbs: 51, fats: 7.3, servingSize: 50, category: .carb),
        FoodDTO(name: "Crackers", calories: 502, protein: 8.5, carbs: 61, fats: 25, servingSize: 30, category: .carb),
        FoodDTO(name: "Pretzels", calories: 380, protein: 9, carbs: 80, fats: 2.6, servingSize: 30, category: .carb)
    ]
}
