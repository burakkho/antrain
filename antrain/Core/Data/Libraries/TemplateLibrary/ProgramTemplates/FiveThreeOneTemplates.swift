//
//  FiveThreeOneTemplates.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation

/// 5/3/1 workout templates
struct FiveThreeOneTemplates {
    static let all: [TemplateDTO] = [
        squatDay(),
        benchDay(),
        deadliftDay(),
        pressDay()
    ]

    /// Squat Day
    private static func squatDay() -> TemplateDTO {
        TemplateDTO(
            name: "531 Squat",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 3,
                    repRangeMin: 3,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Leg Curl (Lying)",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 2
                ),
                TemplateExerciseDTO(
                    exerciseName: "Plank",
                    setCount: 3,
                    repRangeMin: 30,
                    repRangeMax: 60,
                    order: 3
                )
            ],
            version: 1
        )
    }

    /// Bench Day
    private static func benchDay() -> TemplateDTO {
        TemplateDTO(
            name: "531 Bench",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bench Press",
                    setCount: 3,
                    repRangeMin: 3,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bench Press",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Dumbbell Row",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 2
                ),
                TemplateExerciseDTO(
                    exerciseName: "Cable Tricep Pushdown",
                    setCount: 3,
                    repRangeMin: 12,
                    repRangeMax: 15,
                    order: 3
                )
            ],
            version: 1
        )
    }

    /// Deadlift Day
    private static func deadliftDay() -> TemplateDTO {
        TemplateDTO(
            name: "531 Deadlift",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Deadlift",
                    setCount: 3,
                    repRangeMin: 3,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Romanian Deadlift",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Pull-Up",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 2
                ),
                TemplateExerciseDTO(
                    exerciseName: "Hanging Leg Raise",
                    setCount: 3,
                    repRangeMin: 10,
                    repRangeMax: 15,
                    order: 3
                )
            ],
            version: 1
        )
    }

    /// Press Day
    private static func pressDay() -> TemplateDTO {
        TemplateDTO(
            name: "531 Press",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Overhead Press",
                    setCount: 3,
                    repRangeMin: 3,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Overhead Press",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Chin-Up",
                    setCount: 5,
                    repRangeMin: 10,
                    repRangeMax: 10,
                    order: 2
                ),
                TemplateExerciseDTO(
                    exerciseName: "Dumbbell Lateral Raise",
                    setCount: 3,
                    repRangeMin: 15,
                    repRangeMax: 20,
                    order: 3
                )
            ],
            version: 1
        )
    }
}
