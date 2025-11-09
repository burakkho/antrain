import SwiftUI

/// Workout list view with filtering and pagination
struct WorkoutListView: View {
    let workouts: [Workout]
    let selectedFilter: WorkoutTypeFilter
    let limit: Int

    init(workouts: [Workout], selectedFilter: WorkoutTypeFilter = .all, limit: Int = 5) {
        self.workouts = workouts
        self.selectedFilter = selectedFilter
        self.limit = limit
    }

    var body: some View {
        let filtered = filteredWorkouts
        let displayed = Array(filtered.prefix(limit))
        let hasMore = filtered.count > limit

        VStack(spacing: DSSpacing.sm) {
            // Workouts list
            LazyVStack(spacing: DSSpacing.sm) {
                ForEach(displayed) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        workoutCard(workout)
                    }
                    .buttonStyle(.plain)
                }
            }

            // "View All" button if there are more workouts
            if hasMore {
                viewAllButton(totalCount: filtered.count)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Workout Card

    private func workoutCard(_ workout: Workout) -> some View {
        DSCard {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: workoutIcon(for: workout.type))
                    .font(.title2)
                    .foregroundStyle(workoutColor(for: workout.type))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(workout.type.displayName)
                        .font(DSTypography.headline)
                        .foregroundStyle(DSColors.textPrimary)

                    Text(workout.date, style: .date)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    if let info = workoutInfo(for: workout) {
                        Text(info)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    // MARK: - View All Button

    private func viewAllButton(totalCount: Int) -> some View {
        NavigationLink(destination: WorkoutHistoryFullView()) {
            HStack {
                Text("View All")
                    .font(DSTypography.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(totalCount) workouts")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .padding(DSSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.md)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DSCornerRadius.md)
                    .strokeBorder(DSColors.primary.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filtering

    private var filteredWorkouts: [Workout] {
        guard selectedFilter != .all else {
            return workouts
        }

        return workouts.filter { workout in
            switch selectedFilter {
            case .all:
                return true
            case .lifting:
                return workout.type == .lifting
            case .cardio:
                return workout.type == .cardio
            case .metcon:
                return workout.type == .metcon
            }
        }
    }

    // MARK: - Helpers

    private func workoutIcon(for type: WorkoutType) -> String {
        switch type {
        case .lifting: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .metcon: return "flame.fill"
        }
    }

    private func workoutColor(for type: WorkoutType) -> Color {
        switch type {
        case .lifting: return DSColors.primary
        case .cardio: return .blue
        case .metcon: return .orange
        }
    }

    private func workoutInfo(for workout: Workout) -> String? {
        switch workout.type {
        case .lifting:
            let exerciseCount = workout.exercises.count
            return "\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
        case .cardio:
            if workout.duration > 0 {
                let minutes = Int(workout.duration / 60)
                return "\(minutes) min"
            }
            return nil
        case .metcon:
            if workout.duration > 0 {
                let minutes = Int(workout.duration / 60)
                return "\(minutes) min"
            }
            return nil
        }
    }
}
