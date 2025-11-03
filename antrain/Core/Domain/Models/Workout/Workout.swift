//
//  Workout.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Bir antrenman seansını temsil eder (lifting, cardio veya metcon)
@Model
final class Workout: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: WorkoutType
    var duration: TimeInterval  // Saniye cinsinden
    var notes: String?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutExercise] = []

    // Quick log data için (cardio/metcon)
    // MVP: Basitleştirilmiş - embedded properties
    var cardioType: String?
    var cardioDistance: Double?  // km
    var cardioPace: Double?  // min/km
    var metconType: String?
    var metconRounds: Int?
    var metconResult: String?

    init(
        date: Date = Date(),
        type: WorkoutType,
        duration: TimeInterval = 0,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.duration = duration
        self.notes = notes
    }
}

// MARK: - Computed Properties
extension Workout {
    /// Total sets count (lifting only)
    var totalSets: Int {
        return exercises.reduce(0) { $0 + $1.totalSets }
    }

    /// Completed sets count (lifting only)
    var completedSets: Int {
        return exercises.reduce(0) { $0 + $1.completedSets }
    }

    /// Total volume (lifting only)
    var totalVolume: Double {
        return exercises.reduce(0) { $0 + $1.totalVolume }
    }

    /// Is workout completed?
    var isCompleted: Bool {
        switch type {
        case .lifting:
            return !exercises.isEmpty && exercises.allSatisfy { $0.isAllSetsCompleted }
        case .cardio:
            return cardioType != nil && duration > 0
        case .metcon:
            return metconType != nil && duration > 0
        }
    }

    /// Duration display (formatted)
    var durationDisplay: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    /// Date display (formatted)
    var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Validation
extension Workout {
    func validate() throws {
        // Type-specific validation
        switch type {
        case .lifting:
            guard !exercises.isEmpty else {
                throw ValidationError.businessRuleViolation("Lifting workout must have at least one exercise")
            }

            for exercise in exercises {
                try exercise.validate()
            }

        case .cardio:
            guard cardioType != nil else {
                throw ValidationError.businessRuleViolation("Cardio workout must have a type")
            }

            if let distance = cardioDistance, distance <= 0 {
                throw ValidationError.invalidValue("Distance must be greater than 0")
            }

            if let pace = cardioPace, pace <= 0 {
                throw ValidationError.invalidValue("Pace must be greater than 0")
            }

        case .metcon:
            guard metconType != nil else {
                throw ValidationError.businessRuleViolation("MetCon workout must have a type")
            }

            if let rounds = metconRounds, rounds <= 0 {
                throw ValidationError.invalidValue("Rounds must be greater than 0")
            }
        }

        // Common validation
        guard duration >= 0 else {
            throw ValidationError.invalidValue("Duration cannot be negative")
        }

        if let notes = notes, notes.count > 500 {
            throw ValidationError.invalidValue("Notes must be 500 characters or less")
        }
    }
}

// MARK: - Business Logic
extension Workout {
    /// Add exercise to workout
    func addExercise(_ exercise: WorkoutExercise) {
        exercise.orderIndex = exercises.count
        exercises.append(exercise)
        exercise.workout = self
    }

    /// Remove exercise from workout
    func removeExercise(_ exercise: WorkoutExercise) {
        exercises.removeAll { $0.id == exercise.id }
        // Reorder remaining exercises
        for (index, ex) in exercises.enumerated() {
            ex.orderIndex = index
        }
    }

    /// Calculate duration from start/end time
    func calculateDuration(startTime: Date, endTime: Date) {
        duration = endTime.timeIntervalSince(startTime)
    }

    /// Quick log cardio workout
    func logCardio(type: String, distance: Double?, pace: Double?, duration: TimeInterval) {
        self.cardioType = type
        self.cardioDistance = distance
        self.cardioPace = pace
        self.duration = duration
    }

    /// Quick log metcon workout
    func logMetCon(type: String, rounds: Int?, result: String?, duration: TimeInterval) {
        self.metconType = type
        self.metconRounds = rounds
        self.metconResult = result
        self.duration = duration
    }
}
