//
//  ExerciseLibrary.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Protocol for Exercise Library
protocol ExerciseLibraryProtocol: Sendable {
    /// Get all preset exercises as DTO array
    func getAllPresetExercises() -> [ExerciseDTO]

    /// Get all preset exercises as Exercise models
    func getAllPresetExercisesAsModels() -> [Exercise]

    /// Search exercises by name
    func search(query: String) -> [ExerciseDTO]

    /// Filter by category
    func filterByCategory(_ category: ExerciseCategory) -> [ExerciseDTO]
}

/// Concrete implementation of ExerciseLibrary
/// Provides preset exercises from code-based data files
final class ExerciseLibrary: ExerciseLibraryProtocol, Sendable {
    // Lazy load all preset exercises
    private let presetExercises: [ExerciseDTO]

    init() {
        // Combine all exercise data files
        self.presetExercises = BarbellExercises.all
                             + DumbbellExercises.all
                             + BodyweightExercises.all
                             + WeightliftingExercises.all
                             + MachineExercises.all
                             + CableExercises.all
        // COMPLETE: Barbell (30) + Dumbbell (48) + Bodyweight (35) + Weightlifting (18) + Machine (28) + Cable (24) = 183 exercises
        // Note: Cardio & MetCon use separate enums (CardioType, MetConType) - not in Exercise Library
    }

    /// Get all preset exercises as DTO array
    func getAllPresetExercises() -> [ExerciseDTO] {
        return presetExercises
    }

    /// Get all preset exercises as Exercise models (ready for SwiftData)
    func getAllPresetExercisesAsModels() -> [Exercise] {
        return presetExercises.map { $0.toModel() }
    }

    /// Search exercises by name (case-insensitive)
    func search(query: String) -> [ExerciseDTO] {
        guard !query.isEmpty else {
            return presetExercises
        }

        return presetExercises.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    /// Filter exercises by category
    func filterByCategory(_ category: ExerciseCategory) -> [ExerciseDTO] {
        return presetExercises.filter { $0.category == category }
    }
}

// MARK: - Helper Extensions
extension ExerciseLibrary {
    /// Get exercise count
    var count: Int {
        return presetExercises.count
    }

    /// Get categories with exercises
    var availableCategories: [ExerciseCategory] {
        let categories = presetExercises.map { $0.category }
        return Array(Set(categories)).sorted { $0.rawValue < $1.rawValue }
    }

    /// Get muscle groups covered
    var availableMuscleGroups: [MuscleGroup] {
        let muscleGroups = presetExercises.flatMap { $0.muscleGroups }
        return Array(Set(muscleGroups)).sorted { $0.rawValue < $1.rawValue }
    }
}
