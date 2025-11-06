//
//  TrainingProgram.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import SwiftData

/// Training program (MacroCycle) containing multiple weeks of structured workouts
@Model
final class TrainingProgram: @unchecked Sendable {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Program name
    var name: String

    /// Program description
    var programDescription: String?

    /// Program category
    var category: ProgramCategory

    /// Difficulty level
    var difficulty: DifficultyLevel

    /// Total duration in weeks
    var durationWeeks: Int

    /// Whether this is a custom user program or preset
    var isCustom: Bool

    /// Creation date
    var createdAt: Date

    /// Last used date (optional)
    var lastUsedAt: Date?

    /// Progression pattern
    var progressionPattern: WeekProgressionPattern

    // MARK: - Relationships

    /// Program weeks (MicroCycles)
    @Relationship(deleteRule: .cascade, inverse: \ProgramWeek.program)
    var weeks: [ProgramWeek] = []

    // MARK: - Initialization

    init(
        name: String,
        programDescription: String? = nil,
        category: ProgramCategory,
        difficulty: DifficultyLevel,
        durationWeeks: Int,
        progressionPattern: WeekProgressionPattern = .linear,
        isCustom: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.programDescription = programDescription
        self.category = category
        self.difficulty = difficulty
        self.durationWeeks = durationWeeks
        self.progressionPattern = progressionPattern
        self.isCustom = isCustom
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    /// Total number of weeks in the program
    var totalWeeks: Int {
        weeks.count
    }

    /// Number of training days per week (average)
    var trainingDaysPerWeek: Double {
        guard !weeks.isEmpty else { return 0 }
        let totalDays = weeks.reduce(0) { $0 + $1.days.count }
        return Double(totalDays) / Double(weeks.count)
    }

    /// Estimated total duration in hours
    var estimatedTotalDuration: TimeInterval {
        weeks.reduce(0) { $0 + $1.estimatedDuration }
    }

    /// Check if program is complete (all weeks configured)
    var isComplete: Bool {
        weeks.count == durationWeeks && weeks.allSatisfy { !$0.days.isEmpty }
    }

    // MARK: - Business Logic

    /// Validate program configuration
    func validate() throws {
        // Name validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyField("Program name")
        }

        guard name.count <= 100 else {
            throw ValidationError.invalidValue("Program name must be 100 characters or less")
        }

        // Duration validation
        guard durationWeeks > 0 && durationWeeks <= 52 else {
            throw ValidationError.invalidValue("Duration must be between 1-52 weeks")
        }

        // Week validation
        guard !weeks.isEmpty else {
            throw ValidationError.businessRuleViolation("Program must have at least one week configured")
        }

        // Validate each week
        for week in weeks {
            try week.validate()
        }
    }

    /// Create a duplicate of this program with a new name
    func duplicate(newName: String) -> TrainingProgram {
        let newProgram = TrainingProgram(
            name: newName,
            programDescription: programDescription,
            category: category,
            difficulty: difficulty,
            durationWeeks: durationWeeks,
            progressionPattern: progressionPattern,
            isCustom: true,
            createdAt: Date()
        )

        // Deep copy weeks
        for week in weeks {
            let newWeek = week.duplicate()
            newWeek.program = newProgram
            newProgram.weeks.append(newWeek)
        }

        return newProgram
    }

    /// Get week by number (1-indexed)
    func week(number: Int) -> ProgramWeek? {
        weeks.first { $0.weekNumber == number }
    }

    /// Mark program as used (update lastUsedAt)
    func markAsUsed() {
        lastUsedAt = Date()
    }
}

// MARK: - Comparable

extension TrainingProgram: @preconcurrency Comparable {
    nonisolated static func < (lhs: TrainingProgram, rhs: TrainingProgram) -> Bool {
        // Preset programs come first
        if lhs.isCustom != rhs.isCustom {
            return !lhs.isCustom
        }
        // Then sort alphabetically
        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
