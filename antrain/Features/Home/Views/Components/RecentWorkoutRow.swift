import SwiftUI

/// Recent workout row for home screen
struct RecentWorkoutRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Workout type icon
            Image(systemName: workoutIcon)
                .font(.title2)
                .foregroundStyle(DSColors.primary)
                .frame(width: 40)

            // Workout info
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(workoutTypeText)
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.textPrimary)

                Text(workout.date, style: .date)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(DSColors.textTertiary)
        }
        .padding(DSSpacing.md)
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
    }

    // MARK: - Helpers

    private var workoutIcon: String {
        switch workout.type {
        case .lifting:
            return "dumbbell.fill"
        case .cardio:
            return "figure.run"
        case .metcon:
            return "flame.fill"
        }
    }

    private var workoutTypeText: String {
        switch workout.type {
        case .lifting:
            return "Lifting"
        case .cardio:
            return "Cardio"
        case .metcon:
            return "MetCon"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.sm) {
        RecentWorkoutRow(
            workout: Workout(date: Date(), type: .lifting)
        )

        RecentWorkoutRow(
            workout: Workout(date: Date().addingTimeInterval(-86400), type: .cardio)
        )

        RecentWorkoutRow(
            workout: Workout(date: Date().addingTimeInterval(-172800), type: .metcon)
        )
    }
    .padding()
}
