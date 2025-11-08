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
                    quickActionsSection

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

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick Actions")
                .font(DSTypography.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, DSSpacing.md)

            HStack(spacing: DSSpacing.sm) {
                QuickActionButton(
                    icon: "dumbbell.fill",
                    title: "Start Lifting"
                ) {
                    workoutManager.showFullScreen = true
                }

                QuickActionButton(
                    icon: "figure.run",
                    title: "Log Cardio"
                ) {
                    showCardioLog = true
                }

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
                        calendarItemCard(item: item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func calendarItemCard(item: CalendarItem) -> some View {
        Group {
            switch item.type {
            case .completed(let workout):
                // Completed workout - navigate to detail
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    itemCardContent(item: item)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel?.deleteWorkout(workout)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }

            case .planned(let programDay, let weekModifier):
                // Planned workout - tap to preview, swipe to start/skip
                Group {
                    if let template = programDay.template {
                        Button {
                            previewProgramDay = programDay
                            previewWeekModifier = weekModifier
                            showWorkoutPreview = true
                        } label: {
                            itemCardContent(item: item)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Template not available - show non-interactive card
                        itemCardContent(item: item)
                            .opacity(0.5)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        // Start workout
                        if let template = programDay.template {
                            workoutManager.startWorkoutFromProgram(template, programDay: programDay)
                        }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        // Skip workout (mark as completed with empty data)
                        // TODO: Implement skip logic
                    } label: {
                        Label("Skip", systemImage: "forward.fill")
                    }
                    .tint(.orange)
                }

            case .rest:
                // Rest day - no actions
                itemCardContent(item: item)
            }
        }
    }

    private func itemCardContent(item: CalendarItem) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Icon with status indicator
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(itemColor(for: item))
                    .frame(width: 40, height: 40)

                // Status badge
                if item.type.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .background(Circle().fill(.green).frame(width: 16, height: 16))
                        .offset(x: 4, y: 4)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(DSTypography.subheadline)
                    .fontWeight(item.type.isCompleted ? .semibold : .regular)
                    .foregroundStyle(DSColors.textPrimary)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                // Type indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(itemColor(for: item))
                        .frame(width: 6, height: 6)

                    Text(itemTypeLabel(for: item))
                        .font(.caption2)
                        .foregroundStyle(itemColor(for: item))
                }
            }

            Spacer()

            // Chevron for completed and planned workouts
            if item.type.isCompleted || item.type.isPlanned {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
        .padding(DSSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .overlay {
            // Border styling
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .strokeBorder(
                    itemColor(for: item).opacity(item.type.isPlanned ? 0.5 : 0.2),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: item.type.isPlanned ? [5, 3] : []
                    )
                )
        }
        .opacity(item.type.isRest ? 0.6 : 1.0)
    }

    // MARK: - Calendar Item Styling Helpers

    private func itemColor(for item: CalendarItem) -> Color {
        switch item.type {
        case .completed:
            return .green
        case .planned:
            return .orange
        case .rest:
            return .blue
        }
    }

    private func itemTypeLabel(for item: CalendarItem) -> String {
        switch item.type {
        case .completed:
            return String(localized: "Completed")
        case .planned:
            return String(localized: "Planned")
        case .rest:
            return String(localized: "Rest")
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
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Quick Actions")
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, DSSpacing.md)
                    
                    HStack(spacing: DSSpacing.sm) {
                        QuickActionButton(
                            icon: "dumbbell.fill",
                            title: "Start Lifting"
                        ) {}
                        
                        QuickActionButton(
                            icon: "figure.run",
                            title: "Log Cardio"
                        ) {}
                        
                        QuickActionButton(
                            icon: "flame.fill",
                            title: "Log MetCon"
                        ) {}
                    }
                    .padding(.horizontal, DSSpacing.md)
                }
                
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
                    
                    DSCard {
                        HStack(spacing: DSSpacing.md) {
                            Image(systemName: "figure.run")
                                .font(.title2)
                                .foregroundStyle(.blue)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text("Cardio")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColors.textPrimary)
                                
                                Text("Yesterday")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                                
                                Text("30 min")
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
