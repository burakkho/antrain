import SwiftUI

/// Design System Colors
/// Blue primary + semantic colors, dark mode support
struct DSColors {
    // MARK: - Primary Colors

    /// Primary brand color - Blue (#007AFF)
    static let primary = Color.blue

    /// Secondary actions
    static let secondary = Color.orange

    /// Tertiary UI elements
    static let tertiary = Color.gray

    // MARK: - Semantic Colors

    /// Success states (completed sets, success feedback)
    static let success = Color.green

    /// Warning states
    static let warning = Color.orange

    /// Error states, destructive actions
    static let error = Color.red

    // MARK: - Background Colors

    /// Primary background (adapts to dark mode)
    static let backgroundPrimary = Color(.systemBackground)

    /// Secondary background (cards, sections)
    static let backgroundSecondary = Color(.secondarySystemBackground)

    /// Tertiary background (grouped backgrounds)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Text Colors

    /// Primary text color
    static let textPrimary = Color(.label)

    /// Secondary text color (descriptions, captions)
    static let textSecondary = Color(.secondaryLabel)

    /// Tertiary text color (disabled, placeholders)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - UI Element Colors

    /// Separator lines
    static let separator = Color(.separator)

    /// Card background
    static let cardBackground = Color(.secondarySystemBackground)

    /// Card border
    static let cardBorder = Color(.separator)
}
