import SwiftUI

/// Filter chip component for horizontal scrollable filters
/// Apple Fitness+ style - toggle on/off with tap
struct DSFilterChip: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.vertical, DSSpacing.xs)
                .padding(.horizontal, DSSpacing.sm)
                .background(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
                .foregroundStyle(isSelected ? .white : DSColors.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Filter Chips") {
    VStack(spacing: DSSpacing.md) {
        // Selected state
        DSFilterChip(title: "Barbell", isSelected: true, action: {})

        // Unselected state
        DSFilterChip(title: "Dumbbell", isSelected: false, action: {})

        // Horizontal scroll example
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                DSFilterChip(title: "All", isSelected: true, action: {})
                DSFilterChip(title: "Barbell", isSelected: false, action: {})
                DSFilterChip(title: "Dumbbell", isSelected: false, action: {})
                DSFilterChip(title: "Bodyweight", isSelected: false, action: {})
                DSFilterChip(title: "Machine", isSelected: false, action: {})
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
    .padding()
}
