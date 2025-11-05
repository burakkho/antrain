//
//  CardioLogViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation
import SwiftUI

/// Cardio quick log view model
/// Manages cardio workout entry state and save logic
@Observable @MainActor
final class CardioLogViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - State

    var cardioType: CardioType = .run
    var distance: Double = 0.0  // Display value (km or miles based on user preference)
    var distanceInKm: Double = 0.0  // Actual value stored in database (always km)
    var pace: Double = 0.0  // min/km (optional, auto-calculated if duration + distance)
    var duration: TimeInterval = 0  // seconds
    var notes: String = ""
    var isLoading = false
    var errorMessage: String?

    // Duration input helpers (for UI)
    var durationMinutes: Double = 0
    var durationSeconds: Double = 0

    // MARK: - Computed Properties

    var canSave: Bool {
        duration > 0 || distanceInKm > 0
    }

    // Auto-calculate pace from distance and duration (using km)
    var calculatedPace: Double? {
        guard distanceInKm > 0, duration > 0 else { return nil }
        let durationMinutes = duration / 60.0
        return durationMinutes / distanceInKm
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

    /// Save cardio workout
    func saveWorkout() async throws {
        guard canSave else {
            throw ValidationError.businessRuleViolation("Please enter duration or distance")
        }

        isLoading = true
        errorMessage = nil

        do {
            // Create workout
            let workout = Workout(
                date: Date(),
                type: .cardio,
                duration: duration,
                notes: notes.isEmpty ? nil : notes
            )

            // Set cardio-specific data (always store in km)
            workout.cardioType = cardioType.rawValue
            workout.cardioDistance = distanceInKm > 0 ? distanceInKm : nil
            workout.cardioPace = pace > 0 ? pace : calculatedPace

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

// MARK: - Cardio Types

enum CardioType: String, CaseIterable {
    case run = "Run"
    case bike = "Bike"
    case row = "Row"
    case swim = "Swim"
    case walk = "Walk"
    case elliptical = "Elliptical"
    case stairs = "Stairs"
    case other = "Other"

    var localizedName: LocalizedStringKey {
        switch self {
        case .run:
            return "Run"
        case .bike:
            return "Bike"
        case .row:
            return "Row"
        case .swim:
            return "Swim"
        case .walk:
            return "Walk"
        case .elliptical:
            return "Elliptical"
        case .stairs:
            return "Stairs"
        case .other:
            return "Other"
        }
    }
}
