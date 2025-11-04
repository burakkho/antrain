import SwiftUI

/// Empty state view with icon, title, message, and optional action
/// Usage: No data scenarios, empty lists
struct DSEmptyState: View {
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(DSColors.textTertiary)

            VStack(spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.title2)
                    .foregroundStyle(DSColors.textPrimary)

                Text(message)
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                DSPrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, DSSpacing.xl)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Empty State") {
    DSEmptyState(
        icon: "dumbbell",
        title: "No Workouts Yet",
        message: "Start your first workout to see it here!",
        actionTitle: "Start Workout",
        action: {}
    )
}

#Preview("Empty State - No Action") {
    DSEmptyState(
        icon: "magnifyingglass",
        title: "No Results",
        message: "Try searching with different keywords"
    )
}
