//
//  FatFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Fat-rich foods (per 100g)
struct FatFoods {
    static let all: [FoodDTO] = [
        // Nuts
        FoodDTO(name: "Almonds", calories: 579, protein: 21, carbs: 22, fats: 50, servingSize: 28, category: .fat),
        FoodDTO(name: "Walnuts", calories: 654, protein: 15, carbs: 14, fats: 65, servingSize: 28, category: .fat),
        FoodDTO(name: "Cashews", calories: 553, protein: 18, carbs: 30, fats: 44, servingSize: 28, category: .fat),
        FoodDTO(name: "Peanuts", calories: 567, protein: 26, carbs: 16, fats: 49, servingSize: 28, category: .fat),
        FoodDTO(name: "Pistachios", calories: 560, protein: 20, carbs: 28, fats: 45, servingSize: 28, category: .fat),

        // Nut Butters
        FoodDTO(name: "Peanut Butter", calories: 588, protein: 25, carbs: 20, fats: 50, servingSize: 16, category: .fat),
        FoodDTO(name: "Almond Butter", calories: 614, protein: 21, carbs: 19, fats: 56, servingSize: 16, category: .fat),

        // Seeds
        FoodDTO(name: "Chia Seeds", calories: 486, protein: 17, carbs: 42, fats: 31, servingSize: 15, category: .fat),
        FoodDTO(name: "Flax Seeds", calories: 534, protein: 18, carbs: 29, fats: 42, servingSize: 15, category: .fat),
        FoodDTO(name: "Sunflower Seeds", calories: 584, protein: 21, carbs: 20, fats: 51, servingSize: 28, category: .fat),
        FoodDTO(name: "Pumpkin Seeds", calories: 559, protein: 30, carbs: 14, fats: 49, servingSize: 28, category: .fat),

        // Oils
        FoodDTO(name: "Olive Oil", calories: 884, protein: 0, carbs: 0, fats: 100, servingSize: 14, category: .fat),
        FoodDTO(name: "Coconut Oil", calories: 892, protein: 0, carbs: 0, fats: 100, servingSize: 14, category: .fat),
        FoodDTO(name: "Avocado Oil", calories: 884, protein: 0, carbs: 0, fats: 100, servingSize: 14, category: .fat),

        // Other
        FoodDTO(name: "Avocado", calories: 160, protein: 2, carbs: 9, fats: 15, servingSize: 150, category: .fat),
        FoodDTO(name: "Dark Chocolate (70%)", calories: 598, protein: 8, carbs: 46, fats: 43, servingSize: 30, category: .fat),
        FoodDTO(name: "Coconut (Fresh)", calories: 354, protein: 3.3, carbs: 15, fats: 33, servingSize: 80, category: .fat)
    ]
}
