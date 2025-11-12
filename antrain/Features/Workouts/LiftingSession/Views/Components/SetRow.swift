import SwiftUI

/// Set row with swipeable number fields for gesture-based editing
struct SetRow: View {
    // MARK: - Field Focus Management

    enum Field: Int, Hashable {
        case reps = 0
        case weight = 1
    }

    let set: WorkoutSet
    let setNumber: Int
    let isKeyboardMode: Bool
    let onUpdate: (Int, Double) -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void

    // Smart navigation parameters
    @Binding var focusedField: SetFieldIdentifier?
    let currentSetId: UUID
    let onNavigateToNextSet: (Field) -> Void
    let onNavigateToPreviousSet: (Field) -> Void

    @State private var reps: Double
    @State private var weight: Double
    @State private var offsetX: CGFloat = 0
    @State private var showDeleteButton: Bool = false
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    init(
        set: WorkoutSet,
        setNumber: Int,
        isKeyboardMode: Bool = false,
        onUpdate: @escaping (Int, Double) -> Void,
        onToggle: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        focusedField: Binding<SetFieldIdentifier?>,
        currentSetId: UUID,
        onNavigateToNextSet: @escaping (Field) -> Void,
        onNavigateToPreviousSet: @escaping (Field) -> Void
    ) {
        self.set = set
        self.setNumber = setNumber
        self.isKeyboardMode = isKeyboardMode
        self.onUpdate = onUpdate
        self.onToggle = onToggle
        self.onDelete = onDelete
        self._focusedField = focusedField
        self.currentSetId = currentSetId
        self.onNavigateToNextSet = onNavigateToNextSet
        self.onNavigateToPreviousSet = onNavigateToPreviousSet
        self._reps = State(initialValue: Double(set.reps))

        // Convert weight for display - store as kg internally
        self._weight = State(initialValue: set.weight)
    }

    // MARK: - Weight Conversion

    // Computed binding that converts between kg and display unit
    private var displayWeight: Binding<Double> {
        Binding(
            get: {
                weightUnit == "Pounds" ? weight.kgToLbs() : weight
            },
            set: { newValue in
                weight = weightUnit == "Pounds" ? newValue.lbsToKg() : newValue
            }
        )
    }

    // MARK: - Focus Helpers

    private func isFocused(_ field: Field) -> Binding<Bool> {
        Binding(
            get: { focusedField?.setId == currentSetId && focusedField?.fieldType == field },
            set: { newValue in
                if newValue {
                    focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: field)
                } else if focusedField?.setId == currentSetId && focusedField?.fieldType == field {
                    focusedField = nil
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background (revealed on swipe)
            if showDeleteButton {
                Button(role: .destructive) {
                    withAnimation {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 60)
                        .frame(maxHeight: .infinity)
                }
                .background(DSColors.error)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
            }

            // Main content
            HStack(spacing: DSSpacing.sm) {
                // Set number
                Text("\(setNumber)")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.textSecondary)
                    .strikethrough(set.isCompleted, color: DSColors.textSecondary)
                    .frame(width: 30)

                // Reps input with swipe gestures
                SwipeableNumberField(
                    type: .reps,
                    value: $reps,
                    placeholder: "Reps",
                    isKeyboardMode: isKeyboardMode,
                    onUpdate: {
                        onUpdate(Int(reps), weight)
                    },
                    fieldIndex: 0,
                    totalFields: 2,
                    shouldAutoAdvance: true,
                    onNavigate: { direction in
                        switch direction {
                        case .next:
                            // Move to weight field in the same set
                            focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .weight)
                        case .previous:
                            // Move to previous set's reps field (column-based)
                            onNavigateToPreviousSet(.reps)
                        }
                    },
                    externalFocus: isFocused(.reps)
                )
                .strikethrough(set.isCompleted, color: DSColors.textPrimary)

                Text("×")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textTertiary)
                    .strikethrough(set.isCompleted, color: DSColors.textTertiary)

                // Weight input with swipe gestures
                SwipeableNumberField(
                    type: .weight,
                    value: displayWeight,
                    placeholder: "Weight",
                    isKeyboardMode: isKeyboardMode,
                    onUpdate: {
                        onUpdate(Int(reps), weight)
                    },
                    fieldIndex: 1,
                    totalFields: 2,
                    shouldAutoAdvance: false,
                    onNavigate: { direction in
                        switch direction {
                        case .next:
                            // Move to next set's WEIGHT field (column-based navigation!)
                            onNavigateToNextSet(.weight)
                        case .previous:
                            // Move back to reps in the same set
                            focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .reps)
                        }
                    },
                    externalFocus: isFocused(.weight)
                )
                .strikethrough(set.isCompleted, color: DSColors.textPrimary)

                Text(Double.weightUnitSymbol(weightUnit))
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .strikethrough(set.isCompleted, color: DSColors.textSecondary)

                // Toggle completion button
                Button {
                    // Success haptic on set completion
                    HapticManager.shared.setCompleted()

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        onToggle()
                    }
                } label: {
                    Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(set.isCompleted ? DSColors.success : DSColors.textTertiary)
                        .symbolEffect(.bounce, value: set.isCompleted)
                }
            }
            .padding(DSSpacing.sm)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
            .offset(x: offsetX)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow left swipe (delete gesture) in keyboard mode
                        // Disabled in swipe mode to avoid conflicts with SwipeableNumberField gestures
                        guard isKeyboardMode else { return }

                        // SwipeableNumberField's highPriorityGesture takes precedence for its gestures
                        if value.translation.width < 0 {
                            offsetX = value.translation.width
                        }
                    }
                    .onEnded { value in
                        // Only process delete swipe in keyboard mode
                        guard isKeyboardMode else { return }

                        if value.translation.width < -60 {
                            // Swipe threshold reached - show delete
                            withAnimation(.spring(response: 0.3)) {
                                offsetX = -70
                                showDeleteButton = true
                            }
                        } else {
                            // Not enough swipe - reset
                            withAnimation(.spring(response: 0.3)) {
                                offsetX = 0
                                showDeleteButton = false
                            }
                        }
                    }
            )
            .onChange(of: isKeyboardMode) { _, newValue in
                // Reset delete reveal state when switching to swipe mode
                if !newValue {
                    withAnimation(.spring(response: 0.3)) {
                        offsetX = 0
                        showDeleteButton = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var focusedField: SetFieldIdentifier? = nil

    let set1 = WorkoutSet(reps: 10, weight: 80, isCompleted: false)
    let set2 = WorkoutSet(reps: 10, weight: 80, isCompleted: true)

    VStack(spacing: DSSpacing.md) {
        SetRow(
            set: set1,
            setNumber: 1,
            isKeyboardMode: true,
            onUpdate: { _, _ in },
            onToggle: {},
            onDelete: {},
            focusedField: $focusedField,
            currentSetId: set1.id,
            onNavigateToNextSet: { _ in },
            onNavigateToPreviousSet: { _ in }
        )

        SetRow(
            set: set2,
            setNumber: 2,
            isKeyboardMode: true,
            onUpdate: { _, _ in },
            onToggle: {},
            onDelete: {},
            focusedField: $focusedField,
            currentSetId: set2.id,
            onNavigateToNextSet: { _ in },
            onNavigateToPreviousSet: { _ in }
        )
    }
    .padding()
}
