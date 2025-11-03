//
//  PersistenceController.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Manages SwiftData ModelContainer and seed data
@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let modelContainer: ModelContainer

    private init() {
        do {
            // Configure ModelContainer with all models
            let schema = Schema([
                Workout.self,
                WorkoutExercise.self,
                WorkoutSet.self,
                Exercise.self,
                NutritionLog.self,
                Meal.self,
                FoodEntry.self,
                FoodItem.self,
                UserProfile.self,
                BodyweightEntry.self,
                PersonalRecord.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Seed libraries and create default profile if needed
            Task {
                await seedLibrariesIfNeeded()
                await createDefaultProfileIfNeeded()
            }

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    /// Seed preset exercise and food libraries on first launch
    private func seedLibrariesIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededLibraries")

        guard !hasSeeded else {
            print("✅ Libraries already seeded")
            return
        }

        print("🌱 Seeding libraries...")

        let context = modelContainer.mainContext

        // Seed exercises
        let exerciseLibrary = ExerciseLibrary()
        let presetExercises = exerciseLibrary.getAllPresetExercisesAsModels()

        for exercise in presetExercises {
            context.insert(exercise)
        }

        // Seed foods
        let foodLibrary = FoodLibrary()
        let presetFoods = foodLibrary.getAllPresetFoods()

        for food in presetFoods {
            context.insert(food)
        }

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: "hasSeededLibraries")
            print("✅ Libraries seeded successfully (\(presetExercises.count) exercises, \(presetFoods.count) foods)")
        } catch {
            print("❌ Failed to seed libraries: \(error)")
        }
    }

    /// Create default user profile on first launch
    private func createDefaultProfileIfNeeded() async {
        let context = modelContainer.mainContext

        // Check if profile already exists
        let fetchDescriptor = FetchDescriptor<UserProfile>()
        do {
            let existingProfiles = try context.fetch(fetchDescriptor)
            if !existingProfiles.isEmpty {
                print("✅ UserProfile already exists")
                return
            }

            // Create default profile
            let defaultProfile = UserProfile(
                name: "",
                dailyCalorieGoal: 2000,
                dailyProteinGoal: 150,
                dailyCarbsGoal: 200,
                dailyFatsGoal: 65
            )

            context.insert(defaultProfile)
            try context.save()
            print("✅ Default UserProfile created")
        } catch {
            print("❌ Failed to create default profile: \(error)")
        }
    }
}

// MARK: - Preview Support
extension PersistenceController {
    /// In-memory ModelContainer for SwiftUI previews
    static var preview: ModelContainer {
        do {
            let schema = Schema([
                Workout.self,
                WorkoutExercise.self,
                WorkoutSet.self,
                Exercise.self,
                NutritionLog.self,
                Meal.self,
                FoodEntry.self,
                FoodItem.self,
                UserProfile.self,
                BodyweightEntry.self,
                PersonalRecord.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Add sample data for previews
            let context = container.mainContext

            // Sample user profile
            let sampleProfile = UserProfile(
                name: "Burak",
                dailyCalorieGoal: 2500,
                dailyProteinGoal: 180,
                dailyCarbsGoal: 250,
                dailyFatsGoal: 70
            )
            context.insert(sampleProfile)

            // Sample exercise
            let sampleExercise = Exercise(
                name: "Barbell Bench Press",
                category: .barbell,
                muscleGroups: [.chest, .triceps],
                equipment: .barbell,
                isCustom: false
            )
            context.insert(sampleExercise)

            // Sample workout
            let sampleWorkout = Workout(
                date: Date(),
                type: .lifting,
                duration: 3600,
                notes: "Great workout!"
            )

            let workoutExercise = WorkoutExercise(
                exercise: sampleExercise,
                orderIndex: 0
            )

            let set1 = WorkoutSet(reps: 10, weight: 100, isCompleted: true)
            let set2 = WorkoutSet(reps: 8, weight: 110, isCompleted: true)

            workoutExercise.addSet(set1)
            workoutExercise.addSet(set2)
            sampleWorkout.addExercise(workoutExercise)

            context.insert(sampleWorkout)

            // Sample nutrition log with food entries
            let sampleNutritionLog = NutritionLog(date: Date())

            let sampleFood = FoodItem(
                name: "Tavuk Göğsü",
                calories: 165,
                protein: 31,
                carbs: 0,
                fats: 3.6,
                servingSize: 100,
                category: .protein
            )
            context.insert(sampleFood)

            let foodEntry = FoodEntry(foodItem: sampleFood, servingAmount: 200)
            let breakfastMeal = sampleNutritionLog.getMeal(type: .breakfast)
            breakfastMeal.foodEntries.append(foodEntry)

            context.insert(sampleNutritionLog)

            try context.save()

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
