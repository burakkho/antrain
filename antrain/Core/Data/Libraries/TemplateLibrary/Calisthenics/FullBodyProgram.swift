//
//  FullBodyProgram.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Calisthenics full body program
/// Bodyweight-focused workout for functional strength and control
struct CalisthenicsFullBody {
    static let all: [TemplateDTO] = [fullBody]

    // MARK: - Full Body Calisthenics

    static let fullBody = TemplateDTO(
        name: "Calisthenics - Full Body",
        category: .calisthenics,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Push-Up",
                setCount: 4,
                repRangeMin: 12,
                repRangeMax: 15,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Pull-Up",
                setCount: 4,
                repRangeMin: 8,
                repRangeMax: 12,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Dip",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 15,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Pistol Squat",
                setCount: 3,
                repRangeMin: 8,
                repRangeMax: 10,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Hanging Leg Raise",
                setCount: 3,
                repRangeMin: 10,
                repRangeMax: 15,
                order: 4
            ),
            TemplateExerciseDTO(
                exerciseName: "Plank",
                setCount: 3,
                repRangeMin: 30,
                repRangeMax: 60,
                order: 5
            )
        ],
        version: 1
    )
}
