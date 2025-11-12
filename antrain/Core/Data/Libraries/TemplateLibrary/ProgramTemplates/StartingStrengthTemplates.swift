//
//  StartingStrengthTemplates.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation

/// Starting Strength workout templates
/// Classic beginner program with alternating A/B workouts
struct StartingStrengthTemplates {
    static let all: [TemplateDTO] = [
        workoutA(),
        workoutB()
    ]

    /// Workout A: Squat, Bench/Press, Deadlift
    private static func workoutA() -> TemplateDTO {
        TemplateDTO(
            name: "Starting Strength A",
            category: .strength,
            exercises: [
                // Squat - 3x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 3,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 0
                ),
                // Bench Press - 3x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bench Press",
                    setCount: 3,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 1
                ),
                // Deadlift - 1x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Deadlift",
                    setCount: 1,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 2
                )
            ],
            version: 1
        )
    }

    /// Workout B: Squat, Press, Power Clean/Rows
    private static func workoutB() -> TemplateDTO {
        TemplateDTO(
            name: "Starting Strength B",
            category: .strength,
            exercises: [
                // Squat - 3x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 3,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 0
                ),
                // Overhead Press - 3x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Overhead Press",
                    setCount: 3,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 1
                ),
                // Barbell Row - 3x5
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bent Over Row",
                    setCount: 3,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 2
                )
            ],
            version: 1
        )
    }
}
