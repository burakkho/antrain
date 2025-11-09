import SwiftUI

/// Full workout history view showing all workouts with filtering
struct WorkoutHistoryFullView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WorkoutsViewModel?
    @State private var selectedFilter: WorkoutTypeFilter = .all

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading {
                    DSLoadingView(message: "Loading workouts...")
                } else if let errorMessage = viewModel.errorMessage {
                    DSErrorView(
                        errorMessage: LocalizedStringKey(errorMessage),
                        retryAction: {
                            Task {
                                await viewModel.loadWorkouts()
                            }
                        }
                    )
                } else {
                    contentView(viewModel: viewModel)
                }
            } else {
                DSLoadingView(message: "Loading workouts...")
            }
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = WorkoutsViewModel(
                    workoutRepository: appDependencies.workoutRepository,
                    userProfileRepository: appDependencies.userProfileRepository
                )
                Task {
                    await viewModel?.loadWorkouts()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
            Task {
                await viewModel?.loadWorkouts()
            }
        }
    }

    // MARK: - Content View

    private func contentView(viewModel: WorkoutsViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                // Filter Segmented Control
                filterSection

                // Workouts List or Empty State
                if filteredWorkouts(viewModel: viewModel).isEmpty {
                    emptyFilteredState
                        .padding(.top, DSSpacing.xl)
                } else {
                    workoutsListSection(viewModel: viewModel)
                }
            }
            .padding(.vertical, DSSpacing.md)
        }
        .refreshable {
            await viewModel.loadWorkouts()
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(WorkoutTypeFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Empty Filtered State

    private var emptyFilteredState: some View {
        DSEmptyState(
            icon: "magnifyingglass",
            title: "No \(selectedFilter.rawValue) Workouts",
            message: "Try adjusting your filter or log a new workout."
        )
    }

    // MARK: - Workouts List Section

    private func workoutsListSection(viewModel: WorkoutsViewModel) -> some View {
        LazyVStack(spacing: DSSpacing.sm) {
            ForEach(filteredWorkouts(viewModel: viewModel)) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    DSCard {
                        HStack(spacing: DSSpacing.md) {
                            Image(systemName: workoutIcon(for: workout.type))
                                .font(.title2)
                                .foregroundStyle(workoutColor(for: workout.type))
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text(workoutTypeText(for: workout.type))
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
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Filtered Workouts

    private func filteredWorkouts(viewModel: WorkoutsViewModel) -> [Workout] {
        guard selectedFilter != .all else {
            return viewModel.workouts
        }

        return viewModel.workouts.filter { workout in
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

    private func workoutTypeText(for type: WorkoutType) -> String {
        type.displayName
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

// MARK: - Preview

#Preview {
    NavigationStack {
        WorkoutHistoryFullView()
            .environmentObject(AppDependencies.preview)
    }
}
