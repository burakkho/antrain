//
//  WorkoutSet.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Bir egzersizin tek bir seti (reps + weight + completion state)
@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var reps: Int
    var weight: Double  // kg cinsinden
    var isCompleted: Bool
    var notes: String?
    var restTime: TimeInterval?  // MVP scope dışı ama model hazır

    // CSV import/export support (Hevy, Strong, Fitbod compatible)
    var setType: String?  // "normal", "warmup", "dropset", "failure", custom types
    var rpe: Int?  // Rate of Perceived Exertion (1-10)

    // Relationship
    var workoutExercise: WorkoutExercise?

    init(
        reps: Int,
        weight: Double = 0.0,
        isCompleted: Bool = false,
        notes: String? = nil,
        restTime: TimeInterval? = nil,
        setType: String? = nil,
        rpe: Int? = nil
    ) {
        self.id = UUID()
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.notes = notes
        self.restTime = restTime
        self.setType = setType
        self.rpe = rpe
    }
}

// MARK: - Computed Properties
extension WorkoutSet {
    /// Total volume (reps × weight)
    var volume: Double {
        return Double(reps) * weight
    }

    /// Estimated 1RM using Brzycki formula
    var oneRepMax: Double {
        guard reps > 0 && weight > 0 else { return 0 }
        return weight / (1.0278 - 0.0278 * Double(reps))
    }

    /// Display weight (0 = bodyweight)
    var displayWeight: String {
        weight == 0 ? "BW" : "\(weight) kg"
    }

    /// Parsed SetType from string (nonisolated)
    nonisolated var parsedSetType: SetType {
        SetType.from(string: setType)
    }

    /// Is this a warmup set?
    nonisolated var isWarmup: Bool {
        parsedSetType == .warmup
    }
}

// MARK: - Validation
extension WorkoutSet {
    func validate() throws {
        guard reps > 0 else {
            throw ValidationError.invalidValue("Reps must be greater than 0")
        }

        guard weight >= 0 else {
            throw ValidationError.invalidValue("Weight cannot be negative")
        }

        if let notes = notes, notes.count > 200 {
            throw ValidationError.invalidValue("Notes must be 200 characters or less")
        }

        if let restTime = restTime, restTime < 0 {
            throw ValidationError.invalidValue("Rest time cannot be negative")
        }
    }
}

// MARK: - Business Logic
extension WorkoutSet {
    /// Mark set as completed
    func markComplete() {
        isCompleted = true
    }

    /// Mark set as incomplete
    func markIncomplete() {
        isCompleted = false
    }

    /// Toggle completion state
    func toggleCompletion() {
        isCompleted.toggle()
    }
}
