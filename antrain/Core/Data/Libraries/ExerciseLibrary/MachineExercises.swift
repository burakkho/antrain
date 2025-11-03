//
//  MachineExercises.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Preset machine exercises for the exercise library
/// Comprehensive: 28 machine exercises including Smith Machine variants
struct MachineExercises {
    static let all: [ExerciseDTO] = [
        // LEG MACHINES
        ExerciseDTO(
            name: "Leg Press",
            category: .machine,
            muscleGroups: [.quads, .glutes],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Leg Curl (Lying)",
            category: .machine,
            muscleGroups: [.hamstrings],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Leg Curl (Seated)",
            category: .machine,
            muscleGroups: [.hamstrings],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Leg Extension",
            category: .machine,
            muscleGroups: [.quads],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Hack Squat",
            category: .machine,
            muscleGroups: [.quads, .glutes],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Seated Calf Raise",
            category: .machine,
            muscleGroups: [.calves],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Standing Calf Raise (Machine)",
            category: .machine,
            muscleGroups: [.calves],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Hip Abduction (Machine)",
            category: .machine,
            muscleGroups: [.glutes],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Hip Adduction (Machine)",
            category: .machine,
            muscleGroups: [.glutes],
            equipment: .machine
        ),

        // BACK MACHINES
        ExerciseDTO(
            name: "Lat Pulldown",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Wide-Grip Lat Pulldown",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Close-Grip Lat Pulldown",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Seated Row (Machine)",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "T-Bar Row (Machine)",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Assisted Pull-Up",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),

        // CHEST MACHINES
        ExerciseDTO(
            name: "Chest Press (Machine)",
            category: .machine,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Incline Chest Press (Machine)",
            category: .machine,
            muscleGroups: [.chest, .shoulders, .triceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Pec Fly (Machine)",
            category: .machine,
            muscleGroups: [.chest],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Assisted Dip",
            category: .machine,
            muscleGroups: [.chest, .triceps],
            equipment: .machine
        ),

        // SHOULDER MACHINES
        ExerciseDTO(
            name: "Shoulder Press (Machine)",
            category: .machine,
            muscleGroups: [.shoulders, .triceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Lateral Raise (Machine)",
            category: .machine,
            muscleGroups: [.shoulders],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Rear Delt Fly (Machine)",
            category: .machine,
            muscleGroups: [.shoulders],
            equipment: .machine
        ),

        // SMITH MACHINE
        ExerciseDTO(
            name: "Smith Machine Squat",
            category: .machine,
            muscleGroups: [.quads, .glutes],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Smith Machine Bench Press",
            category: .machine,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Smith Machine Row",
            category: .machine,
            muscleGroups: [.back, .biceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Smith Machine Shoulder Press",
            category: .machine,
            muscleGroups: [.shoulders, .triceps],
            equipment: .machine
        ),
        ExerciseDTO(
            name: "Smith Machine Romanian Deadlift",
            category: .machine,
            muscleGroups: [.hamstrings, .glutes],
            equipment: .machine
        )
    ]
}
