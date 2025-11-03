//
//  TemplateDetailViewModel.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftUI

/// ViewModel for template detail view
@Observable
@MainActor
final class TemplateDetailViewModel {
    // MARK: - Published State

    /// The template being viewed
    private(set) var template: WorkoutTemplate

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: WorkoutTemplateRepositoryProtocol

    // MARK: - Initialization

    init(template: WorkoutTemplate, repository: WorkoutTemplateRepositoryProtocol) {
        self.template = template
        self.repository = repository
    }

    // MARK: - Computed Properties

    /// Exercises sorted by order
    var sortedExercises: [TemplateExercise] {
        template.exercises.sorted(by: TemplateExercise.compare)
    }

    /// Whether this is a preset template (read-only)
    var isPreset: Bool {
        template.isPreset
    }

    // MARK: - Actions

    /// Delete this template
    func deleteTemplate() async throws {
        try await repository.deleteTemplate(template)
    }

    /// Duplicate this template with new name
    func duplicateTemplate(newName: String) async throws {
        _ = try await repository.duplicateTemplate(template, newName: newName)
    }

    /// Mark template as used (when starting workout)
    func markAsUsed() async {
        do {
            try await repository.markTemplateUsed(template)
            // Reload template to get updated lastUsedAt
            if let updated = try await repository.fetchTemplate(by: template.id) {
                template = updated
            }
        } catch {
            self.error = error
            print("❌ Failed to mark template as used: \(error)")
        }
    }

    /// Refresh template data
    func refresh() async {
        isLoading = true
        error = nil

        do {
            if let updated = try await repository.fetchTemplate(by: template.id) {
                template = updated
            }
        } catch {
            self.error = error
            print("❌ Failed to refresh template: \(error)")
        }

        isLoading = false
    }

    // MARK: - Error Handling

    /// Clear error state
    func clearError() {
        error = nil
    }
}
