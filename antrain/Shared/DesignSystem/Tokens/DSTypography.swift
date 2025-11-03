import SwiftUI

/// Design System Typography
/// Apple HIG typography scale with Dynamic Type support
struct DSTypography {
    // MARK: - Title Styles

    /// Extra large title (34pt bold)
    static let largeTitle = Font.largeTitle.weight(.bold)

    /// Title 1 (28pt bold)
    static let title1 = Font.title.weight(.bold)

    /// Title 2 (22pt semibold)
    static let title2 = Font.title2.weight(.semibold)

    /// Title 3 (20pt semibold)
    static let title3 = Font.title3.weight(.semibold)

    // MARK: - Body Styles

    /// Headline (17pt semibold)
    static let headline = Font.headline

    /// Body text (17pt regular)
    static let body = Font.body

    /// Callout (16pt regular)
    static let callout = Font.callout

    /// Subheadline (15pt regular)
    static let subheadline = Font.subheadline

    /// Footnote (13pt regular)
    static let footnote = Font.footnote

    /// Caption (12pt regular)
    static let caption = Font.caption

    /// Caption 2 (11pt regular)
    static let caption2 = Font.caption2

    // MARK: - Custom Styles

    /// Large number display (48pt bold, rounded)
    static let numberDisplay = Font.system(size: 48, weight: .bold, design: .rounded)

    /// Stat value (24pt semibold, rounded)
    static let statValue = Font.system(size: 24, weight: .semibold, design: .rounded)

    /// Button text (17pt semibold)
    static let button = Font.system(size: 17, weight: .semibold)
}
