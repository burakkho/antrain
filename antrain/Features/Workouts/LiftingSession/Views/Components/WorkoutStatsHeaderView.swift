import SwiftUI

/// Header view displaying real-time workout statistics
struct WorkoutStatsHeaderView: View {
    let title: String?
    let duration: TimeInterval
    let volume: Double
    let completedExercises: Int
    let totalExercises: Int

    var body: some View {
        VStack(spacing: 12) {
            // Title (if available)
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Stats
            statsRow
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            // Duration
            StatCard(
                icon: "clock.fill",
                title: "Duration",
                value: formattedDuration
            )

            Divider()
                .frame(height: 60)
                .padding(.vertical, 8)

            // Volume
            StatCard(
                icon: "scalemass.fill",
                title: "Volume",
                value: formattedVolume
            )

            Divider()
                .frame(height: 60)
                .padding(.vertical, 8)

            // Exercises Done
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Exercises Done",
                value: "\(completedExercises) / \(totalExercises)"
            )
        }
    }

    // MARK: - Formatting

    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private var formattedVolume: String {
        if volume >= 1000 {
            return String(format: "%.1fkg", volume / 1000 * 1000)
        } else {
            return String(format: "%.0fkg", volume)
        }
    }
}

// MARK: - Stat Card Component

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        WorkoutStatsHeaderView(
            title: "Push Day",
            duration: 3665, // 1 hour, 1 minute, 5 seconds
            volume: 1021.0,
            completedExercises: 4,
            totalExercises: 8
        )
        .padding()

        WorkoutStatsHeaderView(
            title: nil,
            duration: 125, // 2 minutes, 5 seconds
            volume: 450.0,
            completedExercises: 2,
            totalExercises: 5
        )
        .padding()
    }
}
