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
    private(set) var currentDayNumber = 0
    private(set) var totalDays = 0
    private(set) var streakDays = 0
    private(set) var adherencePercentage = 0.0
    private(set) var completedWorkouts = 0
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
                  let currentDay = userProfile.currentDayNumber else {
                hasActiveProgram = false
                self.activeProgram = nil
                self.todayWorkout = nil
                return
            }

            hasActiveProgram = true
            self.activeProgram = activeProgram
            currentDayNumber = currentDay
            totalDays = activeProgram.totalDays

            // Preload all relationships to avoid lazy loading issues
            // Access days and templates to force SwiftData to load them
            for day in activeProgram.days {
                _ = day.template // Touch template to force load
                _ = day.template?.exercises // Touch exercises too
            }

            // Get today's workout (current day in program)
            self.todayWorkout = activeProgram.day(number: currentDay)

            // Fetch all workouts
            let allWorkouts = try await workoutRepository.fetchAll()

            // Calculate streak and adherence
            calculateStreakAndAdherence(allWorkouts: allWorkouts, startDate: startDate, activeProgram: activeProgram, userProfile: userProfile)

            // Build timeline (14 days: 7 past + today + 6 future)
            buildTimeline(allWorkouts: allWorkouts, activeProgram: activeProgram, startDate: startDate, currentDay: currentDay)

        } catch {
            print("❌ Failed to load timeline data: \(error)")
            hasActiveProgram = false
        }
    }

    // MARK: - Calculations

    private func calculateStreakAndAdherence(allWorkouts: [Workout], startDate: Date, activeProgram: TrainingProgram, userProfile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Count program workouts (workouts that were started from the program)
        let programWorkouts = allWorkouts.filter { workout in
            workout.isFromProgram && workout.programId == activeProgram.id
        }

        completedWorkouts = programWorkouts.count
        adherencePercentage = userProfile.programProgress * 100

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

    private func buildTimeline(allWorkouts: [Workout], activeProgram: TrainingProgram, startDate: Date, currentDay: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var items: [TimelineItem] = []

        // Show program days around current day: currentDay-7 to currentDay+6
        let startDayNumber = max(1, currentDay - 7)
        let endDayNumber = min(activeProgram.totalDays, currentDay + 6)

        for dayNumber in startDayNumber...endDayNumber {
            // Get the program day
            let programDay = activeProgram.day(number: dayNumber)

            // Calculate expected date for this program day
            // Day 1 starts at startDate, Day 2 is startDate + 1 day, etc.
            let daysSinceStart = dayNumber - 1
            guard let expectedDate = calendar.date(byAdding: .day, value: daysSinceStart, to: calendar.startOfDay(for: startDate)) else {
                continue
            }

            // Check if there's a completed workout for this program day
            let completedWorkout = allWorkouts.first { workout in
                workout.programDayNumber == dayNumber && workout.programId == activeProgram.id
            }

            // Determine status
            let status: TimelineItemStatus
            if dayNumber == currentDay {
                status = .today
            } else if completedWorkout != nil {
                status = .completed
            } else if dayNumber < currentDay {
                status = .upcoming // Missed workout
            } else if programDay?.template == nil {
                status = .rest
            } else {
                status = .future
            }

            let item = TimelineItem(
                date: expectedDate,
                programDay: programDay,
                completedWorkout: completedWorkout,
                status: status
            )

            items.append(item)
        }

        timelineItems = items
    }

    // MARK: - Actions

    /// Manual progression to next day (auto progression happens in WorkoutSummaryViewModel)
    func advanceToNextDay() async {
        guard let activeProgram = activeProgram,
              currentDayNumber < activeProgram.totalDays else {
            return
        }

        do {
            try await userProfileRepository.advanceToNextDay()

            // Reload data to reflect changes
            await loadData()
        } catch {
            print("❌ Failed to advance to next day: \(error)")
        }
    }
}
