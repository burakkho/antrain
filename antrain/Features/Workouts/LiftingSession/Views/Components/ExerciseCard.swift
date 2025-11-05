import SwiftUI

/// Exercise card with sets list, collapse/expand, and add set button
struct ExerciseCard: View {
    let workoutExercise: WorkoutExercise
    let isKeyboardMode: Bool
    let onAddSet: () -> Void
    let onUpdateSet: (WorkoutSet, Int, Double) -> Void
    let onToggleSet: (WorkoutSet) -> Void
    let onCompleteAllSets: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onDeleteExercise: () -> Void

    @State private var isExpanded: Bool = true
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header (tappable to collapse/expand)
            Button(action: { withAnimation { isExpanded.toggle() } }) {
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
            }
            .buttonStyle(.plain)
            .contextMenu {
                // Delete via long press context menu
                Button(role: .destructive, action: onDeleteExercise) {
                    Label("Delete Exercise", systemImage: "trash")
                }
            }

            // Expanded content
            if isExpanded {
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
                    Button(action: onAddSet) {
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
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
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
}

// MARK: - Preview

#Preview {
    let exercise = Exercise(
        name: "Barbell Squat",
        category: .barbell,
        muscleGroups: [.quads, .glutes],
        equipment: .barbell,
        isCustom: false,
        version: 1
    )

    let workoutExercise = WorkoutExercise(
        exercise: exercise,
        orderIndex: 0
    )

    workoutExercise.sets = [
        WorkoutSet(reps: 10, weight: 100, isCompleted: true),
        WorkoutSet(reps: 10, weight: 100, isCompleted: false)
    ]

    return ExerciseCard(
        workoutExercise: workoutExercise,
        isKeyboardMode: false,
        onAddSet: {},
        onUpdateSet: { _, _, _ in },
        onToggleSet: { _ in },
        onCompleteAllSets: {},
        onDeleteSet: { _ in },
        onDeleteExercise: {}
    )
    .padding()
}
