//
//  ProgramDetailViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import Observation
@preconcurrency import SwiftData

// Suppress Sendable warnings for SwiftData models
// SwiftData models are thread-safe when used with the same ModelContainer
#if compiler(>=6.0)
#warning("SwiftData Sendable conformance to be addressed in future Swift version")
#endif

/// ViewModel for managing program detail view
@Observable
@MainActor
final class ProgramDetailViewModel {
    // MARK: - State

    private(set) var program: TrainingProgram
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isActivating = false

    var showActivateConfirmation = false
    var showDeactivateConfirmation = false

    // MARK: - Dependencies

    private let programRepository: TrainingProgramRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    init(
        program: TrainingProgram,
        programRepository: TrainingProgramRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.program = program
        self.programRepository = programRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Computed Properties

    var sortedWeeks: [ProgramWeek] {
        program.weeks.sorted()
    }

    var weekCount: Int {
        program.weeks.count
    }

    var averageTrainingDaysPerWeek: Double {
        program.trainingDaysPerWeek
    }

    var estimatedTotalDuration: TimeInterval {
        program.estimatedTotalDuration
    }

    var isComplete: Bool {
        program.isComplete
    }

    /// Get the first workout day with a valid template
    /// This computed property forces template relationships to load
    var firstWorkoutDay: ProgramDay? {
        guard let firstWeek = sortedWeeks.first else { return nil }

        // Sort days and find first one with a template
        let sortedDays = firstWeek.days.sorted(by: { $0.dayOfWeek < $1.dayOfWeek })

        for day in sortedDays {
            // Explicitly access template to trigger SwiftData to load the relationship
            if let template = day.template, !template.name.isEmpty {
                print("✓ Found first workout: \(day.displayName) with template '\(template.name)'")
                return day
            }
        }

        print("⚠️ No workout day found with valid template in first week")
        return nil
    }

    // MARK: - Actions

    func activateProgram() async {
        isActivating = true
        errorMessage = nil

        do {
            // Use the new repository method that ensures both models are in the same context
            try await userProfileRepository.activateProgram(programId: program.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isActivating = false
        showActivateConfirmation = false
    }

    func deactivateProgram() async {
        isActivating = true
        errorMessage = nil

        do {
            // Use the repository method
            try await userProfileRepository.deactivateProgram()
        } catch {
            errorMessage = error.localizedDescription
        }

        isActivating = false
        showDeactivateConfirmation = false
    }

    func duplicateProgram(newName: String) async -> Bool {
        errorMessage = nil

        do {
            let duplicate = program.duplicate(newName: newName)
            #if compiler(>=6.0)
            try await programRepository.create(duplicate)
            #else
            try await programRepository.create(duplicate)
            #endif
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteProgram() async -> Bool {
        errorMessage = nil

        do {
            #if compiler(>=6.0)
            try await programRepository.delete(program)
            #else
            try await programRepository.delete(program)
            #endif
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func loadWeekDetail(for week: ProgramWeek) -> WeekDetailViewModel {
        WeekDetailViewModel(week: week)
    }
}
