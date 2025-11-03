import SwiftUI

/// Primary action button with blue background
/// Usage: Main CTAs, save actions, primary workflows
struct DSPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(title)
                    .font(DSTypography.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .padding(.horizontal, DSSpacing.md)
            .background(isDisabled ? DSColors.textTertiary : DSColors.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
        .disabled(isLoading || isDisabled)
    }
}

// MARK: - Preview

#Preview("Primary Button") {
    VStack(spacing: DSSpacing.md) {
        DSPrimaryButton(title: "Save Workout", action: {})

        DSPrimaryButton(title: "Loading", action: {}, isLoading: true)

        DSPrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
