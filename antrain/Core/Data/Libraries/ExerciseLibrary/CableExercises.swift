//
//  CableExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset cable exercises for the exercise library
/// Comprehensive: 24 cable exercises covering all muscle groups
struct CableExercises {
    static let all: [ExerciseDTO] = [
        // CHEST - CABLE
        ExerciseDTO(
            name: "Cable Crossover",
            category: .cable,
            muscleGroups: [.chest],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Fly (High to Low)",
            category: .cable,
            muscleGroups: [.chest],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Fly (Low to High)",
            category: .cable,
            muscleGroups: [.chest],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Press",
            category: .cable,
            muscleGroups: [.chest, .triceps],
            equipment: .cable
        ),

        // BACK - CABLE
        ExerciseDTO(
            name: "Cable Row (Seated)",
            category: .cable,
            muscleGroups: [.back, .biceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Row (Single-Arm)",
            category: .cable,
            muscleGroups: [.back, .biceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Lat Pulldown",
            category: .cable,
            muscleGroups: [.back, .biceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Face Pull",
            category: .cable,
            muscleGroups: [.shoulders, .back],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Pullover",
            category: .cable,
            muscleGroups: [.back, .chest],
            equipment: .cable
        ),

        // SHOULDERS - CABLE
        ExerciseDTO(
            name: "Cable Lateral Raise",
            category: .cable,
            muscleGroups: [.shoulders],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Front Raise",
            category: .cable,
            muscleGroups: [.shoulders],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Rear Delt Fly",
            category: .cable,
            muscleGroups: [.shoulders],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Upright Row",
            category: .cable,
            muscleGroups: [.shoulders, .traps],
            equipment: .cable
        ),

        // ARMS - BICEPS
        ExerciseDTO(
            name: "Cable Bicep Curl",
            category: .cable,
            muscleGroups: [.biceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Hammer Curl",
            category: .cable,
            muscleGroups: [.biceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Preacher Curl",
            category: .cable,
            muscleGroups: [.biceps],
            equipment: .cable
        ),

        // ARMS - TRICEPS
        ExerciseDTO(
            name: "Cable Tricep Pushdown",
            category: .cable,
            muscleGroups: [.triceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Tricep Pushdown (Rope)",
            category: .cable,
            muscleGroups: [.triceps],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Overhead Tricep Extension",
            category: .cable,
            muscleGroups: [.triceps],
            equipment: .cable
        ),

        // LEGS - CABLE
        ExerciseDTO(
            name: "Cable Kickback",
            category: .cable,
            muscleGroups: [.glutes],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Pull-Through",
            category: .cable,
            muscleGroups: [.glutes, .hamstrings],
            equipment: .cable
        ),

        // CORE - CABLE
        ExerciseDTO(
            name: "Cable Woodchop",
            category: .cable,
            muscleGroups: [.core],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Crunch",
            category: .cable,
            muscleGroups: [.core],
            equipment: .cable
        ),
        ExerciseDTO(
            name: "Cable Pallof Press",
            category: .cable,
            muscleGroups: [.core],
            equipment: .cable
        )
    ]
}
