//
//  WorkoutContextBuilder.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation

/// Service for building WorkoutContext from user's workout data
/// Note: Not MainActor-isolated since it calls multiple actor-isolated repositories
final class WorkoutContextBuilder {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let personalRecordRepository: PersonalRecordRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let nutritionRepository: NutritionRepositoryProtocol

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        personalRecordRepository: PersonalRecordRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        nutritionRepository: NutritionRepositoryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.personalRecordRepository = personalRecordRepository
        self.userProfileRepository = userProfileRepository
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Build Context

    func buildContext() async -> WorkoutContext {
        // Calculate date ranges
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()

        // ✅ PARALLEL DATA FETCHING - All repository calls run concurrently
        async let userProfile = fetchUserProfile()
        async let recentWorkouts = fetchRecentWorkoutsOptimized(startDate: sixtyDaysAgo)
        async let allPRs = fetchPersonalRecords()
        async let recentPRs = fetchRecentPRsOptimized(startDate: thirtyDaysAgo)
        async let nutritionLogs = fetchNutritionLogsOptimized(startDate: thirtyDaysAgo)

        // Await all parallel tasks
        let (profile, workouts, allRecords, recentRecords, nutrition) = await (
            userProfile,
            recentWorkouts,
            allPRs,
            recentPRs,
            nutritionLogs
        )

        // ✅ POST-PROCESSING (fast, minimal data already filtered)
        let workoutSummaries = workouts.map { mapToWorkoutSummary($0) }

        // Get last 10 detailed workouts
        let last10Workouts = Array(workouts.prefix(10))
        let detailedWorkouts = last10Workouts.map { mapToDetailedWorkoutSummary($0) }

        // Calculate workout statistics
        let volumeTrend = calculateVolumeTrend(workouts: workouts)
        let trainingFrequency = calculateTrainingFrequency(workouts: workouts)

        // Map PRs
        let prSummaries = allRecords.map { mapToPRSummary($0) }
        let recentPRCount = recentRecords.count  // Already filtered by database

        // Extract active program info
        let (programName, programCategory, currentDay, totalDays, difficulty) = extractProgramInfo(from: profile)

        // Extract program day details (current + next 7 days)
        let (currentPeriodProgram, nextPeriodProgram) = extractProgramWeekDetails(from: profile)

        // Extract program phase details (not available in day-based system)
        let (isDeload, intensityMod, volumeMod, phaseTag) = extractProgramPhaseDetails(from: profile)

        // ✅ OPTIMIZED NUTRITION CALCULATIONS (single fetch, reused data)
        let nutritionAdherence = calculateNutritionAdherenceOptimized(logs: nutrition, since: thirtyDaysAgo)
        let nutritionSummary = calculateNutritionSummaryOptimized(logs: nutrition)
        let recentNutritionDetails = extractRecentNutritionDetails(from: nutrition)

        // Extract user profile data
        let experienceLevel = difficulty ?? profile?.fitnessLevel?.displayName ?? "Beginner"
        let bodyweightTrend = calculateBodyweightTrend(from: profile)
        let userName = profile?.name
        let height = profile?.height
        let currentWeight = profile?.currentBodyweight?.weight
        let activityLevel = profile?.activityLevel?.displayName

        // AI Onboarding fields
        let fitnessLevel = profile?.fitnessLevel?.displayName
        let fitnessGoals = profile?.fitnessGoals.map { $0.displayName } ?? []
        let weeklyFrequency = profile?.weeklyWorkoutFrequency
        let equipment = profile?.availableEquipment?.displayName

        return WorkoutContext(
            recentWorkouts: workoutSummaries,
            recentDetailedWorkouts: detailedWorkouts,
            volumeTrend: volumeTrend,
            trainingFrequency: trainingFrequency,
            personalRecords: prSummaries,
            recentPRCount: recentPRCount,
            activeProgramName: programName,
            programCategory: programCategory,
            currentWeekNumber: currentDay,
            totalProgramWeeks: totalDays,
            programDifficulty: difficulty,
            currentWeekProgram: currentPeriodProgram,
            nextWeekProgram: nextPeriodProgram,
            currentWeekIsDeload: isDeload,
            currentWeekIntensityModifier: intensityMod,
            currentWeekVolumeModifier: volumeMod,
            currentWeekPhaseTag: phaseTag,
            dailyCalorieGoal: profile?.dailyCalorieGoal ?? 2000,
            dailyProteinGoal: profile?.dailyProteinGoal ?? 150,
            dailyCarbsGoal: profile?.dailyCarbsGoal ?? 250,
            dailyFatsGoal: profile?.dailyFatsGoal ?? 65,
            nutritionAdherence: nutritionAdherence,
            nutritionSummary: nutritionSummary,
            recentNutritionDetails: recentNutritionDetails,
            userName: userName,
            height: height,
            currentWeight: currentWeight,
            activityLevel: activityLevel,
            experienceLevel: experienceLevel,
            bodyweightTrend: bodyweightTrend,
            age: calculateAge(from: profile?.dateOfBirth),
            gender: profile?.gender?.rawValue,
            fitnessLevel: fitnessLevel,
            fitnessGoals: fitnessGoals,
            weeklyWorkoutFrequency: weeklyFrequency,
            availableEquipment: equipment
        )
    }

    // MARK: - Private Helper Methods

    private func fetchUserProfile() async -> UserProfile? {
        do {
            return try await userProfileRepository.fetchOrCreateProfile()
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }

    /// ✅ OPTIMIZED: Database-level filtering (no in-memory filter)
    private func fetchRecentWorkoutsOptimized(startDate: Date) async -> [Workout] {
        do {
            return try await workoutRepository.fetchByDateRange(
                startDate: startDate,
                endDate: Date()
            )
        } catch {
            print("Error fetching recent workouts: \(error)")
            return []
        }
    }

    /// ✅ OPTIMIZED: Database-level filtering for recent PRs
    private func fetchRecentPRsOptimized(startDate: Date) async -> [PersonalRecord] {
        do {
            return try await personalRecordRepository.fetchRecent(since: startDate)
        } catch {
            print("Error fetching recent PRs: \(error)")
            return []
        }
    }

    /// ✅ OPTIMIZED: Single nutrition query (replaces 3 separate fetchAllLogs calls)
    private func fetchNutritionLogsOptimized(startDate: Date) async -> [NutritionLog] {
        do {
            return try await nutritionRepository.fetchLogs(since: startDate)
        } catch {
            print("Error fetching nutrition logs: \(error)")
            return []
        }
    }

    private func fetchPersonalRecords() async -> [PersonalRecord] {
        do {
            return try await personalRecordRepository.fetchAll()
        } catch {
            print("Error fetching personal records: \(error)")
            return []
        }
    }

    /// ✅ OPTIMIZED: Reuses fetched logs (no repository call)
    private func calculateNutritionAdherenceOptimized(logs: [NutritionLog], since startDate: Date) -> Double? {
        // Filter logs within date range (already database-filtered, but double-check)
        let recentLogs = logs.filter { $0.date >= startDate }
        let daysWithLogs = recentLogs.filter { $0.totalCalories > 0 }.count

        return daysWithLogs > 0 ? Double(daysWithLogs) / 30.0 : nil
    }

    /// ✅ OPTIMIZED: Reuses fetched logs (no repository call)
    private func calculateNutritionSummaryOptimized(logs: [NutritionLog]) -> WorkoutContext.NutritionSummary? {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        // Filter to last 7 days
        let recentLogs = logs.filter { $0.date >= sevenDaysAgo }

        // Filter only tracked days (calories > 0)
        let trackedLogs = recentLogs.filter { $0.totalCalories > 0 }

        guard !trackedLogs.isEmpty else { return nil }

        // Calculate averages
        let totalCalories = trackedLogs.reduce(0.0) { $0 + $1.totalCalories }
        let totalProtein = trackedLogs.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = trackedLogs.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFats = trackedLogs.reduce(0.0) { $0 + $1.totalFats }

        let count = Double(trackedLogs.count)

        return WorkoutContext.NutritionSummary(
            averageCalories: totalCalories / count,
            averageProtein: totalProtein / count,
            averageCarbs: totalCarbs / count,
            averageFats: totalFats / count,
            trackedDaysCount: trackedLogs.count,
            totalDaysInPeriod: 7
        )
    }

    /// ✅ OPTIMIZED: Reuses fetched logs (no repository call)
    private func extractRecentNutritionDetails(from logs: [NutritionLog]) -> [WorkoutContext.DailyNutritionDetail] {
        var details: [WorkoutContext.DailyNutritionDetail] = []

        // Get last 3 days
        for daysAgo in 0..<3 {
            guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
                continue
            }

            // Normalize date to start of day for comparison
            let startOfDay = Calendar.current.startOfDay(for: date)

            // Find log for this date
            if let log = logs.first(where: { Calendar.current.startOfDay(for: $0.date) == startOfDay }) {
                let wasTracked = log.totalCalories > 0

                details.append(WorkoutContext.DailyNutritionDetail(
                    daysAgo: daysAgo,
                    calories: log.totalCalories,
                    protein: log.totalProtein,
                    carbs: log.totalCarbs,
                    fats: log.totalFats,
                    wasTracked: wasTracked
                ))
            } else {
                // No log for this day
                details.append(WorkoutContext.DailyNutritionDetail(
                    daysAgo: daysAgo,
                    calories: 0,
                    protein: 0,
                    carbs: 0,
                    fats: 0,
                    wasTracked: false
                ))
            }
        }

        return details
    }

    // MARK: - Mapping Functions

    private func mapToWorkoutSummary(_ workout: Workout) -> WorkoutContext.WorkoutSummary {
        let topMuscles = workout.topMuscleGroups.map { $0.displayName }

        return WorkoutContext.WorkoutSummary(
            date: workout.date,
            type: workout.type.displayName,
            duration: workout.duration,
            totalVolume: workout.totalVolume,
            topMuscleGroups: topMuscles,
            completedSets: workout.completedSets,
            notes: workout.notes,
            rating: workout.rating,
            cardioType: workout.cardioType,
            cardioDistance: workout.cardioDistance,
            cardioPace: workout.cardioPace,
            metconType: workout.metconType,
            metconRounds: workout.metconRounds,
            metconResult: workout.metconResult
        )
    }

    private func mapToPRSummary(_ pr: PersonalRecord) -> WorkoutContext.PersonalRecordSummary {
        WorkoutContext.PersonalRecordSummary(
            exerciseName: pr.exerciseName,
            oneRepMax: pr.estimated1RM,
            date: pr.date,
            reps: pr.reps,
            weight: pr.actualWeight
        )
    }

    private func mapToDetailedWorkoutSummary(_ workout: Workout) -> WorkoutContext.DetailedWorkoutSummary {
        let exerciseDetails = workout.exercises.map { workoutExercise in
            let setDetails = workoutExercise.sets.map { set in
                WorkoutContext.SetDetail(
                    reps: set.reps,
                    weight: set.weight,
                    isCompleted: set.isCompleted,
                    notes: set.notes
                )
            }

            return WorkoutContext.WorkoutExerciseDetail(
                exerciseName: workoutExercise.exercise?.name ?? "Unknown Exercise",
                sets: setDetails
            )
        }

        return WorkoutContext.DetailedWorkoutSummary(
            date: workout.date,
            duration: workout.duration,
            exercises: exerciseDetails,
            totalVolume: workout.totalVolume
        )
    }

    // MARK: - Statistics Calculations

    private func calculateVolumeTrend(workouts: [Workout]) -> Double {
        guard !workouts.isEmpty else { return 0 }

        let now = Date()
        let fifteenDaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: now) ?? now
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now

        let recentWorkouts = workouts.filter { $0.date >= fifteenDaysAgo }
        let olderWorkouts = workouts.filter { $0.date >= thirtyDaysAgo && $0.date < fifteenDaysAgo }

        guard !olderWorkouts.isEmpty else { return 0 }

        let recentVolume = recentWorkouts.reduce(0) { $0 + $1.totalVolume }
        let olderVolume = olderWorkouts.reduce(0) { $0 + $1.totalVolume }

        guard olderVolume > 0 else { return 0 }

        let percentageChange = ((recentVolume - olderVolume) / olderVolume) * 100
        return percentageChange
    }

    private func calculateTrainingFrequency(workouts: [Workout]) -> Double {
        guard !workouts.isEmpty else { return 0 }

        let totalDays = 30.0
        let workoutCount = Double(workouts.count)

        // Convert to workouts per week
        return (workoutCount / totalDays) * 7.0
    }

    private func extractProgramInfo(from profile: UserProfile?) -> (String?, String?, Int?, Int?, String?) {
        guard let profile = profile, let program = profile.activeProgram else {
            return (nil, nil, nil, nil, nil)
        }

        let programName = program.name
        let programCategory = program.category.displayName
        let currentDay = profile.currentDayNumber
        let totalDays = program.totalDays
        let difficulty = program.difficulty.displayName

        return (programName, programCategory, currentDay, totalDays, difficulty)
    }

    private func extractProgramWeekDetails(from profile: UserProfile?) -> ([WorkoutContext.ProgramDaySummary]?, [WorkoutContext.ProgramDaySummary]?) {
        guard let profile = profile,
              let program = profile.activeProgram,
              let currentDayNumber = profile.currentDayNumber else {
            return (nil, nil)
        }

        // Get upcoming 7 days from current position (simulate "current week")
        let currentRangeDays = extractUpcomingDays(from: program, startDay: currentDayNumber, count: 7)

        // Get next 7 days (simulate "next week")
        let nextStartDay = currentDayNumber + 7
        let nextRangeDays = nextStartDay <= program.totalDays
            ? extractUpcomingDays(from: program, startDay: nextStartDay, count: 7)
            : nil

        return (currentRangeDays, nextRangeDays)
    }

    private func extractUpcomingDays(from program: TrainingProgram, startDay: Int, count: Int) -> [WorkoutContext.ProgramDaySummary]? {
        // Get days in range
        let endDay = min(startDay + count - 1, program.totalDays)
        let daysInRange = program.days.filter { $0.dayNumber >= startDay && $0.dayNumber <= endDay }

        // Extract days with exercises
        let daySummaries = daysInRange.compactMap { day -> WorkoutContext.ProgramDaySummary? in
            guard let template = day.template, !template.exercises.isEmpty else {
                return nil // Skip rest days
            }

            let exerciseInfos = template.exercises.sorted(by: { $0.order < $1.order }).map { templateEx in
                WorkoutContext.ProgramExerciseInfo(
                    exerciseName: templateEx.exerciseName,
                    sets: templateEx.setCount,
                    repRange: templateEx.repRangeFormatted,
                    notes: templateEx.notes
                )
            }

            return WorkoutContext.ProgramDaySummary(
                dayName: day.displayName,
                exercises: exerciseInfos
            )
        }

        return daySummaries.isEmpty ? nil : daySummaries
    }

    private func extractProgramPhaseDetails(from profile: UserProfile?) -> (Bool?, Double?, Double?, String?) {
        // Phase details are no longer tracked at the week level in the day-based system
        // Return nil for all values to indicate this information is not available
        return (nil, nil, nil, nil)
    }

    private func calculateBodyweightTrend(from profile: UserProfile?) -> String? {
        guard let profile = profile else { return nil }

        let entries = profile.bodyweightEntries.sorted { $0.date < $1.date }
        guard entries.count >= 2 else { return nil }

        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.date >= thirtyDaysAgo }

        guard let first = recentEntries.first, let last = recentEntries.last else {
            return nil
        }

        let change = last.weight - first.weight

        if abs(change) < 0.5 {
            return "stable"
        } else if change > 0 {
            return String(format: "+%.1fkg", change)
        } else {
            return String(format: "%.1fkg", change)
        }
    }

    private func calculateAge(from dateOfBirth: Date?) -> Int? {
        guard let dob = dateOfBirth else { return nil }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year
    }
}
