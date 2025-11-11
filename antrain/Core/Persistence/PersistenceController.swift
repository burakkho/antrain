//
//  PersistenceController.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Manages SwiftData ModelContainer and seed data
final class PersistenceController {
    static let shared = PersistenceController()

    let modelContainer: ModelContainer

    // Track seeding progress to prevent UI hang
    @MainActor
    private(set) var isSeeding = false

    @MainActor
    private(set) var seedingProgress: String = ""

    @MainActor
    private(set) var currentStep: Int = 0

    @MainActor
    private(set) var totalSteps: Int = 4  // Libraries, Templates, Programs, Profile

    @MainActor
    private(set) var progressPercentage: Double = 0.0

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
                ServingUnit.self,
                UserProfile.self,
                BodyweightEntry.self,
                PersonalRecord.self,
                WorkoutTemplate.self,
                TemplateExercise.self,
                TrainingProgram.self,
                ProgramWeek.self,
                ProgramDay.self,
                ChatMessage.self,
                ChatConversation.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("✅ ModelContainer initialized successfully")

            // Check if seeding is needed before starting background task
            let hasSeededLibraries = UserDefaults.standard.bool(forKey: "hasSeededLibraries")
            let hasSeededTemplates = UserDefaults.standard.bool(forKey: "hasSeededTemplates")
            let hasSeededPrograms = UserDefaults.standard.bool(forKey: "hasSeededPrograms")

            let needsSeeding = !hasSeededLibraries || !hasSeededTemplates || !hasSeededPrograms

            if needsSeeding {
                // Seed libraries and create default profile if needed
                // Run on BACKGROUND thread to avoid blocking main thread
                Task.detached { [weak self] in
                    guard let self else { return }
                    await self.performSeeding()
                }
            } else {
                print("✅ All data already seeded, skipping seeding task")
            }

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    // MARK: - Seeding Coordinator

    /// Update seeding progress
    private func updateProgress(step: Int, message: String) async {
        await MainActor.run {
            self.currentStep = step
            self.seedingProgress = message
            self.progressPercentage = Double(step) / Double(totalSteps)
        }
    }

    /// Performs all seeding operations on background thread
    private func performSeeding() async {
        // Update UI state on main thread
        await MainActor.run {
            self.isSeeding = true
        }
        await updateProgress(step: 0, message: "Initializing...")

        // Perform seeding
        await seedLibrariesIfNeeded()
        await seedTemplatesIfNeeded()
        await seedProgramsIfNeeded()
        await createDefaultProfileIfNeeded()

        // Mark as complete
        await MainActor.run {
            self.isSeeding = false
            self.currentStep = self.totalSteps
            self.progressPercentage = 1.0
            self.seedingProgress = "Complete"
        }

        print("✅ All seeding operations completed")
    }

    /// Seed preset exercise and food libraries on first launch
    private func seedLibrariesIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededLibraries")

        guard !hasSeeded else {
            print("✅ Libraries already seeded")
            await updateProgress(step: 1, message: "Libraries ready")
            return
        }

        await updateProgress(step: 1, message: "Loading exercises and foods...")

        print("🌱 Seeding libraries...")

        // Create background context for seeding (don't block main context!)
        let context = ModelContext(modelContainer)

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

    /// Seed preset workout templates on first launch
    private func seedTemplatesIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededTemplates")

        guard !hasSeeded else {
            print("✅ Templates already seeded")
            await updateProgress(step: 2, message: "Templates ready")
            return
        }

        await updateProgress(step: 2, message: "Creating workout templates...")

        print("🌱 Seeding preset templates...")

        // Create background context for seeding (don't block main context!)
        let context = ModelContext(modelContainer)

        // Fetch all exercises from SwiftData (already seeded)
        let fetchDescriptor = FetchDescriptor<Exercise>()
        let allExercises: [Exercise]

        do {
            allExercises = try context.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to fetch exercises for template seeding: \(error)")
            return
        }

        print("  📋 Loaded \(allExercises.count) exercises")

        // Helper to find exercise by name from SwiftData
        func findExercise(_ name: String) -> Exercise? {
            let exercise = allExercises.first { $0.name.lowercased() == name.lowercased() }
            if exercise == nil {
                print("  ⚠️ Exercise not found: '\(name)'")
            }
            return exercise
        }

        // Seed preset templates using exercises from SwiftData
        let templateLibrary = TemplateLibrary()
        let presetTemplates = templateLibrary.convertToModels(exerciseFinder: findExercise)

        var successCount = 0
        var emptyTemplateCount = 0

        for template in presetTemplates {
            context.insert(template)

            if template.exercises.isEmpty {
                print("  ⚠️ Template '\(template.name)' has NO exercises!")
                emptyTemplateCount += 1
            } else {
                print("  ✓ Template '\(template.name)' created with \(template.exercises.count) exercises")
                successCount += 1
            }
        }

        do {
            try context.save()
            // Process pending changes to ensure templates are available for program seeding
            context.processPendingChanges()
            UserDefaults.standard.set(true, forKey: "hasSeededTemplates")
            print("✅ Preset templates seeded successfully (\(successCount) valid, \(emptyTemplateCount) empty, \(presetTemplates.count) total)")

            if emptyTemplateCount > 0 {
                print("⚠️  WARNING: \(emptyTemplateCount) templates were created without exercises. Check exercise names!")
            }
        } catch {
            print("❌ Failed to seed templates: \(error)")
        }
    }

    /// Seed preset training programs on first launch
    private func seedProgramsIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededPrograms")

        guard !hasSeeded else {
            print("✅ Programs already seeded")
            await updateProgress(step: 3, message: "Programs ready")
            return
        }

        await updateProgress(step: 3, message: "Setting up training programs...")

        print("🌱 Seeding preset programs...")

        // Create background context for seeding (don't block main context!)
        let context = ModelContext(modelContainer)

        // Fetch all templates from SwiftData (already seeded)
        let templateDescriptor = FetchDescriptor<WorkoutTemplate>()
        let allTemplates: [WorkoutTemplate]

        do {
            allTemplates = try context.fetch(templateDescriptor)
        } catch {
            print("❌ Failed to fetch templates for program seeding: \(error)")
            return
        }

        print("  📋 Loaded \(allTemplates.count) templates")

        // Helper to find template by name from SwiftData
        func findTemplate(_ name: String) -> WorkoutTemplate? {
            let template = allTemplates.first { $0.name.lowercased() == name.lowercased() }
            if template == nil {
                print("  ⚠️ Template not found: '\(name)'")
                print("     Available templates: \(allTemplates.map { $0.name }.joined(separator: ", "))")
            } else {
                // Verify template has exercises
                if template!.exercises.isEmpty {
                    print("  ⚠️ Template '\(name)' found but has NO exercises!")
                } else {
                    print("  ✓ Template '\(name)' found with \(template!.exercises.count) exercises")
                }
            }
            return template
        }

        // Get preset program DTOs
        let programDTOs = ProgramLibrary.allPrograms

        // Convert DTOs to models and insert
        for programDTO in programDTOs {
            print("  📝 Processing program: \(programDTO.name)")
            let program = programDTO.toModel(templateFinder: findTemplate)

            // Verify program has days with templates
            var totalDays = 0
            var daysWithTemplates = 0
            for week in program.weeks {
                for day in week.days {
                    totalDays += 1
                    if day.template != nil {
                        daysWithTemplates += 1
                    }
                }
            }

            context.insert(program)
            print("  ✓ Added: \(program.name) - \(daysWithTemplates)/\(totalDays) days have templates")
        }

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: "hasSeededPrograms")
            print("✅ Preset programs seeded successfully (\(programDTOs.count) programs)")
        } catch {
            print("❌ Failed to seed programs: \(error)")
        }
    }

    // MARK: - Debug Helpers

    /// Delete all data from database (useful after model changes)
    /// WARNING: This will delete ALL user data!
    func deleteAllData() async throws {
        print("🗑️ Deleting all data...")

        let context = modelContainer.mainContext

        // Delete all model types
        try context.delete(model: Workout.self)
        try context.delete(model: WorkoutExercise.self)
        try context.delete(model: WorkoutSet.self)
        try context.delete(model: Exercise.self)
        try context.delete(model: NutritionLog.self)
        try context.delete(model: Meal.self)
        try context.delete(model: FoodEntry.self)
        try context.delete(model: FoodItem.self)
        try context.delete(model: ServingUnit.self)
        try context.delete(model: UserProfile.self)
        try context.delete(model: BodyweightEntry.self)
        try context.delete(model: PersonalRecord.self)
        try context.delete(model: WorkoutTemplate.self)
        try context.delete(model: TemplateExercise.self)
        try context.delete(model: TrainingProgram.self)
        try context.delete(model: ProgramWeek.self)
        try context.delete(model: ProgramDay.self)
        try context.delete(model: ChatMessage.self)
        try context.delete(model: ChatConversation.self)

        try context.save()

        // Reset seeding flags
        UserDefaults.standard.set(false, forKey: "hasSeededLibraries")
        UserDefaults.standard.set(false, forKey: "hasSeededTemplates")
        UserDefaults.standard.set(false, forKey: "hasSeededPrograms")

        print("✅ All data deleted")
    }

    /// Reset all seeding flags and reseed data
    /// Call this from a debug menu or when troubleshooting data issues
    /// WARNING: This will recreate all preset data
    func resetAndReseedAllData() async {
        print("🔄 Resetting and reseeding all data...")

        // Delete all existing data first
        do {
            try await deleteAllData()
        } catch {
            print("❌ Failed to delete data: \(error)")
            return
        }

        // Reseed everything
        await seedLibrariesIfNeeded()
        await seedTemplatesIfNeeded()
        await seedProgramsIfNeeded()
        await createDefaultProfileIfNeeded()

        print("✅ All data reseeded successfully")
    }

    /// Reset only program seeding (useful if templates exist but programs are broken)
    func reseedProgramsOnly() async {
        print("🔄 Reseeding programs only...")

        UserDefaults.standard.set(false, forKey: "hasSeededPrograms")
        await seedProgramsIfNeeded()

        print("✅ Programs reseeded")
    }

    // MARK: - Profile Management

    /// Create default user profile on first launch
    private func createDefaultProfileIfNeeded() async {
        await updateProgress(step: 4, message: "Creating your profile...")

        // Create background context (don't block main context!)
        let context = ModelContext(modelContainer)

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
                ServingUnit.self,
                UserProfile.self,
                BodyweightEntry.self,
                PersonalRecord.self,
                WorkoutTemplate.self,
                TemplateExercise.self,
                TrainingProgram.self,
                ProgramWeek.self,
                ProgramDay.self,
                ChatMessage.self,
                ChatConversation.self
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
                height: 180,
                gender: .male,
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -25, to: Date()),
                activityLevel: .moderatelyActive,
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
                name: String(localized: "Chicken Breast"),
                calories: 165,
                protein: 31,
                carbs: 0,
                fats: 3.6,
                servingSize: 100,
                category: .protein
            )
            context.insert(sampleFood)

            // Food now has default gram unit automatically
            let defaultUnit = sampleFood.getDefaultUnit()
            let foodEntry = FoodEntry(foodItem: sampleFood, amount: 200, selectedUnit: defaultUnit)
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
