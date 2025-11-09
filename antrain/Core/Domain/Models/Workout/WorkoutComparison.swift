//
//  WorkoutComparison.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Represents a comparison between two workouts
/// Used in WorkoutSummaryView to show progress
struct WorkoutComparison {
    let previousWorkout: Workout
    let currentWorkout: Workout

    // MARK: - Overall Metrics

    /// Change in total volume (kg)
    var volumeChange: Double {
        currentWorkout.totalVolume - previousWorkout.totalVolume
    }

    /// Percentage change in volume
    var volumeChangePercentage: Double {
        guard previousWorkout.totalVolume > 0 else { return 0 }
        return (volumeChange / previousWorkout.totalVolume) * 100
    }

    /// Change in number of sets
    var setsChange: Int {
        currentWorkout.totalSets - previousWorkout.totalSets
    }

    /// Change in workout duration (seconds)
    var durationChange: TimeInterval {
        currentWorkout.duration - previousWorkout.duration
    }

    /// Change in number of exercises
    var exerciseCountChange: Int {
        currentWorkout.exercises.count - previousWorkout.exercises.count
    }

    // MARK: - Exercise-Level Improvements

    /// Detailed improvements for each exercise
    var exerciseImprovements: [ExerciseImprovement] {
        var improvements: [ExerciseImprovement] = []

        for currentExercise in currentWorkout.exercises {
            guard let exerciseName = currentExercise.exercise?.name else { continue }

            // Find matching exercise in previous workout
            if let previousExercise = previousWorkout.exercises.first(where: {
                $0.exercise?.name == exerciseName
            }) {
                let improvement = ExerciseImprovement(
                    exerciseName: exerciseName,
                    previousExercise: previousExercise,
                    currentExercise: currentExercise
                )
                improvements.append(improvement)
            }
        }

        return improvements
    }

    // MARK: - Computed Properties

    /// Whether this workout shows overall improvement
    var isImprovement: Bool {
        volumeChange > 0 || setsChange > 0
    }

    /// Summary text for quick display
    var summaryText: String {
        if volumeChange > 0 {
            return String(format: "+%.0f kg volume", volumeChange)
        } else if volumeChange < 0 {
            return String(format: "%.0f kg volume", volumeChange)
        } else {
            return "Same volume"
        }
    }
}

/// Represents improvement in a single exercise
struct ExerciseImprovement {
    let exerciseName: String
    let previousExercise: WorkoutExercise
    let currentExercise: WorkoutExercise

    // MARK: - Metrics

    /// Change in total volume for this exercise
    var volumeChange: Double {
        let currentVolume = currentExercise.sets.reduce(0.0) { $0 + $1.volume }
        let previousVolume = previousExercise.sets.reduce(0.0) { $0 + $1.volume }
        return currentVolume - previousVolume
    }

    /// Change in number of sets
    var setsChange: Int {
        currentExercise.sets.count - previousExercise.sets.count
    }

    /// Best set improvement (comparing max weight × reps)
    var bestSetImprovement: Double? {
        guard let currentBest = currentExercise.sets.map({ $0.volume }).max(),
              let previousBest = previousExercise.sets.map({ $0.volume }).max() else {
            return nil
        }
        return currentBest - previousBest
    }

    /// Whether this exercise improved
    var isImprovement: Bool {
        volumeChange > 0
    }

    /// Display text for this improvement
    var displayText: String {
        if volumeChange > 0 {
            return String(format: "+%.0f kg", volumeChange)
        } else if volumeChange < 0 {
            return String(format: "%.0f kg", volumeChange)
        } else {
            return "Same"
        }
    }
}

/// Statistics for muscle group breakdown
struct MuscleGroupStats {
    let muscleGroup: MuscleGroup
    let volume: Double
    let sets: Int
    let exerciseCount: Int

    /// Percentage of total workout volume
    var volumePercentage: Double {
        0 // Will be calculated by parent
    }
}
