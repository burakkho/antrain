import SwiftUI

/// Standard text input field
/// Usage: Text input, search, notes
struct DSTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            if !title.isEmpty {
                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textSecondary)
            }

            TextField(placeholder, text: $text)
                .font(DSTypography.body)
                .padding(DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DSCornerRadius.md)
                        .stroke(errorMessage != nil ? DSColors.error : Color.clear, lineWidth: 1)
                )

            if let errorMessage {
                Text(errorMessage)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.error)
            }
        }
    }
}

// MARK: - Preview

#Preview("Text Field") {
    VStack(spacing: DSSpacing.lg) {
        DSTextField(
            title: "Exercise Name",
            text: .constant(""),
            placeholder: "Enter exercise name"
        )

        DSTextField(
            title: "Notes",
            text: .constant("Felt strong today"),
            placeholder: "Add notes"
        )

        DSTextField(
            title: "With Error",
            text: .constant(""),
            placeholder: "Required field",
            errorMessage: "This field cannot be empty"
        )
    }
    .padding()
}
