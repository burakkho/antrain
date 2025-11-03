//
//  WorkoutTemplateRepositoryProtocol.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation

/// Protocol defining operations for managing workout templates
/// Repository handles persistence, retrieval, and business logic for templates
@MainActor
protocol WorkoutTemplateRepositoryProtocol: Actor {
    // MARK: - CRUD Operations

    /// Creates a new workout template
    /// - Parameter template: The template to create
    /// - Throws: Repository error if creation fails
    func createTemplate(_ template: WorkoutTemplate) async throws

    /// Fetches all workout templates
    /// - Returns: Array of all templates, sorted (presets first, then by name)
    /// - Throws: Repository error if fetch fails
    func fetchAllTemplates() async throws -> [WorkoutTemplate]

    /// Fetches a specific template by ID
    /// - Parameter id: The template's unique identifier
    /// - Returns: The template if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetchTemplate(by id: UUID) async throws -> WorkoutTemplate?

    /// Fetches templates filtered by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of templates in the specified category
    /// - Throws: Repository error if fetch fails
    func fetchTemplatesByCategory(_ category: TemplateCategory) async throws -> [WorkoutTemplate]

    /// Fetches only user-created templates (excludes presets)
    /// - Returns: Array of user templates
    /// - Throws: Repository error if fetch fails
    func fetchUserTemplates() async throws -> [WorkoutTemplate]

    /// Fetches only preset templates
    /// - Returns: Array of preset templates
    /// - Throws: Repository error if fetch fails
    func fetchPresetTemplates() async throws -> [WorkoutTemplate]

    /// Updates an existing template
    /// - Parameter template: The template to update
    /// - Throws: Repository error if update fails
    func updateTemplate(_ template: WorkoutTemplate) async throws

    /// Deletes a template
    /// - Parameter template: The template to delete
    /// - Throws: Repository error if deletion fails or template is a preset
    func deleteTemplate(_ template: WorkoutTemplate) async throws

    // MARK: - Preset Management

    /// Seeds the database with preset templates (idempotent)
    /// Only seeds if no preset templates exist
    /// - Throws: Repository error if seeding fails
    func seedPresetTemplates() async throws

    /// Checks if preset templates have been seeded
    /// - Returns: True if presets exist, false otherwise
    /// - Throws: Repository error if check fails
    func hasPresetTemplates() async throws -> Bool

    // MARK: - Duplication

    /// Creates a duplicate of an existing template
    /// - Parameters:
    ///   - template: The template to duplicate
    ///   - newName: Name for the duplicated template
    /// - Returns: The newly created template copy
    /// - Throws: Repository error if duplication fails
    func duplicateTemplate(_ template: WorkoutTemplate, newName: String) async throws -> WorkoutTemplate

    // MARK: - Usage Tracking

    /// Marks a template as used (updates lastUsedAt)
    /// - Parameter template: The template that was used
    /// - Throws: Repository error if update fails
    func markTemplateUsed(_ template: WorkoutTemplate) async throws

    // MARK: - Validation

    /// Validates a template's uniqueness (name must be unique)
    /// - Parameters:
    ///   - name: The template name to check
    ///   - excludingId: Optional template ID to exclude from check (for updates)
    /// - Returns: True if name is unique, false if duplicate exists
    /// - Throws: Repository error if validation fails
    func isTemplateNameUnique(_ name: String, excludingId: UUID?) async throws -> Bool
}
