import SwiftUI

/// Reusable stat item view with icon, value, and label
struct StatItemView: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = DSColors.primary

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(iconColor)
            Text(value)
                .font(DSTypography.body)
                .fontWeight(.semibold)
            Text(label)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HStack(spacing: DSSpacing.xl) {
        StatItemView(
            icon: "dumbbell.fill",
            value: "5",
            label: "Exercises"
        )

        StatItemView(
            icon: "number",
            value: "15",
            label: "Sets"
        )

        StatItemView(
            icon: "clock",
            value: "45 min",
            label: "Duration"
        )
    }
    .padding()
}
