//
//  ProgramDay.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//  Updated: Simplified to day-based system (removed week concept)
//

import Foundation
import SwiftData

/// Program day containing a workout template reference
@Model
final class ProgramDay: @unchecked Sendable {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Day number in program sequence (1, 2, 3, ... totalDays)
    var dayNumber: Int

    /// Optional day name (e.g., "Upper Body", "Push Day")
    var name: String?

    /// Optional notes for the day
    var notes: String?

    // MARK: - Relationships

    /// Parent program
    var program: TrainingProgram?

    /// Reference to workout template (nullify on delete to prevent cascade)
    @Relationship(deleteRule: .nullify)
    var template: WorkoutTemplate?

    // MARK: - Initialization

    init(
        dayNumber: Int,
        name: String? = nil,
        notes: String? = nil,
        template: WorkoutTemplate? = nil
    ) {
        self.id = UUID()
        self.dayNumber = dayNumber
        self.name = name
        self.notes = notes
        self.template = template
    }

    // MARK: - Computed Properties

    /// Display name for the day
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        if let template = template {
            return template.name
        }
        return String(localized: "Day \(dayNumber)")
    }

    /// Estimated workout duration
    var estimatedDuration: TimeInterval {
        template?.estimatedDuration ?? 3600 // Default 1 hour
    }

    /// Whether this day has a workout assigned
    var hasWorkout: Bool {
        template != nil
    }

    /// Whether this is a rest day
    var isRestDay: Bool {
        template == nil
    }

    // MARK: - Business Logic

    /// Validate day configuration
    func validate() throws {
        // Day number validation
        guard dayNumber >= 1 else {
            throw ValidationError.invalidValue("Day number must be at least 1")
        }

        // Notes length validation
        if let notes = notes, notes.count > 500 {
            throw ValidationError.invalidValue("Notes must be 500 characters or less")
        }
    }

    /// Create a duplicate of this day
    func duplicate() -> ProgramDay {
        ProgramDay(
            dayNumber: dayNumber,
            name: name,
            notes: notes,
            template: template
        )
    }

    /// Set workout template for this day
    func setTemplate(_ template: WorkoutTemplate?) {
        self.template = template
    }

    /// Clear workout template
    func clearTemplate() {
        self.template = nil
    }
}

// MARK: - Comparable

extension ProgramDay: @preconcurrency Comparable {
    nonisolated static func < (lhs: ProgramDay, rhs: ProgramDay) -> Bool {
        lhs.dayNumber < rhs.dayNumber
    }
}
