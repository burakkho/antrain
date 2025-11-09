//
//  ExerciseNameMapper.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Maps exercise names from external sources (Hevy, Strong) to Antrain exercise library
//

import Foundation

/// Maps exercise names from imports to Antrain's exercise library
@MainActor
class ExerciseNameMapper {
    private let exerciseRepository: ExerciseRepository

    init(exerciseRepository: ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }

    /// Find exercise in library or create custom exercise
    /// - Parameter name: Exercise name from CSV
    /// - Returns: Exercise from library or newly created custom exercise
    func findOrCreateExercise(name: String) async throws -> Exercise {
        // Try exact match first
        if let exercise = try await findExactMatch(name: name) {
            return exercise
        }

        // Try fuzzy match
        if let exercise = try await findFuzzyMatch(name: name) {
            return exercise
        }

        // Create custom exercise
        return try await createCustomExercise(name: name)
    }

    // MARK: - Private Helpers

    private func findExactMatch(name: String) async throws -> Exercise? {
        let exercises = try await exerciseRepository.fetchAll()
        return exercises.first { $0.name.lowercased() == name.lowercased() }
    }

    private func findFuzzyMatch(name: String) async throws -> Exercise? {
        let normalizedName = normalize(name)
        let exercises = try await exerciseRepository.fetchAll()

        // Try normalized match
        if let exercise = exercises.first(where: { normalize($0.name) == normalizedName }) {
            return exercise
        }

        // Try contains match (e.g., "Bench Press (Bar)" → "Bench Press")
        if let exercise = exercises.first(where: { normalizedName.contains(normalize($0.name)) }) {
            return exercise
        }

        return nil
    }

    private func createCustomExercise(name: String) async throws -> Exercise {
        // Infer category and equipment from name
        let category = inferCategory(from: name)
        let equipment = inferEquipment(from: name)
        let muscleGroups = inferMuscleGroups(from: name)

        let exercise = Exercise(
            name: name,
            category: category,
            muscleGroups: muscleGroups,
            equipment: equipment,
            isCustom: true
        )

        try await exerciseRepository.save(exercise)
        return exercise
    }

    private func normalize(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "(bar)", with: "")
            .replacingOccurrences(of: "(barbell)", with: "")
            .replacingOccurrences(of: "(dumbbell)", with: "")
            .replacingOccurrences(of: "(ağırlıklı)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Name Analysis

    private func inferCategory(from name: String) -> ExerciseCategory {
        let lowerName = name.lowercased()

        if lowerName.contains("barbell") || lowerName.contains("bar)") || lowerName.contains("squat") || lowerName.contains("deadlift") || lowerName.contains("bench") {
            return .barbell
        }
        if lowerName.contains("dumbbell") || lowerName.contains("db") {
            return .dumbbell
        }
        if lowerName.contains("bodyweight") || lowerName.contains("pull up") || lowerName.contains("push up") || lowerName.contains("dip") || lowerName.contains("barfiks") {
            return .bodyweight
        }
        if lowerName.contains("machine") || lowerName.contains("leg press") {
            return .machine
        }
        if lowerName.contains("cable") || lowerName.contains("lat pulldown") {
            return .cable
        }
        if lowerName.contains("clean") || lowerName.contains("snatch") || lowerName.contains("koparma") {
            return .weightlifting
        }

        return .barbell  // Default
    }

    private func inferEquipment(from name: String) -> Equipment {
        let lowerName = name.lowercased()

        if lowerName.contains("barbell") || lowerName.contains("bar)") {
            return .barbell
        }
        if lowerName.contains("dumbbell") || lowerName.contains("db") {
            return .dumbbell
        }
        if lowerName.contains("machine") {
            return .machine
        }
        if lowerName.contains("cable") {
            return .cable
        }
        if lowerName.contains("kettlebell") || lowerName.contains("kb") {
            return .kettlebell
        }
        if lowerName.contains("bodyweight") || lowerName.contains("pull up") || lowerName.contains("push up") || lowerName.contains("dip") || lowerName.contains("barfiks") {
            return .none
        }

        return .barbell  // Default
    }

    private func inferMuscleGroups(from name: String) -> [MuscleGroup] {
        let lowerName = name.lowercased()
        var groups: Set<MuscleGroup> = []

        // Chest
        if lowerName.contains("bench") || lowerName.contains("press") && lowerName.contains("chest") || lowerName.contains("dip") {
            groups.insert(.chest)
        }

        // Back
        if lowerName.contains("row") || lowerName.contains("pull") || lowerName.contains("lat") || lowerName.contains("deadlift") || lowerName.contains("barfiks") {
            groups.insert(.back)
        }

        // Shoulders
        if lowerName.contains("shoulder") || lowerName.contains("overhead") || lowerName.contains("military") || lowerName.contains("push press") || lowerName.contains("z press") {
            groups.insert(.shoulders)
        }

        // Legs
        if lowerName.contains("squat") || lowerName.contains("leg") || lowerName.contains("lunge") {
            groups.insert(.quads)
        }
        if lowerName.contains("deadlift") || lowerName.contains("romanian") || lowerName.contains("hamstring") {
            groups.insert(.hamstrings)
        }
        if lowerName.contains("glute") || lowerName.contains("hip thrust") {
            groups.insert(.glutes)
        }
        if lowerName.contains("calf") {
            groups.insert(.calves)
        }

        // Arms
        if lowerName.contains("curl") || lowerName.contains("bicep") {
            groups.insert(.biceps)
        }
        if lowerName.contains("tricep") || lowerName.contains("dip") || lowerName.contains("extension") {
            groups.insert(.triceps)
        }

        // Core
        if lowerName.contains("core") || lowerName.contains("ab") || lowerName.contains("plank") {
            groups.insert(.core)
        }

        // Olympic lifts
        if lowerName.contains("clean") || lowerName.contains("snatch") || lowerName.contains("koparma") {
            groups.insert(.fullBody)
        }

        // Default if nothing matched
        if groups.isEmpty {
            groups.insert(.fullBody)
        }

        return Array(groups)
    }
}
