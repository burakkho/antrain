//
//  TDEECalculator.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftUI

/// TDEE (Total Daily Energy Expenditure) Calculator
/// Uses Mifflin-St Jeor formula for BMR calculation
struct TDEECalculator {

    // MARK: - Activity Level

    /// Physical activity levels with corresponding multipliers
    enum ActivityLevel: String, CaseIterable, Identifiable, Codable, Sendable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extraActive = "Extra Active"

        var id: String { rawValue }

        var localizedName: LocalizedStringKey {
            switch self {
            case .sedentary:
                return "Sedentary"
            case .lightlyActive:
                return "Lightly Active"
            case .moderatelyActive:
                return "Moderately Active"
            case .veryActive:
                return "Very Active"
            case .extraActive:
                return "Extra Active"
            }
        }

        /// Activity multiplier for TDEE calculation
        nonisolated var multiplier: Double {
            switch self {
            case .sedentary:        return 1.2   // Little or no exercise
            case .lightlyActive:    return 1.375 // Exercise 1-3 days/week
            case .moderatelyActive: return 1.55  // Exercise 3-5 days/week
            case .veryActive:       return 1.725 // Exercise 6-7 days/week
            case .extraActive:      return 1.9   // Very hard exercise & physical job
            }
        }

        /// Description of activity level
        nonisolated var description: String {
            switch self {
            case .sedentary:
                return "Little or no exercise"
            case .lightlyActive:
                return "Exercise 1-3 days/week"
            case .moderatelyActive:
                return "Exercise 3-5 days/week"
            case .veryActive:
                return "Exercise 6-7 days/week"
            case .extraActive:
                return "Very hard exercise & physical job"
            }
        }
    }

    // MARK: - Goal Type

    /// Fitness goal affecting calorie recommendations
    enum GoalType: String, CaseIterable, Identifiable, Sendable {
        case cut = "Cut"
        case maintain = "Maintain"
        case bulk = "Bulk"

        var id: String { rawValue }

        var localizedName: LocalizedStringKey {
            switch self {
            case .cut:
                return "Cut"
            case .maintain:
                return "Maintain"
            case .bulk:
                return "Bulk"
            }
        }

        /// Calorie adjustment from TDEE
        nonisolated var calorieAdjustment: Double {
            switch self {
            case .cut:      return -500  // Lose ~0.5kg per week
            case .maintain: return 0     // Maintain current weight
            case .bulk:     return +500  // Gain ~0.5kg per week
            }
        }

        var description: String {
            switch self {
            case .cut:
                return "Lose weight (~0.5kg/week)"
            case .maintain:
                return "Maintain current weight"
            case .bulk:
                return "Gain muscle (~0.5kg/week)"
            }
        }
    }

    // MARK: - BMR Calculation

    /// Calculate Basal Metabolic Rate using Mifflin-St Jeor formula
    /// Most accurate modern formula (±10% accuracy)
    ///
    /// Formula:
    /// - Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) + 5
    /// - Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) - 161
    ///
    /// - Parameters:
    ///   - weight: Weight in kilograms
    ///   - height: Height in centimeters
    ///   - age: Age in years
    ///   - gender: Gender for formula selection
    /// - Returns: BMR in calories per day
    nonisolated static func calculateBMR(
        weight: Double,
        height: Double,
        age: Int,
        gender: UserProfile.Gender
    ) -> Double {
        let baseBMR = 10 * weight + 6.25 * height - 5 * Double(age)

        switch gender {
        case .male:
            return baseBMR + 5
        case .female:
            return baseBMR - 161
        case .other, .preferNotToSay:
            // Use average of male and female formulas
            return baseBMR - 78
        }
    }

    // MARK: - TDEE Calculation

    /// Calculate Total Daily Energy Expenditure
    /// TDEE = BMR × Activity Level Multiplier
    ///
    /// - Parameters:
    ///   - weight: Weight in kilograms
    ///   - height: Height in centimeters
    ///   - age: Age in years
    ///   - gender: Gender for BMR calculation
    ///   - activityLevel: Physical activity level
    /// - Returns: TDEE in calories per day
    nonisolated static func calculateTDEE(
        weight: Double,
        height: Double,
        age: Int,
        gender: UserProfile.Gender,
        activityLevel: ActivityLevel
    ) -> Double {
        let bmr = calculateBMR(
            weight: weight,
            height: height,
            age: age,
            gender: gender
        )

        return bmr * activityLevel.multiplier
    }

    // MARK: - Goal-Based Recommendations

    /// Calculate recommended daily calories based on goal
    ///
    /// - Parameters:
    ///   - tdee: Calculated TDEE
    ///   - goal: Fitness goal (cut, maintain, bulk)
    /// - Returns: Recommended daily calories
    nonisolated static func recommendedCalories(
        tdee: Double,
        goal: GoalType
    ) -> Double {
        return tdee + goal.calorieAdjustment
    }

    /// Calculate all three goal recommendations at once
    ///
    /// - Parameter tdee: Calculated TDEE
    /// - Returns: Dictionary of goal types to recommended calories
    nonisolated static func allGoalRecommendations(
        tdee: Double
    ) -> [GoalType: Double] {
        return [
            .cut: recommendedCalories(tdee: tdee, goal: .cut),
            .maintain: recommendedCalories(tdee: tdee, goal: .maintain),
            .bulk: recommendedCalories(tdee: tdee, goal: .bulk)
        ]
    }

    // MARK: - Macro Recommendations

    /// Recommended macro split for a given goal and calorie target
    ///
    /// - Parameters:
    ///   - calories: Target daily calories
    ///   - weight: Body weight in kg (for protein calculation)
    ///   - goal: Fitness goal
    /// - Returns: Tuple of (protein, carbs, fats) in grams
    nonisolated static func recommendedMacros(
        calories: Double,
        weight: Double,
        goal: GoalType
    ) -> (protein: Double, carbs: Double, fats: Double) {
        // Protein target: 2.0-2.2g per kg body weight for all goals
        let protein = weight * 2.0

        // Fat percentage varies by goal
        let fatPercentage: Double
        switch goal {
        case .cut:
            fatPercentage = 0.25  // 25% for cut (hormone support)
        case .maintain:
            fatPercentage = 0.30  // 30% for maintenance
        case .bulk:
            fatPercentage = 0.25  // 25% for bulk (more room for carbs)
        }

        // Calculate fats in grams (9 cal per gram)
        let fatCalories = calories * fatPercentage
        let fats = fatCalories / 9.0

        // Remaining calories go to carbs (4 cal per gram)
        let proteinCalories = protein * 4.0
        let carbCalories = calories - proteinCalories - fatCalories
        let carbs = carbCalories / 4.0

        return (
            protein: protein.rounded(),
            carbs: max(0, carbs.rounded()),
            fats: fats.rounded()
        )
    }
}

// MARK: - Gender Extension

extension UserProfile.Gender {
    /// Display name for gender in TDEE context
    var tdeeDisplayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        case .preferNotToSay:
            return "Prefer not to say"
        }
    }
}
