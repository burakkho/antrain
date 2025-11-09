//
//  ProgramDay.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import SwiftData

/// Program day containing a workout template reference and day-specific settings
@Model
final class ProgramDay: @unchecked Sendable {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    var dayOfWeek: Int

    /// Optional day name (e.g., "Upper Body", "Push Day")
    var name: String?

    /// Optional notes for the day
    var notes: String?

    /// Day-specific intensity override (nil = use week's modifier)
    var intensityOverride: Double?

    /// Day-specific volume override (nil = use week's modifier)
    var volumeOverride: Double?

    // MARK: - Relationships

    /// Parent week
    var week: ProgramWeek?

    /// Reference to workout template (nullify on delete to prevent cascade)
    @Relationship(deleteRule: .nullify)
    var template: WorkoutTemplate?

    // MARK: - Initialization

    init(
        dayOfWeek: Int,
        name: String? = nil,
        notes: String? = nil,
        template: WorkoutTemplate? = nil,
        intensityOverride: Double? = nil,
        volumeOverride: Double? = nil
    ) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.name = name
        self.notes = notes
        self.template = template
        self.intensityOverride = intensityOverride
        self.volumeOverride = volumeOverride
    }

    // MARK: - Computed Properties

    /// Display name for the day (custom name or template name or day of week)
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        if let template = template {
            return template.name
        }
        return dayOfWeekName
    }

    /// Localized day of week name
    var dayOfWeekName: String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return weekdaySymbols[index]
    }

    /// Short day of week name (e.g., "Mon", "Tue")
    var shortDayOfWeekName: String {
        let calendar = Calendar.current
        let shortWeekdaySymbols = calendar.shortWeekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return shortWeekdaySymbols[index]
    }

    /// Effective intensity modifier (override or week's modifier)
    var effectiveIntensityModifier: Double {
        intensityOverride ?? week?.intensityModifier ?? 1.0
    }

    /// Effective volume modifier (override or week's modifier)
    var effectiveVolumeModifier: Double {
        volumeOverride ?? week?.volumeModifier ?? 1.0
    }

    /// Combined effective modifier
    var effectiveModifier: Double {
        effectiveIntensityModifier * effectiveVolumeModifier
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
        // Day of week validation
        guard dayOfWeek >= 1 && dayOfWeek <= 7 else {
            throw ValidationError.invalidValue("Day of week must be between 1-7")
        }

        // Intensity override validation
        if let intensityOverride = intensityOverride {
            guard intensityOverride > 0 && intensityOverride <= 2.0 else {
                throw ValidationError.invalidValue("Intensity override must be between 0-200%")
            }
        }

        // Volume override validation
        if let volumeOverride = volumeOverride {
            guard volumeOverride > 0 && volumeOverride <= 2.0 else {
                throw ValidationError.invalidValue("Volume override must be between 0-200%")
            }
        }

        // Notes length validation
        if let notes = notes, notes.count > 500 {
            throw ValidationError.invalidValue("Notes must be 500 characters or less")
        }
    }

    /// Create a duplicate of this day
    func duplicate() -> ProgramDay {
        ProgramDay(
            dayOfWeek: dayOfWeek,
            name: name,
            notes: notes,
            template: template,
            intensityOverride: intensityOverride,
            volumeOverride: volumeOverride
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
        lhs.dayOfWeek < rhs.dayOfWeek
    }
}
