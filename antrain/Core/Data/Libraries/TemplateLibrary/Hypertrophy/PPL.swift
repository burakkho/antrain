//
//  PPL.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Push/Pull/Legs (PPL) program
/// 3-day split designed for muscle hypertrophy
struct PPLProgram {
    static let all: [TemplateDTO] = [pushDay, pullDay, legsDay]

    // MARK: - Day 1: Push (Chest, Shoulders, Triceps)

    static let pushDay = TemplateDTO(
        name: "PPL - Push",
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
                exerciseName: "Dumbbell Incline Bench Press",
                setCount: 3,
                repRangeMin: 10,
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
                exerciseName: "Dumbbell Lateral Raise",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Tricep Pushdown",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 4
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Overhead Tricep Extension",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 5
            )
        ],
        version: 1
    )

    // MARK: - Day 2: Pull (Back, Biceps)

    static let pullDay = TemplateDTO(
        name: "PPL - Pull",
        category: .hypertrophy,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Deadlift",
                setCount: 3,
                repRangeMin: 6,
                repRangeMax: 8,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Pull-Up",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bent Over Row",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Row (Seated)",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Cable Face Pull",
                setCount: 3,
                repRangeMin: 15,
                repRangeMax: 20,
                order: 4
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Bicep Curl",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 5
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Hammer Curl",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 6
            )
        ],
        version: 1
    )

    // MARK: - Day 3: Legs (Quads, Hamstrings, Calves)

    static let legsDay = TemplateDTO(
        name: "PPL - Legs",
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
                exerciseName: "Leg Press",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 15,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Curl (Lying)",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 12,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Leg Extension",
                setCount: 3,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Calf Raise",
                setCount: 4,
                repRangeMin: 15,
                repRangeMax: 20,
                order: 4
            )
        ],
        version: 1
    )
}
