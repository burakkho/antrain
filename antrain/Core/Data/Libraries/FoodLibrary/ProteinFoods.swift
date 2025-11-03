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
        FoodDTO(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fats: 3.6, servingSize: 150, category: .protein),
        FoodDTO(name: "Chicken Thigh", calories: 209, protein: 26, carbs: 0, fats: 11, servingSize: 150, category: .protein),
        FoodDTO(name: "Turkey Breast", calories: 135, protein: 30, carbs: 0, fats: 0.7, servingSize: 150, category: .protein),
        FoodDTO(name: "Ground Turkey", calories: 149, protein: 21, carbs: 0, fats: 6.6, servingSize: 100, category: .protein),

        // Meat
        FoodDTO(name: "Lean Beef (95%)", calories: 137, protein: 21, carbs: 0, fats: 5, servingSize: 100, category: .protein),
        FoodDTO(name: "Ground Beef (85%)", calories: 215, protein: 18, carbs: 0, fats: 15, servingSize: 100, category: .protein),
        FoodDTO(name: "Pork Tenderloin", calories: 143, protein: 26, carbs: 0, fats: 3.5, servingSize: 100, category: .protein),
        FoodDTO(name: "Lamb", calories: 258, protein: 25, carbs: 0, fats: 17, servingSize: 100, category: .protein),

        // Seafood
        FoodDTO(name: "Salmon", calories: 208, protein: 20, carbs: 0, fats: 13, servingSize: 150, category: .protein),
        FoodDTO(name: "Tuna", calories: 130, protein: 29, carbs: 0, fats: 0.9, servingSize: 100, category: .protein),
        FoodDTO(name: "Tilapia", calories: 129, protein: 26, carbs: 0, fats: 2.7, servingSize: 150, category: .protein),
        FoodDTO(name: "Cod", calories: 82, protein: 18, carbs: 0, fats: 0.7, servingSize: 150, category: .protein),
        FoodDTO(name: "Shrimp", calories: 99, protein: 24, carbs: 0.2, fats: 0.3, servingSize: 100, category: .protein),
        FoodDTO(name: "Sardines", calories: 208, protein: 25, carbs: 0, fats: 11, servingSize: 80, category: .protein),

        // Eggs & Dairy
        FoodDTO(name: "Whole Egg", calories: 155, protein: 13, carbs: 1.1, fats: 11, servingSize: 50, category: .protein),
        FoodDTO(name: "Egg Whites", calories: 52, protein: 11, carbs: 0.7, fats: 0.2, servingSize: 60, category: .protein),
        FoodDTO(name: "Greek Yogurt (Plain)", calories: 59, protein: 10, carbs: 3.6, fats: 0.4, servingSize: 170, category: .protein),
        FoodDTO(name: "Cottage Cheese (Low Fat)", calories: 72, protein: 12, carbs: 3.4, fats: 1, servingSize: 100, category: .protein),
        FoodDTO(name: "Cheddar Cheese", calories: 403, protein: 25, carbs: 1.3, fats: 33, servingSize: 30, category: .protein),
        FoodDTO(name: "Mozzarella Cheese", calories: 280, protein: 28, carbs: 2.2, fats: 17, servingSize: 30, category: .protein),

        // Legumes
        FoodDTO(name: "Lentils (Cooked)", calories: 116, protein: 9, carbs: 20, fats: 0.4, servingSize: 200, category: .protein),
        FoodDTO(name: "Chickpeas (Cooked)", calories: 164, protein: 9, carbs: 27, fats: 2.6, servingSize: 150, category: .protein),
        FoodDTO(name: "Black Beans (Cooked)", calories: 132, protein: 9, carbs: 24, fats: 0.5, servingSize: 150, category: .protein),
        FoodDTO(name: "Kidney Beans (Cooked)", calories: 127, protein: 9, carbs: 23, fats: 0.5, servingSize: 150, category: .protein),
        FoodDTO(name: "Edamame", calories: 122, protein: 11, carbs: 10, fats: 5, servingSize: 100, category: .protein),

        // Tofu & Tempeh
        FoodDTO(name: "Tofu (Firm)", calories: 144, protein: 17, carbs: 2.3, fats: 9, servingSize: 100, category: .protein),
        FoodDTO(name: "Tempeh", calories: 193, protein: 20, carbs: 9, fats: 11, servingSize: 100, category: .protein),
        FoodDTO(name: "Seitan", calories: 370, protein: 75, carbs: 14, fats: 1.9, servingSize: 100, category: .protein),

        // Protein Powder
        FoodDTO(name: "Whey Protein Powder", calories: 400, protein: 80, carbs: 8, fats: 5, servingSize: 30, category: .protein),
        FoodDTO(name: "Casein Protein Powder", calories: 380, protein: 78, carbs: 8, fats: 3, servingSize: 30, category: .protein),
        FoodDTO(name: "Pea Protein Powder", calories: 380, protein: 80, carbs: 7, fats: 5, servingSize: 30, category: .protein)
    ]
}
