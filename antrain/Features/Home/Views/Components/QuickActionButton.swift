import SwiftUI

/// Quick action button for home screen
struct QuickActionButton: View {
    let icon: String
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: {
            // Medium impact haptic for satisfying tap feel
            HapticManager.shared.medium()

            action()
        }) {
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
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
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
