//
//  SaveWorkoutAsTemplateViewModel.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftUI

/// ViewModel for saving a completed workout as a template
@Observable
@MainActor
final class SaveWorkoutAsTemplateViewModel {
    // MARK: - Published State

    /// Template name (pre-filled with date)
    var templateName: String

    /// Selected category
    var selectedCategory: TemplateCategory = .strength

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: Error?

    // MARK: - Dependencies

    private let templateRepository: WorkoutTemplateRepositoryProtocol
    private let workout: Workout
    private let exercises: [WorkoutExercise]

    // MARK: - Initialization

    init(
        workout: Workout,
        exercises: [WorkoutExercise],
        templateRepository: WorkoutTemplateRepositoryProtocol
    ) {
        self.workout = workout
        self.exercises = exercises
        self.templateRepository = templateRepository

        // Pre-fill name with date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        self.templateName = "Workout on \(formatter.string(from: workout.date))"
    }

    // MARK: - Computed Properties

    /// Whether form is valid
    var isValid: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !exercises.isEmpty
    }

    /// Exercise configurations extracted from workout
    var exerciseConfigs: [(exercise: Exercise, sets: Int, repMin: Int, repMax: Int)] {
        exercises.compactMap { workoutExercise in
            guard let exercise = workoutExercise.exercise else { return nil }
            guard !workoutExercise.sets.isEmpty else { return nil }

            let completedSets = workoutExercise.sets.filter { $0.isCompleted }
            guard !completedSets.isEmpty else { return nil }

            let setCount = completedSets.count
            let reps = completedSets.map { $0.reps }
            let repMin = reps.min() ?? 8
            let repMax = reps.max() ?? 12

            return (exercise, setCount, repMin, repMax)
        }
    }

    // MARK: - Save Template

    /// Save workout as template
    func saveAsTemplate() async throws {
        guard isValid else {
            throw SaveTemplateError.invalidData
        }

        isLoading = true
        error = nil

        do {
            // Create template
            let template = WorkoutTemplate(
                name: templateName,
                category: selectedCategory,
                exercises: []
            )

            // Convert workout exercises to template exercises
            for (index, config) in exerciseConfigs.enumerated() {
                let templateExercise = TemplateExercise(
                    order: index,
                    exerciseId: config.exercise.id,
                    exerciseName: config.exercise.name,
                    setCount: config.sets,
                    repRangeMin: config.repMin,
                    repRangeMax: config.repMax,
                    notes: nil
                )
                templateExercise.template = template
                template.exercises.append(templateExercise)
            }

            // Save to repository
            try await templateRepository.createTemplate(template)

            print("✅ Saved workout as template: \(templateName)")
        } catch {
            self.error = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Error Handling

    /// Clear error state
    func clearError() {
        error = nil
    }
}

// MARK: - Errors

enum SaveTemplateError: LocalizedError {
    case invalidData
    case noCompletedSets

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Please provide a valid template name"
        case .noCompletedSets:
            return "No completed sets found in workout"
        }
    }
}
