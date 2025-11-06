//
//  WeekDetailViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import Observation
@preconcurrency import SwiftData

/// ViewModel for managing program week detail
@Observable
@MainActor
final class WeekDetailViewModel {
    // MARK: - State

    let week: ProgramWeek

    // MARK: - Initialization

    init(week: ProgramWeek) {
        self.week = week
    }

    // MARK: - Computed Properties

    var displayName: String {
        week.displayName
    }

    var sortedDays: [ProgramDay] {
        week.days.sorted()
    }

    var trainingDays: Int {
        week.trainingDays
    }

    var restDays: Int {
        7 - trainingDays
    }

    var estimatedDuration: TimeInterval {
        week.estimatedDuration
    }

    var intensityModifier: Double {
        week.intensityModifier
    }

    var volumeModifier: Double {
        week.volumeModifier
    }

    var combinedModifier: Double {
        week.combinedModifier
    }

    var isDeload: Bool {
        week.isDeload
    }

    var phaseTag: TrainingPhase? {
        week.phaseTag
    }

    var notes: String? {
        week.notes
    }

    // MARK: - Helpers

    func dayName(for dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return weekdaySymbols[index]
    }

    func shortDayName(for dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let shortWeekdaySymbols = calendar.shortWeekdaySymbols
        let index = (dayOfWeek - 1) % 7
        return shortWeekdaySymbols[index]
    }
}
