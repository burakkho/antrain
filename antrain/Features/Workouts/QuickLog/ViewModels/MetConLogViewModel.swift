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
    var result: String = ""  // For Time result or general notes
    var duration: TimeInterval = 0  // seconds
    var notes: String = ""
    var isLoading = false
    var errorMessage: String?

    // Duration input helpers (for UI)
    var durationMinutes: Double = 0
    var durationSeconds: Double = 0

    // MARK: - Computed Properties

    var canSave: Bool {
        duration > 0 && !result.isEmpty
    }

    // MARK: - Initialization

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Actions

    /// Update duration from minutes and seconds input
    func updateDuration() {
        duration = (durationMinutes * 60) + durationSeconds
    }

    /// Save metcon workout
    func saveWorkout() async throws {
        guard canSave else {
            throw ValidationError.businessRuleViolation("Please enter duration and result/notes")
        }

        isLoading = true
        errorMessage = nil

        do {
            // Create workout
            let workout = Workout(
                date: Date(),
                type: .metcon,
                duration: duration,
                notes: notes.isEmpty ? nil : notes
            )

            // Set metcon-specific data
            workout.metconType = metconType.rawValue
            workout.metconRounds = rounds > 0 ? rounds : nil
            workout.metconResult = result

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
