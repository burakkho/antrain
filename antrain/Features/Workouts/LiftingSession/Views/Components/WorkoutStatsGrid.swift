import SwiftUI

/// Workout stats grid with 2x2 layout
struct WorkoutStatsGrid: View {
    let exerciseCount: Int
    let totalSets: Int
    let durationDisplay: String
    let totalVolume: Double

    var body: some View {
        Section {
            VStack(spacing: 12) {
                // Row 1
                HStack(spacing: 12) {
                    statBox(title: "Exercises", value: "\(exerciseCount)", icon: "dumbbell.fill")
                    statBox(title: "Sets", value: "\(totalSets)", icon: "list.number")
                }

                // Row 2
                HStack(spacing: 12) {
                    statBox(title: "Duration", value: durationDisplay, icon: "clock.fill")
                    statBox(title: "Volume", value: String(format: "%.0f kg", totalVolume), icon: "scalemass.fill")
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        } header: {
            Text("Overview")
        }
    }

    // MARK: - Stat Box

    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}
