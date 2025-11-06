//
//  BeginnerFullBody.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Beginner full body programs
/// Simple, effective workouts for those new to strength training
struct BeginnerFullBody {
    static let all: [TemplateDTO] = [workoutA, workoutB]

    // MARK: - Workout A

    static let workoutA = TemplateDTO(
        name: "Beginner - Full Body A",
        category: .beginner,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Back Squat",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bench Press",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Bent Over Row",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Plank",
                setCount: 3,
                repRangeMin: 30,
                repRangeMax: 45,
                order: 3
            )
        ],
        version: 1
    )

    // MARK: - Workout B

    static let workoutB = TemplateDTO(
        name: "Beginner - Full Body B",
        category: .beginner,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Barbell Deadlift",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Dumbbell Shoulder Press",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Pull-Up",
                setCount: 3,
                repRangeMin: 5,
                repRangeMax: 10,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Hanging Leg Raise",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 3
            )
        ],
        version: 1
    )
}
