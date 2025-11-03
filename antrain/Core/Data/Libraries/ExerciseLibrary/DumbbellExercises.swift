//
//  DumbbellExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset dumbbell exercises for the exercise library
/// Comprehensive: 48 dumbbell exercises covering all muscle groups
struct DumbbellExercises {
    static let all: [ExerciseDTO] = [
        // UPPER BODY COMPOUND - CHEST
        ExerciseDTO(
            name: "Dumbbell Bench Press",
            category: .dumbbell,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Incline Bench Press",
            category: .dumbbell,
            muscleGroups: [.chest, .shoulders, .triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Decline Bench Press",
            category: .dumbbell,
            muscleGroups: [.chest, .triceps],
            equipment: .dumbbell
        ),

        // UPPER BODY COMPOUND - BACK
        ExerciseDTO(
            name: "Dumbbell Row",
            category: .dumbbell,
            muscleGroups: [.back, .biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Single-Arm Row",
            category: .dumbbell,
            muscleGroups: [.back, .biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Bent Over Row",
            category: .dumbbell,
            muscleGroups: [.back, .biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Seal Row",
            category: .dumbbell,
            muscleGroups: [.back, .biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Renegade Row",
            category: .dumbbell,
            muscleGroups: [.back, .core, .shoulders],
            equipment: .dumbbell
        ),

        // UPPER BODY COMPOUND - SHOULDERS
        ExerciseDTO(
            name: "Dumbbell Shoulder Press",
            category: .dumbbell,
            muscleGroups: [.shoulders, .triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Arnold Press",
            category: .dumbbell,
            muscleGroups: [.shoulders, .triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Seated Shoulder Press",
            category: .dumbbell,
            muscleGroups: [.shoulders, .triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Push Press",
            category: .dumbbell,
            muscleGroups: [.shoulders, .triceps, .quads],
            equipment: .dumbbell
        ),

        // UPPER BODY ISOLATION - CHEST
        ExerciseDTO(
            name: "Dumbbell Fly",
            category: .dumbbell,
            muscleGroups: [.chest],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Incline Fly",
            category: .dumbbell,
            muscleGroups: [.chest],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Pullover",
            category: .dumbbell,
            muscleGroups: [.chest, .back],
            equipment: .dumbbell
        ),

        // UPPER BODY ISOLATION - SHOULDERS
        ExerciseDTO(
            name: "Dumbbell Lateral Raise",
            category: .dumbbell,
            muscleGroups: [.shoulders],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Front Raise",
            category: .dumbbell,
            muscleGroups: [.shoulders],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Rear Delt Fly",
            category: .dumbbell,
            muscleGroups: [.shoulders],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Upright Row",
            category: .dumbbell,
            muscleGroups: [.shoulders, .traps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Shrug",
            category: .dumbbell,
            muscleGroups: [.traps],
            equipment: .dumbbell
        ),

        // UPPER BODY ISOLATION - BICEPS
        ExerciseDTO(
            name: "Dumbbell Bicep Curl",
            category: .dumbbell,
            muscleGroups: [.biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Hammer Curl",
            category: .dumbbell,
            muscleGroups: [.biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Concentration Curl",
            category: .dumbbell,
            muscleGroups: [.biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Incline Curl",
            category: .dumbbell,
            muscleGroups: [.biceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Preacher Curl",
            category: .dumbbell,
            muscleGroups: [.biceps],
            equipment: .dumbbell
        ),

        // UPPER BODY ISOLATION - TRICEPS
        ExerciseDTO(
            name: "Dumbbell Tricep Extension",
            category: .dumbbell,
            muscleGroups: [.triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Overhead Tricep Extension",
            category: .dumbbell,
            muscleGroups: [.triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Skull Crusher",
            category: .dumbbell,
            muscleGroups: [.triceps],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Tricep Kickback",
            category: .dumbbell,
            muscleGroups: [.triceps],
            equipment: .dumbbell
        ),

        // LOWER BODY - QUADS & GLUTES
        ExerciseDTO(
            name: "Dumbbell Goblet Squat",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes, .core],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Front Squat",
            category: .dumbbell,
            muscleGroups: [.quads, .core],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Sumo Squat",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Lunge",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Walking Lunge",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Reverse Lunge",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Bulgarian Split Squat",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Step-Up",
            category: .dumbbell,
            muscleGroups: [.quads, .glutes],
            equipment: .dumbbell
        ),

        // LOWER BODY - HAMSTRINGS & GLUTES
        ExerciseDTO(
            name: "Dumbbell Romanian Deadlift",
            category: .dumbbell,
            muscleGroups: [.hamstrings, .glutes, .back],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Single-Leg Romanian Deadlift",
            category: .dumbbell,
            muscleGroups: [.hamstrings, .glutes, .core],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Stiff-Leg Deadlift",
            category: .dumbbell,
            muscleGroups: [.hamstrings, .glutes],
            equipment: .dumbbell
        ),

        // LOWER BODY - CALVES
        ExerciseDTO(
            name: "Dumbbell Calf Raise",
            category: .dumbbell,
            muscleGroups: [.calves],
            equipment: .dumbbell
        ),

        // FULL BODY & FUNCTIONAL
        ExerciseDTO(
            name: "Dumbbell Thruster",
            category: .dumbbell,
            muscleGroups: [.quads, .shoulders, .core],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Snatch",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Clean",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Clean & Press",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Turkish Get-Up",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Man Maker",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Devil Press",
            category: .dumbbell,
            muscleGroups: [.fullBody],
            equipment: .dumbbell
        ),
        ExerciseDTO(
            name: "Dumbbell Farmer's Walk",
            category: .dumbbell,
            muscleGroups: [.core, .traps],
            equipment: .dumbbell
        )
    ]
}
