//
//  MetConLogViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// MetCon quick log view model
/// Manages MetCon workout entry state and save logic
@Observable @MainActor
final class MetConLogViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - State

    var metconType: MetConType = .amrap
    var rounds: Int = 0  // For AMRAP/EMOM
    var workoutDescription: String = ""  // WOD description (exercises, rep schemes)
    var score: String = ""  // Performance result/score
    var duration: TimeInterval = 0  // seconds
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var canSave: Bool {
        duration > 0 && !workoutDescription.isEmpty && !score.isEmpty
    }

    // MARK: - Initialization

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Actions

    /// Save metcon workout
    func saveWorkout() async throws {
        guard canSave else {
            throw ValidationError.businessRuleViolation("Please enter duration, workout description, and score")
        }

        isLoading = true
        errorMessage = nil

        do {
            // Create workout
            let workout = Workout(
                date: Date(),
                type: .metcon,
                duration: duration,
                notes: workoutDescription
            )

            // Set metcon-specific data
            workout.metconType = metconType.rawValue
            workout.metconRounds = rounds > 0 ? rounds : nil
            workout.metconResult = score

            // Validate and save
            try workout.validate()
            try await workoutRepository.save(workout)

            // Success - notify views to refresh
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutSaved"), object: nil)

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
            throw error
        }
    }
}

// MARK: - MetCon Types

enum MetConType: String, CaseIterable {
    case amrap = "AMRAP"  // As Many Rounds As Possible
    case emom = "EMOM"    // Every Minute On the Minute
    case forTime = "For Time"
    case tabata = "Tabata"
    case chipper = "Chipper"
    case other = "Other"

    var description: String {
        switch self {
        case .amrap:
            return String(localized: "As Many Rounds As Possible")
        case .emom:
            return String(localized: "Every Minute On the Minute")
        case .forTime:
            return String(localized: "Complete workout as fast as possible")
        case .tabata:
            return String(localized: "20s work, 10s rest")
        case .chipper:
            return String(localized: "Complete all exercises in order")
        case .other:
            return String(localized: "Custom MetCon")
        }
    }
}
