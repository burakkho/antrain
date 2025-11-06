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
    // MARK: - Dependencies

    // Note: We need TrainingProgramRepository to check template usage
    // This will be injected after Phase 2 is complete
    private var trainingProgramRepository: TrainingProgramRepositoryProtocol?

    func setTrainingProgramRepository(_ repository: TrainingProgramRepositoryProtocol) {
        self.trainingProgramRepository = repository
    }
    // MARK: - CRUD Operations

    func createTemplate(_ template: WorkoutTemplate) async throws {
        // Validate template before saving
        try template.validate()

        // Check name uniqueness
        let isUnique = try await isTemplateNameUnique(template.name, excludingId: nil)
        guard isUnique else {
            throw WorkoutTemplateRepositoryError.duplicateName
        }

        modelContext.insert(template)
        try modelContext.save()
    }

    func fetchAllTemplates() async throws -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        let templates = try modelContext.fetch(descriptor)
        // Sort manually: presets first, then by name
        return templates.sorted(by: WorkoutTemplate.compare)
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
            sortBy: [SortDescriptor(\.name)]
        )
        let templates = try modelContext.fetch(descriptor)
        // Sort manually: presets first, then by name
        return templates.sorted(by: WorkoutTemplate.compare)
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
            throw WorkoutTemplateRepositoryError.duplicateName
        }

        try modelContext.save()
    }

    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        // Prevent deleting preset templates
        guard !template.isPreset else {
            throw WorkoutTemplateRepositoryError.cannotDeletePreset
        }

        // Training Programs v2.0: Check if template is used in any programs
        if let programRepo = trainingProgramRepository {
            let programNames = try await programRepo.findProgramsUsingTemplate(template)

            guard programNames.isEmpty else {
                throw WorkoutTemplateRepositoryError.usedInPrograms(programNames: programNames)
            }
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

        // Fetch all exercises from SwiftData first
        let allExercisesDescriptor = FetchDescriptor<Exercise>()
        let allExercises = try modelContext.fetch(allExercisesDescriptor)

        // Create exercise finder closure
        let exerciseFinder: (String) -> Exercise? = { name in
            allExercises.first { $0.name.lowercased() == name.lowercased() }
        }

        // Create all preset templates using TemplateLibrary on MainActor
        let presets = await MainActor.run {
            let templateLibrary = TemplateLibrary()
            return templateLibrary.convertToModels(exerciseFinder: exerciseFinder)
        }

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

    func duplicateTemplate(_ template: WorkoutTemplate, newName: String) async throws -> WorkoutTemplate {
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

        // Fetch all templates and filter manually (SwiftData predicates don't support lowercased())
        let descriptor = FetchDescriptor<WorkoutTemplate>()
        let allTemplates = try modelContext.fetch(descriptor)

        let duplicates = allTemplates.filter { template in
            let matches = template.name.lowercased() == trimmedName
            if let excludingId {
                return matches && template.id != excludingId
            } else {
                return matches
            }
        }

        return duplicates.isEmpty
    }
}

// MARK: - Repository Errors

enum WorkoutTemplateRepositoryError: LocalizedError {
    case duplicateName
    case cannotDeletePreset
    case usedInPrograms(programNames: [String])
    case templateNotFound
    case invalidTemplate

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return String(localized: "A template with this name already exists",
                         comment: "Error: Duplicate template name")
        case .cannotDeletePreset:
            return String(localized: "Preset templates cannot be deleted",
                         comment: "Error: Cannot delete preset")
        case .usedInPrograms(let programNames):
            let names = programNames.joined(separator: ", ")
            return String(localized: "This template is used in programs: \(names). Remove it from programs first.",
                         comment: "Error: Template used in programs")
        case .templateNotFound:
            return String(localized: "Template not found",
                         comment: "Error: Template not found")
        case .invalidTemplate:
            return String(localized: "Template data is invalid",
                         comment: "Error: Invalid template")
        }
    }
}
