//
//  ServingUnit.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Serving unit for food items (cup, tablespoon, piece, etc.)
@Model
final class ServingUnit {
    @Attribute(.unique) var id: UUID
    var unitType: ServingUnitType
    var gramsPerUnit: Double  // How many grams per unit
    var unitDescription: String   // Localized description (e.g., "1 cup" or "1 kase")
    var isDefault: Bool  // Is this the default unit for this food?
    var orderIndex: Int  // Display order in UI

    // Relationship
    var foodItem: FoodItem?

    init(
        unitType: ServingUnitType,
        gramsPerUnit: Double,
        description: String,
        isDefault: Bool = false,
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.unitType = unitType
        self.gramsPerUnit = gramsPerUnit
        self.unitDescription = description
        self.isDefault = isDefault
        self.orderIndex = orderIndex
    }
}

// MARK: - Serving Unit Type

enum ServingUnitType: String, Codable, CaseIterable {
    case serving = "serving"
    case gram = "gram"
    case ounce = "ounce"
    case cup = "cup"
    case tablespoon = "tablespoon"
    case teaspoon = "teaspoon"
    case piece = "piece"
    case slice = "slice"
    case scoop = "scoop"
    case container = "container"

    var displayName: String {
        switch self {
        case .serving: return String(localized: "Serving")
        case .gram: return String(localized: "Gram")
        case .ounce: return String(localized: "Ounce")
        case .cup: return String(localized: "Cup")
        case .tablespoon: return String(localized: "Tablespoon")
        case .teaspoon: return String(localized: "Teaspoon")
        case .piece: return String(localized: "Piece")
        case .slice: return String(localized: "Slice")
        case .scoop: return String(localized: "Scoop")
        case .container: return String(localized: "Container")
        }
    }
}

// MARK: - Display Helpers

extension ServingUnit {
    /// Get display text for weight based on user preference (kg/lbs)
    func displayWeight(using weightUnit: String) -> String {
        if weightUnit == "Pounds" {
            let ounces = gramsPerUnit / 28.35
            return String(format: "%.1foz", ounces)
        } else {
            return "\(Int(gramsPerUnit))g"
        }
    }

    /// Get full display text with unit name
    /// Example: "1 porsiyon (100g)" or "1 serving (3.5oz)"
    func fullDisplayText(using weightUnit: String) -> String {
        let weight = displayWeight(using: weightUnit)

        // If it's just gram/ounce, return only the weight
        if unitType == .gram || unitType == .ounce {
            return weight
        }

        // For other units, show name + weight
        return "\(unitDescription) (\(weight))"
    }

    /// Get unit description for display (respects kg/lbs preference)
    func displayDescription(weightUnit: String) -> String {
        // Gram unit changes based on preference
        if unitType == .gram {
            return weightUnit == "Pounds" ? "oz" : "g"
        }

        // Other units stay the same
        return unitDescription
    }

    /// Short display for segmented picker
    /// Example: "Porsiyon" or "Gram"
    var shortDisplay: String {
        // Remove "1 " prefix if exists
        if unitDescription.hasPrefix("1 ") {
            return String(unitDescription.dropFirst(2)).capitalized
        }

        return unitDescription.capitalized
    }
}
