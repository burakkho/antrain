import SwiftUI

/// Workout detail view showing full exercise/set list
struct WorkoutDetailView: View {
    let workout: Workout
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                // Workout metadata
                metadataSection

                // Type-specific content
                switch workout.type {
                case .lifting:
                    if !workout.exercises.isEmpty {
                        exercisesSection
                    }
                case .cardio:
                    cardioSection
                case .metcon:
                    metconSection
                }

                // Notes / Workout Description
                if let notes = workout.notes, !notes.isEmpty {
                    let title = workout.type == .metcon ? "Workout Description" : "Notes"
                    notesSection(notes: notes, title: title)
                }
            }
            .padding(DSSpacing.md)
        }
        .navigationTitle(workoutTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        DSCard {
            VStack(spacing: DSSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text("Date")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)

                        Text(workout.date, style: .date)
                            .font(DSTypography.body)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: DSSpacing.xxs) {
                        Text("Duration")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)

                        Text(formatDuration(workout.duration))
                            .font(DSTypography.body)
                    }
                }

                Divider()

                // Stats row
                HStack(spacing: DSSpacing.md) {
                    switch workout.type {
                    case .lifting:
                        statItem(title: "Exercises", value: "\(workout.exercises.count)")
                        Divider()
                        statItem(title: "Total Sets", value: "\(workout.totalSets)")
                        Divider()
                        statItem(title: "Volume", value: workout.totalVolume.formattedWeight(unit: weightUnit))
                    case .cardio:
                        if let distance = workout.cardioDistance, distance > 0 {
                            statItem(title: "Distance", value: distance.formattedDistance(unit: weightUnit))
                        }
                        if let pace = workout.cardioPace, pace > 0 {
                            if workout.cardioDistance != nil { Divider() }
                            statItem(title: "Avg Pace", value: String(format: "%.2f min/km", pace))
                        }
                    case .metcon:
                        if let rounds = workout.metconRounds, rounds > 0 {
                            statItem(title: "Rounds", value: "\(rounds)")
                        }
                        if let metconType = workout.metconType {
                            if workout.metconRounds != nil { Divider() }
                            statItem(title: "Type", value: metconType.uppercased())
                        }
                    }
                }
                .frame(height: 50)
            }
        }
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(value)
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textPrimary)

            Text(title)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Exercises Section

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Exercises")
                .font(DSTypography.title3)

            ForEach(workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { workoutExercise in
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                            .font(DSTypography.headline)

                        if !workoutExercise.sets.isEmpty {
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                                    HStack {
                                        Text("Set \(index + 1)")
                                            .font(DSTypography.subheadline)
                                            .foregroundStyle(DSColors.textSecondary)
                                            .frame(width: 60, alignment: .leading)

                                        Text("\(set.reps) reps × \(set.weight.formattedWeight(unit: weightUnit))")
                                            .font(DSTypography.body)

                                        Spacer()

                                        if set.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(DSColors.success)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cardio Section

    private var cardioSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Cardio Details")
                .font(DSTypography.title3)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if let cardioType = workout.cardioType {
                        HStack {
                            Text("Type")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Text(cardioType.capitalized)
                                .font(DSTypography.body)
                        }
                    }

                    if let distance = workout.cardioDistance, distance > 0 {
                        HStack {
                            Text("Distance")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Text(distance.formattedDistance(unit: weightUnit))
                                .font(DSTypography.body)
                        }
                    }

                    if let pace = workout.cardioPace, pace > 0 {
                        HStack {
                            Text("Pace")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Text(String(format: "%.2f min/km", pace))
                                .font(DSTypography.body)
                        }
                    }
                }
            }
        }
    }

    // MARK: - MetCon Section

    private var metconSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("MetCon Details")
                .font(DSTypography.title3)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if let metconType = workout.metconType {
                        HStack {
                            Text("Type")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Text(metconType.uppercased())
                                .font(DSTypography.body)
                        }
                    }

                    if let rounds = workout.metconRounds, rounds > 0 {
                        HStack {
                            Text("Rounds")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Text("\(rounds)")
                                .font(DSTypography.body)
                        }
                    }

                    if let result = workout.metconResult, !result.isEmpty {
                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text("Result")
                                .font(DSTypography.subheadline)
                                .foregroundStyle(DSColors.textSecondary)
                            Text(result)
                                .font(DSTypography.body)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notes Section

    private func notesSection(notes: String, title: String = "Notes") -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(DSTypography.title3)

            DSCard {
                Text(notes)
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    // MARK: - Helpers

    private var workoutTitle: String {
        switch workout.type {
        case .lifting:
            return "Lifting Workout"
        case .cardio:
            return "Cardio Workout"
        case .metcon:
            return "MetCon Workout"
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            // 1+ hours: show "1h 25m"
            return "\(hours)h \(minutes)m"
        } else if seconds > 0 {
            // < 1 hour with seconds: show "25m 30s"
            return "\(minutes)m \(seconds)s"
        } else {
            // Exactly minutes: show "25 min"
            return "\(minutes) min"
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let workout = Workout(date: Date(), type: .lifting)
        workout.duration = 2400

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
            WorkoutSet(reps: 10, weight: 100, isCompleted: true),
            WorkoutSet(reps: 8, weight: 100, isCompleted: true)
        ]

        workout.exercises = [workoutExercise]
        workout.notes = "Great workout! Felt strong today."

        return WorkoutDetailView(workout: workout)
    }
}
