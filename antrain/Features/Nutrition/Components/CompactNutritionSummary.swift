//
//  CompactNutritionSummary.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Compact card showing today's nutrition macro summary
/// Optimized for HomeView with tighter spacing (about 50% smaller than DailyNutritionSummary)
struct CompactNutritionSummary: View {
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
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Header - smaller font for compact design
            HStack {
                Text("Today's Nutrition")
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(DSColors.textTertiary)
            }

            // Macro Progress Bars - tighter spacing
            VStack(spacing: DSSpacing.xxs) {
                CompactMacroProgressBar(
                    title: "Calories",
                    current: calories,
                    goal: calorieGoal,
                    color: DSColors.primary,
                    unit: String(localized: "kcal")
                )

                CompactMacroProgressBar(
                    title: "Protein",
                    current: protein,
                    goal: proteinGoal,
                    color: .red,
                    unit: String(localized: "g")
                )

                CompactMacroProgressBar(
                    title: "Carbs",
                    current: carbs,
                    goal: carbsGoal,
                    color: .orange,
                    unit: String(localized: "g")
                )

                CompactMacroProgressBar(
                    title: "Fats",
                    current: fats,
                    goal: fatsGoal,
                    color: .yellow,
                    unit: String(localized: "g")
                )
            }
        }
        .padding(DSSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .onTapGesture {
            onTap()
        }
    }
}

/// Compact version of MacroProgressBar with smaller height and tighter spacing
private struct CompactMacroProgressBar: View {
    let title: LocalizedStringKey
    let current: Double
    let goal: Double
    let color: Color
    let unit: String

    var progress: Double {
        min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
            // Header
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)

                Spacer()

                Text("\(Int(current)) / \(Int(goal)) \(unit)")
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Progress bar - reduced height from 8pt to 6pt
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                        .fill(DSColors.backgroundSecondary)
                        .frame(height: 6)

                    // Progress
                    RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                        .fill(color)
                        .frame(
                            width: geometry.size.width * progress,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    CompactNutritionSummary(
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
