import SwiftUI

/// Quick action button for home screen
struct QuickActionButton: View {
    let icon: String
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(DSColors.primary)

                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, DSSpacing.md)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: DSSpacing.md) {
        QuickActionButton(
            icon: "dumbbell.fill",
            title: "Start Workout"
        ) {}

        QuickActionButton(
            icon: "figure.run",
            title: "Log Cardio"
        ) {}

        QuickActionButton(
            icon: "fork.knife",
            title: "Log Meal"
        ) {}
    }
    .padding()
}
