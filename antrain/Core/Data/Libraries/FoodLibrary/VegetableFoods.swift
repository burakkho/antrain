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
        FoodDTO(name: "Spinach", calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Kale", calories: 49, protein: 4.3, carbs: 9, fats: 0.9, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Lettuce", calories: 15, protein: 1.4, carbs: 2.9, fats: 0.2, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Arugula", calories: 25, protein: 2.6, carbs: 3.7, fats: 0.7, servingSize: 100, category: .vegetable),

        // Cruciferous
        FoodDTO(name: "Broccoli", calories: 34, protein: 2.8, carbs: 7, fats: 0.4, servingSize: 150, category: .vegetable),
        FoodDTO(name: "Cauliflower", calories: 25, protein: 1.9, carbs: 5, fats: 0.3, servingSize: 150, category: .vegetable),
        FoodDTO(name: "Brussels Sprouts", calories: 43, protein: 3.4, carbs: 9, fats: 0.3, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Cabbage", calories: 25, protein: 1.3, carbs: 6, fats: 0.1, servingSize: 100, category: .vegetable),

        // Root Vegetables
        FoodDTO(name: "Carrot", calories: 41, protein: 0.9, carbs: 10, fats: 0.2, servingSize: 120, category: .vegetable),
        FoodDTO(name: "Beet", calories: 43, protein: 1.6, carbs: 10, fats: 0.2, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Radish", calories: 16, protein: 0.7, carbs: 3.4, fats: 0.1, servingSize: 100, category: .vegetable),

        // Other Vegetables
        FoodDTO(name: "Bell Pepper (Red)", calories: 31, protein: 1, carbs: 6, fats: 0.3, servingSize: 120, category: .vegetable),
        FoodDTO(name: "Cucumber", calories: 16, protein: 0.7, carbs: 3.6, fats: 0.1, servingSize: 120, category: .vegetable),
        FoodDTO(name: "Tomato", calories: 18, protein: 0.9, carbs: 3.9, fats: 0.2, servingSize: 150, category: .vegetable),
        FoodDTO(name: "Zucchini", calories: 17, protein: 1.2, carbs: 3.1, fats: 0.3, servingSize: 150, category: .vegetable),
        FoodDTO(name: "Eggplant", calories: 25, protein: 1, carbs: 6, fats: 0.2, servingSize: 150, category: .vegetable),
        FoodDTO(name: "Mushrooms", calories: 22, protein: 3.1, carbs: 3.3, fats: 0.3, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Asparagus", calories: 20, protein: 2.2, carbs: 3.9, fats: 0.1, servingSize: 100, category: .vegetable),
        FoodDTO(name: "Green Beans", calories: 31, protein: 1.8, carbs: 7, fats: 0.2, servingSize: 100, category: .vegetable),

        // Fruits
        FoodDTO(name: "Apple", calories: 52, protein: 0.3, carbs: 14, fats: 0.2, servingSize: 150, category: .fruit),
        FoodDTO(name: "Banana", calories: 89, protein: 1.1, carbs: 23, fats: 0.3, servingSize: 120, category: .fruit),
        FoodDTO(name: "Orange", calories: 47, protein: 0.9, carbs: 12, fats: 0.1, servingSize: 150, category: .fruit),
        FoodDTO(name: "Strawberry", calories: 32, protein: 0.7, carbs: 7.7, fats: 0.3, servingSize: 150, category: .fruit),
        FoodDTO(name: "Blueberry", calories: 57, protein: 0.7, carbs: 14, fats: 0.3, servingSize: 150, category: .fruit),
        FoodDTO(name: "Grape", calories: 69, protein: 0.7, carbs: 18, fats: 0.2, servingSize: 150, category: .fruit),
        FoodDTO(name: "Watermelon", calories: 30, protein: 0.6, carbs: 8, fats: 0.2, servingSize: 200, category: .fruit),
        FoodDTO(name: "Pineapple", calories: 50, protein: 0.5, carbs: 13, fats: 0.1, servingSize: 150, category: .fruit),
        FoodDTO(name: "Mango", calories: 60, protein: 0.8, carbs: 15, fats: 0.4, servingSize: 150, category: .fruit),
        FoodDTO(name: "Peach", calories: 39, protein: 0.9, carbs: 10, fats: 0.3, servingSize: 150, category: .fruit),
        FoodDTO(name: "Pear", calories: 57, protein: 0.4, carbs: 15, fats: 0.1, servingSize: 150, category: .fruit)
    ]
}
