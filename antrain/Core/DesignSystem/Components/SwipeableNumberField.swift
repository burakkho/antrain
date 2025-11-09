import SwiftUI

/// Swipeable number input field with gesture-based value adjustment
/// Supports multi-directional swipes with different increments
struct SwipeableNumberField: View {
    // MARK: - Types

    enum FieldType {
        case reps
        case weight
    }

    enum Direction {
        case previous
        case next
    }

    // MARK: - Properties

    let type: FieldType
    @Binding var value: Double
    let placeholder: LocalizedStringKey
    let isKeyboardMode: Bool // Now externally controlled
    let onUpdate: () -> Void

    // Field navigation
    let fieldIndex: Int?
    let totalFields: Int?
    let shouldAutoAdvance: Bool
    let onNavigate: ((Direction) -> Void)?
    let externalFocus: Binding<Bool>? // Optional external focus control

    @State private var dragOffset: CGSize = .zero
    @State private var lastSwipeTime: Date?
    @State private var swipeCount: Int = 0
    @State private var feedbackText: String?
    @State private var feedbackColor: Color?
    @FocusState private var isFocused: Bool
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"
    @State private var debounceTask: Task<Void, Never>?
    @State private var resetSwipeTask: Task<Void, Never>?
    @State private var feedbackTask: Task<Void, Never>?

    // MARK: - Constants

    private let swipeThreshold: CGFloat = 30
    private let multiSwipeWindow: TimeInterval = 0.5

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
            .onChange(of: value) { oldValue, newValue in
                // Only debounce in keyboard mode (gesture mode updates immediately in updateValue)
                guard isKeyboardMode else { return }

                debounceTask?.cancel()
                debounceTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    guard !Task.isCancelled else { return }
                    onUpdate()
                }
            }
            .highPriorityGesture(
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
            .onChange(of: isKeyboardMode) { oldMode, newMode in
                // Mode switch cleanup
                if oldMode != newMode {
                    // Cancel all pending tasks
                    debounceTask?.cancel()
                    resetSwipeTask?.cancel()
                    feedbackTask?.cancel()

                    // Clear focus when switching to swipe mode
                    if !newMode {
                        isFocused = false
                    }

                    // Clear feedback
                    feedbackText = nil
                    feedbackColor = nil
                }
            }
            .toolbar {
                if isKeyboardMode && isFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        // Previous button
                        if let fieldIndex = fieldIndex, let totalFields = totalFields {
                            Button(action: {
                                onNavigate?(.previous)
                            }) {
                                Image(systemName: "chevron.up")
                            }
                            .disabled(fieldIndex == 0)

                            Button(action: {
                                onNavigate?(.next)
                            }) {
                                Image(systemName: "chevron.down")
                            }
                            .disabled(fieldIndex >= totalFields - 1)
                        }

                        Spacer()

                        // Done button
                        Button("Done") {
                            isFocused = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .onChange(of: externalFocus?.wrappedValue) { oldValue, newValue in
                // Sync external focus to internal focus (one-way binding)
                if let newValue = newValue, isFocused != newValue {
                    isFocused = newValue
                }
            }
            .onChange(of: isFocused) { oldFocused, newFocused in
                // When focus is lost in keyboard mode, immediately update (don't wait for debounce)
                if oldFocused && !newFocused && isKeyboardMode {
                    debounceTask?.cancel()
                    onUpdate()
                }
            }
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
            let color: Color = isRight ? .green : .red
            showFeedback(text: isRight ? "+1" : "-1", color: color)
        } else {
            // Weight: unit-specific increments
            let isMultiSwipe = checkMultiSwipe()
            let baseIncrement: Double
            let unit: String

            if weightUnit == "Pounds" {
                // US plates: 5 lbs or 10 lbs
                baseIncrement = isMultiSwipe ? 10.0 : 5.0
                unit = String(localized: "lbs")
            } else {
                // Olympic plates: 2.5kg or 5kg
                baseIncrement = isMultiSwipe ? 5.0 : 2.5
                unit = String(localized: "kg")
            }

            let increment = isRight ? baseIncrement : -baseIncrement
            updateValue(by: increment)

            // Simple semantic colors: green for increase, red for decrease
            let color: Color = isRight ? .green : .red
            let sign = isRight ? "+" : "-"
            let formattedIncrement = String(format: "%.1f", baseIncrement)
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
        let baseIncrement: Double
        let unit: String

        if weightUnit == "Pounds" {
            // US plates: 25, 35, 45, 55 lbs
            let increments: [Int: Double] = [1: 25, 2: 35, 3: 45, 4: 55]
            baseIncrement = increments[swipes] ?? 25
            unit = String(localized: "lbs")
        } else {
            // Olympic plates: 10, 15, 20, 25 kg
            let increments: [Int: Double] = [1: 10, 2: 15, 3: 20, 4: 25]
            baseIncrement = increments[swipes] ?? 10
            unit = String(localized: "kg")
        }

        let increment = isUp ? baseIncrement : -baseIncrement
        updateValue(by: increment)

        // Simple semantic colors: green for increase, red for decrease
        let color: Color = isUp ? .green : .red
        let sign = isUp ? "+" : "-"
        let formattedIncrement = String(format: "%.0f", baseIncrement)
        showFeedback(
            text: "\(sign)\(formattedIncrement)\(unit)",
            color: color,
            plate: baseIncrement
        )
    }

    private func updateValue(by increment: Double) {
        let newValue = max(0, value + increment) // Minimum 0
        value = newValue

        // For gesture mode: immediate update (cancel debounce, update now)
        debounceTask?.cancel()
        onUpdate()

        triggerHaptic(for: abs(increment))
    }

    // MARK: - Multi-Swipe Detection

    private func checkMultiSwipe() -> Bool {
        let now = Date()
        defer {
            lastSwipeTime = now
            swipeCount += 1

            // Reset counter after time window (cancellable task)
            resetSwipeTask?.cancel()
            resetSwipeTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(multiSwipeWindow * 1_000_000_000))
                guard !Task.isCancelled else { return }
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

        // Hide after delay (cancellable task)
        feedbackTask?.cancel()
        feedbackTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            guard !Task.isCancelled else { return }
            withAnimation {
                feedbackText = nil
                feedbackColor = nil
            }
        }
    }

    private func triggerHaptic(for increment: Double) {
        let generator = UIImpactFeedbackGenerator()

        // Different haptic intensity based on increment
        let smallThreshold: Double = weightUnit == "Pounds" ? 5 : 2.5
        let mediumThreshold: Double = weightUnit == "Pounds" ? 25 : 10

        if increment <= smallThreshold {
            generator.impactOccurred(intensity: 0.5) // Light
        } else if increment <= mediumThreshold {
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
            onUpdate: {},
            fieldIndex: nil,
            totalFields: nil,
            shouldAutoAdvance: false,
            onNavigate: nil,
            externalFocus: nil
        )

        SwipeableNumberField(
            type: .weight,
            value: .constant(80),
            placeholder: "Weight",
            isKeyboardMode: false,
            onUpdate: {},
            fieldIndex: nil,
            totalFields: nil,
            shouldAutoAdvance: false,
            onNavigate: nil,
            externalFocus: nil
        )

        Divider()

        Text("Keyboard Mode")
            .font(.headline)

        SwipeableNumberField(
            type: .reps,
            value: .constant(10),
            placeholder: "Reps",
            isKeyboardMode: true,
            onUpdate: {},
            fieldIndex: 0,
            totalFields: 2,
            shouldAutoAdvance: true,
            onNavigate: { _ in },
            externalFocus: nil
        )

        SwipeableNumberField(
            type: .weight,
            value: .constant(80),
            placeholder: "Weight",
            isKeyboardMode: true,
            onUpdate: {},
            fieldIndex: 1,
            totalFields: 2,
            shouldAutoAdvance: false,
            onNavigate: { _ in },
            externalFocus: nil
        )
    }
    .padding()
}
