//
//  TemplateLibrary.swift
//  antrain
//
//  Created on 2025-11-05.
//

import Foundation

/// Central library for all preset workout templates
/// Combines templates from all categories into a single, extensible collection
final class TemplateLibrary: Sendable {

    // MARK: - Properties

    private let presetTemplates: [TemplateDTO]

    // MARK: - Initialization

    init() {
        // Combine all templates from modular category files
        self.presetTemplates =
            // Strength category
            PowerliftingSplit.all +

            // Hypertrophy category
            PPLProgram.all +
            UpperLowerProgram.all +

            // Calisthenics category
            CalisthenicsFullBody.all +

            // Weightlifting category
            OlympicProgram.all +

            // Beginner category
            BeginnerFullBody.all +

            // Program-specific templates
            StartingStrengthTemplates.all +
            StrongLiftsTemplates.all +
            PPLTemplates.all +
            FiveThreeOneTemplates.all
    }

    // MARK: - Public Methods

    /// Returns all preset templates as DTOs
    /// - Returns: Array of TemplateDTO objects
    func getAllPresetTemplates() -> [TemplateDTO] {
        return presetTemplates
    }

    /// Converts all preset templates to SwiftData models
    /// - Parameter exerciseFinder: Closure to find exercises by name from SwiftData
    /// - Returns: Array of WorkoutTemplate models ready for database insertion
    func convertToModels(exerciseFinder: @escaping (String) -> Exercise?) -> [WorkoutTemplate] {
        return presetTemplates.compactMap { dto in
            dto.toModel(exerciseFinder: exerciseFinder)
        }
    }

    /// Returns templates filtered by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of templates in the specified category
    func getTemplates(byCategory category: TemplateCategory) -> [TemplateDTO] {
        return presetTemplates.filter { $0.category == category }
    }

    /// Returns the total number of preset templates
    /// - Returns: Count of all preset templates
    func getTemplateCount() -> Int {
        return presetTemplates.count
    }

    /// Returns template count grouped by category
    /// - Returns: Dictionary mapping categories to their template counts
    func getTemplateCountByCategory() -> [TemplateCategory: Int] {
        var counts: [TemplateCategory: Int] = [:]
        for template in presetTemplates {
            counts[template.category, default: 0] += 1
        }
        return counts
    }
}

// MARK: - Library Statistics (for debugging/logging)

extension TemplateLibrary {
    /// Prints a summary of the template library contents
    func printLibrarySummary() {
        print("📚 Template Library Summary")
        print("   Total templates: \(getTemplateCount())")
        print("   By category:")

        let countsByCategory = getTemplateCountByCategory()
        for (category, count) in countsByCategory.sorted(by: { $0.value > $1.value }) {
            print("   - \(category.rawValue): \(count)")
        }
    }
}
