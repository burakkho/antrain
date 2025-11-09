import SwiftUI

/// Reusable modifier chip for displaying intensity/volume adjustments
struct ModifierChipView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: DSSpacing.xs)
                .fill(color.opacity(0.1))
        }
    }
}

#Preview {
    HStack(spacing: DSSpacing.md) {
        ModifierChipView(
            icon: "bolt.fill",
            label: "Intensity",
            value: "+10%",
            color: .orange
        )

        ModifierChipView(
            icon: "chart.bar.fill",
            label: "Volume",
            value: "-20%",
            color: .green
        )

        HStack(spacing: 4) {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.green)
            Text("Deload")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: DSSpacing.xs)
                .fill(Color.green.opacity(0.1))
        }
    }
    .padding()
}
