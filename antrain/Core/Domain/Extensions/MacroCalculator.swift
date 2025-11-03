//
//  MacroCalculator.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Pure calculation functions for macro and calorie conversions
enum MacroCalculator {
    // MARK: - Constants

    /// Calories per gram of protein
    static let caloriesPerGramProtein: Double = 4.0

    /// Calories per gram of carbohydrates
    static let caloriesPerGramCarbs: Double = 4.0

    /// Calories per gram of fats
    static let caloriesPerGramFats: Double = 9.0

    // MARK: - Macro to Calories

    /// Calculate total calories from macro grams
    /// - Parameters:
    ///   - protein: Protein in grams
    ///   - carbs: Carbohydrates in grams
    ///   - fats: Fats in grams
    /// - Returns: Total calories
    static func calculateCalories(protein: Double, carbs: Double, fats: Double) -> Double {
        return (protein * caloriesPerGramProtein) +
               (carbs * caloriesPerGramCarbs) +
               (fats * caloriesPerGramFats)
    }

    // MARK: - Calories to Macros

    /// Scale macros proportionally to match target calories
    /// - Parameters:
    ///   - currentProtein: Current protein in grams
    ///   - currentCarbs: Current carbs in grams
    ///   - currentFats: Current fats in grams
    ///   - targetCalories: Target total calories
    /// - Returns: Scaled macros (protein, carbs, fats) in grams, or nil if invalid
    static func scaleMacrosToCalories(
        currentProtein: Double,
        currentCarbs: Double,
        currentFats: Double,
        targetCalories: Double
    ) -> (protein: Double, carbs: Double, fats: Double)? {
        // Calculate current calories
        let currentCalories = calculateCalories(
            protein: currentProtein,
            carbs: currentCarbs,
            fats: currentFats
        )

        // Validate inputs
        guard currentCalories > 0, targetCalories > 0 else {
            return nil
        }

        // Calculate scaling factor
        let scaleFactor = targetCalories / currentCalories

        // Scale all macros
        return (
            protein: (currentProtein * scaleFactor).rounded(),
            carbs: (currentCarbs * scaleFactor).rounded(),
            fats: (currentFats * scaleFactor).rounded()
        )
    }

    // MARK: - Percentage Distribution

    /// Calculate percentage distribution of macros
    /// - Parameters:
    ///   - protein: Protein in grams
    ///   - carbs: Carbs in grams
    ///   - fats: Fats in grams
    /// - Returns: Percentages (protein, carbs, fats) as decimals (0.0-1.0)
    static func calculateMacroPercentages(
        protein: Double,
        carbs: Double,
        fats: Double
    ) -> (protein: Double, carbs: Double, fats: Double) {
        let totalCalories = calculateCalories(protein: protein, carbs: carbs, fats: fats)

        guard totalCalories > 0 else {
            return (0, 0, 0)
        }

        let proteinCalories = protein * caloriesPerGramProtein
        let carbsCalories = carbs * caloriesPerGramCarbs
        let fatsCalories = fats * caloriesPerGramFats

        return (
            protein: proteinCalories / totalCalories,
            carbs: carbsCalories / totalCalories,
            fats: fatsCalories / totalCalories
        )
    }

    // MARK: - Validation

    /// Validate that macro percentages sum to approximately 100%
    /// - Parameters:
    ///   - proteinPercent: Protein percentage (0.0-1.0)
    ///   - carbsPercent: Carbs percentage (0.0-1.0)
    ///   - fatsPercent: Fats percentage (0.0-1.0)
    ///   - tolerance: Acceptable deviation from 1.0 (default: 0.01 = 1%)
    /// - Returns: True if percentages are valid
    static func validateMacroPercentages(
        proteinPercent: Double,
        carbsPercent: Double,
        fatsPercent: Double,
        tolerance: Double = 0.01
    ) -> Bool {
        let sum = proteinPercent + carbsPercent + fatsPercent
        return abs(sum - 1.0) <= tolerance
    }
}
