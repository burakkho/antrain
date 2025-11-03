//
//  FoodCategory.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Food category for classification
enum FoodCategory: String, Codable, CaseIterable {
    case protein = "Protein"
    case carb = "Carbohydrate"
    case fat = "Fat"
    case vegetable = "Vegetable"
    case fruit = "Fruit"
    case dairy = "Dairy"
    case other = "Other"
}
