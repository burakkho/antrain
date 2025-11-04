//
//  GoalDifferenceRow.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Extracted from SmartNutritionGoalsEditor.swift for better modularity
//

import SwiftUI

/// Row showing difference between original and new nutrition goal value
struct GoalDifferenceRow: View {
    let name: String
    let original: Double
    let new: Double
    let unit: String

    private var difference: Double {
        new - original
    }

    private var differenceColor: Color {
        if difference > 0 { return .green }
        if difference < 0 { return .red }
        return DSColors.textSecondary
    }

    var body: some View {
        HStack {
            Text(name)
                .font(DSTypography.body)
            Spacer()
            if abs(difference) > 0.5 {
                Text(difference > 0 ? "+\(Int(difference))" : "\(Int(difference))")
                    .font(DSTypography.body)
                    .fontWeight(.bold)
                    .foregroundStyle(differenceColor)
                Image(systemName: difference > 0 ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundStyle(differenceColor)
            } else {
                Text("No change")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }
}

#Preview {
    List {
        GoalDifferenceRow(name: "Calories", original: 2000, new: 2200, unit: "kcal")
        GoalDifferenceRow(name: "Protein", original: 150, new: 150, unit: "g")
        GoalDifferenceRow(name: "Carbs", original: 200, new: 180, unit: "g")
    }
}
