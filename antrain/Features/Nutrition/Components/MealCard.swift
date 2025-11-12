//
//  MealCard.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI
import UniformTypeIdentifiers

/// Card displaying a meal with food entries
struct MealCard: View {
    let meal: Meal
    let mealType: Meal.MealType
    let onAddFood: () -> Void
    let onEditFood: (FoodEntry) -> Void
    let onRemoveFood: (FoodEntry) -> Void
    let onMoveFoodToMeal: (UUID, Meal.MealType, Meal.MealType) -> Void
    let onReorderFoods: (Int, Int) -> Void

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
                            Text("\(Int(totalCalories)) \(String(localized: "kcal")) • P: \(Int(totalProtein))\(String(localized: "g")) C: \(Int(totalCarbs))\(String(localized: "g")) F: \(Int(totalFats))\(String(localized: "g"))")
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
                        .dropDestination(for: FoodEntryTransfer.self) { items, _ in
                            handleDrop(items: items)
                            return true
                        }
                } else {
                    VStack(spacing: DSSpacing.xs) {
                        ForEach(Array(meal.foodEntries.enumerated()), id: \.element.id) { index, entry in
                            SwipeableFoodEntryRow(
                                entry: entry,
                                onEdit: { onEditFood(entry) },
                                onDelete: { onRemoveFood(entry) }
                            )
                            .draggable(FoodEntryTransfer(
                                entryId: entry.id,
                                sourceMealType: mealType
                            )) {
                                // Drag preview
                                HStack {
                                    Text(entry.foodItem?.name ?? "Food")
                                        .font(DSTypography.body)
                                        .padding(.horizontal, DSSpacing.sm)
                                        .padding(.vertical, DSSpacing.xs)
                                        .background(DSColors.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
                                }
                            }
                            .dropDestination(for: FoodEntryTransfer.self) { items, _ in
                                handleDrop(items: items, targetIndex: index)
                                return true
                            }
                        }
                        .onMove { from, to in
                            onReorderFoods(from.first ?? 0, to)
                        }
                    }
                    .dropDestination(for: FoodEntryTransfer.self) { items, _ in
                        handleDrop(items: items)
                        return true
                    }
                }
            }
        }
    }

    // MARK: - Drag & Drop Handling

    private func handleDrop(items: [FoodEntryTransfer], targetIndex: Int? = nil) {
        guard let item = items.first else { return }

        // Check if this is a cross-meal move or reorder within same meal
        if item.sourceMealType == mealType {
            // Reorder within same meal
            if let targetIndex = targetIndex,
               let sourceIndex = meal.foodEntries.firstIndex(where: { $0.id == item.entryId }) {
                onReorderFoods(sourceIndex, targetIndex)
            }
        } else {
            // Move to different meal
            onMoveFoodToMeal(item.entryId, item.sourceMealType, mealType)
        }
    }
}

// MARK: - Transferable Data

/// Transferable data for drag-and-drop operations
struct FoodEntryTransfer: Codable, Transferable {
    let entryId: UUID
    let sourceMealType: Meal.MealType

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: UTType(exportedAs: "com.antrain.foodentry"))
    }
}

#Preview {
    let meal = Meal(name: "Breakfast")
    VStack {
        MealCard(
            meal: meal,
            mealType: .breakfast,
            onAddFood: {},
            onEditFood: { _ in },
            onRemoveFood: { _ in },
            onMoveFoodToMeal: { _, _, _ in },
            onReorderFoods: { _, _ in }
        )
    }
    .padding()
}
