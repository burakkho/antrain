//
//  ExerciseRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Concrete implementation of ExerciseRepositoryProtocol
/// Uses @ModelActor for thread-safe SwiftData operations
@ModelActor
actor ExerciseRepository: ExerciseRepositoryProtocol {
    // ModelContext automatically provided by @ModelActor

    /// Fetch all exercises (preset + custom)
    func fetchAll() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all exercises (alias for fetchAll for compatibility)
    func fetchAllExercises() async throws -> [Exercise] {
        return try await fetchAll()
    }

    /// Fetch exercise by ID
    func fetchExercise(by id: UUID) async throws -> Exercise? {
        let predicate = #Predicate<Exercise> { exercise in
            exercise.id == id
        }
        var descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// Fetch only preset exercises
    func fetchPresetOnly() async throws -> [Exercise] {
        let predicate = #Predicate<Exercise> { exercise in
            exercise.isCustom == false
        }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch only custom exercises
    func fetchCustomOnly() async throws -> [Exercise] {
        let predicate = #Predicate<Exercise> { exercise in
            exercise.isCustom == true
        }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Search exercises by name
    func search(query: String) async throws -> [Exercise] {
        guard !query.isEmpty else {
            return try await fetchAll()
        }

        let predicate = #Predicate<Exercise> { exercise in
            exercise.name.localizedStandardContains(query)
        }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Filter exercises by category
    func fetchByCategory(_ category: ExerciseCategory) async throws -> [Exercise] {
        let predicate = #Predicate<Exercise> { exercise in
            exercise.category == category
        }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Filter exercises by muscle group
    func fetchByMuscleGroup(_ muscleGroup: MuscleGroup) async throws -> [Exercise] {
        let predicate = #Predicate<Exercise> { exercise in
            exercise.muscleGroups.contains(muscleGroup)
        }
        let descriptor = FetchDescriptor<Exercise>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Save (insert or update) an exercise
    func save(_ exercise: Exercise) async throws {
        // Validate before saving
        try exercise.validate()

        // Insert (SwiftData handles update if already exists)
        modelContext.insert(exercise)

        // Save context
        try modelContext.save()
    }

    /// Delete an exercise (only if custom)
    func delete(_ exercise: Exercise) async throws {
        // Prevent deletion of preset exercises
        guard exercise.isCustom else {
            throw RepositoryError.cannotDeletePreset
        }

        modelContext.delete(exercise)
        try modelContext.save()
    }

    /// Seed preset exercises from ExerciseLibrary into SwiftData (idempotent)
    func seedPresetExercises() async throws {
        // Check if already seeded
        let existingPresets = try await fetchPresetOnly()
        guard existingPresets.isEmpty else {
            return // Already seeded
        }

        // Get all preset exercises from library on MainActor
        let presetExercises = await MainActor.run {
            let library = ExerciseLibrary()
            return library.getAllPresetExercisesAsModels()
        }

        // Insert all preset exercises
        for exercise in presetExercises {
            modelContext.insert(exercise)
        }

        try modelContext.save()
    }
}
