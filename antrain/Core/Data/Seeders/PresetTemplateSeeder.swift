//
//  PresetTemplateSeeder.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation

/// Seeds preset workout templates into the database
/// Templates designed by personal trainer with standard configurations
struct PresetTemplateSeeder {
    /// Creates all preset templates
    /// - Returns: Array of preset workout templates ready for insertion
    static func createPresetTemplates() -> [WorkoutTemplate] {
        let exerciseLibrary = ExerciseLibrary()
        let allExercises = exerciseLibrary.getAllPresetExercisesAsModels()

        // Helper to find exercise by name
        func findExercise(_ name: String) -> Exercise? {
            allExercises.first { $0.name.lowercased() == name.lowercased() }
        }

        var templates: [WorkoutTemplate] = []

        // MARK: - Strength Templates

        // 1. Powerlifting - Day 1: Squat Focus
        templates.append(createTemplate(
            name: "Powerlifting - Squat Day",
            category: .strength,
            exercises: [
                ("Back Squat", 4, 3, 5),
                ("Front Squat", 3, 5, 8),
                ("Leg Press", 3, 8, 12),
                ("Bulgarian Split Squat", 3, 6, 8),
                ("Leg Curl", 3, 10, 12)
            ],
            exerciseFinder: findExercise
        ))

        // 2. Powerlifting - Day 2: Bench Focus
        templates.append(createTemplate(
            name: "Powerlifting - Bench Day",
            category: .strength,
            exercises: [
                ("Barbell Bench Press", 4, 3, 5),
                ("Incline Barbell Bench Press", 3, 5, 8),
                ("Close Grip Bench Press", 3, 6, 8),
                ("Dips", 3, 8, 12),
                ("Tricep Pushdown", 3, 10, 15)
            ],
            exerciseFinder: findExercise
        ))

        // 3. Powerlifting - Day 3: Deadlift Focus
        templates.append(createTemplate(
            name: "Powerlifting - Deadlift Day",
            category: .strength,
            exercises: [
                ("Barbell Deadlift", 4, 3, 5),
                ("Romanian Deadlift", 3, 5, 8),
                ("Barbell Bent Over Row", 3, 6, 8),
                ("Pull-ups", 3, 6, 10),
                ("Face Pulls", 3, 12, 15)
            ],
            exerciseFinder: findExercise
        ))

        // MARK: - Hypertrophy Templates

        // 4. PPL - Push Day
        templates.append(createTemplate(
            name: "PPL - Push",
            category: .hypertrophy,
            exercises: [
                ("Barbell Bench Press", 4, 8, 12),
                ("Incline Dumbbell Press", 3, 10, 12),
                ("Dumbbell Shoulder Press", 3, 10, 12),
                ("Dumbbell Lateral Raise", 3, 12, 15),
                ("Tricep Pushdown", 3, 12, 15),
                ("Dumbbell Overhead Extension", 3, 10, 12)
            ],
            exerciseFinder: findExercise
        ))

        // 5. PPL - Pull Day
        templates.append(createTemplate(
            name: "PPL - Pull",
            category: .hypertrophy,
            exercises: [
                ("Barbell Deadlift", 3, 6, 8),
                ("Pull-ups", 3, 8, 12),
                ("Barbell Bent Over Row", 3, 8, 12),
                ("Cable Row", 3, 10, 12),
                ("Face Pulls", 3, 15, 20),
                ("Dumbbell Curl", 3, 12, 15),
                ("Hammer Curl", 3, 10, 12)
            ],
            exerciseFinder: findExercise
        ))

        // 6. PPL - Legs Day
        templates.append(createTemplate(
            name: "PPL - Legs",
            category: .hypertrophy,
            exercises: [
                ("Back Squat", 4, 8, 12),
                ("Leg Press", 3, 10, 15),
                ("Leg Curl", 3, 10, 12),
                ("Leg Extension", 3, 12, 15),
                ("Calf Raises", 4, 15, 20)
            ],
            exerciseFinder: findExercise
        ))

        // 7. Upper/Lower - Upper Body
        templates.append(createTemplate(
            name: "Upper/Lower - Upper",
            category: .hypertrophy,
            exercises: [
                ("Barbell Bench Press", 4, 8, 12),
                ("Barbell Bent Over Row", 4, 8, 12),
                ("Dumbbell Shoulder Press", 3, 10, 12),
                ("Pull-ups", 3, 8, 12),
                ("Dumbbell Curl", 3, 12, 15),
                ("Tricep Pushdown", 3, 12, 15)
            ],
            exerciseFinder: findExercise
        ))

        // 8. Upper/Lower - Lower Body
        templates.append(createTemplate(
            name: "Upper/Lower - Lower",
            category: .hypertrophy,
            exercises: [
                ("Back Squat", 4, 8, 12),
                ("Romanian Deadlift", 3, 10, 12),
                ("Leg Press", 3, 12, 15),
                ("Leg Curl", 3, 10, 12),
                ("Bulgarian Split Squat", 3, 10, 12),
                ("Calf Raises", 3, 15, 20)
            ],
            exerciseFinder: findExercise
        ))

        // MARK: - Calisthenics Templates

        // 9. Full Body Calisthenics
        templates.append(createTemplate(
            name: "Calisthenics - Full Body",
            category: .calisthenics,
            exercises: [
                ("Push-ups", 4, 12, 15),
                ("Pull-ups", 4, 8, 12),
                ("Dips", 3, 10, 15),
                ("Pistol Squats", 3, 8, 10),
                ("Hanging Leg Raise", 3, 10, 15),
                ("Plank", 3, 30, 60)
            ],
            exerciseFinder: findExercise
        ))

        // MARK: - Weightlifting Templates

        // 10. Olympic Lifting Program
        templates.append(createTemplate(
            name: "Olympic Lifting",
            category: .weightlifting,
            exercises: [
                ("Snatch", 5, 2, 3),
                ("Clean and Jerk", 5, 2, 3),
                ("Front Squat", 4, 3, 5),
                ("Overhead Squat", 3, 3, 5),
                ("Push Press", 3, 5, 8)
            ],
            exerciseFinder: findExercise
        ))

        // MARK: - Beginner Templates

        // 11. Beginner Full Body A
        templates.append(createTemplate(
            name: "Beginner - Full Body A",
            category: .beginner,
            exercises: [
                ("Back Squat", 3, 8, 10),
                ("Barbell Bench Press", 3, 8, 10),
                ("Barbell Bent Over Row", 3, 8, 10),
                ("Plank", 3, 30, 45)
            ],
            exerciseFinder: findExercise
        ))

        // 12. Beginner Full Body B
        templates.append(createTemplate(
            name: "Beginner - Full Body B",
            category: .beginner,
            exercises: [
                ("Barbell Deadlift", 3, 8, 10),
                ("Dumbbell Shoulder Press", 3, 8, 10),
                ("Pull-ups", 3, 5, 10),
                ("Hanging Leg Raise", 3, 8, 12)
            ],
            exerciseFinder: findExercise
        ))

        return templates
    }

    // MARK: - Helper Methods

    /// Helper to create a template with exercises
    private static func createTemplate(
        name: String,
        category: TemplateCategory,
        exercises: [(name: String, sets: Int, repMin: Int, repMax: Int)],
        exerciseFinder: (String) -> Exercise?
    ) -> WorkoutTemplate {
        let template = WorkoutTemplate(
            name: name,
            category: category,
            isPreset: true
        )

        for (index, exerciseData) in exercises.enumerated() {
            guard let exercise = exerciseFinder(exerciseData.name) else {
                print("⚠️ Warning: Exercise '\(exerciseData.name)' not found in library")
                continue
            }

            let templateExercise = TemplateExercise(
                order: index,
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                setCount: exerciseData.sets,
                repRangeMin: exerciseData.repMin,
                repRangeMax: exerciseData.repMax
            )
            templateExercise.template = template
            template.exercises.append(templateExercise)
        }

        return template
    }
}
