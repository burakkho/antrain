//
//  ProgramsListViewModel.swift
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

/// ViewModel for managing the programs list
@Observable
@MainActor
final class ProgramsListViewModel {
    // MARK: - State

    private(set) var programs: [TrainingProgram] = []
    private(set) var userPrograms: [TrainingProgram] = []
    private(set) var presetPrograms: [TrainingProgram] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var selectedCategory: ProgramCategory? = nil
    var searchQuery: String = ""

    // MARK: - Dependencies

    private let repository: TrainingProgramRepositoryProtocol

    // MARK: - Initialization

    init(repository: TrainingProgramRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Computed Properties

    var filteredPrograms: [TrainingProgram] {
        var result = programs

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.programDescription?.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }

        return result
    }

    var filteredUserPrograms: [TrainingProgram] {
        filteredPrograms.filter { $0.isCustom }
    }

    var filteredPresetPrograms: [TrainingProgram] {
        filteredPrograms.filter { !$0.isCustom }
    }

    var hasPrograms: Bool {
        !programs.isEmpty
    }

    var hasUserPrograms: Bool {
        !userPrograms.isEmpty
    }

    // MARK: - Actions

    func loadPrograms() async {
        isLoading = true
        errorMessage = nil

        do {
            // SwiftData models are @unchecked Sendable and safe with same ModelContainer
            #if compiler(>=6.0)
            let fetchedPrograms = try await repository.fetchAll()
            #else
            let fetchedPrograms = try await repository.fetchAll()
            #endif
            programs = fetchedPrograms
            userPrograms = programs.filter { $0.isCustom }
            presetPrograms = programs.filter { !$0.isCustom }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteProgram(_ program: TrainingProgram) async {
        errorMessage = nil
        let programId = program.id

        do {
            #if compiler(>=6.0)
            try await repository.delete(program)
            #else
            try await repository.delete(program)
            #endif

            // Remove from local arrays using the ID
            programs.removeAll { $0.id == programId }
            userPrograms.removeAll { $0.id == programId }
            presetPrograms.removeAll { $0.id == programId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func selectCategory(_ category: ProgramCategory?) {
        selectedCategory = category
    }

    func clearFilters() {
        selectedCategory = nil
        searchQuery = ""
    }
}
