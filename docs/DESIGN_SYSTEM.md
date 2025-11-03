# Design System - Antrain

**Amaç:** Reusable design tokens, component library, consistency guidelines

**Prensip:** Apple HIG compliant, dark mode native, accessible, scalable

---

## Design Tokens

### Colors (DSColors.swift)

**Semantic Naming Strategy:** Purpose-based, not color-based

```swift
// Shared/DesignSystem/Tokens/DSColors.swift
import SwiftUI

struct DSColors {
    // MARK: - Primary Colors
    static let primary = Color.blue          // Main brand color (buttons, accents)
    static let secondary = Color.orange      // Secondary actions
    static let tertiary = Color.gray         // Tertiary UI elements

    // MARK: - Semantic Colors
    static let success = Color.green         // Completed sets, success states
    static let warning = Color.orange        // Warnings, cautions
    static let error = Color.red             // Errors, destructive actions

    // MARK: - Background Colors
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Text Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - UI Element Colors
    static let separator = Color(.separator)
    static let cardBackground = Color(.secondarySystemBackground)
    static let cardBorder = Color(.separator)
}
```

**Dark Mode Support:**
- All colors use system colors (otomatik dark mode)
- Custom colors için dark variant tanımla

**Usage:**
```swift
Text("Hello")
    .foregroundStyle(DSColors.textPrimary)

Button("Save") { }
    .foregroundStyle(DSColors.primary)
```

---

### Typography (DSTypography.swift)

**Apple HIG Typography Scale**

```swift
// Shared/DesignSystem/Tokens/DSTypography.swift
import SwiftUI

struct DSTypography {
    // MARK: - Title Styles
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)

    // MARK: - Body Styles
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption

    // MARK: - Custom Styles
    static let numberDisplay = Font.system(size: 48, weight: .bold, design: .rounded)
    static let statValue = Font.system(size: 24, weight: .semibold, design: .rounded)
}
```

**Dynamic Type Support:** Tüm fonts otomatik scale olur

**Usage:**
```swift
Text("Workout Title")
    .font(DSTypography.title2)

Text("165 kg")
    .font(DSTypography.numberDisplay)
```

---

### Spacing (DSSpacing.swift)

**8-Point Grid System**

```swift
// Shared/DesignSystem/Tokens/DSSpacing.swift
import SwiftUI

struct DSSpacing {
    static let xxxs: CGFloat = 2    // Minimal spacing
    static let xxs: CGFloat = 4     // Tight spacing
    static let xs: CGFloat = 8      // Extra small
    static let sm: CGFloat = 12     // Small
    static let md: CGFloat = 16     // Medium (default)
    static let lg: CGFloat = 24     // Large
    static let xl: CGFloat = 32     // Extra large
    static let xxl: CGFloat = 48    // Extra extra large
    static let xxxl: CGFloat = 64   // Maximum spacing
}
```

**Usage Guidelines:**

| Use Case | Spacing | Token |
|----------|---------|-------|
| Innermost padding (button internal) | 8pt | `.xs` |
| Card padding | 16pt | `.md` |
| Section spacing | 24pt | `.lg` |
| Screen edge padding | 16pt | `.md` |
| List item spacing | 12pt | `.sm` |

**Usage:**
```swift
VStack(spacing: DSSpacing.md) {
    // content
}
.padding(DSSpacing.md)
```

---

### Corner Radius (DSCornerRadius.swift)

```swift
// Shared/DesignSystem/Tokens/DSCornerRadius.swift
import SwiftUI

struct DSCornerRadius {
    static let sm: CGFloat = 4      // Small elements (tags, badges)
    static let md: CGFloat = 8      // Buttons, text fields
    static let lg: CGFloat = 12     // Cards
    static let xl: CGFloat = 16     // Large cards, modals
    static let full: CGFloat = 9999 // Pills, circular buttons
}
```

**Usage:**
```swift
RoundedRectangle(cornerRadius: DSCornerRadius.lg)
```

---

## Component Library

### Buttons

**1. DSPrimaryButton**

**Purpose:** Primary actions (Save, Start Workout, Add Exercise)

```swift
// Shared/DesignSystem/Components/Buttons/DSPrimaryButton.swift
struct DSPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(DSTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(DSSpacing.md)
            .background(DSColors.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
        .disabled(isLoading)
    }
}
```

**Usage:**
```swift
DSPrimaryButton(title: "Save Workout", action: saveWorkout, isLoading: viewModel.isLoading)
```

---

**2. DSSecondaryButton**

**Purpose:** Secondary actions (Cancel, Skip, Back)

```swift
struct DSSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(DSSpacing.md)
                .background(DSColors.backgroundSecondary)
                .foregroundStyle(DSColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
    }
}
```

---

**3. DSIconButton**

**Purpose:** Icon-only actions (Delete, Edit, Add)

```swift
struct DSIconButton: View {
    let icon: String  // SF Symbol name
    let action: () -> Void
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary, secondary, destructive
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(foregroundColor)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return DSColors.primary
        case .destructive: return .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return DSColors.primary
        case .secondary: return DSColors.backgroundSecondary
        case .destructive: return DSColors.error
        }
    }
}
```

---

### Cards

**1. DSCard**

**Purpose:** Generic container for content

```swift
// Shared/DesignSystem/Components/Cards/DSCard.swift
struct DSCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(DSSpacing.md)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
```

**Usage:**
```swift
DSCard {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
        Text("Title")
        Text("Content")
    }
}
```

---

**2. DSListCard**

**Purpose:** List items with tap action

```swift
struct DSListCard<Content: View>: View {
    let action: () -> Void
    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            HStack {
                content
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
            .padding(DSSpacing.md)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
        }
        .buttonStyle(.plain)
    }
}
```

---

### Text Fields

**1. DSTextField**

**Purpose:** Text input

```swift
// Shared/DesignSystem/Components/TextFields/DSTextField.swift
struct DSTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(title)
                .font(DSTypography.subheadline)
                .foregroundStyle(DSColors.textSecondary)

            TextField(placeholder, text: $text)
                .padding(DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
    }
}
```

---

**2. DSNumberField**

**Purpose:** Numeric input (weight, reps, calories)

```swift
struct DSNumberField: View {
    let title: String
    @Binding var value: Double
    var unit: String = ""
    var format: FloatingPointFormatStyle<Double> = .number

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(title)
                .font(DSTypography.subheadline)
                .foregroundStyle(DSColors.textSecondary)

            HStack {
                TextField(title, value: $value, format: format)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)

                if !unit.isEmpty {
                    Text(unit)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
    }
}
```

---

### Other Components

**1. DSLoadingView**

```swift
struct DSLoadingView: View {
    var message: String = "Yükleniyor..."

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
            Text(message)
                .font(DSTypography.subheadline)
                .foregroundStyle(DSColors.textSecondary)
        }
    }
}
```

---

**2. DSEmptyState**

```swift
struct DSEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
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
    }
}
```

---

**3. DSErrorView**

```swift
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

            DSPrimaryButton(title: "Tekrar Dene", action: retryAction)
                .padding(.horizontal, DSSpacing.xl)
        }
        .padding(DSSpacing.xl)
    }
}
```

---

## Accessibility

### VoiceOver Labels

**Button accessibility:**
```swift
DSPrimaryButton(title: "Save")
    .accessibilityLabel("Save workout")
    .accessibilityHint("Saves the current workout to history")
```

### Dynamic Type

All components automatically support Dynamic Type (system fonts kullanıldığı için)

### Color Contrast

- Primary text: WCAG AA compliant (4.5:1 ratio)
- Secondary text: 3:1 minimum
- Interactive elements: 3:1 minimum

---

## Animation Standards

### Duration

```swift
struct DSAnimation {
    static let fast: Double = 0.2       // Quick feedback
    static let normal: Double = 0.3     // Standard transition
    static let slow: Double = 0.5       // Emphasis
}
```

### Curves

```swift
// Spring animation (natural feel)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)

// Ease in/out (smooth)
.animation(.easeInOut(duration: DSAnimation.normal), value: offset)
```

### Haptic Feedback

```swift
struct DSHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
```

**Usage:**
```swift
Button("Complete Set") {
    completeSet()
    DSHaptics.light()
}
```

---

## Component Usage Guidelines

| Component | When to Use | When NOT to Use |
|-----------|-------------|-----------------|
| DSPrimaryButton | Main action (1 per screen max) | Multiple actions |
| DSSecondaryButton | Alternative actions | Primary CTA |
| DSCard | Content grouping | List items (use DSListCard) |
| DSTextField | Text input | Numbers (use DSNumberField) |
| DSEmptyState | No data scenarios | Error states (use DSErrorView) |

---

**Son Güncelleme:** 2025-02-11
**Dosya Boyutu:** ~180 satır
**Token Efficiency:** Code examples, clear structure
