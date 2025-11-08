//
//  MacroDistributionChart.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Visual representation of macro distribution with pie chart
struct MacroDistributionChart: View {
    let protein: Double
    let carbs: Double
    let fats: Double
    let totalCalories: Int

    // Calculate percentages
    private var totalGrams: Double {
        protein + carbs + fats
    }

    private var proteinPercentage: Double {
        guard totalGrams > 0 else { return 0 }
        return (protein / totalGrams) * 100
    }

    private var carbsPercentage: Double {
        guard totalGrams > 0 else { return 0 }
        return (carbs / totalGrams) * 100
    }

    private var fatsPercentage: Double {
        guard totalGrams > 0 else { return 0 }
        return (fats / totalGrams) * 100
    }

    // Calculate calorie percentages
    private var proteinCalories: Int {
        Int(protein * 4)
    }

    private var carbsCalories: Int {
        Int(carbs * 4)
    }

    private var fatsCalories: Int {
        Int(fats * 9)
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Pie Chart
            ZStack {
                // Protein slice
                PieSlice(
                    startAngle: .degrees(0),
                    endAngle: .degrees(proteinPercentage * 3.6)
                )
                .fill(.red)

                // Carbs slice
                PieSlice(
                    startAngle: .degrees(proteinPercentage * 3.6),
                    endAngle: .degrees((proteinPercentage + carbsPercentage) * 3.6)
                )
                .fill(.orange)

                // Fats slice
                PieSlice(
                    startAngle: .degrees((proteinPercentage + carbsPercentage) * 3.6),
                    endAngle: .degrees(360)
                )
                .fill(.yellow)

                // Center label
                VStack(spacing: 2) {
                    Text("\(totalCalories)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(DSColors.textPrimary)

                    Text("kcal")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .frame(width: 180, height: 180)

            // Legend
            VStack(spacing: DSSpacing.sm) {
                MacroLegendRow(
                    color: .red,
                    name: "Protein",
                    grams: Int(protein),
                    calories: proteinCalories,
                    percentage: proteinPercentage
                )

                MacroLegendRow(
                    color: .orange,
                    name: "Carbs",
                    grams: Int(carbs),
                    calories: carbsCalories,
                    percentage: carbsPercentage
                )

                MacroLegendRow(
                    color: .yellow,
                    name: "Fats",
                    grams: Int(fats),
                    calories: fatsCalories,
                    percentage: fatsPercentage
                )
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                .fill(DSColors.cardBackground)
        )
    }
}

// MARK: - Pie Slice Shape

private struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle - .degrees(90),
            endAngle: endAngle - .degrees(90),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Legend Row

private struct MacroLegendRow: View {
    let color: Color
    let name: String
    let grams: Int
    let calories: Int
    let percentage: Double

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Color indicator
            RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                .fill(color)
                .frame(width: 12, height: 12)

            // Macro name
            Text(name)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textPrimary)
                .frame(width: 60, alignment: .leading)

            Spacer()

            // Grams
            Text("\(grams)g")
                .font(DSTypography.body)
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textPrimary)
                .frame(width: 50, alignment: .trailing)

            // Calories
            Text("\(calories) kcal")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
                .frame(width: 70, alignment: .trailing)

            // Percentage
            Text(String(format: "%.0f%%", percentage))
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textTertiary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.lg) {
        MacroDistributionChart(
            protein: 150,
            carbs: 200,
            fats: 65,
            totalCalories: 1985
        )

        MacroDistributionChart(
            protein: 180,
            carbs: 250,
            fats: 70,
            totalCalories: 2270
        )
    }
    .padding()
}
