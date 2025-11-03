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
}
