//
//  TrainingProgramRepositoryProtocol.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Protocol defining training program repository operations
protocol TrainingProgramRepositoryProtocol: Actor {
    // MARK: - CRUD Operations

    /// Create a new training program
    /// - Parameter program: The program to create
    /// - Throws: Repository errors if creation fails
    func create(_ program: TrainingProgram) async throws

    /// Fetch all training programs
    /// - Returns: Array of all programs (preset + custom)
    func fetchAll() async throws -> [TrainingProgram]

    /// Fetch a program by ID
    /// - Parameter id: The program's unique identifier
    /// - Returns: The program if found, nil otherwise
    func fetchById(_ id: UUID) async throws -> TrainingProgram?

    /// Fetch programs by category
    /// - Parameter category: The program category to filter by
    /// - Returns: Array of programs in the specified category
    func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram]

    /// Fetch user's custom programs only
    /// - Returns: Array of custom programs (isCustom = true)
    func fetchUserPrograms() async throws -> [TrainingProgram]

    /// Fetch preset programs only
    /// - Returns: Array of preset programs (isCustom = false)
    func fetchPresetPrograms() async throws -> [TrainingProgram]

    /// Update an existing program
    /// - Parameter program: The program to update
    /// - Throws: Repository errors if update fails
    func update(_ program: TrainingProgram) async throws

    /// Delete a program
    /// - Parameter program: The program to delete
    /// - Throws: Repository errors if deletion fails or if program is preset
    func delete(_ program: TrainingProgram) async throws

    // MARK: - Template Safety

    /// Find names of all programs that use a specific workout template
    /// - Parameter template: The template to check for usage
    /// - Returns: Array of program names that reference this template
    func findProgramsUsingTemplate(_ template: WorkoutTemplate) async throws -> [String]

    // MARK: - Seeding

    /// Check if preset programs have been seeded
    /// - Returns: True if presets exist, false otherwise
    func hasPresetPrograms() async throws -> Bool
}
