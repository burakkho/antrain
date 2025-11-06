//
//  ProgramProgressStatsViewModel.swift
//  antrain
//
//  ViewModel for program progress and statistics tracking
//

import Foundation
import Observation

@Observable
@MainActor
final class ProgramProgressStatsViewModel {
    // MARK: - State

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Program info
    private(set) var program: TrainingProgram?
    private(set) var startDate: Date?
    private(set) var currentWeek: Int = 1
    private(set) var totalWeeks: Int = 0

    // Overall stats
    private(set) var completionPercentage: Double = 0.0
    private(set) var adherencePercentage: Double = 0.0
    private(set) var totalWorkoutsCompleted: Int = 0
    private(set) var totalWorkoutsPlanned: Int = 0
    private(set) var currentStreak: Int = 0

    // Volume stats
    private(set) var totalVolume: Double = 0.0
    private(set) var averageVolumePerWorkout: Double = 0.0
    private(set) var volumeByWeek: [WeekVolumeData] = []

    // Exercise stats
    private(set) var totalExercisesPerformed: Int = 0
    private(set) var uniqueExercises: Int = 0

    // Week comparison
    private(set) var weeklyComparison: [WeekComparisonData] = []

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
        errorMessage = nil
        defer { isLoading = false }

        do {
            let userProfile = try await userProfileRepository.fetchOrCreateProfile()

            guard let activeProgram = userProfile.activeProgram,
                  let programStartDate = userProfile.activeProgramStartDate,
                  let currentWeekNumber = userProfile.currentWeekNumber else {
                errorMessage = String(localized: "No active program found")
                return
            }

            program = activeProgram
            startDate = programStartDate
            currentWeek = currentWeekNumber
            totalWeeks = activeProgram.durationWeeks

            // Fetch all workouts
            let allWorkouts = try await workoutRepository.fetchAll()

            // Filter workouts for this program (from start date onwards)
            let programWorkouts = allWorkouts.filter { workout in
                workout.date >= programStartDate
            }

            // Calculate stats
            calculateOverallStats(programWorkouts: programWorkouts, activeProgram: activeProgram, startDate: programStartDate)
            calculateVolumeStats(programWorkouts: programWorkouts, activeProgram: activeProgram, startDate: programStartDate)
            calculateExerciseStats(programWorkouts: programWorkouts)
            calculateWeeklyComparison(programWorkouts: programWorkouts, activeProgram: activeProgram, startDate: programStartDate)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Calculations

    private func calculateOverallStats(programWorkouts: [Workout], activeProgram: TrainingProgram, startDate: Date) {
        let calendar = Calendar.current
        let today = Date()

        // Calculate total workouts planned up to today
        let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: calendar.startOfDay(for: today)).day ?? 0
        let weeksSinceStart = min((daysSinceStart / 7) + 1, activeProgram.weeks.count)

        var planned = 0
        for weekNum in 1...weeksSinceStart {
            if let week = activeProgram.weeks.first(where: { $0.weekNumber == weekNum }) {
                planned += week.days.filter { $0.template != nil }.count
            }
        }

        totalWorkoutsPlanned = planned
        totalWorkoutsCompleted = programWorkouts.count

        // Calculate completion percentage (of total program)
        let totalProgramWorkouts = activeProgram.weeks.reduce(0) { total, week in
            total + week.days.filter { $0.template != nil }.count
        }

        if totalProgramWorkouts > 0 {
            completionPercentage = (Double(totalWorkoutsCompleted) / Double(totalProgramWorkouts)) * 100
        }

        // Calculate adherence (of workouts planned so far)
        if totalWorkoutsPlanned > 0 {
            adherencePercentage = (Double(totalWorkoutsCompleted) / Double(totalWorkoutsPlanned)) * 100
        }

        // Calculate streak
        var streak = 0
        var checkDate = calendar.startOfDay(for: today)

        for _ in 0..<30 {
            let hasWorkout = programWorkouts.contains { workout in
                calendar.isDate(workout.date, inSameDayAs: checkDate)
            }

            if hasWorkout {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        currentStreak = streak
    }

    private func calculateVolumeStats(programWorkouts: [Workout], activeProgram: TrainingProgram, startDate: Date) {
        // Total volume
        totalVolume = programWorkouts.reduce(0.0) { $0 + $1.totalVolume }

        // Average volume per workout
        if totalWorkoutsCompleted > 0 {
            averageVolumePerWorkout = totalVolume / Double(totalWorkoutsCompleted)
        }

        // Volume by week
        let calendar = Calendar.current
        var weeklyData: [WeekVolumeData] = []

        for weekNum in 1...currentWeek {
            guard let week = activeProgram.weeks.first(where: { $0.weekNumber == weekNum }) else {
                continue
            }

            // Calculate date range for this week
            let weekStartOffset = (weekNum - 1) * 7
            guard let weekStart = calendar.date(byAdding: .day, value: weekStartOffset, to: startDate),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                continue
            }

            // Get workouts for this week
            let weekWorkouts = programWorkouts.filter { workout in
                workout.date >= weekStart && workout.date < weekEnd
            }

            let weekVolume = weekWorkouts.reduce(0.0) { $0 + $1.totalVolume }
            let weekWorkoutCount = weekWorkouts.count
            let plannedWorkouts = week.days.filter { $0.template != nil }.count

            weeklyData.append(WeekVolumeData(
                weekNumber: weekNum,
                volume: weekVolume,
                workoutsCompleted: weekWorkoutCount,
                workoutsPlanned: plannedWorkouts
            ))
        }

        volumeByWeek = weeklyData
    }

    private func calculateExerciseStats(programWorkouts: [Workout]) {
        var exerciseCount = 0
        var uniqueExerciseNames = Set<String>()

        for workout in programWorkouts where workout.type == .lifting {
            for exercise in workout.exercises {
                exerciseCount += 1
                uniqueExerciseNames.insert(exercise.exerciseName)
            }
        }

        totalExercisesPerformed = exerciseCount
        uniqueExercises = uniqueExerciseNames.count
    }

    private func calculateWeeklyComparison(programWorkouts: [Workout], activeProgram: TrainingProgram, startDate: Date) {
        let calendar = Calendar.current
        var comparisonData: [WeekComparisonData] = []

        for weekNum in 1...currentWeek {
            guard let week = activeProgram.weeks.first(where: { $0.weekNumber == weekNum }) else {
                continue
            }

            // Calculate date range
            let weekStartOffset = (weekNum - 1) * 7
            guard let weekStart = calendar.date(byAdding: .day, value: weekStartOffset, to: startDate),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                continue
            }

            // Get workouts for this week
            let weekWorkouts = programWorkouts.filter { workout in
                workout.date >= weekStart && workout.date < weekEnd
            }

            let volume = weekWorkouts.reduce(0.0) { $0 + $1.totalVolume }
            let totalSets = weekWorkouts.reduce(0) { $0 + $1.totalSets }
            let completed = weekWorkouts.count
            let planned = week.days.filter { $0.template != nil }.count
            let adherence = planned > 0 ? (Double(completed) / Double(planned)) * 100 : 0

            comparisonData.append(WeekComparisonData(
                weekNumber: weekNum,
                weekName: week.displayName,
                phase: week.phaseTag,
                workoutsCompleted: completed,
                workoutsPlanned: planned,
                adherence: adherence,
                totalVolume: volume,
                totalSets: totalSets
            ))
        }

        weeklyComparison = comparisonData
    }
}

// MARK: - Supporting Types

struct WeekVolumeData: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let volume: Double
    let workoutsCompleted: Int
    let workoutsPlanned: Int

    var adherence: Double {
        guard workoutsPlanned > 0 else { return 0 }
        return (Double(workoutsCompleted) / Double(workoutsPlanned)) * 100
    }
}

struct WeekComparisonData: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let weekName: String
    let phase: TrainingPhase?
    let workoutsCompleted: Int
    let workoutsPlanned: Int
    let adherence: Double
    let totalVolume: Double
    let totalSets: Int
}
