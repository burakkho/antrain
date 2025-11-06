//
//  WorkoutRepositoryProtocol.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Repository protocol for Workout CRUD operations
/// Implemented by concrete WorkoutRepository in Data layer
protocol WorkoutRepositoryProtocol: Actor {
    /// Fetch all workouts, sorted by date (most recent first)
    func fetchAll() async throws -> [Workout]

    /// Fetch workout by ID
    func fetch(id: UUID) async throws -> Workout?

    /// Fetch workouts by type
    func fetchByType(_ type: WorkoutType) async throws -> [Workout]

    /// Fetch workouts for a specific date
    func fetchByDate(_ date: Date) async throws -> [Workout]

    /// Fetch recent workouts with limit
    /// - Parameter limit: Maximum number of workouts to return
    /// - Returns: Array of recent workouts, sorted by date (most recent first)
    func fetchRecent(limit: Int) async throws -> [Workout]

    /// Save (insert or update) a workout
    func save(_ workout: Workout) async throws

    /// Delete a workout
    func delete(_ workout: Workout) async throws

    /// Delete multiple workouts
    func deleteAll(_ workouts: [Workout]) async throws
}
