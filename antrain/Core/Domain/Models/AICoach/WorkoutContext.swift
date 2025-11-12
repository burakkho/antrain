//
//  WorkoutContext.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation

/// Context data about user's workout history and profile to send to Gemini AI
struct WorkoutContext {
    // MARK: - Recent Workout Data (30 days)

    struct WorkoutSummary {
        let date: Date
        let type: String // "Lifting", "Cardio", "METCON"
        let duration: TimeInterval
        let totalVolume: Double // kg
        let topMuscleGroups: [String]
        let completedSets: Int

        // User feedback
        let notes: String?
        let rating: Int? // 1-5 stars

        // Cardio-specific data
        let cardioType: String? // "Running", "Cycling", "Rowing"
        let cardioDistance: Double? // in km
        let cardioPace: Double? // min/km

        // METCON-specific data
        let metconType: String? // "AMRAP", "EMOM", "For Time"
        let metconRounds: Int?
        let metconResult: String? // "15 rounds", "12:34", etc.
    }

    // MARK: - Detailed Workout Data (Last 5 workouts)

    struct DetailedWorkoutSummary {
        let date: Date
        let duration: TimeInterval
        let exercises: [WorkoutExerciseDetail]
        let totalVolume: Double
    }

    struct WorkoutExerciseDetail {
        let exerciseName: String
        let sets: [SetDetail]
    }

    struct SetDetail {
        let reps: Int
        let weight: Double // kg
        let isCompleted: Bool
        let notes: String? // "Too heavy", "Perfect form", "Fatigued", etc.
    }

    // MARK: - Training Program Details

    struct ProgramDaySummary {
        let dayName: String // "Push Day", "Pull Day", "Leg Day"
        let exercises: [ProgramExerciseInfo]
    }

    struct ProgramExerciseInfo {
        let exerciseName: String
        let sets: Int
        let repRange: String // "6-8", "8-10", "10-12"
        let notes: String? // "RPE 8", "Drop set", etc.
    }

    let recentWorkouts: [WorkoutSummary]
    let recentDetailedWorkouts: [DetailedWorkoutSummary] // Last 5 workouts
    let volumeTrend: Double // % change from previous 30 days
    let trainingFrequency: Double // workouts per week

    // MARK: - Personal Records

    struct PersonalRecordSummary {
        let exerciseName: String
        let oneRepMax: Double // kg
        let date: Date
        let reps: Int
        let weight: Double // kg
    }

    let personalRecords: [PersonalRecordSummary]
    let recentPRCount: Int // PRs in last 30 days

    // MARK: - Active Training Program

    let activeProgramName: String?
    let programCategory: String? // "PPL", "Upper/Lower", etc.
    let currentWeekNumber: Int?
    let totalProgramWeeks: Int?
    let programDifficulty: String? // "Beginner", "Intermediate", "Advanced"
    let currentWeekProgram: [ProgramDaySummary]? // Current week's workout days
    let nextWeekProgram: [ProgramDaySummary]? // Next week's workout days

    // Program Phase Details (for intelligent programming advice)
    let currentWeekIsDeload: Bool?
    let currentWeekIntensityModifier: Double? // e.g., 0.9 for deload, 1.1 for peak
    let currentWeekVolumeModifier: Double? // e.g., 0.7 for deload, 1.2 for high volume
    let currentWeekPhaseTag: String? // "Accumulation", "Intensification", "Deload", "Peak"

    // MARK: - Nutrition Data

    struct NutritionSummary {
        let averageCalories: Double
        let averageProtein: Double
        let averageCarbs: Double
        let averageFats: Double
        let trackedDaysCount: Int
        let totalDaysInPeriod: Int

        var caloriesDelta: Double { averageCalories - 0 } // Will be calculated against goal
        var proteinDelta: Double { averageProtein - 0 }
        var carbsDelta: Double { averageCarbs - 0 }
        var fatsDelta: Double { averageFats - 0 }
    }

    struct DailyNutritionDetail {
        let daysAgo: Int
        let calories: Double
        let protein: Double
        let carbs: Double
        let fats: Double
        let wasTracked: Bool
    }

    let dailyCalorieGoal: Double
    let dailyProteinGoal: Double
    let dailyCarbsGoal: Double
    let dailyFatsGoal: Double
    let nutritionAdherence: Double? // % of days with complete nutrition logs
    let nutritionSummary: NutritionSummary? // Last 7 days average
    let recentNutritionDetails: [DailyNutritionDetail] // Last 3 days

    // MARK: - User Profile

    let userName: String? // User's name for personalization
    let height: Double? // Height in cm
    let currentWeight: Double? // Current bodyweight in kg
    let activityLevel: String? // "Sedentary", "Lightly Active", "Moderately Active", etc.
    let experienceLevel: String // Inferred from program difficulty or custom
    let bodyweightTrend: String? // "stable", "+2.5kg", "-1.2kg" over 30 days
    let age: Int?
    let gender: String?

    // AI Onboarding Fields (from UserProfile)
    let fitnessLevel: String? // "Beginner", "Intermediate", "Advanced"
    let fitnessGoals: [String] // ["Muscle Gain", "Fat Loss", "Strength", "Endurance"]
    let weeklyWorkoutFrequency: Int? // How many days per week user can train
    let availableEquipment: String? // "Gym", "Home", "Minimal"

    // MARK: - Computed Properties

    var hasWorkoutHistory: Bool {
        !recentWorkouts.isEmpty
    }

    var hasActiveProgram: Bool {
        activeProgramName != nil
    }

    var hasPRs: Bool {
        !personalRecords.isEmpty
    }

    var isNewUser: Bool {
        recentWorkouts.isEmpty && personalRecords.isEmpty
    }

    // MARK: - Methods

    /// Converts workout context to a formatted string for Gemini prompt
    func toPromptString(language: String = "English") -> String {
        var contextParts: [String] = []

        // User Profile
        if !isNewUser {
            var profileParts: [String] = []

            // Name for personalization
            if let name = userName, !name.isEmpty {
                profileParts.append("Name: \(name)")
            }

            // Age and Gender
            var demographics: [String] = []
            if let age = age {
                demographics.append("\(age) years old")
            }
            if let gender = gender {
                demographics.append(gender)
            }
            if !demographics.isEmpty {
                profileParts.append(demographics.joined(separator: ", "))
            }

            // Physical Stats
            if let height = height, let weight = currentWeight {
                profileParts.append(String(format: "Height: %.0fcm", height))
                profileParts.append(String(format: "Current Weight: %.1fkg", weight))

                // Calculate BMI
                let heightInMeters = height / 100.0
                let bmi = weight / (heightInMeters * heightInMeters)
                let bmiCategory: String
                if bmi < 18.5 {
                    bmiCategory = "Underweight"
                } else if bmi < 25 {
                    bmiCategory = "Normal"
                } else if bmi < 30 {
                    bmiCategory = "Overweight"
                } else {
                    bmiCategory = "Obese"
                }
                profileParts.append(String(format: "BMI: %.1f (%@)", bmi, bmiCategory))

                // Bodyweight trend
                if let trend = bodyweightTrend {
                    profileParts.append("Weight trend (30 days): \(trend)")
                }
            } else if let weight = currentWeight {
                // Only weight available
                profileParts.append(String(format: "Current Weight: %.1fkg", weight))
                if let trend = bodyweightTrend {
                    profileParts.append("Weight trend (30 days): \(trend)")
                }
            } else if let trend = bodyweightTrend {
                // Only trend available (fallback)
                profileParts.append("Bodyweight trend: \(trend)")
            }

            // Activity Level
            if let activity = activityLevel {
                profileParts.append("Activity Level: \(activity)")
            }

            // Experience Level
            profileParts.append("Training Experience: \(experienceLevel)")

            // Fitness Level (from AI onboarding)
            if let fitness = fitnessLevel {
                profileParts.append("Fitness Level: \(fitness)")
            }

            // Fitness Goals
            if !fitnessGoals.isEmpty {
                profileParts.append("Goals: \(fitnessGoals.joined(separator: ", "))")
            }

            // Weekly Workout Frequency
            if let frequency = weeklyWorkoutFrequency {
                profileParts.append("Can train \(frequency) days per week")
            }

            // Available Equipment
            if let equipment = availableEquipment {
                profileParts.append("Equipment: \(equipment)")
            }

            contextParts.append("USER PROFILE:\n- " + profileParts.joined(separator: "\n- "))
        }

        // Active Program with Details
        if let program = activeProgramName {
            var programParts: [String] = []
            programParts.append("Program: \(program)")

            if let category = programCategory {
                programParts.append("Type: \(category)")
            }

            if let week = currentWeekNumber, let total = totalProgramWeeks {
                programParts.append("Progress: Week \(week)/\(total)")
            }

            if let difficulty = programDifficulty {
                programParts.append("Difficulty: \(difficulty)")
            }

            // Program Phase Details (Critical for programming advice)
            if let isDeload = currentWeekIsDeload, isDeload {
                programParts.append("⚠️ DELOAD WEEK - Reduced intensity and volume for recovery")
            }

            if let phaseTag = currentWeekPhaseTag {
                programParts.append("Training Phase: \(phaseTag)")
            }

            var modifiers: [String] = []
            if let intensityMod = currentWeekIntensityModifier, intensityMod != 1.0 {
                modifiers.append(String(format: "Intensity: %.0f%%", intensityMod * 100))
            }
            if let volumeMod = currentWeekVolumeModifier, volumeMod != 1.0 {
                modifiers.append(String(format: "Volume: %.0f%%", volumeMod * 100))
            }
            if !modifiers.isEmpty {
                programParts.append("Week Modifiers: \(modifiers.joined(separator: ", "))")
            }

            // Current Week Program Details
            if let currentWeek = currentWeekProgram, !currentWeek.isEmpty {
                programParts.append("\nCurrent Week Workouts:")
                for day in currentWeek {
                    programParts.append("• \(day.dayName):")
                    for exercise in day.exercises {
                        let notesPart = exercise.notes.map { " (\($0))" } ?? ""
                        programParts.append("  - \(exercise.exerciseName): \(exercise.sets) sets x \(exercise.repRange) reps\(notesPart)")
                    }
                }
            }

            // Next Week Program Details (if available)
            if let nextWeek = nextWeekProgram, !nextWeek.isEmpty {
                programParts.append("\nNext Week Workouts:")
                for day in nextWeek {
                    programParts.append("• \(day.dayName):")
                    for exercise in day.exercises {
                        let notesPart = exercise.notes.map { " (\($0))" } ?? ""
                        programParts.append("  - \(exercise.exerciseName): \(exercise.sets) sets x \(exercise.repRange) reps\(notesPart)")
                    }
                }
            }

            contextParts.append("\nACTIVE PROGRAM:\n- " + programParts.joined(separator: "\n- "))
        }

        // Recent Workout Activity
        if !recentWorkouts.isEmpty {
            let workoutCount = recentWorkouts.count
            let avgDuration = recentWorkouts.map { $0.duration }.reduce(0, +) / Double(workoutCount)
            let totalVolume = recentWorkouts.map { $0.totalVolume }.reduce(0, +)

            var workoutParts: [String] = []
            workoutParts.append("\(workoutCount) workouts in last 30 days")
            workoutParts.append(String(format: "Training frequency: %.1f days/week", trainingFrequency))
            workoutParts.append(String(format: "Average duration: %.0f minutes", avgDuration / 60))
            workoutParts.append(String(format: "Total volume: %.0f kg", totalVolume))

            if volumeTrend != 0 {
                let trend = volumeTrend > 0 ? "+" : ""
                workoutParts.append(String(format: "Volume trend: %@%.1f%%", trend, volumeTrend))
            }

            // Most trained muscle groups
            let allMuscleGroups = recentWorkouts.flatMap { $0.topMuscleGroups }
            let muscleGroupCounts = Dictionary(grouping: allMuscleGroups) { $0 }.mapValues { $0.count }
            let topMuscles = muscleGroupCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
            if !topMuscles.isEmpty {
                workoutParts.append("Top muscle groups: \(topMuscles.joined(separator: ", "))")
            }

            contextParts.append("\nRECENT WORKOUTS (30 days):\n- " + workoutParts.joined(separator: "\n- "))
        }

        // Recent Detailed Workouts (Last 5)
        if !recentDetailedWorkouts.isEmpty {
            var detailedParts: [String] = []
            detailedParts.append("RECENT WORKOUT DETAILS:")

            for (index, workout) in recentDetailedWorkouts.enumerated() {
                let daysAgo = Calendar.current.dateComponents([.day], from: workout.date, to: Date()).day ?? 0
                let timeDesc = daysAgo == 0 ? "Today" : daysAgo == 1 ? "Yesterday" : "\(daysAgo) days ago"
                let duration = Int(workout.duration / 60)

                detailedParts.append("\n\(index + 1). \(timeDesc) (\(duration) min, \(String(format: "%.0f", workout.totalVolume))kg total):")

                for exercise in workout.exercises {
                    // Group sets by weight for compact format
                    var setsGrouped: [Double: [(reps: Int, completed: Bool)]] = [:]
                    for set in exercise.sets {
                        if setsGrouped[set.weight] == nil {
                            setsGrouped[set.weight] = []
                        }
                        setsGrouped[set.weight]?.append((set.reps, set.isCompleted))
                    }

                    // Format: "Bench Press: 4x8 @75kg, 2x6 @80kg"
                    let setDescriptions = setsGrouped.sorted { $0.key > $1.key }.map { weight, sets -> String in
                        let completedSets = sets.filter { $0.completed }
                        let avgReps = completedSets.isEmpty ? 0 : completedSets.map { $0.reps }.reduce(0, +) / completedSets.count
                        let setCount = completedSets.count
                        let allSame = completedSets.allSatisfy { $0.reps == completedSets.first?.reps }

                        if allSame && !completedSets.isEmpty {
                            return "\(setCount)x\(completedSets.first!.reps) @\(String(format: "%.1f", weight))kg"
                        } else if !completedSets.isEmpty {
                            let repsStr = completedSets.map { String($0.reps) }.joined(separator: ",")
                            return "\(setCount) sets (\(repsStr) reps) @\(String(format: "%.1f", weight))kg"
                        } else {
                            return ""
                        }
                    }.filter { !$0.isEmpty }

                    if !setDescriptions.isEmpty {
                        detailedParts.append("   • \(exercise.exerciseName): \(setDescriptions.joined(separator: ", "))")
                    }
                }
            }

            contextParts.append("\n" + detailedParts.joined(separator: "\n"))
        }

        // Personal Records
        if !personalRecords.isEmpty {
            let topPRs = personalRecords.prefix(5)
            var prParts: [String] = []
            prParts.append("Total PRs: \(personalRecords.count)")

            if recentPRCount > 0 {
                prParts.append("New PRs (last 30 days): \(recentPRCount)")
            }

            prParts.append("\nTop Personal Records:")
            for pr in topPRs {
                prParts.append(String(format: "• %@: %.1f kg (1RM)", pr.exerciseName, pr.oneRepMax))
            }

            contextParts.append("\nPERSONAL RECORDS:\n- " + prParts.joined(separator: "\n- "))
        }

        // Nutrition Tracking
        var nutritionParts: [String] = []
        nutritionParts.append("NUTRITION TRACKING:")
        nutritionParts.append(String(format: "Goals: %.0f kcal, %.0fg protein, %.0fg carbs, %.0fg fats",
                                      dailyCalorieGoal, dailyProteinGoal, dailyCarbsGoal, dailyFatsGoal))

        if let adherence = nutritionAdherence {
            nutritionParts.append(String(format: "Adherence: %.0f%% (tracked days in last 30 days)", adherence * 100))
        }

        // Last 7 days summary
        if let summary = nutritionSummary {
            nutritionParts.append("")
            nutritionParts.append("Last 7 days average (\(summary.trackedDaysCount)/\(summary.totalDaysInPeriod) days tracked):")

            let calDelta = summary.averageCalories - dailyCalorieGoal
            let proteinDelta = summary.averageProtein - dailyProteinGoal
            let carbsDelta = summary.averageCarbs - dailyCarbsGoal
            let fatsDelta = summary.averageFats - dailyFatsGoal

            nutritionParts.append(String(format: "- Calories: %.0f/%.0f (%@%.0f %@)",
                                          summary.averageCalories, dailyCalorieGoal,
                                          calDelta >= 0 ? "+" : "", calDelta,
                                          calDelta > 50 ? "surplus" : calDelta < -50 ? "deficit" : "on target"))

            nutritionParts.append(String(format: "- Protein: %.0f/%.0f (%@%.0fg) %@",
                                          summary.averageProtein, dailyProteinGoal,
                                          proteinDelta >= 0 ? "+" : "", proteinDelta,
                                          abs(proteinDelta) < 10 ? "✅" : ""))

            nutritionParts.append(String(format: "- Carbs: %.0f/%.0f (%@%.0fg)",
                                          summary.averageCarbs, dailyCarbsGoal,
                                          carbsDelta >= 0 ? "+" : "", carbsDelta))

            nutritionParts.append(String(format: "- Fats: %.0f/%.0f (%@%.0fg)",
                                          summary.averageFats, dailyFatsGoal,
                                          fatsDelta >= 0 ? "+" : "", fatsDelta))

            // Overall trend
            if abs(calDelta) > 50 {
                let trend = calDelta > 0 ? "Surplus" : "Deficit"
                nutritionParts.append(String(format: "\nTrend: %@ (~%.0f kcal/day)", trend, abs(calDelta)))
            } else {
                nutritionParts.append("\nTrend: Maintenance")
            }

            // Bodyweight correlation
            if let bwTrend = bodyweightTrend {
                nutritionParts.append("Bodyweight trend: \(bwTrend)")
                if calDelta < -100 && bwTrend.contains("+") {
                    nutritionParts.append("⚠️ Note: Bodyweight increasing despite calorie deficit suggests inconsistent tracking")
                } else if calDelta > 100 && bwTrend.contains("-") {
                    nutritionParts.append("⚠️ Note: Bodyweight decreasing despite calorie surplus suggests inconsistent tracking")
                }
            }
        }

        // Recent 3 days detail
        if !recentNutritionDetails.isEmpty {
            nutritionParts.append("")
            nutritionParts.append("Recent 3 days:")
            for detail in recentNutritionDetails {
                let dayLabel = detail.daysAgo == 0 ? "Today" : detail.daysAgo == 1 ? "Yesterday" : "\(detail.daysAgo) days ago"

                if detail.wasTracked {
                    nutritionParts.append(String(format: "- %@: %.0f kcal, %.0fp, %.0fc, %.0ff",
                                                  dayLabel, detail.calories, detail.protein, detail.carbs, detail.fats))
                } else {
                    nutritionParts.append("- \(dayLabel): NOT TRACKED")
                }
            }
        }

        contextParts.append("\n" + nutritionParts.joined(separator: "\n"))

        // New user message
        if isNewUser {
            return "USER STATUS: New user - no workout history yet. Encourage them to start their fitness journey!"
        }

        return contextParts.joined(separator: "\n")
    }

    /// Returns a minimal context string for follow-up messages (after first message)
    /// This saves tokens by not repeating detailed information already sent
    func toMinimalPromptString() -> String {
        // New user case
        if isNewUser {
            return "USER STATUS: New user"
        }

        var parts: [String] = []

        // Basic identification
        if let name = userName, !name.isEmpty {
            parts.append("User: \(name)")
        }

        parts.append("Experience: \(experienceLevel)")

        // Active program (important for context)
        if let programName = activeProgramName {
            var programInfo = "Active Program: \(programName)"
            if let week = currentWeekNumber, let total = totalProgramWeeks {
                programInfo += " (Week \(week)/\(total))"
            }
            parts.append(programInfo)
        }

        // Primary goal (if set)
        if !fitnessGoals.isEmpty {
            parts.append("Goal: \(fitnessGoals[0])")
        }

        return parts.joined(separator: " | ")
    }

    // MARK: - Factory Methods

    /// Creates an empty context for new users
    static func empty(
        dailyCalorieGoal: Double = 2000,
        dailyProteinGoal: Double = 150,
        dailyCarbsGoal: Double = 250,
        dailyFatsGoal: Double = 65
    ) -> WorkoutContext {
        WorkoutContext(
            recentWorkouts: [],
            recentDetailedWorkouts: [],
            volumeTrend: 0,
            trainingFrequency: 0,
            personalRecords: [],
            recentPRCount: 0,
            activeProgramName: nil,
            programCategory: nil,
            currentWeekNumber: nil,
            totalProgramWeeks: nil,
            programDifficulty: nil,
            currentWeekProgram: nil,
            nextWeekProgram: nil,
            currentWeekIsDeload: nil,
            currentWeekIntensityModifier: nil,
            currentWeekVolumeModifier: nil,
            currentWeekPhaseTag: nil,
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatsGoal: dailyFatsGoal,
            nutritionAdherence: nil,
            nutritionSummary: nil,
            recentNutritionDetails: [],
            userName: nil,
            height: nil,
            currentWeight: nil,
            activityLevel: nil,
            experienceLevel: "Beginner",
            bodyweightTrend: nil,
            age: nil,
            gender: nil,
            fitnessLevel: nil,
            fitnessGoals: [],
            weeklyWorkoutFrequency: nil,
            availableEquipment: nil
        )
    }
}
