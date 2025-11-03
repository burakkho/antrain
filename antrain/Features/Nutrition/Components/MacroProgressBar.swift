//
//  MacroProgressBar.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Progress bar showing macro progress toward goal
struct MacroProgressBar: View {
    let title: String
    let current: Double
    let goal: Double
    let color: Color
    let unit: String

    var progress: Double {
        min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Header
            HStack {
                Text(title)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)

                Spacer()

                Text("\(Int(current)) / \(Int(goal)) \(unit)")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                        .fill(DSColors.backgroundSecondary)
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                        .fill(color)
                        .frame(
                            width: geometry.size.width * progress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.md) {
        MacroProgressBar(
            title: "Calories",
            current: 1850,
            goal: 2500,
            color: DSColors.primary,
            unit: "kcal"
        )

        MacroProgressBar(
            title: "Protein",
            current: 120,
            goal: 180,
            color: .red,
            unit: "g"
        )

        MacroProgressBar(
            title: "Carbs",
            current: 200,
            goal: 250,
            color: .orange,
            unit: "g"
        )

        MacroProgressBar(
            title: "Fats",
            current: 50,
            goal: 70,
            color: .yellow,
            unit: "g"
        )
    }
    .padding()
}
