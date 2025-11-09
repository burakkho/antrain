import SwiftUI

/// Template exercise list preview
struct TemplateExerciseList: View {
    let template: WorkoutTemplate
    let exercises: [TemplateExercise]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Workout Plan")
                .font(DSTypography.headline)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Template header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(DSTypography.body)
                                .fontWeight(.semibold)
                            Text(template.category.displayName)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(DSColors.textTertiary)
                    }

                    Divider()

                    // Exercise list
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise)

                        if exercise != exercises.last {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: TemplateExercise

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Exercise order badge
            Text("\(exercise.order + 1)")
                .font(DSTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textSecondary)
                .frame(width: 24, height: 24)
                .background {
                    Circle()
                        .fill(DSColors.primary.opacity(0.1))
                }

            // Exercise details
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exerciseName)
                    .font(DSTypography.body)

                HStack(spacing: DSSpacing.xs) {
                    Text("\(exercise.setCount) sets")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    Text("•")
                        .foregroundStyle(DSColors.textTertiary)

                    if exercise.repRangeMin == exercise.repRangeMax {
                        Text("\(exercise.repRangeMin) reps")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    } else {
                        Text("\(exercise.repRangeMin)-\(exercise.repRangeMax) reps")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                // Exercise notes
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textTertiary)
                        .italic()
                }
            }

            Spacer()
        }
    }
}
