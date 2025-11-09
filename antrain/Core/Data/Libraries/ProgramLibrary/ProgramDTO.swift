//
//  ProgramDTO.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Data Transfer Object for preset programs
/// Used to define programs in code before converting to SwiftData models
struct ProgramDTO: Sendable {
    let name: String
    let description: String
    let category: ProgramCategory
    let difficulty: DifficultyLevel
    let durationWeeks: Int
    let progressionPattern: WeekProgressionPattern
    let weeks: [WeekDTO]

    init(
        name: String,
        description: String,
        category: ProgramCategory,
        difficulty: DifficultyLevel,
        durationWeeks: Int,
        progressionPattern: WeekProgressionPattern,
        weeks: [WeekDTO]
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.durationWeeks = durationWeeks
        self.progressionPattern = progressionPattern
        self.weeks = weeks
    }
}

/// Data Transfer Object for a program week
struct WeekDTO: Sendable {
    let weekNumber: Int
    let name: String?
    let phaseTag: TrainingPhase?
    let intensityModifier: Double
    let volumeModifier: Double
    let isDeload: Bool
    let notes: String?
    let days: [DayDTO]

    init(
        weekNumber: Int,
        name: String? = nil,
        phaseTag: TrainingPhase? = nil,
        intensityModifier: Double = 1.0,
        volumeModifier: Double = 1.0,
        isDeload: Bool = false,
        notes: String? = nil,
        days: [DayDTO]
    ) {
        self.weekNumber = weekNumber
        self.name = name
        self.phaseTag = phaseTag
        self.intensityModifier = intensityModifier
        self.volumeModifier = volumeModifier
        self.isDeload = isDeload
        self.notes = notes
        self.days = days
    }
}

/// Data Transfer Object for a program day
struct DayDTO: Sendable {
    let dayOfWeek: Int  // 1=Sunday, 2=Monday, etc.
    let name: String?
    let templateName: String?  // Reference to template by name
    let notes: String?

    init(
        dayOfWeek: Int,
        name: String? = nil,
        templateName: String? = nil,
        notes: String? = nil
    ) {
        self.dayOfWeek = dayOfWeek
        self.name = name
        self.templateName = templateName
        self.notes = notes
    }
}

// MARK: - Conversion Extensions

extension ProgramDTO {
    /// Convert DTO to TrainingProgram model
    /// - Parameter templateFinder: Closure to find templates by name
    /// - Returns: TrainingProgram model instance
    func toModel(templateFinder: (String) -> WorkoutTemplate?) -> TrainingProgram {
        let program = TrainingProgram(
            name: name,
            programDescription: description,
            category: category,
            difficulty: difficulty,
            durationWeeks: durationWeeks,
            progressionPattern: progressionPattern,
            isCustom: false
        )

        for weekDTO in weeks {
            let week = weekDTO.toModel(templateFinder: templateFinder)
            week.program = program
            program.weeks.append(week)
        }

        return program
    }
}

extension WeekDTO {
    /// Convert DTO to ProgramWeek model
    func toModel(templateFinder: (String) -> WorkoutTemplate?) -> ProgramWeek {
        let week = ProgramWeek(
            weekNumber: weekNumber,
            name: name,
            notes: notes,
            phaseTag: phaseTag,
            intensityModifier: intensityModifier,
            volumeModifier: volumeModifier,
            isDeload: isDeload
        )

        for dayDTO in days {
            let day = dayDTO.toModel(templateFinder: templateFinder)
            day.week = week
            week.days.append(day)
        }

        return week
    }
}

extension DayDTO {
    /// Convert DTO to ProgramDay model
    func toModel(templateFinder: (String) -> WorkoutTemplate?) -> ProgramDay {
        var template: WorkoutTemplate? = nil
        if let templateName = templateName {
            template = templateFinder(templateName)
        }

        return ProgramDay(
            dayOfWeek: dayOfWeek,
            name: name,
            notes: notes,
            template: template
        )
    }
}
