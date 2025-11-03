//
//  DailyNutritionSummary.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Reusable card showing today's nutrition macro summary
/// Can be used in HomeView, Nutrition tab, or anywhere else
struct DailyNutritionSummary: View {
    let calories: Double
    let calorieGoal: Double
    let protein: Double
    let proteinGoal: Double
    let carbs: Double
    let carbsGoal: Double
    let fats: Double
    let fatsGoal: Double
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header
            HStack {
                Text("Today's Nutrition")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }

            // Macro Progress Bars
            VStack(spacing: DSSpacing.sm) {
                MacroProgressBar(
                    title: "Calories",
                    current: calories,
                    goal: calorieGoal,
                    color: DSColors.primary,
                    unit: "kcal"
                )

                MacroProgressBar(
                    title: "Protein",
                    current: protein,
                    goal: proteinGoal,
                    color: .red,
                    unit: "g"
                )

                MacroProgressBar(
                    title: "Carbs",
                    current: carbs,
                    goal: carbsGoal,
                    color: .orange,
                    unit: "g"
                )

                MacroProgressBar(
                    title: "Fats",
                    current: fats,
                    goal: fatsGoal,
                    color: .yellow,
                    unit: "g"
                )
            }
        }
        .padding(DSSpacing.md)
        .background(DSColors.cardBackground)
        .cornerRadius(DSCornerRadius.lg)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    DailyNutritionSummary(
        calories: 1450,
        calorieGoal: 2000,
        protein: 85,
        proteinGoal: 150,
        carbs: 150,
        carbsGoal: 200,
        fats: 45,
        fatsGoal: 65,
        onTap: {}
    )
    .padding()
}
