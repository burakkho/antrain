import SwiftUI

/// Header view displaying real-time workout statistics
struct WorkoutStatsHeaderView: View {
    let title: String?
    let startDate: Date
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
            // Duration (using native timer)
            DurationStatCard(
                icon: "clock.fill",
                title: "Duration",
                startDate: startDate
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

    private var formattedVolume: String {
        // Nil safety: guard against NaN, infinity, or negative values
        guard volume.isFinite, volume >= 0 else {
            return "0kg"
        }

        if volume >= 1000 {
            return String(format: "%.0fkg", volume / 1000 * 1000)
        } else {
            return String(format: "%.0fkg", volume)
        }
    }
}

// MARK: - Stat Card Components

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

/// Duration stat card using native SwiftUI timer (Apple WWDC 2025 best practice)
/// Automatically updates without manual timer - no view body re-renders needed
private struct DurationStatCard: View {
    let icon: String
    let title: String
    let startDate: Date

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Apple's native timer - updates automatically without triggering view body
            Text(startDate, style: .timer)
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
            startDate: Date().addingTimeInterval(-3665), // Started 1 hour, 1 minute, 5 seconds ago
            volume: 1021.0,
            completedExercises: 4,
            totalExercises: 8
        )
        .padding()

        WorkoutStatsHeaderView(
            title: nil,
            startDate: Date().addingTimeInterval(-125), // Started 2 minutes, 5 seconds ago
            volume: 450.0,
            completedExercises: 2,
            totalExercises: 5
        )
        .padding()
    }
}
