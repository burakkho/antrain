//
//  TrainingProgram.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//  Updated: Simplified to day-based system (removed week concept)
//

import Foundation
import SwiftData

/// Training program containing a sequence of workout days
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

    /// Total duration in days
    var totalDays: Int

    /// Whether this is a custom user program or preset
    var isCustom: Bool

    /// Creation date
    var createdAt: Date

    /// Last used date (optional)
    var lastUsedAt: Date?

    // MARK: - Relationships

    /// Program days
    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.program)
    var days: [ProgramDay] = []

    // MARK: - Initialization

    init(
        name: String,
        programDescription: String? = nil,
        category: ProgramCategory,
        difficulty: DifficultyLevel,
        totalDays: Int,
        isCustom: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.programDescription = programDescription
        self.category = category
        self.difficulty = difficulty
        self.totalDays = totalDays
        self.isCustom = isCustom
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    /// Number of training days (non-rest days)
    var trainingDaysCount: Int {
        days.filter { $0.hasWorkout }.count
    }

    /// Number of rest days
    var restDaysCount: Int {
        days.filter { $0.isRestDay }.count
    }

    /// Estimated total duration in hours
    var estimatedTotalDuration: TimeInterval {
        days.reduce(0) { $0 + $1.estimatedDuration }
    }

    /// Check if program is complete (all days configured)
    var isComplete: Bool {
        days.count == totalDays
    }

    /// Progress percentage (0.0 - 1.0)
    var completionPercentage: Double {
        guard totalDays > 0 else { return 0 }
        return Double(days.count) / Double(totalDays)
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
        guard totalDays > 0 && totalDays <= 365 else {
            throw ValidationError.invalidValue("Total days must be between 1-365")
        }

        // Day validation
        guard !days.isEmpty else {
            throw ValidationError.businessRuleViolation("Program must have at least one day configured")
        }

        // Validate each day
        for day in days {
            try day.validate()
        }

        // Validate day numbers are sequential
        let dayNumbers = days.map { $0.dayNumber }.sorted()
        for (index, dayNumber) in dayNumbers.enumerated() {
            guard dayNumber == index + 1 else {
                throw ValidationError.businessRuleViolation("Day numbers must be sequential starting from 1")
            }
        }
    }

    /// Create a duplicate of this program with a new name
    func duplicate(newName: String) -> TrainingProgram {
        let newProgram = TrainingProgram(
            name: newName,
            programDescription: programDescription,
            category: category,
            difficulty: difficulty,
            totalDays: totalDays,
            isCustom: true,
            createdAt: Date()
        )

        // Deep copy days
        for day in days.sorted() {
            let newDay = day.duplicate()
            newDay.program = newProgram
            newProgram.days.append(newDay)
        }

        return newProgram
    }

    /// Get day by number (1-indexed)
    func day(number: Int) -> ProgramDay? {
        days.first { $0.dayNumber == number }
    }

    /// Get sorted days
    func sortedDays() -> [ProgramDay] {
        days.sorted { $0.dayNumber < $1.dayNumber }
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
