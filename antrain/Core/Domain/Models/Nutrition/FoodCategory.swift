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

    /// Localized display name
    var displayName: String {
        switch self {
        case .protein:
            return String(localized: "Protein", comment: "Food category: Protein")
        case .carb:
            return String(localized: "Carbohydrate", comment: "Food category: Carbohydrate")
        case .fat:
            return String(localized: "Fat", comment: "Food category: Fat")
        case .vegetable:
            return String(localized: "Vegetable", comment: "Food category: Vegetable")
        case .fruit:
            return String(localized: "Fruit", comment: "Food category: Fruit")
        case .dairy:
            return String(localized: "Dairy", comment: "Food category: Dairy")
        case .other:
            return String(localized: "Other", comment: "Food category: Other")
        }
    }
}
