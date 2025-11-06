//
//  ProgressiveOverloadService.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Service for calculating progressive overload suggestions based on previous performance and week modifiers
@MainActor
final class ProgressiveOverloadService {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - Initialization

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Public API

    /// Generate workout suggestions based on template, week modifier, and previous performance
    /// - Parameters:
    ///   - template: The workout template to base suggestions on
    ///   - weekModifier: Intensity modifier from program week (e.g., 1.0, 1.025, 0.6)
    ///   - previousWorkouts: Recent workouts for this template (for historical weight analysis)
    /// - Returns: Suggested workout with recommended weights/reps
    func suggestWorkout(
        for template: WorkoutTemplate,
        weekModifier: Double,
        previousWorkouts: [Workout]
    ) async -> SuggestedWorkout {
        var suggestions: [ExerciseSuggestion] = []

        // For each exercise in template
        for templateExercise in template.exercises {
            let suggestion = await calculateExerciseSuggestion(
                templateExercise: templateExercise,
                weekModifier: weekModifier,
                previousWorkouts: previousWorkouts
            )
            suggestions.append(suggestion)
        }

        return SuggestedWorkout(
            templateName: template.name,
            weekModifier: weekModifier,
            exercises: suggestions
        )
    }

    // MARK: - Private Methods

    /// Calculate suggestion for a single exercise
    private func calculateExerciseSuggestion(
        templateExercise: TemplateExercise,
        weekModifier: Double,
        previousWorkouts: [Workout]
    ) async -> ExerciseSuggestion {
        // Find the most recent workout that contains this exercise
        let lastPerformance = findLastPerformance(
            exerciseId: templateExercise.exerciseId,
            in: previousWorkouts
        )

        guard let lastWeight = lastPerformance else {
            // No previous performance - use template defaults
            return ExerciseSuggestion(
                exerciseId: templateExercise.exerciseId,
                exerciseName: templateExercise.exerciseName,
                suggestedSets: templateExercise.setCount,
                suggestedReps: templateExercise.repRangeMax,
                suggestedWeight: 0, // User must set initial weight
                reasoning: .noHistory
            )
        }

        // Calculate suggestion based on week modifier
        let suggestion = calculateSuggestion(
            lastWeight: lastWeight,
            weekModifier: weekModifier
        )

        return ExerciseSuggestion(
            exerciseId: templateExercise.exerciseId,
            exerciseName: templateExercise.exerciseName,
            suggestedSets: templateExercise.setCount,
            suggestedReps: templateExercise.repRangeMax,
            suggestedWeight: suggestion.weight,
            reasoning: suggestion.reasoning
        )
    }

    /// Find the last performance for a specific exercise
    private func findLastPerformance(
        exerciseId: UUID,
        in workouts: [Workout]
    ) -> Double? {
        // Sort workouts by date (most recent first)
        let sortedWorkouts = workouts.sorted { $0.date > $1.date }

        // Find most recent workout with this exercise
        for workout in sortedWorkouts {
            for workoutExercise in workout.exercises {
                if workoutExercise.exercise?.id == exerciseId {
                    // Find the heaviest completed set
                    let completedSets = workoutExercise.sets.filter { $0.isCompleted }
                    if let heaviestSet = completedSets.max(by: { $0.weight < $1.weight }) {
                        return heaviestSet.weight
                    }
                }
            }
        }

        return nil
    }

    /// Calculate weight suggestion based on week modifier and progression
    private func calculateSuggestion(
        lastWeight: Double,
        weekModifier: Double
    ) -> (weight: Double, reasoning: SuggestionReasoning) {
        // Progressive overload based on week modifier
        // Week modifiers typically range:
        // - 0.6-0.7 for deload weeks
        // - 1.0 for maintenance
        // - 1.025-1.05 for progression weeks

        let newWeight = lastWeight * weekModifier

        let reasoning: SuggestionReasoning
        if weekModifier < 0.9 {
            reasoning = .deload
        } else if weekModifier > 1.01 {
            reasoning = .weekModifier
        } else {
            reasoning = .weekModifier
        }

        return (newWeight, reasoning)
    }
}

// MARK: - Data Structures

/// Suggested workout with all exercise recommendations
struct SuggestedWorkout {
    let templateName: String
    let weekModifier: Double
    let exercises: [ExerciseSuggestion]
}

/// Suggestion for a single exercise
struct ExerciseSuggestion {
    let exerciseId: UUID
    let exerciseName: String
    let suggestedSets: Int
    let suggestedReps: Int
    let suggestedWeight: Double
    let reasoning: SuggestionReasoning
}

/// Reason for the suggestion
enum SuggestionReasoning {
    case noHistory           // No previous data
    case deload             // Deload week (week modifier < 0.9)
    case weekModifier       // Using week modifier for progression

    var displayText: String {
        switch self {
        case .noHistory:
            return String(localized: "No previous data - set your starting weight",
                         comment: "Suggestion reason: no history")
        case .deload:
            return String(localized: "Deload week - reduced intensity",
                         comment: "Suggestion reason: deload")
        case .weekModifier:
            return String(localized: "Based on program week progression",
                         comment: "Suggestion reason: week modifier")
        }
    }
}
