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
    var pace: Double = 0.0  // Display value (min/km or min/mile based on user preference)
    var paceInMinPerKm: Double = 0.0  // Actual value stored in database (always min/km)
    var duration: TimeInterval = 0  // seconds
    var notes: String = ""
    var isLoading = false
    var errorMessage: String?
    var weightUnit: String = "Kilograms"  // User preference for distance unit

    // Duration input helpers (for UI)
    var durationMinutes: Double = 0
    var durationSeconds: Double = 0

    // MARK: - Computed Properties

    var canSave: Bool {
        duration > 0 || distanceInKm > 0
    }

    // Auto-calculate pace from distance and duration
    // Returns pace in user's preferred unit (min/km or min/mile)
    var calculatedPace: Double? {
        guard distanceInKm > 0, duration > 0 else { return nil }
        let durationMinutes = duration / 60.0
        let pacePerKm = durationMinutes / distanceInKm

        if weightUnit == "Pounds" {
            // Convert min/km to min/mile
            return pacePerKm * 1.60934
        } else {
            return pacePerKm
        }
    }

    // Auto-calculate pace in min/km (for storage)
    var calculatedPaceInMinPerKm: Double? {
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

            // Set cardio-specific data (always store in km and min/km)
            workout.cardioType = cardioType.rawValue
            workout.cardioDistance = distanceInKm > 0 ? distanceInKm : nil

            // Convert pace to min/km for storage if manually entered
            if pace > 0 {
                if weightUnit == "Pounds" {
                    // User entered min/mile, convert to min/km
                    workout.cardioPace = pace / 1.60934
                } else {
                    // Already in min/km
                    workout.cardioPace = pace
                }
            } else if let calculatedPaceKm = calculatedPaceInMinPerKm {
                // Use auto-calculated pace (already in min/km)
                workout.cardioPace = calculatedPaceKm
            }

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

    var displayName: String {
        switch self {
        case .run:
            return String(localized: "Run")
        case .bike:
            return String(localized: "Bike")
        case .row:
            return String(localized: "Row")
        case .swim:
            return String(localized: "Swim")
        case .walk:
            return String(localized: "Walk")
        case .elliptical:
            return String(localized: "Elliptical")
        case .stairs:
            return String(localized: "Stairs")
        case .other:
            return String(localized: "Other")
        }
    }
}
