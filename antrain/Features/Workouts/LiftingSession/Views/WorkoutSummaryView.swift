import SwiftUI

/// Workout summary view with notes input before saving
struct WorkoutSummaryView: View {
    let workout: Workout
    let exercises: [WorkoutExercise]
    let onSave: (String?) async -> Void
    let onCancel: () -> Void

    @State private var notes: String = ""
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    // Summary Stats
                    statsSection

                    // Exercises Summary
                    exercisesSummarySection

                    // Notes
                    notesSection

                    // Save Button
                    DSPrimaryButton(
                        title: "Save Workout",
                        action: {
                            Task {
                                isSaving = true
                                await onSave(notes.isEmpty ? nil : notes)
                                isSaving = false
                                dismiss()
                            }
                        },
                        isLoading: isSaving
                    )
                    .padding(.top, DSSpacing.md)
                }
                .padding(DSSpacing.md)
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        DSCard {
            VStack(spacing: DSSpacing.md) {
                HStack {
                    statItem(
                        title: "Exercises",
                        value: "\(exercises.count)"
                    )

                    Divider()

                    statItem(
                        title: "Total Sets",
                        value: "\(totalSets)"
                    )

                    Divider()

                    statItem(
                        title: "Duration",
                        value: formatDuration(workout.duration)
                    )
                }
                .frame(height: 60)
            }
        }
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(value)
                .font(DSTypography.title2)
                .foregroundStyle(DSColors.textPrimary)

            Text(title)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Exercises Summary Section

    private var exercisesSummarySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Exercises")
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            ForEach(exercises) { workoutExercise in
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(workoutExercise.exercise?.name ?? "Unknown")
                            .font(DSTypography.headline)

                        Text("\(workoutExercise.sets.count) sets")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Notes (Optional)")
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            TextField("How did it go?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .font(DSTypography.body)
                .padding(DSSpacing.sm)
                .background(DSColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
    }

    // MARK: - Helpers

    private var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Preview

#Preview {
    let exercise = Exercise(
        name: "Barbell Squat",
        category: .barbell,
        muscleGroups: [.quads],
        equipment: .barbell,
        isCustom: false,
        version: 1
    )

    let workoutExercise = WorkoutExercise(exercise: exercise, orderIndex: 0)
    workoutExercise.sets = [
        WorkoutSet(reps: 10, weight: 100, isCompleted: true),
        WorkoutSet(reps: 10, weight: 100, isCompleted: true)
    ]

    let workout = Workout(date: Date(), type: .lifting)
    workout.duration = 2400 // 40 minutes

    return WorkoutSummaryView(
        workout: workout,
        exercises: [workoutExercise],
        onSave: { _ in },
        onCancel: {}
    )
}
