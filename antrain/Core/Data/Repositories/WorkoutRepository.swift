//
//  WorkoutRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Concrete implementation of WorkoutRepositoryProtocol
/// Uses @ModelActor for thread-safe SwiftData operations
@ModelActor
actor WorkoutRepository: WorkoutRepositoryProtocol {
    // ModelContext automatically provided by @ModelActor

    /// Fetch all workouts, sorted by date (most recent first)
    func fetchAll() async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch workout by ID
    func fetch(id: UUID) async throws -> Workout? {
        let predicate = #Predicate<Workout> { workout in
            workout.id == id
        }
        let descriptor = FetchDescriptor<Workout>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    /// Fetch workouts by type
    func fetchByType(_ type: WorkoutType) async throws -> [Workout] {
        let predicate = #Predicate<Workout> { workout in
            workout.type == type
        }
        let descriptor = FetchDescriptor<Workout>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch workouts for a specific date (same calendar day)
    func fetchByDate(_ date: Date) async throws -> [Workout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = #Predicate<Workout> { workout in
            workout.date >= startOfDay && workout.date < endOfDay
        }
        let descriptor = FetchDescriptor<Workout>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch recent workouts with limit (database-level filtering)
    /// - Parameter limit: Maximum number of workouts to return
    /// - Returns: Array of recent workouts, sorted by date (most recent first)
    func fetchRecent(limit: Int) async throws -> [Workout] {
        var descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit  // Database-level limit (Apple best practice)
        return try modelContext.fetch(descriptor)
    }

    /// Fetch workouts within a date range (database-level filtering)
    /// - Parameters:
    ///   - startDate: Start of date range (inclusive)
    ///   - endDate: End of date range (exclusive)
    /// - Returns: Workouts in date range, sorted by date (most recent first)
    func fetchByDateRange(startDate: Date, endDate: Date) async throws -> [Workout] {
        let predicate = #Predicate<Workout> { workout in
            workout.date >= startDate && workout.date < endDate
        }
        let descriptor = FetchDescriptor<Workout>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch recent workouts with date range and limit (database-level filtering)
    /// - Parameters:
    ///   - startDate: Start of date range (inclusive)
    ///   - limit: Maximum number of workouts to return
    /// - Returns: Recent workouts in range, sorted by date (most recent first)
    func fetchRecent(since startDate: Date, limit: Int) async throws -> [Workout] {
        let predicate = #Predicate<Workout> { workout in
            workout.date >= startDate
        }
        var descriptor = FetchDescriptor<Workout>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    /// Save (insert or update) a workout
    func save(_ workout: Workout) async throws {
        // Validate before saving
        try workout.validate()

        // Insert (SwiftData handles update if already exists)
        modelContext.insert(workout)

        // Save context
        try modelContext.save()
    }

    /// Delete a workout
    func delete(_ workout: Workout) async throws {
        // Delete associated personal records first
        let workoutId = workout.id
        let prDescriptor = FetchDescriptor<PersonalRecord>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        let prs = try modelContext.fetch(prDescriptor)
        for pr in prs {
            modelContext.delete(pr)
        }

        modelContext.delete(workout)
        try modelContext.save()
    }

    /// Delete multiple workouts
    func deleteAll(_ workouts: [Workout]) async throws {
        // Delete associated personal records for each workout
        for workout in workouts {
            let workoutId = workout.id
            let prDescriptor = FetchDescriptor<PersonalRecord>(
                predicate: #Predicate { $0.workoutId == workoutId }
            )
            let prs = try modelContext.fetch(prDescriptor)
            for pr in prs {
                modelContext.delete(pr)
            }
        }

        for workout in workouts {
            modelContext.delete(workout)
        }
        try modelContext.save()
    }
}
