import SwiftUI

/// Loading state view with spinner and message
/// Usage: Async operations, data fetching
struct DSLoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .font(DSTypography.subheadline)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Loading View") {
    DSLoadingView()
}

#Preview("Loading with Custom Message") {
    DSLoadingView(message: "Saving workout...")
}
