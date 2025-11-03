//
//  ExerciseDTO.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Data Transfer Object for Exercise
/// Used to define preset exercises in code, then convert to SwiftData models
struct ExerciseDTO: Sendable {
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let equipment: Equipment
    let version: Int

    init(
        name: String,
        category: ExerciseCategory,
        muscleGroups: [MuscleGroup],
        equipment: Equipment,
        version: Int = 1
    ) {
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.equipment = equipment
        self.version = version
    }

    /// Convert DTO to SwiftData Exercise model
    func toModel() -> Exercise {
        return Exercise(
            name: name,
            category: category,
            muscleGroups: muscleGroups,
            equipment: equipment,
            isCustom: false,  // Preset exercise
            version: version
        )
    }
}
