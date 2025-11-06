//
//  ProgramWeek.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import SwiftData

/// Program week (MicroCycle) containing daily workouts and progressive overload settings
@Model
final class ProgramWeek: @unchecked Sendable {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Week number (1-indexed)
    var weekNumber: Int

    /// Optional week name (e.g., "Hypertrophy Phase - Week 1")
    var name: String?

    /// Optional notes for the week
    var notes: String?

    /// Training phase tag (optional)
    var phaseTag: TrainingPhase?

    /// Intensity modifier (1.0 = baseline, 1.05 = +5%, 0.95 = -5%)
    var intensityModifier: Double

    /// Volume modifier (1.0 = baseline, 1.1 = +10%, 0.9 = -10%)
    var volumeModifier: Double

    /// Whether this is a deload week
    var isDeload: Bool

    // MARK: - Relationships

    /// Parent training program
    var program: TrainingProgram?

    /// Days in this week
    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.week)
    var days: [ProgramDay] = []

    // MARK: - Initialization

    init(
        weekNumber: Int,
        name: String? = nil,
        notes: String? = nil,
        phaseTag: TrainingPhase? = nil,
        intensityModifier: Double = 1.0,
        volumeModifier: Double = 1.0,
        isDeload: Bool = false
    ) {
        self.id = UUID()
        self.weekNumber = weekNumber
        self.name = name
        self.notes = notes
        self.phaseTag = phaseTag
        self.intensityModifier = intensityModifier
        self.volumeModifier = volumeModifier
        self.isDeload = isDeload
    }

    // MARK: - Computed Properties

    /// Number of training days in this week
    var trainingDays: Int {
        days.count
    }

    /// Estimated total duration for the week
    var estimatedDuration: TimeInterval {
        days.reduce(0) { $0 + $1.estimatedDuration }
    }

    /// Display name (week name or default)
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return String(localized: "Week \(weekNumber)", comment: "Default week display name")
    }

    /// Combined modifier (intensity × volume)
    var combinedModifier: Double {
        intensityModifier * volumeModifier
    }

    // MARK: - Business Logic

    /// Validate week configuration
    func validate() throws {
        // Week number validation
        guard weekNumber > 0 else {
            throw ValidationError.invalidValue("Week number must be positive")
        }

        // Modifier validation
        guard intensityModifier > 0 && intensityModifier <= 2.0 else {
            throw ValidationError.invalidValue("Intensity modifier must be between 0-200%")
        }

        guard volumeModifier > 0 && volumeModifier <= 2.0 else {
            throw ValidationError.invalidValue("Volume modifier must be between 0-200%")
        }

        // Notes length validation
        if let notes = notes, notes.count > 500 {
            throw ValidationError.invalidValue("Notes must be 500 characters or less")
        }

        // Validate each day
        for day in days {
            try day.validate()
        }
    }

    /// Create a duplicate of this week
    func duplicate() -> ProgramWeek {
        let newWeek = ProgramWeek(
            weekNumber: weekNumber,
            name: name,
            notes: notes,
            phaseTag: phaseTag,
            intensityModifier: intensityModifier,
            volumeModifier: volumeModifier,
            isDeload: isDeload
        )

        // Deep copy days
        for day in days {
            let newDay = day.duplicate()
            newDay.week = newWeek
            newWeek.days.append(newDay)
        }

        return newWeek
    }

    /// Get day by day of week (1 = Sunday, 2 = Monday, etc.)
    func day(forDayOfWeek dayOfWeek: Int) -> ProgramDay? {
        days.first { $0.dayOfWeek == dayOfWeek }
    }

    /// Add a day to this week
    func addDay(_ day: ProgramDay) {
        day.week = self
        days.append(day)
    }

    /// Remove a day from this week
    func removeDay(_ day: ProgramDay) {
        days.removeAll { $0.id == day.id }
    }

    /// Sort days by day of week
    func sortDays() {
        days.sort { $0.dayOfWeek < $1.dayOfWeek }
    }
}

// MARK: - Comparable

extension ProgramWeek: @preconcurrency Comparable {
    nonisolated static func < (lhs: ProgramWeek, rhs: ProgramWeek) -> Bool {
        lhs.weekNumber < rhs.weekNumber
    }
}
