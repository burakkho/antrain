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

    // MARK: - Initialization

    init(day: ProgramDay) {
        self.day = day
    }
}
