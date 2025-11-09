import SwiftUI

/// Muscle group breakdown section
struct MuscleGroupSection: View {
    let muscleGroupStats: [MuscleGroupStats]

    var body: some View {
        Section {
            ForEach(Array(muscleGroupStats.prefix(5)), id: \.muscleGroup) { stat in
                HStack {
                    Text(stat.muscleGroup.displayName)
                        .foregroundStyle(.primary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f kg", stat.volume))
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text("\(stat.sets) sets")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }
}
