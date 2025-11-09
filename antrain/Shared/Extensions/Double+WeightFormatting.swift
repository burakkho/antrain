//
//  Double+WeightFormatting.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

extension Double {
    /// Convert kg to lbs
    nonisolated func kgToLbs() -> Double {
        return self * 2.20462
    }

    /// Convert lbs to kg
    nonisolated func lbsToKg() -> Double {
        return self / 2.20462
    }

    /// Convert grams to ounces
    nonisolated func gramsToOz() -> Double {
        return self * 0.035274
    }

    /// Convert ounces to grams
    nonisolated func ozToGrams() -> Double {
        return self / 0.035274
    }

    /// Convert km to miles
    nonisolated func kmToMiles() -> Double {
        return self * 0.621371
    }

    /// Convert miles to km
    nonisolated func milesToKm() -> Double {
        return self / 0.621371
    }

    /// Format distance based on unit preference
    /// - Parameter unit: "Kilograms" or "Pounds" (determines km vs miles)
    /// - Returns: Formatted distance string (e.g., "5.00 km" or "3.11 mi")
    nonisolated func formattedDistance(unit: String) -> String {
        let displayDistance = unit == "Pounds" ? self.kmToMiles() : self
        let formatted = String(format: "%.2f", displayDistance)
        let unitSymbol = unit == "Pounds" ? "mi" : "km"
        return "\(formatted) \(unitSymbol)"
    }

    /// Get distance unit symbol
    /// - Parameter unit: "Kilograms" or "Pounds"
    /// - Returns: "km" or "mi"
    nonisolated static func distanceUnitSymbol(_ unit: String) -> String {
        return unit == "Pounds" ? "mi" : "km"
    }

    /// Format weight based on unit preference
    /// - Parameter unit: "Kilograms" or "Pounds"
    /// - Returns: Formatted weight string (e.g., "100 kg" or "220 lbs")
    nonisolated func formattedWeight(unit: String) -> String {
        let displayWeight = unit == "Pounds" ? self.kgToLbs() : self
        let formatted = String(format: "%.0f", displayWeight)
        let unitSymbol = unit == "Pounds" ? "lbs" : "kg"
        return "\(formatted) \(unitSymbol)"
    }

    /// Get weight unit symbol
    /// - Parameter unit: "Kilograms" or "Pounds"
    /// - Returns: "kg" or "lbs"
    nonisolated static func weightUnitSymbol(_ unit: String) -> String {
        return unit == "Pounds" ? "lbs" : "kg"
    }

    // MARK: - Height Formatting

    /// Convert cm to inches
    nonisolated func cmToInches() -> Double {
        return self / 2.54
    }

    /// Convert inches to cm
    nonisolated func inchesToCm() -> Double {
        return self * 2.54
    }

    /// Format height based on unit preference
    /// - Parameter unit: "Kilograms" or "Pounds" (determines cm vs inches)
    /// - Returns: Formatted height string (e.g., "175 cm" or "5'9\"")
    nonisolated func formattedHeight(unit: String) -> String {
        if unit == "Pounds" {
            // Imperial: feet and inches
            let totalInches = self.cmToInches()
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
        } else {
            // Metric: centimeters
            return String(format: "%.0f cm", self)
        }
    }
}
