import SwiftUI

/// Numeric input field with optional unit display
/// Usage: Weight, reps, calories, macros
struct DSNumberField: View {
    let title: String
    @Binding var value: Double
    var unit: String = ""
    var placeholder: String = "0"
    var format: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(0...1))

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            if !title.isEmpty {
                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textSecondary)
            }

            HStack {
                TextField(placeholder, value: $value, format: format)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(DSTypography.body)

                if !unit.isEmpty {
                    Text(unit)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
    }
}

// MARK: - Preview

#Preview("Number Field") {
    VStack(spacing: DSSpacing.lg) {
        DSNumberField(
            title: "Weight",
            value: .constant(80),
            unit: "kg"
        )

        DSNumberField(
            title: "Reps",
            value: .constant(10)
        )

        DSNumberField(
            title: "Distance",
            value: .constant(5.5),
            unit: "km",
            format: .number.precision(.fractionLength(1))
        )
    }
    .padding()
}
