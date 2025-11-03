//
//  MacroVisualFeedback.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Visual feedback showing macro distribution with progress bars
struct MacroVisualFeedback: View {
    let protein: Double  // in grams
    let carbs: Double    // in grams
    let fats: Double     // in grams

    private var proteinCalories: Double { protein * 4 }
    private var carbsCalories: Double { carbs * 4 }
    private var fatsCalories: Double { fats * 9 }
    private var totalCalories: Double { proteinCalories + carbsCalories + fatsCalories }

    private var proteinPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (proteinCalories / totalCalories) * 100
    }

    private var carbsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (carbsCalories / totalCalories) * 100
    }

    private var fatsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (fatsCalories / totalCalories) * 100
    }

    var body: some View {
        VStack(spacing: 12) {
            // Combined progress bar showing all macros
            HStack(spacing: 2) {
                if proteinPercentage > 0 {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: proteinPercentage * 3)
                }
                if carbsPercentage > 0 {
                    Rectangle()
                        .fill(.orange)
                        .frame(width: carbsPercentage * 3)
                }
                if fatsPercentage > 0 {
                    Rectangle()
                        .fill(.red)
                        .frame(width: fatsPercentage * 3)
                }
            }
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Individual macro breakdowns
            VStack(spacing: 8) {
                MacroRow(
                    name: "Protein",
                    grams: protein,
                    calories: proteinCalories,
                    percentage: proteinPercentage,
                    color: .blue
                )

                MacroRow(
                    name: "Carbs",
                    grams: carbs,
                    calories: carbsCalories,
                    percentage: carbsPercentage,
                    color: .orange
                )

                MacroRow(
                    name: "Fats",
                    grams: fats,
                    calories: fatsCalories,
                    percentage: fatsPercentage,
                    color: .red
                )
            }
        }
        .padding(12)
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Individual macro row with progress bar
private struct MacroRow: View {
    let name: String
    let grams: Double
    let calories: Double
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(name)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                Text("\(Int(grams))g")
                    .font(DSTypography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.textPrimary)

                Text("(\(Int(percentage))%)")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(DSColors.separator.opacity(0.3))
                        .frame(height: 6)

                    // Progress
                    Rectangle()
                        .fill(color)
                        .frame(
                            width: min(
                                (percentage / 100) * geometry.size.width,
                                geometry.size.width
                            ),
                            height: 6
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Compact Version

/// Compact version showing only combined progress bar
struct MacroVisualFeedbackCompact: View {
    let protein: Double
    let carbs: Double
    let fats: Double

    private var proteinCalories: Double { protein * 4 }
    private var carbsCalories: Double { carbs * 4 }
    private var fatsCalories: Double { fats * 9 }
    private var totalCalories: Double { proteinCalories + carbsCalories + fatsCalories }

    private var proteinPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (proteinCalories / totalCalories)
    }

    private var carbsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (carbsCalories / totalCalories)
    }

    private var fatsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (fatsCalories / totalCalories)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                if proteinPercentage > 0 {
                    Rectangle()
                        .fill(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                        .frame(width: proteinPercentage * UIScreen.main.bounds.width * 0.8)
                }
                if carbsPercentage > 0 {
                    Rectangle()
                        .fill(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                        .frame(width: carbsPercentage * UIScreen.main.bounds.width * 0.8)
                }
                if fatsPercentage > 0 {
                    Rectangle()
                        .fill(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                        .frame(width: fatsPercentage * UIScreen.main.bounds.width * 0.8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))

            HStack(spacing: 12) {
                MacroLabel(color: .blue, percentage: proteinPercentage * 100)
                MacroLabel(color: .orange, percentage: carbsPercentage * 100)
                MacroLabel(color: .red, percentage: fatsPercentage * 100)
            }
        }
    }
}

private struct MacroLabel: View {
    let color: Color
    let percentage: Double

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(Int(percentage))%")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview("Full") {
    MacroVisualFeedback(
        protein: 200,
        carbs: 250,
        fats: 70
    )
    .padding()
}

#Preview("Compact") {
    MacroVisualFeedbackCompact(
        protein: 200,
        carbs: 250,
        fats: 70
    )
    .padding()
}
