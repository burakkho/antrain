//
//  WorkoutTemplateRepository.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftData

/// Repository for managing workout templates with SwiftData persistence
@ModelActor
actor WorkoutTemplateRepository: WorkoutTemplateRepositoryProtocol {
    // MARK: - CRUD Operations

    func createTemplate(_ template: WorkoutTemplate) async throws {
        // Validate template before saving
        try template.validate()

        // Check name uniqueness
        let isUnique = try await isTemplateNameUnique(template.name, excludingId: nil)
        guard isUnique else {
            throw RepositoryError.duplicateName
        }

        modelContext.insert(template)
        try modelContext.save()
    }

    func fetchAllTemplates() async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [
                SortDescriptor(\.isPreset, order: .reverse), // Presets first
                SortDescriptor(\.name)
            ]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchTemplate(by id: UUID) async throws -> WorkoutTemplate? {
        var descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func fetchTemplatesByCategory(_ category: TemplateCategory) async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.category == category },
            sortBy: [
                SortDescriptor(\.isPreset, order: .reverse),
                SortDescriptor(\.name)
            ]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchUserTemplates() async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.isPreset == false },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchPresetTemplates() async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.isPreset == true },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func updateTemplate(_ template: WorkoutTemplate) async throws {
        // Validate template
        try template.validate()

        // Check name uniqueness (excluding current template)
        let isUnique = try await isTemplateNameUnique(template.name, excludingId: template.id)
        guard isUnique else {
            throw RepositoryError.duplicateName
        }

        try modelContext.save()
    }

    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        // Prevent deleting preset templates
        guard !template.isPreset else {
            throw RepositoryError.cannotDeletePreset
        }

        modelContext.delete(template)
        try modelContext.save()
    }

    // MARK: - Preset Management

    func seedPresetTemplates() async throws {
        // Check if already seeded (idempotent)
        let hasPresets = try await hasPresetTemplates()
        guard !hasPresets else {
            return // Already seeded
        }

        // Create all preset templates
        let presets = PresetTemplateSeeder.createPresetTemplates()

        // Insert all presets
        for preset in presets {
            modelContext.insert(preset)
        }

        try modelContext.save()
    }

    func hasPresetTemplates() async throws -> Bool {
        var descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.isPreset == true }
        )
        descriptor.fetchLimit = 1
        let presets = try modelContext.fetch(descriptor)
        return !presets.isEmpty
    }

    // MARK: - Duplication

    func duplicateTemplate(_ template: WorkoutTemplate, newName: String) async throws {
        // Create duplicate using template's duplicate method
        let duplicate = template.duplicate(newName: newName)

        // Validate and save
        try duplicate.validate()
        modelContext.insert(duplicate)
        try modelContext.save()

        return duplicate
    }

    // MARK: - Usage Tracking

    func markTemplateUsed(_ template: WorkoutTemplate) async throws {
        template.markAsUsed()
        try modelContext.save()
    }

    // MARK: - Validation

    func isTemplateNameUnique(_ name: String, excludingId: UUID?) async throws -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces).lowercased()

        let descriptor: FetchDescriptor<WorkoutTemplate>
        if let excludingId {
            descriptor = FetchDescriptor<WorkoutTemplate>(
                predicate: #Predicate { template in
                    template.id != excludingId &&
                    template.name.lowercased() == trimmedName
                }
            )
        } else {
            descriptor = FetchDescriptor<WorkoutTemplate>(
                predicate: #Predicate { template in
                    template.name.lowercased() == trimmedName
                }
            )
        }

        let duplicates = try modelContext.fetch(descriptor)
        return duplicates.isEmpty
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case duplicateName
    case cannotDeletePreset
    case templateNotFound
    case invalidTemplate

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "A template with this name already exists"
        case .cannotDeletePreset:
            return "Preset templates cannot be deleted"
        case .templateNotFound:
            return "Template not found"
        case .invalidTemplate:
            return "Template data is invalid"
        }
    }
}
