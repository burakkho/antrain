//
//  TemplateExercise.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftData

/// Represents an exercise within a workout template
/// Contains exercise reference and set/rep configuration
@Model
final class TemplateExercise {
    // MARK: - Identity

    /// Unique identifier for this template exercise
    @Attribute(.unique)
    var id: UUID

    /// Order of this exercise in the template (0-indexed)
    var order: Int

    // MARK: - Exercise Reference

    /// Reference to the exercise in the ExerciseLibrary
    /// Uses reference approach since exercises are read-only
    var exerciseId: UUID

    /// Snapshot of exercise name for display purposes
    /// Preserved even if exercise is removed from library in future
    var exerciseName: String

    // MARK: - Set Configuration

    /// Recommended number of sets for this exercise
    var setCount: Int

    /// Minimum reps in the recommended range
    var repRangeMin: Int

    /// Maximum reps in the recommended range
    var repRangeMax: Int

    // MARK: - Notes

    /// Optional notes for this exercise (e.g., "Dropset on last set")
    var notes: String?

    // MARK: - Relationships

    /// The template this exercise belongs to
    var template: WorkoutTemplate?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        order: Int,
        exerciseId: UUID,
        exerciseName: String,
        setCount: Int,
        repRangeMin: Int,
        repRangeMax: Int,
        notes: String? = nil
    ) {
        self.id = id
        self.order = order
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.setCount = setCount
        self.repRangeMin = repRangeMin
        self.repRangeMax = repRangeMax
        self.notes = notes
    }

    // MARK: - Computed Properties

    /// Formatted rep range string (e.g., "8-12 reps", "5 reps")
    var repRangeFormatted: String {
        if repRangeMin == repRangeMax {
            return "\(repRangeMin) reps"
        } else {
            return "\(repRangeMin)-\(repRangeMax) reps"
        }
    }

    /// Formatted set/rep configuration (e.g., "3 sets x 8-12 reps")
    var configurationFormatted: String {
        let setsText = setCount == 1 ? "1 set" : "\(setCount) sets"
        return "\(setsText) x \(repRangeFormatted)"
    }

    // MARK: - Business Logic

    /// Validates the exercise configuration
    /// - Throws: ValidationError if configuration is invalid
    func validate() throws {
        // Set count must be between 1 and 10
        guard setCount >= 1 && setCount <= 10 else {
            throw ValidationError.invalidSetCount
        }

        // Rep range must be valid
        guard repRangeMin > 0 && repRangeMax > 0 && repRangeMin <= repRangeMax else {
            throw ValidationError.invalidRepRange
        }

        // Exercise name must not be empty
        guard !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTemplateName
        }
    }
}

// MARK: - Comparable

extension TemplateExercise: Comparable {
    static func < (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        lhs.order < rhs.order
    }
}
