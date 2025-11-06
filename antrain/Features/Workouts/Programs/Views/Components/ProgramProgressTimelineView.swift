//
//  ProgramProgressTimelineView.swift
//  antrain
//
//  Program progress timeline with past, present, and future workouts
//

import SwiftUI

/// Timeline view showing program progress with past/present/future workouts
struct ProgramProgressTimelineView: View {
    @EnvironmentObject private var deps: AppDependencies
    @State private var viewModel: ProgramProgressTimelineViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.hasActiveProgram {
                    timelineContent(viewModel: viewModel)
                } else {
                    noProgramState
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProgramProgressTimelineViewModel(
                    userProfileRepository: deps.userProfileRepository,
                    workoutRepository: deps.workoutRepository
                )
                Task {
                    await viewModel?.loadData()
                }
            }
        }
        .refreshable {
            await viewModel?.loadData()
        }
    }

    // MARK: - Timeline Content

    @ViewBuilder
    private func timelineContent(viewModel: ProgramProgressTimelineViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Workout Streak Card
                if viewModel.streakDays > 0 {
                    WorkoutStreakCard(
                        streakDays: viewModel.streakDays,
                        adherencePercentage: viewModel.adherencePercentage
                    )
                }

                // Week Overview Card
                WeekOverviewCard(
                    currentWeek: viewModel.currentWeekNumber,
                    totalWeeks: viewModel.totalWeeks,
                    workoutsThisWeek: viewModel.workoutsCompletedThisWeek,
                    totalWorkoutsThisWeek: viewModel.totalWorkoutsThisWeek,
                    totalVolumeThisWeek: viewModel.totalVolumeThisWeek
                )

                // Timeline
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Your Schedule", comment: "Timeline section header")
                        .font(DSTypography.title3)
                        .padding(.horizontal, DSSpacing.md)

                    ForEach(viewModel.timelineItems) { item in
                        TimelineItemCard(item: item)
                    }
                }
            }
            .padding(DSSpacing.md)
        }
        .background(DSColors.backgroundPrimary)
    }

    // MARK: - No Program State

    private var noProgramState: some View {
        ContentUnavailableView {
            Label("No Active Program", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("Activate a training program to see your schedule and track progress")
        } actions: {
            NavigationLink(destination: ProgramsListView()) {
                Text("Browse Programs")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Workout Streak Card

struct WorkoutStreakCard: View {
    let streakDays: Int
    let adherencePercentage: Double

    var body: some View {
        DSCard {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(streakDays) Day Streak", comment: "Workout streak title")
                        .font(DSTypography.title3)
                        .fontWeight(.bold)

                    Text("\(Int(adherencePercentage))% Program Adherence", comment: "Adherence percentage")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                Spacer()

                Text("🔥")
                    .font(.system(size: 32))
            }
        }
    }
}

// MARK: - Week Overview Card

struct WeekOverviewCard: View {
    let currentWeek: Int
    let totalWeeks: Int
    let workoutsThisWeek: Int
    let totalWorkoutsThisWeek: Int
    let totalVolumeThisWeek: Double

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    Text("Week \(currentWeek)/\(totalWeeks)", comment: "Current week indicator")
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(workoutsThisWeek)/\(totalWorkoutsThisWeek) workouts", comment: "Workouts completed this week")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                ProgressView(value: Double(workoutsThisWeek), total: Double(totalWorkoutsThisWeek))
                    .tint(DSColors.primary)

                HStack(spacing: DSSpacing.lg) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Volume", comment: "Total volume label")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(Int(totalVolumeThisWeek)) kg")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining", comment: "Remaining workouts label")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(totalWorkoutsThisWeek - workoutsThisWeek) workouts")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Timeline Item Card

struct TimelineItemCard: View {
    let item: TimelineItem

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(item.status.color)
                    .frame(width: 12, height: 12)

                if item.status != .future {
                    Rectangle()
                        .fill(item.status.color.opacity(0.3))
                        .frame(width: 2)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 0) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        // Date & Status
                        HStack {
                            Text(item.dateDisplay)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)

                            Spacer()

                            item.status.badge
                        }

                        // Workout info
                        if let programDay = item.programDay {
                            if programDay.template != nil {
                                Text(programDay.displayName)
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColors.textPrimary)

                                if let template = programDay.template {
                                    Text("\(template.exerciseCount) exercises")
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                            } else {
                                // Rest Day
                                HStack {
                                    Image(systemName: "moon.zzz.fill")
                                        .foregroundStyle(.blue)
                                    Text("Rest Day", comment: "Rest day label")
                                        .font(DSTypography.headline)
                                        .foregroundStyle(DSColors.textPrimary)
                                }

                                Text("Recovery is important", comment: "Rest day message")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                        }

                        // Completed workout stats
                        if let workout = item.completedWorkout {
                            HStack(spacing: DSSpacing.sm) {
                                Label("\(workout.totalSets) sets", systemImage: "list.bullet")
                                Text("•")
                                Label("\(Int(workout.totalVolume)) kg", systemImage: "scalemass")
                            }
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }

                Spacer().frame(height: DSSpacing.sm)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }
}

// MARK: - Supporting Types

enum TimelineItemStatus {
    case completed
    case today
    case upcoming
    case future
    case rest

    var color: Color {
        switch self {
        case .completed: return .green
        case .today: return .blue
        case .upcoming: return .orange
        case .future: return .gray
        case .rest: return .blue
        }
    }

    @ViewBuilder
    var badge: some View {
        switch self {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .today:
            Text("Today", comment: "Today badge")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue)
                .clipShape(Capsule())
        case .upcoming:
            Text("Upcoming", comment: "Upcoming badge")
                .font(.caption)
                .foregroundStyle(.orange)
        case .future, .rest:
            EmptyView()
        }
    }
}

struct TimelineItem: Identifiable {
    let id = UUID()
    let date: Date
    let programDay: ProgramDay?
    let completedWorkout: Workout?
    let status: TimelineItemStatus

    var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    ProgramProgressTimelineView()
        .environmentObject(AppDependencies.preview)
}
