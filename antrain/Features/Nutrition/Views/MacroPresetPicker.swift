//
//  MacroPresetPicker.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Picker view for selecting macro presets
struct MacroPresetPicker: View {
    let currentCalories: Double
    let onPresetSelected: (_ protein: Double, _ carbs: Double, _ fats: Double) -> Void

    @State private var selectedPreset: MacroPreset?
    @State private var showingDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Presets")
                .font(DSTypography.body)
                .fontWeight(.bold)
                .foregroundStyle(DSColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MacroPreset.allPresets) { preset in
                        PresetButton(
                            preset: preset,
                            isSelected: selectedPreset?.id == preset.id,
                            action: {
                                selectedPreset = preset
                                applyPreset(preset)
                            }
                        )
                    }
                }
            }

            if let selected = selectedPreset {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(DSColors.textSecondary)
                    Text(selected.description)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
        }
    }

    private func applyPreset(_ preset: MacroPreset) {
        let macros = preset.calculateMacros(calories: currentCalories)
        onPresetSelected(macros.protein, macros.carbs, macros.fats)
    }
}

/// Individual preset button
private struct PresetButton: View {
    let preset: MacroPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(DSTypography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? .white : DSColors.textPrimary)

                HStack(spacing: 2) {
                    MacroIndicator(
                        color: .blue,
                        width: preset.proteinPercent * 60
                    )
                    MacroIndicator(
                        color: .orange,
                        width: preset.carbsPercent * 60
                    )
                    MacroIndicator(
                        color: .red,
                        width: preset.fatsPercent * 60
                    )
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? DSColors.primary : DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? DSColors.primary : DSColors.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Color indicator for macro distribution visualization
private struct MacroIndicator: View {
    let color: Color
    let width: Double

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        MacroPresetPicker(
            currentCalories: 2500,
            onPresetSelected: { protein, carbs, fats in
                print("Selected: P=\(protein)g, C=\(carbs)g, F=\(fats)g")
            }
        )
        .padding()
    }
}
