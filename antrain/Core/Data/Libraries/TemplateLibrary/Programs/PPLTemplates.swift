//
//  PPLTemplates.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation

/// Push Pull Legs workout templates
struct PPLTemplates {
    static let all: [TemplateDTO] = [
        pushDay(),
        pullDay(),
        legDay()
    ]

    /// Push Day: Chest, Shoulders, Triceps
    private static func pushDay() -> TemplateDTO {
        TemplateDTO(
            name: "PPL Push",
            category: .hypertrophy,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bench Press",
                    setCount: 4,
                    repRangeMin: 5,
                    repRangeMax: 8,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Overhead Press",
                    setCount: 3,
                    repRangeMin: 8,
                    repRangeMax: 12,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Dumbbell Incline Bench Press",
                    setCount: 3,
                    repRangeMin: 8,
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
                )
            ],
            version: 1
        )
    }

    /// Pull Day: Back, Biceps
    private static func pullDay() -> TemplateDTO {
        TemplateDTO(
            name: "PPL Pull",
            category: .hypertrophy,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Deadlift",
                    setCount: 3,
                    repRangeMin: 5,
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
                    exerciseName: "Cable Face Pull",
                    setCount: 3,
                    repRangeMin: 15,
                    repRangeMax: 20,
                    order: 3
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bicep Curl",
                    setCount: 3,
                    repRangeMin: 10,
                    repRangeMax: 12,
                    order: 4
                )
            ],
            version: 1
        )
    }

    /// Leg Day: Quads, Hamstrings, Glutes
    private static func legDay() -> TemplateDTO {
        TemplateDTO(
            name: "PPL Legs",
            category: .hypertrophy,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 4,
                    repRangeMin: 5,
                    repRangeMax: 8,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Romanian Deadlift",
                    setCount: 3,
                    repRangeMin: 8,
                    repRangeMax: 12,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Leg Press",
                    setCount: 3,
                    repRangeMin: 10,
                    repRangeMax: 15,
                    order: 2
                ),
                TemplateExerciseDTO(
                    exerciseName: "Leg Curl (Lying)",
                    setCount: 3,
                    repRangeMin: 12,
                    repRangeMax: 15,
                    order: 3
                ),
                TemplateExerciseDTO(
                    exerciseName: "Standing Calf Raise (Machine)",
                    setCount: 4,
                    repRangeMin: 15,
                    repRangeMax: 20,
                    order: 4
                )
            ],
            version: 1
        )
    }
}
