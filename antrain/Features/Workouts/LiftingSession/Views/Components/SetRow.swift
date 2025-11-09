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
    typealias SetFieldIdentifier = ExerciseCard.SetFieldIdentifier
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

    private var isRepsFocused: Bool {
        focusedField?.setId == currentSetId && focusedField?.fieldType == .reps
    }

    private var isWeightFocused: Bool {
        focusedField?.setId == currentSetId && focusedField?.fieldType == .weight
    }

    private func focusReps() {
        focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .reps)
    }

    private func focusWeight() {
        focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .weight)
    }

    // Computed binding for reps focus
    private var repsFocusBinding: Binding<Bool> {
        Binding(
            get: { isRepsFocused },
            set: { newValue in
                if newValue {
                    focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .reps)
                } else if isRepsFocused {
                    focusedField = nil
                }
            }
        )
    }

    // Computed binding for weight focus
    private var weightFocusBinding: Binding<Bool> {
        Binding(
            get: { isWeightFocused },
            set: { newValue in
                if newValue {
                    focusedField = SetFieldIdentifier(setId: currentSetId, fieldType: .weight)
                } else if isWeightFocused {
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

                // SetType indicator (if not normal)
                if let setType = set.setType {
                    let parsedType = SetType.from(string: setType)
                    if parsedType != .normal {
                        Text(parsedType.icon)
                            .font(.caption2)
                            .frame(width: 16)
                    } else {
                        Spacer().frame(width: 16)  // Maintain alignment
                    }
                } else {
                    Spacer().frame(width: 16)  // Maintain alignment
                }

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
                            focusWeight()
                        case .previous:
                            // Move to previous set's reps field (column-based)
                            onNavigateToPreviousSet(.reps)
                        }
                    },
                    externalFocus: repsFocusBinding
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
                            focusReps()
                        }
                    },
                    externalFocus: weightFocusBinding
                )
                .strikethrough(set.isCompleted, color: DSColors.textPrimary)

                Text(Double.weightUnitSymbol(weightUnit))
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .strikethrough(set.isCompleted, color: DSColors.textSecondary)

                // RPE indicator (if set)
                if let rpe = set.rpe, rpe > 0 {
                    Text("@\(rpe)")
                        .font(.caption)
                        .foregroundStyle(DSColors.textSecondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(DSColors.cardBackground.opacity(0.5))
                        .cornerRadius(4)
                }

                // Toggle completion button
                Button {
                    // ROADMAP: Phase 1, Day 1 - Haptic Feedback
                    // Success haptic on set completion
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow left swipe
                        if value.translation.width < 0 {
                            offsetX = value.translation.width
                        }
                    }
                    .onEnded { value in
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
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var focusedField: SetRow.SetFieldIdentifier? = nil

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
