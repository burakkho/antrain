//
//  WeightliftingExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset Olympic weightlifting exercises for the exercise library
/// Comprehensive: 18 weightlifting exercises - Clean & Jerk and Snatch variations
struct WeightliftingExercises {
    static let all: [ExerciseDTO] = [
        // CLEAN & JERK COMPLEX
        ExerciseDTO(
            name: "Clean & Jerk",
            category: .weightlifting,
            muscleGroups: [.fullBody],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Power Clean & Jerk",
            category: .weightlifting,
            muscleGroups: [.fullBody],
            equipment: .barbell
        ),

        // CLEAN VARIATIONS
        ExerciseDTO(
            name: "Clean (Squat Clean)",
            category: .weightlifting,
            muscleGroups: [.quads, .back, .shoulders, .traps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Power Clean",
            category: .weightlifting,
            muscleGroups: [.back, .shoulders, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Hang Clean (Knee)",
            category: .weightlifting,
            muscleGroups: [.back, .shoulders, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Hang Clean (High)",
            category: .weightlifting,
            muscleGroups: [.back, .shoulders, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Muscle Clean",
            category: .weightlifting,
            muscleGroups: [.back, .shoulders, .traps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Clean Pull",
            category: .weightlifting,
            muscleGroups: [.back, .traps, .hamstrings],
            equipment: .barbell
        ),

        // JERK VARIATIONS
        ExerciseDTO(
            name: "Split Jerk",
            category: .weightlifting,
            muscleGroups: [.shoulders, .quads, .core],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Push Jerk",
            category: .weightlifting,
            muscleGroups: [.shoulders, .quads, .triceps],
            equipment: .barbell
        ),

        // SNATCH VARIATIONS
        ExerciseDTO(
            name: "Snatch",
            category: .weightlifting,
            muscleGroups: [.fullBody],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Power Snatch",
            category: .weightlifting,
            muscleGroups: [.shoulders, .back, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Hang Snatch (Knee)",
            category: .weightlifting,
            muscleGroups: [.shoulders, .back, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Hang Snatch (High)",
            category: .weightlifting,
            muscleGroups: [.shoulders, .back, .traps, .quads],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Muscle Snatch",
            category: .weightlifting,
            muscleGroups: [.shoulders, .back, .traps],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Snatch Pull",
            category: .weightlifting,
            muscleGroups: [.back, .traps, .hamstrings, .shoulders],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Snatch Balance",
            category: .weightlifting,
            muscleGroups: [.shoulders, .quads, .core],
            equipment: .barbell
        ),

        // ACCESSORY
        ExerciseDTO(
            name: "Overhead Squat",
            category: .weightlifting,
            muscleGroups: [.quads, .shoulders, .core],
            equipment: .barbell
        )
    ]
}
