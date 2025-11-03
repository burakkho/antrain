//
//  BarbellExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset barbell exercises for the exercise library
/// Comprehensive: 30 barbell exercises covering all major movement patterns
struct BarbellExercises {
    static let all: [ExerciseDTO] = [
        // SQUAT VARIATIONS
        ExerciseDTO(
            name: "Barbell Back Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .core],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Front Squat",
            category: .barbell,
            muscleGroups: [.quads, .core],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Box Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Pause Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .core],
            equipment: .barbell
        ),

        // DEADLIFT VARIATIONS
        ExerciseDTO(
            name: "Barbell Deadlift",
            category: .barbell,
            muscleGroups: [.back, .hamstrings, .glutes],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Romanian Deadlift",
            category: .barbell,
            muscleGroups: [.hamstrings, .glutes, .back],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Sumo Deadlift",
            category: .barbell,
            muscleGroups: [.back, .glutes, .hamstrings],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Deficit Deadlift",
            category: .barbell,
            muscleGroups: [.back, .hamstrings, .glutes],
            equipment: .barbell
        ),

        // BENCH PRESS VARIATIONS
        ExerciseDTO(
            name: "Barbell Bench Press",
            category: .barbell,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Incline Bench Press",
            category: .barbell,
            muscleGroups: [.chest, .shoulders, .triceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Decline Bench Press",
            category: .barbell,
            muscleGroups: [.chest, .triceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Close-Grip Bench Press",
            category: .barbell,
            muscleGroups: [.triceps, .chest, .shoulders],
            equipment: .barbell
        ),

        // OVERHEAD PRESS VARIATIONS
        ExerciseDTO(
            name: "Barbell Overhead Press",
            category: .barbell,
            muscleGroups: [.shoulders, .triceps, .core],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Push Press",
            category: .barbell,
            muscleGroups: [.shoulders, .triceps, .quads],
            equipment: .barbell
        ),

        // ROW VARIATIONS
        ExerciseDTO(
            name: "Barbell Bent Over Row",
            category: .barbell,
            muscleGroups: [.back, .biceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Pendlay Row",
            category: .barbell,
            muscleGroups: [.back, .biceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Underhand Row",
            category: .barbell,
            muscleGroups: [.back, .biceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Seal Row",
            category: .barbell,
            muscleGroups: [.back, .biceps],
            equipment: .barbell
        ),

        // SHOULDER EXERCISES
        ExerciseDTO(
            name: "Barbell Upright Row",
            category: .barbell,
            muscleGroups: [.shoulders, .traps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell High Pull",
            category: .barbell,
            muscleGroups: [.shoulders, .traps, .back],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Shrug",
            category: .barbell,
            muscleGroups: [.traps],
            equipment: .barbell
        ),

        // LEG EXERCISES
        ExerciseDTO(
            name: "Barbell Lunge",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Walking Lunge",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Bulgarian Split Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Hip Thrust",
            category: .barbell,
            muscleGroups: [.glutes, .hamstrings],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Good Morning",
            category: .barbell,
            muscleGroups: [.hamstrings, .glutes, .back],
            equipment: .barbell
        ),

        // ARM EXERCISES
        ExerciseDTO(
            name: "Barbell Bicep Curl",
            category: .barbell,
            muscleGroups: [.biceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Close-Grip Curl",
            category: .barbell,
            muscleGroups: [.biceps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Skull Crusher",
            category: .barbell,
            muscleGroups: [.triceps],
            equipment: .barbell
        ),

        // FULL BODY
        ExerciseDTO(
            name: "Barbell Thruster",
            category: .barbell,
            muscleGroups: [.quads, .shoulders, .core],
            equipment: .barbell
        )
    ]
}
