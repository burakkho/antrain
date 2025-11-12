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
    let totalDays: Int
    let days: [DayDTO]

    init(
        name: String,
        description: String,
        category: ProgramCategory,
        difficulty: DifficultyLevel,
        totalDays: Int,
        days: [DayDTO]
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.totalDays = totalDays
        self.days = days
    }
}

/// Data Transfer Object for a program day
struct DayDTO: Sendable {
    let dayNumber: Int  // 1-indexed day number in program
    let name: String?
    let templateName: String?  // Reference to template by name
    let notes: String?

    init(
        dayNumber: Int,
        name: String? = nil,
        templateName: String? = nil,
        notes: String? = nil
    ) {
        self.dayNumber = dayNumber
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
            totalDays: totalDays,
            isCustom: false
        )

        for dayDTO in days {
            let day = dayDTO.toModel(templateFinder: templateFinder)
            day.program = program
            program.days.append(day)
        }

        return program
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
            dayNumber: dayNumber,
            name: name,
            notes: notes,
            template: template
        )
    }
}
