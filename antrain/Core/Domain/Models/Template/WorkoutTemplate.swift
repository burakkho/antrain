//
//  WorkoutTemplate.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftData

/// Represents a workout template that can be reused for lifting sessions
/// Templates contain a pre-defined list of exercises with set/rep configurations
@Model
final class WorkoutTemplate {
    // MARK: - Identity

    /// Unique identifier for the template
    @Attribute(.unique)
    var id: UUID

    /// Template name (e.g., "Push Day", "PPL - Pull")
    var name: String

    /// Category for organization and filtering
    var category: TemplateCategory

    /// Whether this is a preset template (read-only, seeded by app)
    var isPreset: Bool

    // MARK: - Metadata

    /// When the template was created
    var createdAt: Date

    /// When the template was last used to start a workout
    var lastUsedAt: Date?

    /// Number of times this template has been used
    var usageCount: Int = 0

    // MARK: - Relationships

    /// Exercises included in this template with their configurations
    @Relationship(deleteRule: .cascade, inverse: \TemplateExercise.template)
    var exercises: [TemplateExercise]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        category: TemplateCategory,
        isPreset: Bool = false,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        usageCount: Int = 0,
        exercises: [TemplateExercise] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.isPreset = isPreset
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.usageCount = usageCount
        self.exercises = exercises
    }

    // MARK: - Computed Properties

    /// Number of exercises in the template
    var exerciseCount: Int {
        exercises.count
    }

    /// Estimated workout duration based on exercises and sets
    /// Assumes ~2 minutes per set including rest
    var estimatedDuration: TimeInterval {
        let totalSets = exercises.reduce(0) { $0 + $1.setCount }
        return Double(totalSets) * 120 // 2 minutes per set
    }

    /// Estimated duration formatted as string (e.g., "45 min", "1h 15min")
    var estimatedDurationFormatted: String {
        let minutes = Int(estimatedDuration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)min"
            }
        }
    }

    // MARK: - Business Logic

    /// Marks the template as used (updates lastUsedAt and increments usageCount)
    func markAsUsed() {
        lastUsedAt = Date()
        usageCount += 1
    }

    /// Creates a deep copy of this template with a new name
    /// - Parameter newName: Name for the duplicated template
    /// - Returns: New template instance with copied exercises
    func duplicate(newName: String) -> WorkoutTemplate {
        let newTemplate = WorkoutTemplate(
            name: newName,
            category: category,
            isPreset: false, // Copies are never presets
            exercises: []
        )

        // Deep copy exercises
        for exercise in exercises {
            let copiedExercise = TemplateExercise(
                order: exercise.order,
                exerciseId: exercise.exerciseId,
                exerciseName: exercise.exerciseName,
                setCount: exercise.setCount,
                repRangeMin: exercise.repRangeMin,
                repRangeMax: exercise.repRangeMax,
                notes: exercise.notes
            )
            copiedExercise.template = newTemplate
            newTemplate.exercises.append(copiedExercise)
        }

        return newTemplate
    }

    /// Validates the template data
    /// - Throws: TemplateValidationError if template is invalid
    func validate() throws {
        // Name must not be empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TemplateValidationError.emptyTemplateName
        }

        // Must have at least one exercise
        guard !exercises.isEmpty else {
            throw TemplateValidationError.templateRequiresExercises
        }

        // Validate each exercise
        for exercise in exercises {
            try exercise.validate()
        }
    }
}

// MARK: - Validation Errors

enum TemplateValidationError: LocalizedError {
    case emptyTemplateName
    case templateRequiresExercises
    case invalidSetCount
    case invalidRepRange

    var errorDescription: String? {
        switch self {
        case .emptyTemplateName:
            return "Template name cannot be empty"
        case .templateRequiresExercises:
            return "Template must contain at least one exercise"
        case .invalidSetCount:
            return "Set count must be between 1 and 10"
        case .invalidRepRange:
            return "Rep range must be valid (min < max, both > 0)"
        }
    }
}

// MARK: - Comparable

extension WorkoutTemplate: Comparable {
    nonisolated static func < (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        // Presets first, then by name
        if lhs.isPreset != rhs.isPreset {
            return lhs.isPreset
        }
        return lhs.name < rhs.name
    }
}
