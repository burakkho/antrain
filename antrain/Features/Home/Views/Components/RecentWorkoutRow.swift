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
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
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
        workout.type.displayName
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
