//
//  PersonalRecord.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Personal Record (PR) for lifting exercises
/// Tracks estimated 1RM based on Brzycki formula
@Model
final class PersonalRecord: @unchecked Sendable {
    @Attribute(.unique) var id: UUID

    /// Exercise name (denormalized for quick access)
    var exerciseName: String

    /// Exercise ID (for linking)
    var exerciseId: UUID

    /// Estimated 1 Rep Max (Brzycki formula)
    var estimated1RM: Double

    /// Actual weight used in the set
    var actualWeight: Double

    /// Reps performed in the set
    var reps: Int

    /// Date when PR was achieved
    var date: Date

    /// Workout ID where PR was achieved
    var workoutId: UUID

    /// Version for data migration
    var version: Int

    init(
        exerciseName: String,
        exerciseId: UUID,
        estimated1RM: Double,
        actualWeight: Double,
        reps: Int,
        date: Date,
        workoutId: UUID,
        version: Int = 1
    ) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.exerciseId = exerciseId
        self.estimated1RM = estimated1RM
        self.actualWeight = actualWeight
        self.reps = reps
        self.date = date
        self.workoutId = workoutId
        self.version = version
    }
}

// MARK: - Display Helpers

extension PersonalRecord {
    /// Formatted PR display
    /// Example: "Bench Press: 100.0kg (8 reps x 85kg)"
    func formattedDisplay(weightUnit: String = "Kilograms") -> String {
        let displayWeight = weightUnit == "Pounds" ? estimated1RM.kgToLbs() : estimated1RM
        let displayActual = weightUnit == "Pounds" ? actualWeight.kgToLbs() : actualWeight
        let unit = weightUnit == "Kilograms" ? "kg" : "lbs"

        let weight1RMStr = String(format: "%.1f", displayWeight)
        let actualWeightStr = String(format: "%.1f", displayActual)

        if reps == 1 {
            return "\(exerciseName): \(weight1RMStr)\(unit)"
        } else {
            return "\(exerciseName): \(weight1RMStr)\(unit) (\(reps) reps × \(actualWeightStr)\(unit))"
        }
    }

    /// Short display for cards
    /// Example: "100kg"
    func formattedWeight(weightUnit: String = "Kilograms") -> String {
        return estimated1RM.formattedWeight(unit: weightUnit)
    }

    /// Relative time display
    /// Example: "2 days ago"
    var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days < 7 {
                return "\(days) days ago"
            } else if days < 30 {
                let weeks = days / 7
                return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
            } else {
                let months = days / 30
                return "\(months) month\(months == 1 ? "" : "s") ago"
            }
        }
    }
}

// MARK: - Validation

extension PersonalRecord {
    func validate() throws {
        guard !exerciseName.isEmpty else {
            throw ValidationError.emptyField("Exercise name")
        }

        guard estimated1RM > 0 else {
            throw ValidationError.invalidValue("Estimated 1RM must be greater than 0")
        }

        guard actualWeight > 0 else {
            throw ValidationError.invalidValue("Actual weight must be greater than 0")
        }

        guard reps > 0 && reps <= 20 else {
            throw ValidationError.invalidValue("Reps must be between 1 and 20")
        }
    }
}
