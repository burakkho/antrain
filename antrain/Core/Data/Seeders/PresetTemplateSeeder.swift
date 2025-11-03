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
    /// - Parameter exerciseFinder: Closure to find exercises by name from SwiftData
    /// - Returns: Array of preset workout templates ready for insertion
    @MainActor
    static func createPresetTemplates(exerciseFinder: @escaping (String) -> Exercise?) -> [WorkoutTemplate] {
        var templates: [WorkoutTemplate] = []

        // MARK: - Strength Templates

        // 1. Powerlifting - Day 1: Squat Focus
        templates.append(createTemplate(
            name: "Powerlifting - Squat Day",
            category: .strength,
            exercises: [
                ("Barbell Back Squat", 4, 3, 5),
                ("Barbell Front Squat", 3, 5, 8),
                ("Leg Press", 3, 8, 12),
                ("Barbell Bulgarian Split Squat", 3, 6, 8),
                ("Leg Curl (Lying)", 3, 10, 12)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 2. Powerlifting - Day 2: Bench Focus
        templates.append(createTemplate(
            name: "Powerlifting - Bench Day",
            category: .strength,
            exercises: [
                ("Barbell Bench Press", 4, 3, 5),
                ("Barbell Incline Bench Press", 3, 5, 8),
                ("Barbell Close-Grip Bench Press", 3, 6, 8),
                ("Dip", 3, 8, 12),
                ("Cable Tricep Pushdown", 3, 10, 15)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 3. Powerlifting - Day 3: Deadlift Focus
        templates.append(createTemplate(
            name: "Powerlifting - Deadlift Day",
            category: .strength,
            exercises: [
                ("Barbell Deadlift", 4, 3, 5),
                ("Barbell Romanian Deadlift", 3, 5, 8),
                ("Barbell Bent Over Row", 3, 6, 8),
                ("Pull-Up", 3, 6, 10),
                ("Cable Face Pull", 3, 12, 15)
            ],
            exerciseFinder: exerciseFinder
        ))

        // MARK: - Hypertrophy Templates

        // 4. PPL - Push Day
        templates.append(createTemplate(
            name: "PPL - Push",
            category: .hypertrophy,
            exercises: [
                ("Barbell Bench Press", 4, 8, 12),
                ("Dumbbell Incline Bench Press", 3, 10, 12),
                ("Dumbbell Shoulder Press", 3, 10, 12),
                ("Dumbbell Lateral Raise", 3, 12, 15),
                ("Cable Tricep Pushdown", 3, 12, 15),
                ("Dumbbell Overhead Tricep Extension", 3, 10, 12)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 5. PPL - Pull Day
        templates.append(createTemplate(
            name: "PPL - Pull",
            category: .hypertrophy,
            exercises: [
                ("Barbell Deadlift", 3, 6, 8),
                ("Pull-Up", 3, 8, 12),
                ("Barbell Bent Over Row", 3, 8, 12),
                ("Cable Row (Seated)", 3, 10, 12),
                ("Cable Face Pull", 3, 15, 20),
                ("Dumbbell Bicep Curl", 3, 12, 15),
                ("Dumbbell Hammer Curl", 3, 10, 12)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 6. PPL - Legs Day
        templates.append(createTemplate(
            name: "PPL - Legs",
            category: .hypertrophy,
            exercises: [
                ("Barbell Back Squat", 4, 8, 12),
                ("Leg Press", 3, 10, 15),
                ("Leg Curl (Lying)", 3, 10, 12),
                ("Leg Extension", 3, 12, 15),
                ("Calf Raise", 4, 15, 20)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 7. Upper/Lower - Upper Body
        templates.append(createTemplate(
            name: "Upper/Lower - Upper",
            category: .hypertrophy,
            exercises: [
                ("Barbell Bench Press", 4, 8, 12),
                ("Barbell Bent Over Row", 4, 8, 12),
                ("Dumbbell Shoulder Press", 3, 10, 12),
                ("Pull-Up", 3, 8, 12),
                ("Dumbbell Bicep Curl", 3, 12, 15),
                ("Cable Tricep Pushdown", 3, 12, 15)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 8. Upper/Lower - Lower Body
        templates.append(createTemplate(
            name: "Upper/Lower - Lower",
            category: .hypertrophy,
            exercises: [
                ("Barbell Back Squat", 4, 8, 12),
                ("Barbell Romanian Deadlift", 3, 10, 12),
                ("Leg Press", 3, 12, 15),
                ("Leg Curl (Lying)", 3, 10, 12),
                ("Barbell Bulgarian Split Squat", 3, 10, 12),
                ("Calf Raise", 3, 15, 20)
            ],
            exerciseFinder: exerciseFinder
        ))

        // MARK: - Calisthenics Templates

        // 9. Full Body Calisthenics
        templates.append(createTemplate(
            name: "Calisthenics - Full Body",
            category: .calisthenics,
            exercises: [
                ("Push-Up", 4, 12, 15),
                ("Pull-Up", 4, 8, 12),
                ("Dip", 3, 10, 15),
                ("Pistol Squat", 3, 8, 10),
                ("Hanging Leg Raise", 3, 10, 15),
                ("Plank", 3, 30, 60)
            ],
            exerciseFinder: exerciseFinder
        ))

        // MARK: - Weightlifting Templates

        // 10. Olympic Lifting Program
        templates.append(createTemplate(
            name: "Olympic Lifting",
            category: .weightlifting,
            exercises: [
                ("Snatch", 5, 2, 3),
                ("Clean & Jerk", 5, 2, 3),
                ("Barbell Front Squat", 4, 3, 5),
                ("Overhead Squat", 3, 3, 5),
                ("Barbell Push Press", 3, 5, 8)
            ],
            exerciseFinder: exerciseFinder
        ))

        // MARK: - Beginner Templates

        // 11. Beginner Full Body A
        templates.append(createTemplate(
            name: "Beginner - Full Body A",
            category: .beginner,
            exercises: [
                ("Barbell Back Squat", 3, 8, 10),
                ("Barbell Bench Press", 3, 8, 10),
                ("Barbell Bent Over Row", 3, 8, 10),
                ("Plank", 3, 30, 45)
            ],
            exerciseFinder: exerciseFinder
        ))

        // 12. Beginner Full Body B
        templates.append(createTemplate(
            name: "Beginner - Full Body B",
            category: .beginner,
            exercises: [
                ("Barbell Deadlift", 3, 8, 10),
                ("Dumbbell Shoulder Press", 3, 8, 10),
                ("Pull-Up", 3, 5, 10),
                ("Hanging Leg Raise", 3, 8, 12)
            ],
            exerciseFinder: exerciseFinder
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
