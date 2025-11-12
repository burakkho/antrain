import SwiftUI

/// Day information card showing stats, RPE, and modifiers
struct DayInfoCard: View {
    let day: ProgramDay
    let viewModel: DayDetailViewModel

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                // Day header
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(DSColors.primary)
                    Text(day.displayName)
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)
                }

                Divider()

                // Content based on day type
                if !day.isRestDay {
                    workoutDayContent
                } else {
                    restDayContent
                }
            }
        }
    }

    // MARK: - Workout Day Content

    private var workoutDayContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Workout stats
            HStack(spacing: DSSpacing.xl) {
                StatItemView(
                    icon: "dumbbell.fill",
                    value: "\(viewModel.sortedExercises.count)",
                    label: "Exercises"
                )

                StatItemView(
                    icon: "number",
                    value: "\(viewModel.totalSets)",
                    label: "Sets"
                )

                if let duration = day.template?.estimatedDurationFormatted {
                    StatItemView(
                        icon: "clock",
                        value: duration,
                        label: "Duration"
                    )
                }
            }
        }
    }

    // MARK: - Rest Day Content

    private var restDayContent: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: "zzz")
                .font(.title)
                .foregroundStyle(DSColors.textSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("Rest Day")
                    .font(DSTypography.title3)
                    .foregroundStyle(DSColors.textSecondary)
                Text("Active recovery and restoration")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
    }
}
