import SwiftUI

/// Error state view with message and retry action
/// Usage: Failed operations, error scenarios
struct DSErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DSColors.error)

            Text(errorMessage)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)

            DSPrimaryButton(title: "Retry", action: retryAction)
                .padding(.horizontal, DSSpacing.xl)
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Error View") {
    DSErrorView(
        errorMessage: "Failed to load workouts.\nPlease try again.",
        retryAction: {}
    )
}
