import SwiftUI

/// Programs view for managing training programs and tracking progress
struct WorkoutProgramsView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: ProgramProgressTimelineViewModel?
    @State private var showProgramsList = false
    @State private var showProgressStats = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
                        DSLoadingView(message: "Loading program...")
                    } else {
                        contentView(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProgramsList = true
                    } label: {
                        Image(systemName: "book.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showProgramsList) {
                NavigationStack {
                    ProgramsListView()
                        .environmentObject(appDependencies)
                }
            }
            .sheet(isPresented: $showProgressStats) {
                ProgramProgressStatsView()
                    .environmentObject(appDependencies)
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ProgramProgressTimelineViewModel(
                        userProfileRepository: appDependencies.userProfileRepository,
                        workoutRepository: appDependencies.workoutRepository
                    )
                    Task {
                        await viewModel?.loadData()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToProgramsTab"))) { _ in
                // Reload data when program is activated
                Task {
                    await viewModel?.loadData()
                }
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(viewModel: ProgramProgressTimelineViewModel) -> some View {
        if viewModel.hasActiveProgram {
            activeProgramContent(viewModel: viewModel)
        } else {
            noProgramState
        }
    }

    // MARK: - Active Program Content

    @ViewBuilder
    private func activeProgramContent(viewModel: ProgramProgressTimelineViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Active Program Card
                if let activeProgram = viewModel.activeProgram {
                    ActiveProgramCard(
                        program: activeProgram,
                        currentWeekNumber: viewModel.currentWeekNumber,
                        todayWorkout: viewModel.todayWorkout,
                        onStartWorkout: {
                            if let todayWorkout = viewModel.todayWorkout,
                               let template = todayWorkout.template {
                                workoutManager.startWorkoutFromProgram(template, programDay: todayWorkout)
                            }
                        },
                        onNextWeek: {
                            Task {
                                await viewModel.advanceToNextWeek()
                            }
                        }
                    )
                    .padding(.horizontal, DSSpacing.md)
                }

                // Quick Actions for Programs
                programActionsSection

                // Workout Streak Card
                if viewModel.streakDays > 0 {
                    WorkoutStreakCard(
                        streakDays: viewModel.streakDays,
                        adherencePercentage: viewModel.adherencePercentage
                    )
                    .padding(.horizontal, DSSpacing.md)
                }

                // Week Overview Card
                WeekOverviewCard(
                    currentWeek: viewModel.currentWeekNumber,
                    totalWeeks: viewModel.totalWeeks,
                    workoutsThisWeek: viewModel.workoutsCompletedThisWeek,
                    totalWorkoutsThisWeek: viewModel.totalWorkoutsThisWeek,
                    totalVolumeThisWeek: viewModel.totalVolumeThisWeek
                )
                .padding(.horizontal, DSSpacing.md)

                // Timeline Section
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Your Schedule", comment: "Timeline section header")
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, DSSpacing.md)

                    ForEach(viewModel.timelineItems) { item in
                        TimelineItemCard(item: item)
                    }
                }
            }
            .padding(.vertical, DSSpacing.md)
        }
        .background(DSColors.backgroundPrimary)
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - Program Actions Section

    private var programActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Actions")
                .font(DSTypography.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, DSSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    ProgramActionCard(
                        icon: "book.fill",
                        title: "Browse",
                        subtitle: "All Programs"
                    ) {
                        showProgramsList = true
                    }

                    ProgramActionCard(
                        icon: "calendar",
                        title: "Calendar",
                        subtitle: "View Schedule"
                    ) {
                        // Switch to Workouts tab and open calendar view
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToWorkoutsCalendar"), object: nil)
                    }

                    ProgramActionCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress",
                        subtitle: "View Stats"
                    ) {
                        showProgressStats = true
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    // MARK: - No Program State

    private var noProgramState: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            VStack(spacing: DSSpacing.md) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 64))
                    .foregroundStyle(DSColors.textSecondary)

                Text("No Active Program")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.textPrimary)

                Text("Start a structured training program to reach your fitness goals")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.xl)

                Button {
                    showProgramsList = true
                } label: {
                    Label("Browse Programs", systemImage: "book.fill")
                        .font(DSTypography.body)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, DSSpacing.md)
            }

            Spacer()

            // Info Cards
            VStack(spacing: DSSpacing.sm) {
                InfoCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Structured Progress",
                    description: "Follow proven programs with progressive overload"
                )

                InfoCard(
                    icon: "calendar.badge.clock",
                    title: "Weekly Planning",
                    description: "Know exactly what to do each training day"
                )

                InfoCard(
                    icon: "trophy.fill",
                    title: "Track Results",
                    description: "Monitor your progress and celebrate achievements"
                )
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}

// MARK: - Program Action Card

private struct ProgramActionCard: View {
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
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.md)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Card

private struct InfoCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(DSColors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColors.textPrimary)

                Text(description)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}

// MARK: - Preview

#Preview("Active Program") {
    WorkoutProgramsView()
        .environmentObject(AppDependencies.preview)
}

#Preview("No Program") {
    WorkoutProgramsView()
        .environmentObject(AppDependencies.preview)
}
