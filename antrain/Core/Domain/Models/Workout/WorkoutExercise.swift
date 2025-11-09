//
//  WorkoutExercise.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Bir workout içindeki egzersiz (Exercise library'den referans + sets)
@Model
final class WorkoutExercise: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int

    // Relationships
    var exercise: Exercise?  // Exercise silinirse nil olur
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet] = []
    var workout: Workout?

    init(
        exercise: Exercise,
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
    }
}

// MARK: - Computed Properties
extension WorkoutExercise {
    /// Total sets count
    var totalSets: Int {
        return sets.count
    }

    /// Completed sets count
    var completedSets: Int {
        return sets.filter { $0.isCompleted }.count
    }

    /// Total volume (sum of all sets' volume)
    var totalVolume: Double {
        return sets.reduce(0) { $0 + $1.volume }
    }

    /// Heaviest set (by weight)
    var heaviestSet: WorkoutSet? {
        return sets.max(by: { $0.weight < $1.weight })
    }

    /// Exercise name (handles deleted exercise)
    var exerciseName: String {
        return exercise?.name ?? "Deleted Exercise"
    }

    /// Is all sets completed?
    var isAllSetsCompleted: Bool {
        guard !sets.isEmpty else { return false }
        return sets.allSatisfy { $0.isCompleted }
    }
}

// MARK: - Validation
extension WorkoutExercise {
    func validate() throws {
        guard !sets.isEmpty else {
            throw ValidationError.businessRuleViolation("Exercise must have at least one set")
        }

        guard orderIndex >= 0 else {
            throw ValidationError.invalidValue("Order index cannot be negative")
        }
    }
}

// MARK: - Business Logic
extension WorkoutExercise {
    /// Add a new set
    func addSet(_ set: WorkoutSet) {
        sets.append(set)
        set.workoutExercise = self
    }

    /// Remove a set
    func removeSet(_ set: WorkoutSet) {
        sets.removeAll { $0.id == set.id }
    }

    /// Duplicate last set (convenience for adding similar sets)
    func duplicateLastSet() -> WorkoutSet? {
        guard let lastSet = sets.last else { return nil }

        let newSet = WorkoutSet(
            reps: lastSet.reps,
            weight: lastSet.weight,
            isCompleted: false
        )

        addSet(newSet)
        return newSet
    }

    /// Mark all sets as completed
    func completeAllSets() {
        sets.forEach { $0.markComplete() }
    }
}
