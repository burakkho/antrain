//
//  PRDetectionService.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Service for detecting new Personal Records (PRs) in workouts
/// Automatically analyzes lifting workouts and saves new PRs
actor PRDetectionService {
    private let prRepository: PersonalRecordRepository

    init(prRepository: PersonalRecordRepository) {
        self.prRepository = prRepository
    }

    /// Analyze a workout and detect any new PRs
    /// Should be called after a workout is saved
    ///
    /// - Parameter workout: The workout to analyze
    /// - Returns: Array of new PRs detected (for notification purposes)
    func detectAndSavePRs(from workout: Workout) async throws -> [PersonalRecord] {
        // Only process lifting workouts
        guard workout.type == .lifting else {
            return []
        }

        var newPRs: [PersonalRecord] = []

        // Iterate through all exercises in the workout
        for workoutExercise in workout.exercises {
            // Find the best set (highest estimated 1RM) for this exercise
            if let bestPR = try await findBestSet(in: workoutExercise, workout: workout) {
                newPRs.append(bestPR)
            }
        }

        return newPRs
    }

    /// Find the best set in a workout exercise and check if it's a PR
    private func findBestSet(
        in workoutExercise: WorkoutExercise,
        workout: Workout
    ) async throws -> PersonalRecord? {
        // Skip if exercise was deleted
        guard let exercise = workoutExercise.exercise else { return nil }

        var bestSet: WorkoutSet?
        var bestEstimated1RM: Double = 0

        // Find the set with highest estimated 1RM
        for set in workoutExercise.sets {
            // Only consider valid PR candidates (weight + reps sets)
            guard set.isPRCandidate else { continue }

            if let estimated1RM = set.estimated1RM {
                if estimated1RM > bestEstimated1RM {
                    bestEstimated1RM = estimated1RM
                    bestSet = set
                }
            }
        }

        // No valid sets found
        guard let set = bestSet else { return nil }

        // Check if this would be a new PR
        let isNewPR = try await prRepository.wouldBeNewPR(
            exerciseId: exercise.id,
            estimated1RM: bestEstimated1RM
        )

        guard isNewPR else {
            print("Not a new PR for \(workoutExercise.exerciseName): \(bestEstimated1RM)kg")
            return nil
        }

        // Create and save the new PR
        let pr = PersonalRecord(
            exerciseName: workoutExercise.exerciseName,
            exerciseId: exercise.id,
            estimated1RM: bestEstimated1RM,
            actualWeight: set.weight,
            reps: set.reps,
            date: workout.date,
            workoutId: workout.id
        )

        try await prRepository.save(pr)

        return pr
    }

    /// Re-calculate PRs for an existing workout
    /// Useful if workout is edited
    func recalculatePRs(for workout: Workout) async throws {
        // Delete old PRs for this workout
        try await prRepository.deletePRsForWorkout(workout.id)

        // Detect new PRs
        _ = try await detectAndSavePRs(from: workout)
    }
}
