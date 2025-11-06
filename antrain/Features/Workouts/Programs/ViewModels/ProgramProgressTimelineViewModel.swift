//
//  ProgramProgressTimelineViewModel.swift
//  antrain
//
//  ViewModel for program progress timeline
//

import Foundation
import Observation

@Observable
@MainActor
final class ProgramProgressTimelineViewModel {
    // MARK: - State

    private(set) var hasActiveProgram = false
    private(set) var activeProgram: TrainingProgram?
    private(set) var todayWorkout: ProgramDay?
    private(set) var currentWeekNumber = 0
    private(set) var totalWeeks = 0
    private(set) var streakDays = 0
    private(set) var adherencePercentage = 0.0
    private(set) var workoutsCompletedThisWeek = 0
    private(set) var totalWorkoutsThisWeek = 0
    private(set) var totalVolumeThisWeek = 0.0
    private(set) var timelineItems: [TimelineItem] = []
    private(set) var isLoading = false

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol
    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - Initialization

    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        workoutRepository: WorkoutRepositoryProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.workoutRepository = workoutRepository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let userProfile = try await userProfileRepository.fetchOrCreateProfile()

            guard let activeProgram = userProfile.activeProgram,
                  let startDate = userProfile.activeProgramStartDate,
                  let currentWeek = userProfile.currentWeekNumber else {
                hasActiveProgram = false
                self.activeProgram = nil
                self.todayWorkout = nil
                return
            }

            hasActiveProgram = true
            self.activeProgram = activeProgram
            currentWeekNumber = currentWeek
            totalWeeks = activeProgram.durationWeeks

            // Preload all relationships to avoid lazy loading issues
            // Access weeks, days, and templates to force SwiftData to load them
            for week in activeProgram.weeks {
                _ = week.days.compactMap { day in
                    _ = day.template // Touch template to force load
                    _ = day.template?.exercises // Touch exercises too
                    return day
                }
            }

            // Get today's workout
            let calendar = Calendar.current
            let today = Date()
            let dayOfWeek = calendar.component(.weekday, from: today)

            self.todayWorkout = activeProgram.weeks
                .first(where: { $0.weekNumber == currentWeek })?
                .days
                .first(where: { $0.dayOfWeek == dayOfWeek })

            // Fetch all workouts
            let allWorkouts = try await workoutRepository.fetchAll()

            // Calculate streak and adherence
            calculateStreakAndAdherence(allWorkouts: allWorkouts, startDate: startDate, activeProgram: activeProgram)

            // Calculate this week's stats
            calculateWeekStats(allWorkouts: allWorkouts, currentWeek: currentWeek, activeProgram: activeProgram)

            // Build timeline (14 days: 7 past + today + 6 future)
            buildTimeline(allWorkouts: allWorkouts, activeProgram: activeProgram, startDate: startDate, currentWeek: currentWeek)

        } catch {
            print("❌ Failed to load timeline data: \(error)")
            hasActiveProgram = false
        }
    }

    // MARK: - Calculations

    private func calculateStreakAndAdherence(allWorkouts: [Workout], startDate: Date, activeProgram: TrainingProgram) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate total expected workouts since start
        let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: today).day ?? 0
        let weeksSinceStart = daysSinceStart / 7

        var expectedWorkouts = 0
        for weekNum in 1...min(weeksSinceStart + 1, activeProgram.weeks.count) {
            if let week = activeProgram.weeks.first(where: { $0.weekNumber == weekNum }) {
                expectedWorkouts += week.days.filter { $0.template != nil }.count
            }
        }

        // Count completed workouts
        let completedWorkouts = allWorkouts.filter { workout in
            workout.date >= startDate && workout.date <= Date()
        }.count

        // Calculate adherence
        if expectedWorkouts > 0 {
            adherencePercentage = (Double(completedWorkouts) / Double(expectedWorkouts)) * 100
        }

        // Calculate streak (consecutive days with workouts)
        var currentStreak = 0
        var checkDate = today

        for _ in 0..<30 { // Check last 30 days
            let hasWorkout = allWorkouts.contains { workout in
                calendar.isDate(workout.date, inSameDayAs: checkDate)
            }

            if hasWorkout {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        streakDays = currentStreak
    }

    private func calculateWeekStats(allWorkouts: [Workout], currentWeek: Int, activeProgram: TrainingProgram) {
        guard let week = activeProgram.weeks.first(where: { $0.weekNumber == currentWeek }) else {
            return
        }

        // Total workouts scheduled this week
        totalWorkoutsThisWeek = week.days.filter { $0.template != nil }.count

        // Get start of current week
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today

        // Count completed workouts this week
        let thisWeekWorkouts = allWorkouts.filter { workout in
            workout.date >= weekStart && workout.date < weekEnd
        }

        workoutsCompletedThisWeek = thisWeekWorkouts.count

        // Calculate total volume this week
        totalVolumeThisWeek = thisWeekWorkouts.reduce(0.0) { $0 + $1.totalVolume }
    }

    private func buildTimeline(allWorkouts: [Workout], activeProgram: TrainingProgram, startDate: Date, currentWeek: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var items: [TimelineItem] = []

        // Show 14 days: 7 past + today + 6 future
        for dayOffset in -7...6 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }

            // Calculate which week and day of week this date corresponds to
            let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: date).day ?? 0
            let weekNumber = (daysSinceStart / 7) + 1
            let dayOfWeek = calendar.component(.weekday, from: date)

            // Get the program day for this date
            let programDay = activeProgram.weeks
                .first(where: { $0.weekNumber == weekNumber })?
                .days
                .first(where: { $0.dayOfWeek == dayOfWeek })

            // Check if there's a completed workout on this date
            let completedWorkout = allWorkouts.first { workout in
                calendar.isDate(workout.date, inSameDayAs: date)
            }

            // Determine status
            let status: TimelineItemStatus
            if calendar.isDateInToday(date) {
                status = .today
            } else if completedWorkout != nil {
                status = .completed
            } else if date < today {
                status = .upcoming // Missed workout
            } else if programDay?.template == nil {
                status = .rest
            } else {
                status = .future
            }

            let item = TimelineItem(
                date: date,
                programDay: programDay,
                completedWorkout: completedWorkout,
                status: status
            )

            items.append(item)
        }

        timelineItems = items
    }

    // MARK: - Actions

    func advanceToNextWeek() async {
        guard let activeProgram = activeProgram,
              currentWeekNumber < activeProgram.durationWeeks else {
            return
        }

        do {
            try await userProfileRepository.advanceToNextWeek()

            // Reload data to reflect changes
            await loadData()
        } catch {
            print("❌ Failed to advance to next week: \(error)")
        }
    }
}
