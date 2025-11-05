import SwiftUI

/// Set row with swipeable number fields for gesture-based editing
struct SetRow: View {
    let set: WorkoutSet
    let setNumber: Int
    let isKeyboardMode: Bool
    let onUpdate: (Int, Double) -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void

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
        onDelete: @escaping () -> Void
    ) {
        self.set = set
        self.setNumber = setNumber
        self.isKeyboardMode = isKeyboardMode
        self.onUpdate = onUpdate
        self.onToggle = onToggle
        self.onDelete = onDelete
        self._reps = State(initialValue: Double(set.reps))

        // Convert weight for display based on user preference
        // Note: Weight is always stored as kg in database
        let storedWeightKg = set.weight
        let weightUnit = UserDefaults.standard.string(forKey: "weightUnit") ?? "Kilograms"
        let displayWeight = weightUnit == "Pounds" ? storedWeightKg.kgToLbs() : storedWeightKg
        self._weight = State(initialValue: displayWeight)
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
                        onUpdate(Int(reps), weightInKg)
                    }
                )
                .strikethrough(set.isCompleted, color: DSColors.textPrimary)

                Text("×")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textTertiary)
                    .strikethrough(set.isCompleted, color: DSColors.textTertiary)

                // Weight input with swipe gestures
                SwipeableNumberField(
                    type: .weight,
                    value: $weight,
                    placeholder: "Weight",
                    isKeyboardMode: isKeyboardMode,
                    onUpdate: {
                        onUpdate(Int(reps), weightInKg)
                    }
                )
                .strikethrough(set.isCompleted, color: DSColors.textPrimary)

                Text(Double.weightUnitSymbol(weightUnit))
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .strikethrough(set.isCompleted, color: DSColors.textSecondary)

                // Toggle completion button
                Button {
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

    // Helper to convert weight to kg for storage
    private var weightInKg: Double {
        weightUnit == "Pounds" ? weight.lbsToKg() : weight
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.md) {
        SetRow(
            set: WorkoutSet(reps: 10, weight: 80, isCompleted: false),
            setNumber: 1,
            onUpdate: { _, _ in },
            onToggle: {},
            onDelete: {}
        )

        SetRow(
            set: WorkoutSet(reps: 10, weight: 80, isCompleted: true),
            setNumber: 2,
            onUpdate: { _, _ in },
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
}
