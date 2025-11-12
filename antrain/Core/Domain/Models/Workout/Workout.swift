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
    var rating: Int?  // 1-5 stars, optional

    // Program tracking (optional - nil if not from program)
    var programDayId: UUID?  // Which ProgramDay this workout was started from
    var programDayNumber: Int?  // Day number in program (1-totalDays)
    var programId: UUID?  // Which TrainingProgram

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
        notes: String? = nil,
        programDayId: UUID? = nil,
        programDayNumber: Int? = nil,
        programId: UUID? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.duration = duration
        self.notes = notes
        self.programDayId = programDayId
        self.programDayNumber = programDayNumber
        self.programId = programId
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

    /// Was this workout started from a training program?
    var isFromProgram: Bool {
        programDayId != nil
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

// MARK: - Advanced Stats

extension Workout {
    /// Total tonnage (same as totalVolume, but semantically clearer for stats)
    var totalTonnage: Double {
        totalVolume
    }

    /// Volume breakdown by muscle group
    /// Returns dictionary of muscle groups and their total volume in this workout
    var volumeByMuscleGroup: [MuscleGroup: Double] {
        var breakdown: [MuscleGroup: Double] = [:]

        for workoutExercise in exercises {
            guard let exercise = workoutExercise.exercise else { continue }

            let exerciseVolume = workoutExercise.sets.reduce(0.0) { $0 + $1.volume }

            // Distribute volume across all muscle groups for this exercise
            for muscleGroup in exercise.muscleGroups {
                breakdown[muscleGroup, default: 0] += exerciseVolume
            }
        }

        return breakdown
    }

    /// Detailed muscle group statistics
    var muscleGroupStats: [MuscleGroupStats] {
        let volumeBreakdown = volumeByMuscleGroup

        return volumeBreakdown.map { muscleGroup, volume in
            // Count sets for this muscle group
            let setsCount = exercises.reduce(0) { total, workoutExercise in
                guard let exercise = workoutExercise.exercise,
                      exercise.muscleGroups.contains(muscleGroup) else {
                    return total
                }
                return total + workoutExercise.sets.count
            }

            // Count exercises for this muscle group
            let exerciseCount = exercises.filter { workoutExercise in
                guard let exercise = workoutExercise.exercise else { return false }
                return exercise.muscleGroups.contains(muscleGroup)
            }.count

            return MuscleGroupStats(
                muscleGroup: muscleGroup,
                volume: volume,
                sets: setsCount,
                exerciseCount: exerciseCount
            )
        }.sorted { $0.volume > $1.volume } // Sort by volume descending
    }

    /// Top 3 muscle groups trained (by volume)
    var topMuscleGroups: [MuscleGroup] {
        Array(muscleGroupStats.prefix(3).map { $0.muscleGroup })
    }

    /// Compare this workout with another workout
    /// - Parameter other: The previous workout to compare with
    /// - Returns: Comparison object with detailed metrics
    func compare(with other: Workout) -> WorkoutComparison {
        WorkoutComparison(previousWorkout: other, currentWorkout: self)
    }

    /// Get PRs that were set in this workout
    /// Note: This method requires PersonalRecordRepository to find PRs by workoutId
    /// - Parameter repository: PersonalRecord repository
    /// - Returns: Array of PRs that were achieved in this workout
    func getPRs(from repository: PersonalRecordRepository) async throws -> [PersonalRecord] {
        let allPRs = try await repository.fetchAll()
        return allPRs.filter { $0.workoutId == self.id }
    }

    /// Count of PRs achieved in this workout
    /// Note: This is a convenience wrapper that returns the count
    /// - Parameter repository: PersonalRecord repository
    /// - Returns: Number of PRs achieved in this workout
    func getPRCount(from repository: PersonalRecordRepository) async throws -> Int {
        try await getPRs(from: repository).count
    }
}
