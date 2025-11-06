//
//  UserProfileRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Concrete implementation of UserProfileRepositoryProtocol
/// Uses @ModelActor for thread-safe SwiftData operations
@ModelActor
actor UserProfileRepository: UserProfileRepositoryProtocol {
    // ModelContext automatically provided by @ModelActor

    /// Fetch the user profile (creates default if none exists)
    func fetchOrCreateProfile() async throws -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)

        // Return existing profile if found
        if let existingProfile = profiles.first {
            return existingProfile
        }

        // Create default profile if none exists
        let defaultProfile = UserProfile(
            name: "",
            dailyCalorieGoal: 2000,
            dailyProteinGoal: 150,
            dailyCarbsGoal: 200,
            dailyFatsGoal: 65
        )

        modelContext.insert(defaultProfile)
        try modelContext.save()

        return defaultProfile
    }

    /// Update user profile
    func updateProfile(
        name: String? = nil,
        dailyCalorieGoal: Double? = nil,
        dailyProteinGoal: Double? = nil,
        dailyCarbsGoal: Double? = nil,
        dailyFatsGoal: Double? = nil
    ) async throws -> UserProfile {
        let profile = try await fetchOrCreateProfile()

        profile.update(
            name: name,
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatsGoal: dailyFatsGoal
        )

        try profile.validate()
        try modelContext.save()

        return profile
    }

    /// Add a bodyweight entry to the profile
    func addBodyweightEntry(weight: Double, date: Date = Date(), notes: String? = nil) async throws -> BodyweightEntry {
        let profile = try await fetchOrCreateProfile()

        let entry = BodyweightEntry(date: date, weight: weight, notes: notes)
        try entry.validate()

        profile.addBodyweightEntry(entry)
        modelContext.insert(entry)
        try modelContext.save()

        return entry
    }

    /// Delete a bodyweight entry
    func deleteBodyweightEntry(_ entry: BodyweightEntry) async throws {
        let profile = try await fetchOrCreateProfile()
        profile.removeBodyweightEntry(entry)

        modelContext.delete(entry)
        try modelContext.save()
    }

    /// Fetch all bodyweight entries, sorted by date (most recent first)
    func fetchBodyweightHistory() async throws -> [BodyweightEntry] {
        let descriptor = FetchDescriptor<BodyweightEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Training Program Management

    /// Activate a training program for the user profile
    /// Ensures both models are in the same ModelContext to avoid relationship errors
    func activateProgram(programId: UUID) async throws {
        // Fetch profile in this context
        let profile = try await fetchOrCreateProfile()
        
        // Fetch program in the SAME context
        let programDescriptor = FetchDescriptor<TrainingProgram>(
            predicate: #Predicate { $0.id == programId }
        )
        
        guard let program = try modelContext.fetch(programDescriptor).first else {
            throw UserProfileRepositoryError.programNotFound
        }
        
        // Now both models are in the same context - safe to relate them
        profile.activateProgram(program)
        
        // Save changes
        try modelContext.save()
    }
    
    /// Deactivate the current training program
    func deactivateProgram() async throws {
        let profile = try await fetchOrCreateProfile()
        profile.deactivateProgram()
        try modelContext.save()
    }

    /// Advance active program to next week
    func advanceToNextWeek() async throws {
        let profile = try await fetchOrCreateProfile()
        profile.progressToNextWeek()
        try modelContext.save()
    }
}


// MARK: - Repository Errors

enum UserProfileRepositoryError: LocalizedError {
    case programNotFound
    
    var errorDescription: String? {
        switch self {
        case .programNotFound:
            return String(localized: "Training program not found", comment: "Error: Program not found")
        }
    }
}
