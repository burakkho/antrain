//
//  ProgramLibrary.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//
//  Refactored by Gemini on 2025-11-12 to be a modular aggregator.
//

import Foundation

/// Central library for all preset training programs.
/// Combines programs from all modular program files into a single, extensible collection.
final class ProgramLibrary: Sendable {

    // MARK: - Properties

    private let presetPrograms: [ProgramDTO]

    // MARK: - Initialization

    init() {
        // Combine all programs from modular files
        self.presetPrograms =
            BeginnerCalisthenicsProgram.all +
            StartingStrengthProgram.all +
            StrongLiftsProgram.all +
            PPLSplitProgram.all +
            UpperLowerSplitProgram.all +
            PowerliftingFocusProgram.all +
            FiveThreeOneProgram.all
    }

    // MARK: - Public Methods

    /// Returns all preset programs as DTOs.
    func getAllPresetPrograms() -> [ProgramDTO] {
        return presetPrograms
    }

    /// Returns programs filtered by category.
    func getPrograms(byCategory category: ProgramCategory) -> [ProgramDTO] {
        return presetPrograms.filter { $0.category == category }
    }

    /// Returns programs filtered by difficulty.
    func getPrograms(byDifficulty difficulty: DifficultyLevel) -> [ProgramDTO] {
        return presetPrograms.filter { $0.difficulty == difficulty }
    }
    
    /// Returns the total number of preset programs.
    func getProgramCount() -> Int {
        return presetPrograms.count
    }
}

