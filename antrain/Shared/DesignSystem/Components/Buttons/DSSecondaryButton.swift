import SwiftUI

/// Secondary action button with secondary background
/// Usage: Cancel, skip, alternative actions
struct DSSecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.button)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .padding(.horizontal, DSSpacing.md)
                .background(DSColors.backgroundSecondary)
                .foregroundStyle(isDisabled ? DSColors.textTertiary : DSColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview

#Preview("Secondary Button") {
    VStack(spacing: DSSpacing.md) {
        DSSecondaryButton(title: "Cancel", action: {})

        DSSecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
