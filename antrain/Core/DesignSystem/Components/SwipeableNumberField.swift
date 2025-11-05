import SwiftUI

/// Swipeable number input field with gesture-based value adjustment
/// Supports multi-directional swipes with different increments
struct SwipeableNumberField: View {
    // MARK: - Types

    enum FieldType {
        case reps
        case weight
    }

    // MARK: - Properties

    let type: FieldType
    @Binding var value: Double
    let placeholder: LocalizedStringKey
    let isKeyboardMode: Bool // Now externally controlled
    let onUpdate: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var lastSwipeTime: Date?
    @State private var swipeCount: Int = 0
    @State private var feedbackText: String?
    @State private var feedbackColor: Color?
    @FocusState private var isFocused: Bool
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    // MARK: - Constants

    private let swipeThreshold: CGFloat = 30
    private let multiSwipeWindow: TimeInterval = 0.5

    // Olympic plate colors
    private let plateColors: [Double: Color] = [
        2.5: .gray,
        5: .black,
        10: .green,
        15: .yellow,
        20: .blue,
        25: .red
    ]

    var body: some View {
        TextField(placeholder, value: $value, format: .number.precision(.fractionLength(0...1)))
            .keyboardType(type == .reps ? .numberPad : .decimalPad)
            .multilineTextAlignment(.center)
            .font(DSTypography.body)
            .padding(DSSpacing.sm)
            .background(DSColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSCornerRadius.md)
                    .stroke(feedbackColor ?? .clear, lineWidth: 2)
            )
            .focused($isFocused)
            .disabled(!isKeyboardMode) // Disable when in swipe mode
            .onChange(of: value) { _, _ in
                onUpdate()
            }
            .gesture(
                isKeyboardMode ? nil : DragGesture(minimumDistance: 20)
                    .onChanged { gesture in
                        dragOffset = gesture.translation
                    }
                    .onEnded { gesture in
                        handleSwipeGesture(translation: gesture.translation)
                        dragOffset = .zero
                    }
            )
            .overlay(alignment: .topTrailing) {
                // Floating feedback label
                if let feedbackText, let feedbackColor {
                    Text(feedbackText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(feedbackColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(feedbackColor.opacity(0.2))
                        .clipShape(Capsule())
                        .offset(x: -4, y: -24)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3), value: feedbackText)
    }

    // MARK: - Gesture Handling

    private func handleSwipeGesture(translation: CGSize) {
        let horizontal = translation.width
        let vertical = translation.height

        // Determine primary direction
        if abs(horizontal) > abs(vertical) {
            // Horizontal swipe
            if abs(horizontal) > swipeThreshold {
                handleHorizontalSwipe(isRight: horizontal > 0)
            }
        } else {
            // Vertical swipe
            if abs(vertical) > swipeThreshold {
                handleVerticalSwipe(isUp: vertical < 0)
            }
        }
    }

    private func handleHorizontalSwipe(isRight: Bool) {
        if type == .reps {
            // Reps: simple +1/-1
            let increment = isRight ? 1.0 : -1.0
            updateValue(by: increment)
            showFeedback(text: isRight ? "+1" : "-1", color: .primary)
        } else {
            // Weight: 2.5kg or 5kg (multi-swipe)
            let isMultiSwipe = checkMultiSwipe()
            let baseIncrement = isMultiSwipe ? 5.0 : 2.5
            let increment = isRight ? baseIncrement : -baseIncrement

            updateValue(by: increment)

            let color = plateColors[abs(baseIncrement)] ?? .gray
            let sign = isRight ? "+" : "-"
            let formattedIncrement = String(format: "%.1f", baseIncrement)
            let unit = String(localized: "kg")
            showFeedback(
                text: "\(sign)\(formattedIncrement)\(unit)",
                color: color,
                plate: baseIncrement
            )
        }
    }

    private func handleVerticalSwipe(isUp: Bool) {
        guard type == .weight else { return }

        let swipes = checkMultiSwipe() ? (checkTripleSwipe() ? (checkQuadSwipe() ? 4 : 3) : 2) : 1
        let increments: [Int: Double] = [1: 10, 2: 15, 3: 20, 4: 25]
        let baseIncrement = increments[swipes] ?? 10
        let increment = isUp ? baseIncrement : -baseIncrement

        updateValue(by: increment)

        let color = plateColors[abs(baseIncrement)] ?? .green
        let sign = isUp ? "+" : "-"
        let formattedIncrement = String(format: "%.0f", baseIncrement)
        let unit = String(localized: "kg")
        showFeedback(
            text: "\(sign)\(formattedIncrement)\(unit)",
            color: color,
            plate: baseIncrement
        )
    }

    private func updateValue(by increment: Double) {
        let newValue = max(0, value + increment) // Minimum 0
        value = newValue
        triggerHaptic(for: abs(increment))
    }

    // MARK: - Multi-Swipe Detection

    private func checkMultiSwipe() -> Bool {
        let now = Date()
        defer {
            lastSwipeTime = now
            swipeCount += 1

            // Reset counter after time window
            DispatchQueue.main.asyncAfter(deadline: .now() + multiSwipeWindow) {
                if let last = lastSwipeTime, now.timeIntervalSince(last) >= multiSwipeWindow {
                    swipeCount = 0
                }
            }
        }

        if let last = lastSwipeTime, now.timeIntervalSince(last) < multiSwipeWindow {
            return swipeCount >= 1
        }
        return false
    }

    private func checkTripleSwipe() -> Bool {
        return swipeCount >= 2
    }

    private func checkQuadSwipe() -> Bool {
        return swipeCount >= 3
    }

    // MARK: - Feedback

    private func showFeedback(text: String, color: Color, plate: Double? = nil) {
        withAnimation(.spring(response: 0.3)) {
            feedbackText = text
            feedbackColor = color
        }

        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                feedbackText = nil
                feedbackColor = nil
            }
        }
    }

    private func triggerHaptic(for increment: Double) {
        let generator = UIImpactFeedbackGenerator()

        // Different haptic intensity based on increment
        if increment <= 2.5 {
            generator.impactOccurred(intensity: 0.5) // Light
        } else if increment <= 10 {
            generator.impactOccurred(intensity: 0.7) // Medium
        } else {
            generator.impactOccurred(intensity: 1.0) // Heavy
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Swipe Mode")
            .font(.headline)

        SwipeableNumberField(
            type: .reps,
            value: .constant(10),
            placeholder: "Reps",
            isKeyboardMode: false,
            onUpdate: {}
        )

        SwipeableNumberField(
            type: .weight,
            value: .constant(80),
            placeholder: "Weight",
            isKeyboardMode: false,
            onUpdate: {}
        )

        Divider()

        Text("Keyboard Mode")
            .font(.headline)

        SwipeableNumberField(
            type: .reps,
            value: .constant(10),
            placeholder: "Reps",
            isKeyboardMode: true,
            onUpdate: {}
        )

        SwipeableNumberField(
            type: .weight,
            value: .constant(80),
            placeholder: "Weight",
            isKeyboardMode: true,
            onUpdate: {}
        )
    }
    .padding()
}
