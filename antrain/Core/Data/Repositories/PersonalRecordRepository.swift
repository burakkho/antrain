//
//  PersonalRecordRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Repository protocol for Personal Record operations
protocol PersonalRecordRepositoryProtocol: Sendable {
    /// Fetch all PRs
    func fetchAll() async throws -> [PersonalRecord]

    /// Get top N PRs (highest 1RM)
    func getTopPRs(limit: Int) async throws -> [PersonalRecord]

    /// Get PR for specific exercise
    func getPR(for exerciseId: UUID) async throws -> PersonalRecord?

    /// Save or update PR
    func save(_ pr: PersonalRecord) async throws

    /// Delete PR
    func delete(_ pr: PersonalRecord) async throws

    /// Check if a set would be a new PR
    func wouldBeNewPR(exerciseId: UUID, estimated1RM: Double) async throws -> Bool
}

/// Concrete implementation of PersonalRecordRepository
@ModelActor
actor PersonalRecordRepository: PersonalRecordRepositoryProtocol {
    // ModelContext automatically provided by @ModelActor

    /// Fetch all PRs, sorted by date (newest first)
    func fetchAll() async throws -> [PersonalRecord] {
        let descriptor = FetchDescriptor<PersonalRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get top N PRs (highest estimated 1RM)
    /// Returns one PR per exercise (the best one)
    func getTopPRs(limit: Int) async throws -> [PersonalRecord] {
        // Fetch all PRs
        let allPRs = try await fetchAll()

        // Group by exercise, keep only the highest 1RM for each
        var bestPRs: [UUID: PersonalRecord] = [:]

        for pr in allPRs {
            if let existingPR = bestPRs[pr.exerciseId] {
                // Keep the one with higher 1RM
                if pr.estimated1RM > existingPR.estimated1RM {
                    bestPRs[pr.exerciseId] = pr
                }
            } else {
                bestPRs[pr.exerciseId] = pr
            }
        }

        // Sort by 1RM (highest first), take top N
        return Array(bestPRs.values)
            .sorted { $0.estimated1RM > $1.estimated1RM }
            .prefix(limit)
            .map { $0 }
    }

    /// Get current PR for a specific exercise
    /// Returns the PR with highest estimated 1RM
    func getPR(for exerciseId: UUID) async throws -> PersonalRecord? {
        let descriptor = FetchDescriptor<PersonalRecord>(
            predicate: #Predicate { $0.exerciseId == exerciseId },
            sortBy: [SortDescriptor(\.estimated1RM, order: .reverse)]
        )

        let prs = try modelContext.fetch(descriptor)
        return prs.first
    }

    /// Save or update a PR
    /// If this is a new PR for the exercise, saves it
    /// If not better than existing PR, does nothing
    func save(_ pr: PersonalRecord) async throws {
        // Validate before saving
        try pr.validate()

        // Check if this is actually a PR
        if let existingPR = try await getPR(for: pr.exerciseId) {
            // Only save if new 1RM is higher
            guard pr.estimated1RM > existingPR.estimated1RM else {
                print("Not a new PR - existing: \(existingPR.estimated1RM), new: \(pr.estimated1RM)")
                return
            }
        }

        modelContext.insert(pr)
        try modelContext.save()

        print("New PR saved: \(pr.exerciseName) - \(pr.estimated1RM)kg")
    }

    /// Delete a PR
    func delete(_ pr: PersonalRecord) async throws {
        modelContext.delete(pr)
        try modelContext.save()
    }

    /// Check if a set would be a new PR for an exercise
    func wouldBeNewPR(exerciseId: UUID, estimated1RM: Double) async throws -> Bool {
        guard let currentPR = try await getPR(for: exerciseId) else {
            // No existing PR, so this would be the first
            return true
        }

        return estimated1RM > currentPR.estimated1RM
    }

    /// Delete all PRs for a specific workout
    /// Called when a workout is deleted
    func deletePRsForWorkout(_ workoutId: UUID) async throws {
        let descriptor = FetchDescriptor<PersonalRecord>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )

        let prs = try modelContext.fetch(descriptor)
        for pr in prs {
            modelContext.delete(pr)
        }

        try modelContext.save()
    }
}
