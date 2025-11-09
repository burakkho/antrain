import SwiftUI

/// Exercise details list showing sets and volume for each exercise
struct ExerciseDetailsList: View {
    let exercises: [WorkoutExercise]

    var body: some View {
        ForEach(exercises) { workoutExercise in
            Section {
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                    SummarySetRow(set: set, index: index)
                }

                // Total Volume
                HStack {
                    Text("Total Volume")
                        .font(.callout)
                        .fontWeight(.medium)

                    Spacer()

                    Text(String(format: "%.0f kg", workoutExercise.sets.reduce(0.0) { $0 + $1.volume }))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            } header: {
                Text(workoutExercise.exercise?.name ?? "Unknown")
            }
        }
    }
}

// MARK: - Summary Set Row

private struct SummarySetRow: View {
    let set: WorkoutSet
    let index: Int

    var body: some View {
        HStack {
            Text("Set \(index + 1)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            Text("\(set.reps)")
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .trailing)

            Text("×")
                .font(.body)
                .foregroundStyle(.secondary)

            Text("\(Int(set.weight)) kg")
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            if set.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .imageScale(.small)
            }
        }
    }
}
