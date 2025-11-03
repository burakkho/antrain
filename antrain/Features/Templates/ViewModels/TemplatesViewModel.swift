//
//  TemplatesViewModel.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftUI

/// ViewModel for managing workout templates list
@Observable
@MainActor
final class TemplatesViewModel {
    // MARK: - Published State

    /// All templates fetched from repository
    private(set) var templates: [WorkoutTemplate] = []

    /// Currently selected category filter
    var selectedCategory: TemplateCategory? = nil

    /// Search text
    var searchText: String = ""

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: WorkoutTemplateRepositoryProtocol

    // MARK: - Initialization

    init(repository: WorkoutTemplateRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Computed Properties

    /// Filtered templates based on selected category and search
    var filteredTemplates: [WorkoutTemplate] {
        var result = templates

        // Category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Search filter
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            result = result.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    /// User-created templates (not presets)
    var userTemplates: [WorkoutTemplate] {
        filteredTemplates.filter { !$0.isPreset }
    }

    /// Preset templates
    var presetTemplates: [WorkoutTemplate] {
        filteredTemplates.filter { $0.isPreset }
    }

    /// Whether there are no templates at all
    var isEmpty: Bool {
        templates.isEmpty
    }

    /// Whether filtered list is empty (but templates exist)
    var isFilteredEmpty: Bool {
        !templates.isEmpty && filteredTemplates.isEmpty
    }

    // MARK: - Data Loading

    /// Fetch all templates from repository
    func fetchTemplates() async {
        isLoading = true
        error = nil

        do {
            templates = try await repository.fetchAllTemplates()
        } catch {
            self.error = error
            print("❌ Failed to fetch templates: \(error)")
        }

        isLoading = false
    }

    /// Refresh templates (for pull-to-refresh)
    func refresh() async {
        await fetchTemplates()
    }

    // MARK: - Category Filtering

    /// Set category filter
    func selectCategory(_ category: TemplateCategory?) {
        selectedCategory = category
    }

    /// Clear category filter (show all)
    func clearFilter() {
        selectedCategory = nil
    }

    // MARK: - Template Actions

    /// Delete a template
    func deleteTemplate(_ template: WorkoutTemplate) async {
        do {
            try await repository.deleteTemplate(template)
            // Remove from local array
            templates.removeAll { $0.id == template.id }
        } catch {
            self.error = error
            print("❌ Failed to delete template: \(error)")
        }
    }

    /// Duplicate a template with new name
    func duplicateTemplate(_ template: WorkoutTemplate, newName: String) async {
        do {
            try await repository.duplicateTemplate(template, newName: newName)
            // Refresh to show new template
            await fetchTemplates()
        } catch {
            self.error = error
            print("❌ Failed to duplicate template: \(error)")
        }
    }

    /// Mark template as used (when starting workout)
    func markTemplateUsed(_ template: WorkoutTemplate) async {
        do {
            try await repository.markTemplateUsed(template)
            // Update lastUsedAt in local array
            if let index = templates.firstIndex(where: { $0.id == template.id }) {
                templates[index].lastUsedAt = Date()
            }
        } catch {
            print("❌ Failed to mark template as used: \(error)")
        }
    }

    // MARK: - Error Handling

    /// Clear error state
    func clearError() {
        error = nil
    }
}
