import SwiftUI

/// Exercise card with sets list, collapse/expand, and add set button
struct ExerciseCard: View {
    // MARK: - Focus Management for Smart Navigation

    struct SetFieldIdentifier: Hashable {
        let setId: UUID
        let fieldType: SetRow.Field
    }

    let workoutExercise: WorkoutExercise
    let isKeyboardMode: Bool
    let suggestion: ExerciseSuggestion?
    let onAddSet: () -> Void
    let onUpdateSet: (WorkoutSet, Int, Double) -> Void
    let onToggleSet: (WorkoutSet) -> Void
    let onCompleteAllSets: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onDeleteExercise: () -> Void

    @State private var isExpanded: Bool = true
    @FocusState private var focusedField: SetFieldIdentifier?
    @State private var focusedFieldState: SetFieldIdentifier?
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header (tappable to collapse/expand)
            HStack {
                // Exercise name and icon
                HStack(spacing: 8) {
                    Image(systemName: workoutExercise.exercise?.category.icon ?? "dumbbell")
                        .font(.title3)
                        .foregroundStyle(DSColors.primary)

                    Text(workoutExercise.exercise?.name ?? String(localized: "Unknown Exercise"))
                        .font(DSTypography.headline)
                        .foregroundStyle(DSColors.textPrimary)
                }

                Spacer()

                // Collapsed state info
                if !isExpanded {
                    collapsedInfo
                }

                // Chevron indicator
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(DSColors.textSecondary)
                    .padding(.horizontal, 8)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .contextMenu {
                // Delete via long press context menu
                Button(role: .destructive, action: {
                    // ROADMAP: Phase 1, Day 1 - Haptic Feedback
                    // Warning haptic for destructive action
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                    onDeleteExercise()
                }) {
                    Label("Delete Exercise", systemImage: "trash")
                }
            }

            // Expanded content
            if isExpanded {
                // Suggestion banner (if available)
                if let suggestion = suggestion {
                    suggestionBanner(suggestion)
                }

                // Sets list
                if workoutExercise.sets.isEmpty {
                    Text("No sets yet. Tap \"Add Set\" to start.")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                        .padding(.vertical, DSSpacing.sm)
                } else {
                    VStack(spacing: DSSpacing.xs) {
                        ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                            SetRow(
                                set: set,
                                setNumber: index + 1,
                                isKeyboardMode: isKeyboardMode,
                                onUpdate: { reps, weight in
                                    onUpdateSet(set, reps, weight)
                                },
                                onToggle: {
                                    onToggleSet(set)
                                },
                                onDelete: {
                                    onDeleteSet(set)
                                },
                                focusedField: $focusedFieldState,
                                currentSetId: set.id,
                                onNavigateToNextSet: { currentFieldType in
                                    navigateToNextSet(from: index, fieldType: currentFieldType)
                                },
                                onNavigateToPreviousSet: { currentFieldType in
                                    navigateToPreviousSet(from: index, fieldType: currentFieldType)
                                }
                            )
                        }
                    }
                }

                HStack(spacing: DSSpacing.xs) {
                    // Complete All Sets button (only show if there are incomplete sets)
                    if hasIncompleteSets {
                        Button(action: onCompleteAllSets) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Complete All")
                            }
                            .font(DSTypography.subheadline)
                            .foregroundStyle(DSColors.success)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.sm)
                            .background(DSColors.success.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                        }
                    }

                    // Add Set button
                    Button(action: {
                        onAddSet()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Set")
                        }
                        .font(DSTypography.subheadline)
                        .foregroundStyle(DSColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(DSColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                    }
                }
            }
        }
        .padding(DSSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: {
                // ROADMAP: Phase 1, Day 1 - Haptic Feedback
                // Warning haptic for swipe delete
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                onDeleteExercise()
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .onChange(of: focusedFieldState) { _, newValue in
            focusedField = newValue
        }
    }

    // MARK: - Collapsed Info

    @ViewBuilder
    private var collapsedInfo: some View {
        HStack(spacing: 12) {
            // Set progress
            Text("\(completedSets)/\(totalSets) \(String(localized: "sets"))")
                .font(.caption)
                .foregroundStyle(DSColors.textSecondary)

            // Last set info
            if let lastSet = workoutExercise.sets.last {
                Text("•")
                    .foregroundStyle(DSColors.textTertiary)

                Text("\(lastSet.reps) × \(formattedWeight(lastSet.weight))")
                    .font(.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    // MARK: - Suggestion Banner

    @ViewBuilder
    private func suggestionBanner(_ suggestion: ExerciseSuggestion) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Suggested:")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    Text("\(suggestion.suggestedSets) × \(suggestion.suggestedReps) @ \(formattedWeight(suggestion.suggestedWeight))")
                        .font(DSTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColors.textPrimary)
                }

                Text(suggestion.reasoning.displayText)
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
            }

            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
    }

    // MARK: - Computed Properties

    private var completedSets: Int {
        workoutExercise.sets.filter { $0.isCompleted }.count
    }

    private var totalSets: Int {
        workoutExercise.sets.count
    }

    private var hasIncompleteSets: Bool {
        workoutExercise.sets.contains { !$0.isCompleted }
    }

    // MARK: - Helpers

    private func formattedWeight(_ weight: Double) -> String {
        let displayWeight: Double
        let unit: String

        if weightUnit == "Pounds" {
            displayWeight = weight * 2.20462 // kg to lbs
            unit = String(localized: "lbs")
        } else {
            displayWeight = weight
            unit = String(localized: "kg")
        }

        return String(format: "%.1f", displayWeight) + unit
    }

    // MARK: - Smart Navigation

    /// Navigate to the same field type in the next set (column-based navigation)
    private func navigateToNextSet(from currentIndex: Int, fieldType: SetRow.Field) {
        let nextIndex = currentIndex + 1

        // Check if there's a next set
        if nextIndex < workoutExercise.sets.count {
            let nextSet = workoutExercise.sets[nextIndex]
            // Focus on the SAME field type in the next set
            focusedFieldState = SetFieldIdentifier(setId: nextSet.id, fieldType: fieldType)
        } else {
            // Last set - dismiss keyboard
            focusedFieldState = nil
        }
    }

    /// Navigate to the same field type in the previous set (column-based navigation)
    private func navigateToPreviousSet(from currentIndex: Int, fieldType: SetRow.Field) {
        let previousIndex = currentIndex - 1

        // Check if there's a previous set
        if previousIndex >= 0 {
            let previousSet = workoutExercise.sets[previousIndex]
            // Focus on the SAME field type in the previous set
            focusedFieldState = SetFieldIdentifier(setId: previousSet.id, fieldType: fieldType)
        } else {
            // First set - dismiss keyboard
            focusedFieldState = nil
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var workoutExercise: WorkoutExercise = {
        let exercise = Exercise(
            name: "Barbell Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes],
            equipment: .barbell,
            isCustom: false,
            version: 1
        )

        let workoutEx = WorkoutExercise(
            exercise: exercise,
            orderIndex: 0
        )

        workoutEx.sets = [
            WorkoutSet(reps: 10, weight: 100, isCompleted: true),
            WorkoutSet(reps: 10, weight: 100, isCompleted: false)
        ]

        return workoutEx
    }()

    ExerciseCard(
        workoutExercise: workoutExercise,
        isKeyboardMode: false,
        suggestion: nil,
        onAddSet: {},
        onUpdateSet: { _, _, _ in },
        onToggleSet: { _ in },
        onCompleteAllSets: {},
        onDeleteSet: { _ in },
        onDeleteExercise: {}
    )
    .padding()
}
