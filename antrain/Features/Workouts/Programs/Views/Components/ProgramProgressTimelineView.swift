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

                // Day Progress Card
                DayProgressCard(
                    currentDay: viewModel.currentDayNumber,
                    totalDays: viewModel.totalDays,
                    completedWorkouts: viewModel.completedWorkouts
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
            Label(String(localized: "No Active Program"), systemImage: "calendar.badge.exclamationmark")
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

// MARK: - Day Progress Card

struct DayProgressCard: View {
    let currentDay: Int
    let totalDays: Int
    let completedWorkouts: Int

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    Text("Day \(currentDay) of \(totalDays)", comment: "Current day indicator")
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(completedWorkouts) workouts", comment: "Total workouts completed")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                ProgressView(value: Double(currentDay), total: Double(totalDays))
                    .tint(DSColors.primary)

                HStack(spacing: DSSpacing.lg) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Progress", comment: "Progress percentage label")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(Int((Double(currentDay) / Double(totalDays)) * 100))%")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining", comment: "Remaining days label")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(totalDays - currentDay) days")
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

                Rectangle()
                    .fill(item.status == .future ? item.status.color.opacity(0.1) : item.status.color.opacity(0.3)) // Lighter for future
                    .frame(width: 2)
            }

            // Content
            VStack(alignment: .leading, spacing: DSSpacing.sm) { // This is the content VStack
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
                        Label(String(localized: "\(workout.totalSets) sets"), systemImage: "list.bullet")
                        Text("•")
                        Label(String(localized: "\(Int(workout.totalVolume)) kg"), systemImage: "scalemass")
                    }
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
                }
            }
            .padding(DSSpacing.md) // Apply padding directly
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                    .fill(DSColors.backgroundSecondary)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }
}

// MARK: - Preview

#Preview {
    ProgramProgressTimelineView()
        .environmentObject(AppDependencies.preview)
}
