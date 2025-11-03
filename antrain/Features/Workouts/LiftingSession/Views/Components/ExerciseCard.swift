import SwiftUI

/// Exercise card with sets list and add set button
struct ExerciseCard: View {
    let workoutExercise: WorkoutExercise
    let onAddSet: () -> Void
    let onUpdateSet: (WorkoutSet, Int, Double) -> Void
    let onCompleteSet: (WorkoutSet) -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onDeleteExercise: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                // Delete exercise button
                Button(role: .destructive, action: onDeleteExercise) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundStyle(DSColors.error)
                }
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
                            onUpdate: { reps, weight in
                                onUpdateSet(set, reps, weight)
                            },
                            onComplete: {
                                onCompleteSet(set)
                            },
                            onDelete: {
                                onDeleteSet(set)
                            }
                        )
                    }
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
        .padding(DSSpacing.md)
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
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
        onAddSet: {},
        onUpdateSet: { _, _, _ in },
        onCompleteSet: { _ in },
        onDeleteSet: { _ in },
        onDeleteExercise: {}
    )
    .padding()
}
