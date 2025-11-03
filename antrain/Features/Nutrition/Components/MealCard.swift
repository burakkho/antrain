//
//  MealCard.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Card displaying a meal with food entries
struct MealCard: View {
    let meal: Meal
    let onAddFood: () -> Void
    let onRemoveFood: (FoodEntry) -> Void

    var totalCalories: Double {
        meal.foodEntries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        meal.foodEntries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        meal.foodEntries.reduce(0) { $0 + $1.carbs }
    }

    var totalFats: Double {
        meal.foodEntries.reduce(0) { $0 + $1.fats }
    }

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.name)
                            .font(DSTypography.title3)
                            .foregroundStyle(DSColors.textPrimary)

                        if !meal.foodEntries.isEmpty {
                            Text("\(Int(totalCalories)) kcal • P: \(Int(totalProtein))g C: \(Int(totalCarbs))g F: \(Int(totalFats))g")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onAddFood) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DSColors.primary)
                    }
                }

                // Food entries
                if meal.foodEntries.isEmpty {
                    Text("No food logged")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textSecondary)
                        .padding(.vertical, DSSpacing.xs)
                } else {
                    VStack(spacing: DSSpacing.xs) {
                        ForEach(meal.foodEntries, id: \.id) { entry in
                            FoodEntryRow(
                                entry: entry,
                                onRemove: { onRemoveFood(entry) }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Food Entry Row
private struct FoodEntryRow: View {
    let entry: FoodEntry
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.foodItem?.name ?? "Unknown")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textPrimary)

                Text("\(Int(entry.servingAmount))g • \(Int(entry.calories)) kcal")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, DSSpacing.xxs)
    }
}

#Preview {
    let meal = Meal(name: "Breakfast")
    VStack {
        MealCard(
            meal: meal,
            onAddFood: {},
            onRemoveFood: { _ in }
        )
    }
    .padding()
}
