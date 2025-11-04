import SwiftUI

/// Workouts hub view with Quick Actions, PR tracking, history, and filters
struct WorkoutsView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: WorkoutsViewModel?

    // Sheet states
    @State private var showLiftingSession = false
    @State private var showCardioLog = false
    @State private var showMetConLog = false
    @State private var showTemplatesList = false
    @State private var showTemplateSelector = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showCreateTemplate = false

    // Filter states
    @State private var selectedFilter: WorkoutTypeFilter = .all
    @State private var viewMode: ViewMode = .list

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
                    // Show loading while viewModel is being initialized
                    DSLoadingView(message: "Loading workouts...")
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    viewModeToggle
                }
            }
            .fullScreenCover(isPresented: $showLiftingSession) {
                LiftingSessionView(initialTemplate: selectedTemplate)
                    .environmentObject(appDependencies)
                    .onDisappear {
                        selectedTemplate = nil
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
            .sheet(isPresented: $showTemplatesList) {
                NavigationStack {
                    TemplatesListView()
                        .environmentObject(appDependencies)
                }
            }
            .sheet(isPresented: $showTemplateSelector) {
                TemplateQuickSelectorView { template in
                    selectedTemplate = template
                    showLiftingSession = true
                }
                .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showCreateTemplate) {
                CreateTemplateFlow {
                    Task {
                        await viewModel?.loadWorkouts()
                    }
                }
                .environmentObject(appDependencies)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
                Task {
                    await viewModel?.loadWorkouts()
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = WorkoutsViewModel(workoutRepository: appDependencies.workoutRepository)
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
                // List View: Quick Actions + PR + Filter + List
                VStack(spacing: DSSpacing.md) {
                    // Quick Actions
                    quickActionsSection

                    // My Templates Section
                    myTemplatesSection

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
                        workoutsListSection(viewModel: viewModel)
                    }
                }
                .padding(.vertical, DSSpacing.md)
            } else {
                // Calendar View: Full screen calendar only
                DSCalendarView(items: viewModel.workouts) { workouts in
                    calendarDayContent(workouts: workouts)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.md)
            }
        }
        .refreshable {
            await viewModel.loadWorkouts()
        }
    }

    // MARK: - My Templates Section

    private var myTemplatesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("My Templates")
                    .font(DSTypography.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showTemplatesList = true
                } label: {
                    Text("See All")
                        .font(DSTypography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(DSColors.primary)
                }
            }
            .padding(.horizontal, DSSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    // Recent/Most Used Templates (would need TemplatesViewModel)
                    // For now, show "Browse Templates" and "Create New" cards

                    // Browse Templates Card
                    TemplateQuickCard(
                        icon: "doc.text.fill",
                        title: "Browse",
                        subtitle: "All Templates"
                    ) {
                        showTemplatesList = true
                    }

                    // Start from Template Card
                    TemplateQuickCard(
                        icon: "play.fill",
                        title: "Start",
                        subtitle: "From Template"
                    ) {
                        showTemplateSelector = true
                    }

                    // Create Template Card
                    TemplateQuickCard(
                        icon: "plus.circle.fill",
                        title: "Create",
                        subtitle: "New Template"
                    ) {
                        showCreateTemplate = true
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick Actions")
                .font(DSTypography.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, DSSpacing.md)

            HStack(spacing: DSSpacing.sm) {
                // Start Lifting
                QuickActionButton(
                    icon: "dumbbell.fill",
                    title: "Start Lifting"
                ) {
                    showLiftingSession = true
                }

                // Log Cardio
                QuickActionButton(
                    icon: "figure.run",
                    title: "Log Cardio"
                ) {
                    showCardioLog = true
                }

                // Log MetCon
                QuickActionButton(
                    icon: "flame.fill",
                    title: "Log MetCon"
                ) {
                    showMetConLog = true
                }
            }
            .padding(.horizontal, DSSpacing.md)
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
        Button {
            viewMode = viewMode == .list ? .calendar : .list
        } label: {
            Image(systemName: viewMode == .list ? "calendar" : "list.bullet")
        }
    }

    // MARK: - Calendar Day Content

    @ViewBuilder
    private func calendarDayContent(workouts: [Workout]) -> some View {
        if workouts.isEmpty {
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.title)
                    .foregroundStyle(DSColors.textSecondary)

                Text("No workouts on this day")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.lg)
        } else {
            ScrollView {
                LazyVStack(spacing: DSSpacing.xs) {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            workoutCalendarCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func workoutCalendarCard(workout: Workout) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Workout type icon
            Image(systemName: workoutIcon(for: workout.type))
                .font(.title3)
                .foregroundStyle(workoutColor(for: workout.type))
                .frame(width: 32)

            // Workout info
            VStack(alignment: .leading, spacing: 2) {
                Text(workoutTypeText(for: workout.type))
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textPrimary)

                if let info = workoutInfo(for: workout) {
                    Text(info)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(DSSpacing.sm)
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
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
                            // Workout type icon
                            Image(systemName: workoutIcon(for: workout.type))
                                .font(.title2)
                                .foregroundStyle(workoutColor(for: workout.type))
                                .frame(width: 40)

                            // Workout info
                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text(workoutTypeText(for: workout.type))
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColors.textPrimary)

                                Text(workout.date, style: .date)
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)

                                // Additional info based on type
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
        case .lifting:
            return "dumbbell.fill"
        case .cardio:
            return "figure.run"
        case .metcon:
            return "flame.fill"
        }
    }

    private func workoutTypeText(for type: WorkoutType) -> String {
        switch type {
        case .lifting:
            return "Lifting"
        case .cardio:
            return "Cardio"
        case .metcon:
            return "MetCon"
        }
    }

    private func workoutColor(for type: WorkoutType) -> Color {
        switch type {
        case .lifting:
            return DSColors.primary
        case .cardio:
            return .blue
        case .metcon:
            return .orange
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

// MARK: - Supporting Types

enum WorkoutTypeFilter: String, CaseIterable {
    case all = "All"
    case lifting = "Lifting"
    case cardio = "Cardio"
    case metcon = "MetCon"
}

enum ViewMode {
    case list
    case calendar
}

// MARK: - Template Quick Card

private struct TemplateQuickCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(DSColors.primary)
                    .frame(height: 32)

                VStack(spacing: 2) {
                    Text(title)
                        .font(DSTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColors.textPrimary)

                    Text(subtitle)
                        .font(DSTypography.caption2)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .frame(width: 100)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    WorkoutsView()
        .environmentObject(AppDependencies.preview)
}
