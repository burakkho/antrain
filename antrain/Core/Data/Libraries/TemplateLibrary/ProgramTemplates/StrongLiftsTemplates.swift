//
//  StrongLiftsTemplates.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation

/// StrongLifts 5x5 workout templates
struct StrongLiftsTemplates {
    static let all: [TemplateDTO] = [
        workoutA(),
        workoutB()
    ]

    /// Workout A: Squat, Bench, Row
    private static func workoutA() -> TemplateDTO {
        TemplateDTO(
            name: "StrongLifts 5x5 A",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 5,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bench Press",
                    setCount: 5,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 1
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Bent Over Row",
                    setCount: 5,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 2
                )
            ],
            version: 1
        )
    }

    /// Workout B: Squat, Press, Deadlift
    private static func workoutB() -> TemplateDTO {
        TemplateDTO(
            name: "StrongLifts 5x5 B",
            category: .strength,
            exercises: [
                TemplateExerciseDTO(
                    exerciseName: "Barbell Back Squat",
                    setCount: 5,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 0
                ),
                TemplateExerciseDTO(
                    exerciseName: "Barbell Overhead Press",
                    setCount: 5,
                    repRangeMin: 5,
                    repRangeMax: 5,
                    order: 1
                ),
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
}
