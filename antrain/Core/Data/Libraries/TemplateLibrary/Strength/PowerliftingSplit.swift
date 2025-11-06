//
//  PowerliftingSplit.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Powerlifting program with focus on the big 3 lifts: Squat, Bench, Deadlift
/// 3-day split designed for strength development
struct PowerliftingSplit {
    static let all: [TemplateDTO] = [squatDay, benchDay, deadliftDay]

    // MARK: - Day 1: Squat Focus

    static let squatDay = TemplateDTO(
        name: "Powerlifting - Squat Day",
        category: .strength,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Back Squat",
                setCount: 4,
                repRangeMin: 3,
                repRangeMax: 5,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Front Squat",
                setCount: 3,
                repRangeMin: 5,
                repRangeMax: 8,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Press",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bulgarian Split Squat",
                setCount: 3,
                repRangeMin: 6,
                repRangeMax: 8,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Curl (Lying)",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 4
            )
        ],
        version: 1
    )

    // MARK: - Day 2: Bench Focus

    static let benchDay = TemplateDTO(
        name: "Powerlifting - Bench Day",
        category: .strength,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Bench Press",
                setCount: 4,
                repRangeMin: 3,
                repRangeMax: 5,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Incline Bench Press",
                setCount: 3,
                repRangeMin: 5,
                repRangeMax: 8,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Close-Grip Bench Press",
                setCount: 3,
                repRangeMin: 6,
                repRangeMax: 8,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Dip",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Tricep Pushdown",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 15,
                order: 4
            )
        ],
        version: 1
    )

    // MARK: - Day 3: Deadlift Focus

    static let deadliftDay = TemplateDTO(
        name: "Powerlifting - Deadlift Day",
        category: .strength,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Deadlift",
                setCount: 4,
                repRangeMin: 3,
                repRangeMax: 5,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Romanian Deadlift",
                setCount: 3,
                repRangeMin: 5,
                repRangeMax: 8,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bent Over Row",
                setCount: 3,
                repRangeMin: 6,
                repRangeMax: 8,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Pull-Up",
                setCount: 3,
                repRangeMin: 6,
                repRangeMax: 10,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Face Pull",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 4
            )
        ],
        version: 1
    )
}
