//
//  TemplateDTO.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Data Transfer Object for a single exercise within a template
/// Lightweight, Sendable structure for defining template exercises
struct TemplateExerciseDTO: Sendable {
    let exerciseName: String
    let setCount: Int
    let repRangeMin: Int
    let repRangeMax: Int
    let order: Int

    init(
        exerciseName: String,
        setCount: Int,
        repRangeMin: Int,
        repRangeMax: Int,
        order: Int
    ) {
        self.exerciseName = exerciseName
        self.setCount = setCount
        self.repRangeMin = repRangeMin
        self.repRangeMax = repRangeMax
        self.order = order
    }
}

/// Data Transfer Object for a workout template
/// Lightweight, Sendable structure for defining preset templates
struct TemplateDTO: Sendable {
    let name: String
    let category: TemplateCategory
    let exercises: [TemplateExerciseDTO]
    let version: Int

    init(
        name: String,
        category: TemplateCategory,
        exercises: [TemplateExerciseDTO],
        version: Int = 1
    ) {
        self.name = name
        self.category = category
        self.exercises = exercises
        self.version = version
    }

    /// Converts this DTO to a SwiftData WorkoutTemplate model
    /// - Parameter exerciseFinder: Closure to find exercises by name from SwiftData
    /// - Returns: WorkoutTemplate if all exercises are found, nil otherwise
    func toModel(exerciseFinder: (String) -> Exercise?) -> WorkoutTemplate? {
        let template = WorkoutTemplate(
            name: name,
            category: category,
            isPreset: true
        )

        for exerciseDTO in exercises {
            guard let exercise = exerciseFinder(exerciseDTO.exerciseName) else {
                print("⚠️ Warning: Exercise '\(exerciseDTO.exerciseName)' not found in library for template '\(name)'")
                return nil
            }

            let templateExercise = TemplateExercise(
                order: exerciseDTO.order,
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                setCount: exerciseDTO.setCount,
                repRangeMin: exerciseDTO.repRangeMin,
                repRangeMax: exerciseDTO.repRangeMax
            )
            templateExercise.template = template
            template.exercises.append(templateExercise)
        }

        return template
    }
}
