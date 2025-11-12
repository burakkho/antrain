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

    /// Fetch workouts within a date range (database-level filtering)
    /// - Parameters:
    ///   - startDate: Start of date range (inclusive)
    ///   - endDate: End of date range (exclusive)
    /// - Returns: Workouts in date range, sorted by date (most recent first)
    func fetchByDateRange(startDate: Date, endDate: Date) async throws -> [Workout]

    /// Fetch recent workouts with date range and limit (database-level filtering)
    /// - Parameters:
    ///   - startDate: Start of date range (inclusive)
    ///   - limit: Maximum number of workouts to return
    /// - Returns: Recent workouts in range, sorted by date (most recent first)
    func fetchRecent(since startDate: Date, limit: Int) async throws -> [Workout]

    /// Save (insert or update) a workout
    func save(_ workout: Workout) async throws

    /// Delete a workout
    func delete(_ workout: Workout) async throws

    /// Delete multiple workouts
    func deleteAll(_ workouts: [Workout]) async throws
}
