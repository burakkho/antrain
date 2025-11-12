//
//  TrainingProgramRepository.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import SwiftData

/// Repository for managing training programs
/// Uses @ModelActor for thread-safe SwiftData operations
@ModelActor
actor TrainingProgramRepository: TrainingProgramRepositoryProtocol {
    // MARK: - CRUD Operations

    func create(_ program: TrainingProgram) async throws {
        // Validate before creation
        try program.validate()

        // Insert into context
        modelContext.insert(program)

        // Save
        try modelContext.save()
    }

    func fetchAll() async throws -> [TrainingProgram] {
        let descriptor = FetchDescriptor<TrainingProgram>(
            sortBy: [SortDescriptor(\.name)]
        )
        let programs = try modelContext.fetch(descriptor)
        // Sort manually: presets first (isCustom=false), then custom (isCustom=true)
        return programs.sorted { !$0.isCustom && $1.isCustom }
    }

    func fetchById(_ id: UUID) async throws -> TrainingProgram? {
        let descriptor = FetchDescriptor<TrainingProgram>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram] {
        let descriptor = FetchDescriptor<TrainingProgram>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.name)]
        )
        let programs = try modelContext.fetch(descriptor)
        // Sort manually: presets first (isCustom=false), then custom (isCustom=true)
        return programs.sorted { !$0.isCustom && $1.isCustom }
    }

    func fetchUserPrograms() async throws -> [TrainingProgram] {
        let descriptor = FetchDescriptor<TrainingProgram>(
            predicate: #Predicate { $0.isCustom == true },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchPresetPrograms() async throws -> [TrainingProgram] {
        let descriptor = FetchDescriptor<TrainingProgram>(
            predicate: #Predicate { $0.isCustom == false },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func update(_ program: TrainingProgram) async throws {
        // Validate before update
        try program.validate()

        // Save (SwiftData auto-tracks changes)
        try modelContext.save()
    }

    func delete(_ program: TrainingProgram) async throws {
        // Prevent deletion of preset programs
        guard program.isCustom else {
            throw TrainingProgramRepositoryError.cannotDeletePreset
        }

        // Check if program is currently active for any user
        // Note: In a real app, you'd check all user profiles
        // For MVP, we assume single user - this check could be enhanced
        let userProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        let isActive = userProfiles.contains { $0.activeProgram?.id == program.id }

        if isActive {
            throw TrainingProgramRepositoryError.programIsActive
        }

        // Delete program (days will cascade)
        modelContext.delete(program)
        try modelContext.save()
    }

    // MARK: - Template Safety

    func findProgramsUsingTemplate(_ template: WorkoutTemplate) async throws -> [String] {
        // Fetch all programs
        let allPrograms = try await fetchAll()

        // Filter programs that use this template and return just the names
        return allPrograms.filter { program in
            program.days.contains { day in
                day.template?.id == template.id
            }
        }.map { $0.name }
    }

    // MARK: - Seeding

    func hasPresetPrograms() async throws -> Bool {
        let presets = try await fetchPresetPrograms()
        return !presets.isEmpty
    }
}

// MARK: - Repository Errors

enum TrainingProgramRepositoryError: LocalizedError {
    case cannotDeletePreset
    case programIsActive
    case programNotFound
    case invalidProgram(String)

    var errorDescription: String? {
        switch self {
        case .cannotDeletePreset:
            return String(localized: "Cannot delete preset programs",
                         comment: "Error: Cannot delete preset program")
        case .programIsActive:
            return String(localized: "Cannot delete active program. Deactivate it first.",
                         comment: "Error: Cannot delete active program")
        case .programNotFound:
            return String(localized: "Program not found",
                         comment: "Error: Program not found")
        case .invalidProgram(let message):
            return String(localized: "Invalid program: \(message)",
                         comment: "Error: Invalid program")
        }
    }
}
