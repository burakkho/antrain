//
//  DayDetailViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation
import SwiftUI

/// ViewModel for ProgramDay detail view
@Observable
@MainActor
final class DayDetailViewModel {
    // MARK: - Properties

    let day: ProgramDay

    // MARK: - Computed Properties

    /// Template exercises sorted by order
    var sortedExercises: [TemplateExercise] {
        day.template?.exercises.sorted { $0.order < $1.order } ?? []
    }

    /// Total estimated sets in workout
    var totalSets: Int {
        sortedExercises.reduce(0) { $0 + $1.setCount }
    }

    /// Total estimated volume (sets × average reps)
    var estimatedVolume: Int {
        sortedExercises.reduce(0) { total, exercise in
            let avgReps = (exercise.repRangeMin + exercise.repRangeMax) / 2
            return total + (exercise.setCount * avgReps)
        }
    }

    /// Intensity modifier text (from day or week)
    var intensityModifierText: String? {
        let modifier = day.effectiveIntensityModifier
        guard modifier != 1.0 else { return nil }

        let percentage = Int(modifier * 100)
        let change = percentage - 100

        if change > 0 {
            return "+\(change)%"
        } else {
            return "\(change)%"
        }
    }

    /// Volume modifier text (from day or week)
    var volumeModifierText: String? {
        let modifier = day.effectiveVolumeModifier
        guard modifier != 1.0 else { return nil }

        let percentage = Int(modifier * 100)
        let change = percentage - 100

        if change > 0 {
            return "+\(change)%"
        } else {
            return "\(change)%"
        }
    }

    /// RPE text
    var rpeText: String? {
        guard let rpe = day.suggestedRPE else { return nil }
        return "RPE \(rpe)/10"
    }

    /// RPE description based on value
    var rpeDescription: String? {
        guard let rpe = day.suggestedRPE else { return nil }

        switch rpe {
        case 1...4:
            return String(localized: "Very light effort")
        case 5...6:
            return String(localized: "Moderate effort, could do many more reps")
        case 7:
            return String(localized: "Challenging, could do 3 more reps")
        case 8:
            return String(localized: "Hard, could do 2 more reps")
        case 9:
            return String(localized: "Very hard, could do 1 more rep")
        case 10:
            return String(localized: "Maximum effort, no reps left")
        default:
            return nil
        }
    }

    /// Whether this day has any modifiers applied
    var hasModifiers: Bool {
        day.effectiveIntensityModifier != 1.0 ||
        day.effectiveVolumeModifier != 1.0 ||
        day.week?.isDeload == true
    }

    // MARK: - Initialization

    init(day: ProgramDay) {
        self.day = day
    }
}
