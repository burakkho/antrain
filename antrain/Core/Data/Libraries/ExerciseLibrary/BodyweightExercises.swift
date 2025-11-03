//
//  BodyweightExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset bodyweight exercises for the exercise library
/// Comprehensive: 35 bodyweight exercises across all difficulty levels
struct BodyweightExercises {
    static let all: [ExerciseDTO] = [
        // PUSH MOVEMENTS - BEGINNER TO ADVANCED
        ExerciseDTO(
            name: "Push-Up",
            category: .bodyweight,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Wide-Grip Push-Up",
            category: .bodyweight,
            muscleGroups: [.chest, .shoulders],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Diamond Push-Up",
            category: .bodyweight,
            muscleGroups: [.triceps, .chest],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Decline Push-Up",
            category: .bodyweight,
            muscleGroups: [.chest, .shoulders, .triceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Pike Push-Up",
            category: .bodyweight,
            muscleGroups: [.shoulders, .triceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Handstand Push-Up",
            category: .bodyweight,
            muscleGroups: [.shoulders, .triceps, .core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Dip",
            category: .bodyweight,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .none
        ),

        // PULL MOVEMENTS - BEGINNER TO ADVANCED
        ExerciseDTO(
            name: "Pull-Up",
            category: .bodyweight,
            muscleGroups: [.back, .biceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Chin-Up",
            category: .bodyweight,
            muscleGroups: [.back, .biceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Wide-Grip Pull-Up",
            category: .bodyweight,
            muscleGroups: [.back, .biceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Neutral-Grip Pull-Up",
            category: .bodyweight,
            muscleGroups: [.back, .biceps],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Muscle-Up",
            category: .bodyweight,
            muscleGroups: [.back, .chest, .triceps, .shoulders],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Inverted Row",
            category: .bodyweight,
            muscleGroups: [.back, .biceps],
            equipment: .none
        ),

        // LEGS - BEGINNER TO ADVANCED
        ExerciseDTO(
            name: "Bodyweight Squat",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Jump Squat",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes, .calves],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Pistol Squat",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes, .core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Bodyweight Lunge",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Jumping Lunge",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes, .hamstrings],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Bulgarian Split Squat",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Single-Leg Deadlift",
            category: .bodyweight,
            muscleGroups: [.hamstrings, .glutes, .core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Glute Bridge",
            category: .bodyweight,
            muscleGroups: [.glutes, .hamstrings],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Single-Leg Glute Bridge",
            category: .bodyweight,
            muscleGroups: [.glutes, .hamstrings, .core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Wall Sit",
            category: .bodyweight,
            muscleGroups: [.quads],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Calf Raise",
            category: .bodyweight,
            muscleGroups: [.calves],
            equipment: .none
        ),

        // CORE - BEGINNER TO ADVANCED
        ExerciseDTO(
            name: "Plank",
            category: .bodyweight,
            muscleGroups: [.core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Side Plank",
            category: .bodyweight,
            muscleGroups: [.core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Hollow Hold",
            category: .bodyweight,
            muscleGroups: [.core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "L-Sit",
            category: .bodyweight,
            muscleGroups: [.core, .shoulders],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Hanging Leg Raise",
            category: .bodyweight,
            muscleGroups: [.core],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Toes-to-Bar",
            category: .bodyweight,
            muscleGroups: [.core, .back],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Sit-Up",
            category: .bodyweight,
            muscleGroups: [.core],
            equipment: .none
        ),

        // DYNAMIC & EXPLOSIVE MOVEMENTS
        ExerciseDTO(
            name: "Burpee",
            category: .bodyweight,
            muscleGroups: [.fullBody],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Mountain Climber",
            category: .bodyweight,
            muscleGroups: [.core, .shoulders],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Box Jump",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes, .calves],
            equipment: .none
        ),
        ExerciseDTO(
            name: "Broad Jump",
            category: .bodyweight,
            muscleGroups: [.quads, .glutes],
            equipment: .none
        )
    ]
}
