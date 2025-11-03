import SwiftUI

/// Set row with inline editing and swipe gestures
/// Swipe right = complete, swipe left = delete
struct SetRow: View {
    let set: WorkoutSet
    let setNumber: Int
    let onUpdate: (Int, Double) -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    @State private var reps: Double
    @State private var weight: Double
    @FocusState private var focusedField: Field?
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    enum Field {
        case reps, weight
    }

    init(
        set: WorkoutSet,
        setNumber: Int,
        onUpdate: @escaping (Int, Double) -> Void,
        onComplete: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.set = set
        self.setNumber = setNumber
        self.onUpdate = onUpdate
        self.onComplete = onComplete
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
        HStack(spacing: DSSpacing.sm) {
            // Set number
            Text("\(setNumber)")
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textSecondary)
                .frame(width: 30)

            // Reps input
            TextField("Reps", value: $reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(DSTypography.body)
                .padding(DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                .focused($focusedField, equals: .reps)
                .onChange(of: reps) { _, newValue in
                    onUpdate(Int(newValue), weight)
                }

            Text("×")
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textTertiary)

            // Weight input
            TextField("Weight", value: $weight, format: .number.precision(.fractionLength(0...1)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(DSTypography.body)
                .padding(DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                .focused($focusedField, equals: .weight)
                .onChange(of: weight) { _, newValue in
                    // Convert back to kg for storage if user is using lbs
                    let weightInKg = weightUnit == "Pounds" ? newValue.lbsToKg() : newValue
                    onUpdate(Int(reps), weightInKg)
                }

            Text(Double.weightUnitSymbol(weightUnit))
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textSecondary)

            // Completed indicator
            if set.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(DSColors.success)
            }
        }
        .padding(DSSpacing.sm)
        .background(set.isCompleted ? DSColors.success.opacity(0.1) : DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Swipe right = complete
            Button {
                onComplete()
            } label: {
                Label("Complete", systemImage: "checkmark")
            }
            .tint(DSColors.success)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            // Swipe left = delete
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.md) {
        SetRow(
            set: WorkoutSet(reps: 10, weight: 80, isCompleted: false),
            setNumber: 1,
            onUpdate: { _, _ in },
            onComplete: {},
            onDelete: {}
        )

        SetRow(
            set: WorkoutSet(reps: 10, weight: 80, isCompleted: true),
            setNumber: 2,
            onUpdate: { _, _ in },
            onComplete: {},
            onDelete: {}
        )
    }
    .padding()
}
