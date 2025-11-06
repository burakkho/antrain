//
//  OlympicProgram.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Olympic Weightlifting program
/// Focus on snatch, clean & jerk, and accessory movements
struct OlympicProgram {
    static let all: [TemplateDTO] = [olympicLifting]

    // MARK: - Olympic Lifting Session

    static let olympicLifting = TemplateDTO(
        name: "Olympic Lifting",
        category: .weightlifting,
        exercises: [
            TemplateExerciseDTO(
                exerciseName: "Snatch",
                setCount: 5,
                repRangeMin: 2,
                repRangeMax: 3,
                order: 0
            ),
            TemplateExerciseDTO(
                exerciseName: "Clean & Jerk",
                setCount: 5,
                repRangeMin: 2,
                repRangeMax: 3,
                order: 1
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Front Squat",
                setCount: 4,
                repRangeMin: 3,
                repRangeMax: 5,
                order: 2
            ),
            TemplateExerciseDTO(
                exerciseName: "Overhead Squat",
                setCount: 3,
                repRangeMin: 3,
                repRangeMax: 5,
                order: 3
            ),
            TemplateExerciseDTO(
                exerciseName: "Barbell Push Press",
                setCount: 3,
                repRangeMin: 5,
                repRangeMax: 8,
                order: 4
            )
        ],
        version: 1
    )
}
