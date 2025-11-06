//
//  ProgramLibrary.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Library of preset training programs
struct ProgramLibrary {
    /// All preset programs available in the library
    static let allPrograms: [ProgramDTO] = [
        // Beginner programs
        startingStrengthProgram(),
        strongLifts5x5Program(),

        // Hypertrophy programs
        ppl6DayProgram(),

        // Powerlifting programs
        fiveThreeOneBBBProgram()
    ]

    /// Get program DTOs by category
    static func programs(for category: ProgramCategory) -> [ProgramDTO] {
        allPrograms.filter { $0.category == category }
    }

    /// Get program DTOs by difficulty
    static func programs(for difficulty: DifficultyLevel) -> [ProgramDTO] {
        allPrograms.filter { $0.difficulty == difficulty }
    }
}
