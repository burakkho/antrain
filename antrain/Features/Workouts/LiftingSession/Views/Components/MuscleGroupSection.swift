import SwiftUI

/// Muscle group breakdown section
struct MuscleGroupSection: View {
    let muscleGroupStats: [MuscleGroupStats]

    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    var body: some View {
        Section {
            ForEach(Array(muscleGroupStats.prefix(5)), id: \.muscleGroup) { stat in
                HStack {
                    Text(stat.muscleGroup.displayName)
                        .foregroundStyle(.primary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(stat.volume.formattedWeight(unit: weightUnit))
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
