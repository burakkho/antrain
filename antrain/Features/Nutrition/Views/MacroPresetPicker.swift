//
//  MacroPresetPicker.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Preset macro distribution ratios for quick selection
struct MacroPreset: Identifiable {
    let id = UUID()
    let name: String
    let proteinPercent: Double  // Percentage of total calories
    let carbsPercent: Double
    let fatsPercent: Double
    let description: String

    /// Calculate macro grams from total calories
    /// - Parameter calories: Total daily calories
    /// - Returns: Tuple of (protein, carbs, fats) in grams
    func calculateMacros(calories: Double) -> (protein: Double, carbs: Double, fats: Double) {
        let proteinCalories = calories * proteinPercent
        let carbsCalories = calories * carbsPercent
        let fatsCalories = calories * fatsPercent

        return (
            protein: (proteinCalories / 4.0).rounded(),
            carbs: (carbsCalories / 4.0).rounded(),
            fats: (fatsCalories / 9.0).rounded()
        )
    }

    // MARK: - Preset Library

    static let balanced = MacroPreset(
        name: "Balanced",
        proteinPercent: 0.30,
        carbsPercent: 0.40,
        fatsPercent: 0.30,
        description: "30% P / 40% C / 30% F - General fitness"
    )

    static let highProtein = MacroPreset(
        name: "High Protein",
        proteinPercent: 0.40,
        carbsPercent: 0.30,
        fatsPercent: 0.30,
        description: "40% P / 30% C / 30% F - Muscle building"
    )

    static let keto = MacroPreset(
        name: "Keto",
        proteinPercent: 0.30,
        carbsPercent: 0.05,
        fatsPercent: 0.65,
        description: "30% P / 5% C / 65% F - Ketogenic diet"
    )

    static let lowCarb = MacroPreset(
        name: "Low Carb",
        proteinPercent: 0.35,
        carbsPercent: 0.20,
        fatsPercent: 0.45,
        description: "35% P / 20% C / 45% F - Fat loss"
    )

    static let endurance = MacroPreset(
        name: "Endurance",
        proteinPercent: 0.20,
        carbsPercent: 0.55,
        fatsPercent: 0.25,
        description: "20% P / 55% C / 25% F - Cardio performance"
    )

    static let allPresets: [MacroPreset] = [
        .balanced,
        .highProtein,
        .keto,
        .lowCarb,
        .endurance
    ]
}

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
