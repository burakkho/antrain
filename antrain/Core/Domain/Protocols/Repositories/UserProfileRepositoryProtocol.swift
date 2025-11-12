//
//  UserProfileRepositoryProtocol.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Repository protocol for UserProfile CRUD operations
/// Implemented by concrete UserProfileRepository in Data layer
protocol UserProfileRepositoryProtocol: Actor {
    /// Fetch the user profile (creates default if none exists)
    func fetchOrCreateProfile() async throws -> UserProfile

    /// Update user profile
    func updateProfile(
        name: String?,
        dailyCalorieGoal: Double?,
        dailyProteinGoal: Double?,
        dailyCarbsGoal: Double?,
        dailyFatsGoal: Double?
    ) async throws -> UserProfile

    /// Save the current profile changes to persistence
    func saveProfile() async throws

    /// Add a bodyweight entry to the profile
    func addBodyweightEntry(weight: Double, date: Date, notes: String?) async throws -> BodyweightEntry

    /// Delete a bodyweight entry
    func deleteBodyweightEntry(_ entry: BodyweightEntry) async throws

    /// Fetch all bodyweight entries, sorted by date (most recent first)
    func fetchBodyweightHistory() async throws -> [BodyweightEntry]

    /// Activate a training program for the user profile
    func activateProgram(programId: UUID) async throws

    /// Deactivate the current training program
    func deactivateProgram() async throws

    /// Advance active program to next day
    /// - Returns: True if progressed, false if program completed
    @discardableResult
    func advanceToNextDay() async throws -> Bool
}
