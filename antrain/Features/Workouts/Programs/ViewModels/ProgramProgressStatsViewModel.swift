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
    private(set) var currentDay: Int = 1
    private(set) var totalDays: Int = 0

    // Overall stats
    private(set) var completionPercentage: Double = 0.0
    private(set) var adherencePercentage: Double = 0.0
    private(set) var totalWorkoutsCompleted: Int = 0
    private(set) var currentStreak: Int = 0

    // Volume stats
    private(set) var totalVolume: Double = 0.0
    private(set) var averageVolumePerWorkout: Double = 0.0

    // Exercise stats
    private(set) var totalExercisesPerformed: Int = 0
    private(set) var uniqueExercises: Int = 0

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
                  let currentDayNumber = userProfile.currentDayNumber else {
                errorMessage = String(localized: "No active program found")
                return
            }

            program = activeProgram
            startDate = programStartDate
            currentDay = currentDayNumber
            totalDays = activeProgram.totalDays

            // Fetch all workouts
            let allWorkouts = try await workoutRepository.fetchAll()

            // Filter workouts for this program (using program tracking fields)
            let programWorkouts = allWorkouts.filter { workout in
                workout.isFromProgram && workout.programId == activeProgram.id
            }

            // Calculate stats
            calculateOverallStats(programWorkouts: programWorkouts, activeProgram: activeProgram)
            calculateVolumeStats(programWorkouts: programWorkouts)
            calculateExerciseStats(programWorkouts: programWorkouts)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Calculations

    private func calculateOverallStats(programWorkouts: [Workout], activeProgram: TrainingProgram) {
        let calendar = Calendar.current
        let today = Date()

        totalWorkoutsCompleted = programWorkouts.count

        // Calculate completion percentage (based on current day in program)
        // Expected workouts = current day - 1 (since we're ON day X, we should have completed days 1 to X-1)
        let expectedWorkouts = max(currentDay - 1, 0)

        if expectedWorkouts > 0 {
            adherencePercentage = (Double(totalWorkoutsCompleted) / Double(expectedWorkouts)) * 100
        } else {
            adherencePercentage = 0
        }

        // Calculate overall program completion percentage
        if activeProgram.totalDays > 0 {
            completionPercentage = (Double(totalWorkoutsCompleted) / Double(activeProgram.totalDays)) * 100
        }

        // Calculate streak (consecutive days with workouts)
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

    private func calculateVolumeStats(programWorkouts: [Workout]) {
        // Total volume
        totalVolume = programWorkouts.reduce(0.0) { $0 + $1.totalVolume }

        // Average volume per workout
        if totalWorkoutsCompleted > 0 {
            averageVolumePerWorkout = totalVolume / Double(totalWorkoutsCompleted)
        }
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
}
