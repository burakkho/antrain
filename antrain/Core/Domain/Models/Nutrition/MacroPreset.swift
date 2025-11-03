//
//  MacroPreset.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset macro distribution ratios for quick selection
struct MacroPreset: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let proteinPercent: Double  // Percentage of total calories
    let carbsPercent: Double
    let fatsPercent: Double
    let description: String

    /// Calculate macro grams from total calories
    /// - Parameter calories: Total daily calories
    /// - Returns: Tuple of (protein, carbs, fats) in grams
    nonisolated func calculateMacros(calories: Double) -> (protein: Double, carbs: Double, fats: Double) {
        let proteinCalories = calories * proteinPercent
        let carbsCalories = calories * carbsPercent
        let fatsCalories = calories * fatsPercent

        return (
            protein: (proteinCalories / 4.0).rounded(),
            carbs: (carbsCalories / 4.0).rounded(),
            fats: (fatsCalories / 9.0).rounded()
        )
    }

    // MARK: - Preset Library

    static let balanced = MacroPreset(
        name: "Balanced",
        proteinPercent: 0.30,
        carbsPercent: 0.40,
        fatsPercent: 0.30,
        description: "30% P / 40% C / 30% F - General fitness"
    )

    static let highProtein = MacroPreset(
        name: "High Protein",
        proteinPercent: 0.40,
        carbsPercent: 0.30,
        fatsPercent: 0.30,
        description: "40% P / 30% C / 30% F - Muscle building"
    )

    static let keto = MacroPreset(
        name: "Keto",
        proteinPercent: 0.30,
        carbsPercent: 0.05,
        fatsPercent: 0.65,
        description: "30% P / 5% C / 65% F - Ketogenic diet"
    )

    static let lowCarb = MacroPreset(
        name: "Low Carb",
        proteinPercent: 0.35,
        carbsPercent: 0.20,
        fatsPercent: 0.45,
        description: "35% P / 20% C / 45% F - Fat loss"
    )

    static let endurance = MacroPreset(
        name: "Endurance",
        proteinPercent: 0.20,
        carbsPercent: 0.55,
        fatsPercent: 0.25,
        description: "20% P / 55% C / 25% F - Cardio performance"
    )

    static let allPresets: [MacroPreset] = [
        .balanced,
        .highProtein,
        .keto,
        .lowCarb,
        .endurance
    ]
}
