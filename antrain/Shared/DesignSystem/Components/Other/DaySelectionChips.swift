//
//  DaySelectionChips.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import SwiftUI

/// Multi-select chip component for day of week selection
/// Displays days as horizontal scrollable chips (M, T, W, Th, F, S, Su)
struct DaySelectionChips: View {
    @Binding var selectedDays: Set<Int>

    private let days: [(number: Int, short: String)] = [
        (2, "M"),   // Monday
        (3, "T"),   // Tuesday
        (4, "W"),   // Wednesday
        (5, "Th"),  // Thursday
        (6, "F"),   // Friday
        (7, "S"),   // Saturday
        (1, "Su")   // Sunday
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(days, id: \.number) { day in
                    DayChip(
                        label: day.short,
                        isSelected: selectedDays.contains(day.number),
                        action: {
                            toggleDay(day.number)
                        }
                    )
                }
            }
            .padding(.horizontal, DSSpacing.xs)
        }
    }

    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

// MARK: - Day Chip

private struct DayChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DSTypography.body)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : DSColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DSColors.primary, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Day Selection Chips") {
    VStack(spacing: DSSpacing.lg) {
        Text("Select Active Days")
            .font(DSTypography.headline)

        DaySelectionChips(selectedDays: .constant([2, 4, 6])) // Mon, Wed, Fri

        Spacer()
    }
    .padding()
}

#Preview("All Days Selected") {
    VStack(spacing: DSSpacing.lg) {
        Text("Select Active Days")
            .font(DSTypography.headline)

        DaySelectionChips(selectedDays: .constant(Set(1...7)))

        Spacer()
    }
    .padding()
}

#Preview("No Days Selected") {
    VStack(spacing: DSSpacing.lg) {
        Text("Select Active Days")
            .font(DSTypography.headline)

        DaySelectionChips(selectedDays: .constant([]))

        Spacer()
    }
    .padding()
}
