//
//  MacroSliderField.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Interactive macro input with slider, stepper buttons, and text field
struct MacroSliderField: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let color: Color

    @State private var textValue: String = ""
    @State private var isEditingText: Bool = false
    @State private var showValidationError: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...500,
        step: Double = 1,
        unit: String = "g",
        color: Color = .blue
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
        self.color = color
        self._textValue = State(initialValue: String(Int(value.wrappedValue)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Header with title and value
            HStack {
                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                // Value display with text field
                TextField("", text: $textValue)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(DSTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(showValidationError ? DSColors.error : color)
                    .frame(width: 70)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(
                        RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                            .fill(DSColors.backgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                                    .strokeBorder(
                                        showValidationError ? DSColors.error : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onChange(of: textValue) { _, newValue in
                        validateAndUpdate(newValue)
                    }
                    .onChange(of: isTextFieldFocused) { _, isFocused in
                        if !isFocused {
                            // When focus is lost, ensure value is synced
                            textValue = String(Int(value))
                            showValidationError = false
                        }
                    }

                Text(unit)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Slider with stepper buttons
            HStack(spacing: DSSpacing.sm) {
                // Decrement button
                Button(action: {
                    decrementValue()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(value > range.lowerBound ? color : DSColors.textTertiary)
                }
                .disabled(value <= range.lowerBound)

                // Slider
                Slider(value: $value, in: range, step: step)
                    .tint(color)
                    .onChange(of: value) { _, newValue in
                        // Update text field when slider changes
                        if !isTextFieldFocused {
                            textValue = String(Int(newValue))
                        }
                    }

                // Increment button
                Button(action: {
                    incrementValue()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(value < range.upperBound ? color : DSColors.textTertiary)
                }
                .disabled(value >= range.upperBound)
            }

            // Range indicator
            HStack {
                Text("\(Int(range.lowerBound))\(unit)")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textTertiary)

                Spacer()

                Text("\(Int(range.upperBound))\(unit)")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(DSColors.cardBackground)
        )
    }

    // MARK: - Actions

    private func incrementValue() {
        let newValue = min(value + step, range.upperBound)
        value = newValue
        textValue = String(Int(newValue))
    }

    private func decrementValue() {
        let newValue = max(value - step, range.lowerBound)
        value = newValue
        textValue = String(Int(newValue))
    }

    private func validateAndUpdate(_ text: String) {
        // Allow empty during editing
        if text.isEmpty {
            showValidationError = false
            return
        }

        guard let numValue = Double(text) else {
            showValidationError = true
            return
        }

        // Check if within range
        if numValue < range.lowerBound || numValue > range.upperBound {
            showValidationError = true
            return
        }

        // Valid value
        showValidationError = false
        value = numValue
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.lg) {
        MacroSliderField(
            title: "Protein",
            value: .constant(150),
            range: 0...500,
            step: 5,
            unit: "g",
            color: .red
        )

        MacroSliderField(
            title: "Carbs",
            value: .constant(200),
            range: 0...500,
            step: 5,
            unit: "g",
            color: .orange
        )

        MacroSliderField(
            title: "Fats",
            value: .constant(65),
            range: 0...200,
            step: 1,
            unit: "g",
            color: .yellow
        )
    }
    .padding()
}
