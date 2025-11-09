import SwiftUI

/// Workouts overview showing quick actions, PR tracking, and workout history
struct WorkoutsOverviewView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: WorkoutsViewModel?

    // Sheet states
    @State private var showCardioLog = false
    @State private var showMetConLog = false
    @State private var showWorkoutPreview = false
    @State private var previewProgramDay: ProgramDay?
    @State private var previewWeekModifier: Double = 1.0

    // Filter states
    @State private var selectedFilter: WorkoutTypeFilter = .all
    @Binding var viewMode: HistoryViewMode

    // Initialization with binding
    init(viewMode: Binding<HistoryViewMode>) {
        _viewMode = viewMode
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    viewModeToggle
                }
            }
            .sheet(isPresented: $showCardioLog) {
                CardioLogView()
                    .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showMetConLog) {
                MetConLogView()
                    .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showWorkoutPreview) {
                workoutPreviewSheet
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
                Task {
                    await viewModel?.loadWorkouts()
                }
            }
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
        }
    }

    // MARK: - Content View

    private func contentView(viewModel: WorkoutsViewModel) -> some View {
        ScrollView {
            if viewMode == .list {
                VStack(spacing: DSSpacing.md) {
                    // Quick Actions
                    QuickActionsCard(
                        onStartLifting: {
                            workoutManager.showFullScreen = true
                        },
                        onLogCardio: {
                            showCardioLog = true
                        },
                        onLogMetCon: {
                            showMetConLog = true
                        }
                    )

                    // PR Summary Card
                    DailyWorkoutSummary(limit: 5)
                        .environmentObject(appDependencies)
                        .padding(.horizontal, DSSpacing.md)

                    // Filter Segmented Control
                    filterSection

                    // Workouts List or Empty State
                    if filteredWorkouts(viewModel: viewModel).isEmpty {
                        emptyFilteredState
                            .padding(.top, DSSpacing.xl)
                    } else {
                        WorkoutListView(
                            workouts: viewModel.workouts,
                            selectedFilter: selectedFilter,
                            limit: 5
                        )
                    }
                }
                .padding(.vertical, DSSpacing.md)
            } else {
                // Calendar View
                DSCalendarView(items: viewModel.calendarItems, dateProvider: { $0.date }) { items in
                    calendarDayContent(items: items)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.md)
            }
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

    // MARK: - View Mode Toggle

    private var viewModeToggle: some View {
        Menu {
            Button {
                viewMode = .list
            } label: {
                Label("List View", systemImage: "list.bullet")
            }

            Button {
                viewMode = .calendar
            } label: {
                Label("Calendar View", systemImage: "calendar")
            }
        } label: {
            Image(systemName: viewMode == .list ? "list.bullet" : "calendar")
        }
    }

    // MARK: - Calendar Day Content

    @ViewBuilder
    private func calendarDayContent(items: [CalendarItem]) -> some View {
        if items.isEmpty {
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.title)
                    .foregroundStyle(DSColors.textSecondary)

                Text("No activities on this day")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.lg)
        } else {
            ScrollView {
                LazyVStack(spacing: DSSpacing.xs) {
                    ForEach(items) { item in
                        CalendarItemCardView(
                            item: item,
                            onDelete: { workout in
                                Task {
                                    await viewModel?.deleteWorkout(workout)
                                }
                            },
                            onStartWorkout: { template, programDay in
                                workoutManager.startWorkoutFromProgram(template, programDay: programDay)
                            },
                            onPreview: { programDay, weekModifier in
                                previewProgramDay = programDay
                                previewWeekModifier = weekModifier
                                showWorkoutPreview = true
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Workout Preview Sheet

    private var workoutPreviewSheet: some View {
        NavigationStack {
            if let previewDay = previewProgramDay, let template = previewDay.template {
                WorkoutPreviewView(
                    programDay: previewDay,
                    template: template,
                    weekModifier: previewWeekModifier
                )
                .navigationTitle(previewDay.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            showWorkoutPreview = false
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showWorkoutPreview = false
                            workoutManager.startWorkoutFromProgram(template, programDay: previewDay)
                        } label: {
                            Label("Start", systemImage: "play.fill")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty Filtered State

    private var emptyFilteredState: some View {
        DSEmptyState(
            icon: "magnifyingglass",
            title: "No \(selectedFilter.rawValue) Workouts",
            message: "Try adjusting your filter or log a new workout."
        )
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
}

// MARK: - Supporting Types

enum HistoryViewMode {
    case list
    case calendar
}

// MARK: - Preview

#Preview("List Mode") {
    @Previewable @State var viewMode: HistoryViewMode = .list
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    NavigationStack {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                // Quick Actions Preview
                QuickActionsCard(
                    onStartLifting: {},
                    onLogCardio: {},
                    onLogMetCon: {}
                )

                // Mock workout cards
                VStack(spacing: DSSpacing.sm) {
                    DSCard {
                        HStack(spacing: DSSpacing.md) {
                            Image(systemName: "dumbbell.fill")
                                .font(.title2)
                                .foregroundStyle(DSColors.primary)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text("Lifting")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColors.textPrimary)

                                Text("Today")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)

                                Text("5 exercises")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
            .padding(.vertical, DSSpacing.md)
        }
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Calendar Mode") {
    @Previewable @State var viewMode: HistoryViewMode = .calendar
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    WorkoutsOverviewView(viewMode: $viewMode)
        .environmentObject(AppDependencies.preview)
        .environment(workoutManager)
}
