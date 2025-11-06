//
//  UpperLower.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Upper/Lower split program
/// 2-day split designed for muscle hypertrophy and balanced development
struct UpperLowerProgram {
    static let all: [TemplateDTO] = [upperDay, lowerDay]

    // MARK: - Day 1: Upper Body

    static let upperDay = TemplateDTO(
        name: "Upper/Lower - Upper",
        category: .hypertrophy,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Bench Press",
                setCount: 4,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bent Over Row",
                setCount: 4,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Shoulder Press",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Pull-Up",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Bicep Curl",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 4
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Tricep Pushdown",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 5
            )
        ],
        version: 1
    )

    // MARK: - Day 2: Lower Body

    static let lowerDay = TemplateDTO(
        name: "Upper/Lower - Lower",
        category: .hypertrophy,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Back Squat",
                setCount: 4,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Romanian Deadlift",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Press",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Curl (Lying)",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bulgarian Split Squat",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 4
            ),
            TemplateExerciseDTO(
                exerciseName: "Calf Raise",
                setCount: 3,
                repRangeMin: 15,
                repRangeMax: 20,
                order: 5
            )
        ],
        version: 1
    )
}
