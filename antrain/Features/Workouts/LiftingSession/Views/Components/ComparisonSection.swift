import SwiftUI

/// Comparison section showing workout vs previous workout
struct ComparisonSection: View {
    let volumeChange: Double?
    let workoutComparison: WorkoutComparison?

    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    var body: some View {
        Section {
            if let volumeChange {
                let sign = volumeChange > 0 ? "+" : ""
                let formattedChange = abs(volumeChange).formattedWeight(unit: weightUnit)
                comparisonRow(
                    title: "Volume",
                    value: "\(sign)\(formattedChange)",
                    isPositive: volumeChange > 0
                )
            }

            if let comparison = workoutComparison {
                comparisonRow(
                    title: "Sets",
                    value: "\(comparison.setsChange > 0 ? "+" : "")\(comparison.setsChange)",
                    isPositive: comparison.setsChange > 0
                )

                comparisonRow(
                    title: "Duration",
                    value: formatDurationChange(comparison.durationChange),
                    isPositive: comparison.durationChange < 0
                )
            }
        } header: {
            Label(String(localized: "vs Last Workout"), systemImage: "chart.line.uptrend.xyaxis")
        }
    }

    // MARK: - Comparison Row

    private func comparisonRow(title: String, value: String, isPositive: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Label {
                Text(value)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .imageScale(.small)
            }
            .foregroundStyle(isPositive ? .green : .red)
        }
    }

    // MARK: - Helpers

    private func formatDurationChange(_ duration: TimeInterval) -> String {
        let minutes = Int(abs(duration)) / 60
        let sign = duration < 0 ? "-" : "+"
        return "\(sign)\(minutes) min"
    }
}
