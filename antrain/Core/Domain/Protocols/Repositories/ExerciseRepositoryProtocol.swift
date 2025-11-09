//
//  ExerciseRepositoryProtocol.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Repository protocol for Exercise CRUD operations
/// Handles both preset and custom exercises
protocol ExerciseRepositoryProtocol: Actor {
    /// Fetch all exercises (preset + custom)
    func fetchAll() async throws -> [Exercise]

    /// Fetch exercise by ID
    func fetchExercise(by id: UUID) async throws -> Exercise?

    /// Fetch only preset exercises
    func fetchPresetOnly() async throws -> [Exercise]

    /// Fetch only custom exercises
    func fetchCustomOnly() async throws -> [Exercise]

    /// Search exercises by name
    func search(query: String) async throws -> [Exercise]

    /// Filter exercises by category
    func fetchByCategory(_ category: ExerciseCategory) async throws -> [Exercise]

    /// Filter exercises by muscle group
    func fetchByMuscleGroup(_ muscleGroup: MuscleGroup) async throws -> [Exercise]

    /// Save (insert or update) an exercise
    func save(_ exercise: Exercise) async throws

    /// Delete an exercise (only if custom)
    func delete(_ exercise: Exercise) async throws

    /// Seed preset exercises from ExerciseLibrary into SwiftData (idempotent)
    func seedPresetExercises() async throws
}

// MARK: - Repository Error
enum RepositoryError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case notFound
    case cannotDeletePreset

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .fetchFailed:
            return "Failed to fetch data"
        case .deleteFailed:
            return "Failed to delete data"
        case .notFound:
            return "Data not found"
        case .cannotDeletePreset:
            return "Cannot delete preset exercise"
        }
    }
}
