//
//  SwipeableFoodEntryRow.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Food entry row with iOS Mail-style swipe gestures for edit and delete
struct SwipeableFoodEntryRow: View {
    let entry: FoodEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offsetX: CGFloat = 0
    @State private var showActions: Bool = false

    private let actionButtonWidth: CGFloat = 70
    private let swipeThreshold: CGFloat = -50
    private let fullSwipeThreshold: CGFloat = -120

    var body: some View {
        ZStack(alignment: .trailing) {
            // Background actions (Edit and Delete buttons)
            if showActions {
                HStack(spacing: 0) {
                    // Edit button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            resetSwipe()
                        }
                        onEdit()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.title3)
                            Text("Edit")
                                .font(DSTypography.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: actionButtonWidth)
                        .frame(maxHeight: .infinity)
                    }
                    .background(DSColors.primary)

                    // Delete button
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.3)) {
                            resetSwipe()
                        }
                        onDelete()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.title3)
                            Text("Delete")
                                .font(DSTypography.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: actionButtonWidth)
                        .frame(maxHeight: .infinity)
                    }
                    .background(DSColors.error)
                }
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
            }

            // Main content
            HStack(spacing: DSSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.foodItem?.name ?? String(localized: "Unknown"))
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textPrimary)

                    Text("\(entry.displayAmount) • \(Int(entry.calories)) \(String(localized: "kcal"))")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                Spacer()

                // Visual indicator that item is swipeable
                Image(systemName: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(DSColors.textTertiary.opacity(0.3))
            }
            .padding(.vertical, DSSpacing.xs)
            .padding(.horizontal, DSSpacing.sm)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
            .offset(x: offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow left swipe
                        if value.translation.width < 0 {
                            let translation = value.translation.width
                            // Limit the swipe to the width of both buttons
                            offsetX = max(translation, -(actionButtonWidth * 2))
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.width

                        if translation < fullSwipeThreshold {
                            // Full swipe - reveal both buttons
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offsetX = -(actionButtonWidth * 2)
                                showActions = true
                            }
                            HapticManager.shared.impact(intensity: 0.5)
                        } else if translation < swipeThreshold {
                            // Partial swipe - reveal both buttons at threshold
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offsetX = -(actionButtonWidth * 2)
                                showActions = true
                            }
                            HapticManager.shared.impact(intensity: 0.5)
                        } else {
                            // Not enough swipe - reset
                            resetSwipe()
                        }
                    }
            )
        }
    }

    private func resetSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offsetX = 0
            showActions = false
        }
    }
}

#Preview {
    @Previewable @State var dummy = 0

    let gram = ServingUnit(
        unitType: .gram,
        gramsPerUnit: 1.0,
        description: "gram",
        isDefault: true
    )

    let chickenBreast = FoodItem(
        name: "Chicken Breast",
        calories: 165,
        protein: 31.0,
        carbs: 0,
        fats: 3.6,
        servingSize: 100,
        category: .protein,
        isCustom: false
    )
    chickenBreast.servingUnits.append(gram)

    let entry = FoodEntry(
        foodItem: chickenBreast,
        amount: 200,
        selectedUnit: gram
    )

    return VStack(spacing: DSSpacing.md) {
        SwipeableFoodEntryRow(
            entry: entry,
            onEdit: {
                print("Edit tapped")
            },
            onDelete: {
                print("Delete tapped")
            }
        )

        Text("← Swipe left to reveal actions")
            .font(DSTypography.caption)
            .foregroundStyle(DSColors.textSecondary)
    }
    .padding()
}
