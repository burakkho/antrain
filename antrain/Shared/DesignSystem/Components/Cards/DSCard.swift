import SwiftUI

/// Generic card container with padding and background
/// Usage: Content grouping, sections, list items
struct DSCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(DSSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
    }
}

// MARK: - Preview

#Preview("Card") {
    VStack(spacing: DSSpacing.md) {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Card Title")
                    .font(DSTypography.headline)

                Text("Card content goes here with some description text.")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }

        DSCard {
            HStack {
                VStack(alignment: .leading) {
                    Text("Quick Action")
                        .font(DSTypography.title3)
                    Text("Tap to start")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
    }
    .padding()
}
