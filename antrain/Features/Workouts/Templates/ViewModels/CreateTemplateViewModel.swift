//
//  CreateTemplateViewModel.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftUI

/// ViewModel for creating/editing workout templates
@Observable
@MainActor
final class CreateTemplateViewModel {
    // MARK: - Wizard Steps

    enum Step: Int, CaseIterable {
        case info = 0
        case exercises = 1
        case configuration = 2

        var title: String {
            switch self {
            case .info: return "Template Info"
            case .exercises: return "Select Exercises"
            case .configuration: return "Configure Sets"
            }
        }

        var progress: String {
            "\(rawValue + 1)/3"
        }
    }

    // MARK: - Published State

    /// Current wizard step
    private(set) var currentStep: Step = .info

    /// Template being edited (nil if creating new)
    private(set) var editingTemplate: WorkoutTemplate?

    // Step 1: Template Info
    var templateName: String = ""
    var selectedCategory: TemplateCategory = .strength

    // Step 2: Exercise Selection
    var selectedExercises: [Exercise] = []

    // Step 3: Set Configuration
    var exerciseConfigs: [ExerciseConfig] = []

    /// Loading state
    private(set) var isLoading = false

    /// Error state
    private(set) var error: Error?

    // MARK: - Dependencies

    private let templateRepository: WorkoutTemplateRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol

    // MARK: - Initialization

    init(
        templateRepository: WorkoutTemplateRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        editingTemplate: WorkoutTemplate? = nil
    ) {
        self.templateRepository = templateRepository
        self.exerciseRepository = exerciseRepository
        self.editingTemplate = editingTemplate

        // Pre-fill if editing
        if let template = editingTemplate {
            self.templateName = template.name
            self.selectedCategory = template.category
            // Load exercises and configs in task
        }
    }

    // MARK: - Computed Properties

    /// Whether Step 1 is valid
    var isStep1Valid: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether Step 2 is valid
    var isStep2Valid: Bool {
        !selectedExercises.isEmpty
    }

    /// Whether Step 3 is valid
    var isStep3Valid: Bool {
        !exerciseConfigs.isEmpty &&
        exerciseConfigs.allSatisfy { $0.isValid }
    }

    /// Can navigate to next step
    var canContinue: Bool {
        switch currentStep {
        case .info: return isStep1Valid
        case .exercises: return isStep2Valid
        case .configuration: return isStep3Valid
        }
    }

    /// Whether currently on first step
    var isFirstStep: Bool {
        currentStep == .info
    }

    /// Whether currently on last step
    var isLastStep: Bool {
        currentStep == .configuration
    }

    /// Whether editing (vs creating)
    var isEditing: Bool {
        editingTemplate != nil
    }

    // MARK: - Navigation

    /// Move to next step
    func nextStep() {
        guard canContinue else { return }

        // Prepare data for next step
        switch currentStep {
        case .info:
            currentStep = .exercises
        case .exercises:
            prepareConfigurationStep()
            currentStep = .configuration
        case .configuration:
            break // Already on last step
        }
    }

    /// Move to previous step
    func previousStep() {
        guard !isFirstStep else { return }
        currentStep = Step(rawValue: currentStep.rawValue - 1) ?? .info
    }

    /// Go to specific step
    func goToStep(_ step: Step) {
        currentStep = step
    }

    // MARK: - Step 1: Template Info

    /// Set template name
    func setTemplateName(_ name: String) {
        templateName = name
    }

    /// Set category
    func setCategory(_ category: TemplateCategory) {
        selectedCategory = category
    }

    // MARK: - Step 2: Exercise Selection

    /// Add exercise to selection
    func addExercise(_ exercise: Exercise) {
        if !selectedExercises.contains(where: { $0.id == exercise.id }) {
            selectedExercises.append(exercise)
        }
    }

    /// Remove exercise from selection
    func removeExercise(_ exercise: Exercise) {
        selectedExercises.removeAll { $0.id == exercise.id }
    }

    /// Reorder exercises
    func moveExercises(from: IndexSet, to: Int) {
        selectedExercises.move(fromOffsets: from, toOffset: to)
    }

    // MARK: - Step 3: Set Configuration

    /// Prepare configuration step with default values
    private func prepareConfigurationStep() {
        // Create configs for each exercise if not already done
        if exerciseConfigs.count != selectedExercises.count {
            exerciseConfigs = selectedExercises.map { exercise in
                ExerciseConfig(
                    exercise: exercise,
                    setCount: selectedCategory.defaultSetCount,
                    repRangeMin: selectedCategory.defaultRepRangeMin,
                    repRangeMax: selectedCategory.defaultRepRangeMax,
                    notes: nil
                )
            }
        }
    }

    /// Update exercise configuration
    func updateConfig(for exerciseId: UUID, setCount: Int?, repMin: Int?, repMax: Int?, notes: String?) {
        guard let index = exerciseConfigs.firstIndex(where: { $0.exercise.id == exerciseId }) else {
            return
        }

        if let setCount {
            exerciseConfigs[index].setCount = setCount
        }
        if let repMin {
            exerciseConfigs[index].repRangeMin = repMin
        }
        if let repMax {
            exerciseConfigs[index].repRangeMax = repMax
        }
        if let notes {
            exerciseConfigs[index].notes = notes.isEmpty ? nil : notes
        }
    }

    /// Use default config for exercise based on category
    func useDefaultConfig(for exerciseId: UUID) {
        guard let index = exerciseConfigs.firstIndex(where: { $0.exercise.id == exerciseId }) else {
            return
        }

        exerciseConfigs[index].setCount = selectedCategory.defaultSetCount
        exerciseConfigs[index].repRangeMin = selectedCategory.defaultRepRangeMin
        exerciseConfigs[index].repRangeMax = selectedCategory.defaultRepRangeMax
        exerciseConfigs[index].notes = nil
    }

    // MARK: - Save Template

    /// Create or update template
    func saveTemplate() async throws {
        guard isStep3Valid else {
            throw CreateTemplateError.invalidConfiguration
        }

        isLoading = true
        error = nil

        do {
            if let existing = editingTemplate {
                // Update existing template
                existing.name = templateName
                existing.category = selectedCategory

                // Clear old exercises
                existing.exercises.removeAll()

                // Add new exercises
                for (index, config) in exerciseConfigs.enumerated() {
                    let templateExercise = TemplateExercise(
                        order: index,
                        exerciseId: config.exercise.id,
                        exerciseName: config.exercise.name,
                        setCount: config.setCount,
                        repRangeMin: config.repRangeMin,
                        repRangeMax: config.repRangeMax,
                        notes: config.notes
                    )
                    templateExercise.template = existing
                    existing.exercises.append(templateExercise)
                }

                try await templateRepository.updateTemplate(existing)
            } else {
                // Create new template
                let template = WorkoutTemplate(
                    name: templateName,
                    category: selectedCategory,
                    exercises: []
                )

                // Add exercises
                for (index, config) in exerciseConfigs.enumerated() {
                    let templateExercise = TemplateExercise(
                        order: index,
                        exerciseId: config.exercise.id,
                        exerciseName: config.exercise.name,
                        setCount: config.setCount,
                        repRangeMin: config.repRangeMin,
                        repRangeMax: config.repRangeMax,
                        notes: config.notes
                    )
                    templateExercise.template = template
                    template.exercises.append(templateExercise)
                }

                try await templateRepository.createTemplate(template)
            }
        } catch {
            self.error = error
            throw error
        }

        isLoading = false
    }

    // MARK: - Load for Edit

    /// Load template data for editing
    func loadTemplateForEdit() async {
        guard let template = editingTemplate else { return }

        isLoading = true

        // Fetch exercises for template
        let exerciseIds = template.exercises.map { $0.exerciseId }
        var exercises: [Exercise] = []

        for id in exerciseIds {
            if let exercise = try? await exerciseRepository.fetchExercise(by: id) {
                exercises.append(exercise)
            }
        }

        selectedExercises = exercises

        // Create configs from template exercises
        exerciseConfigs = template.exercises.sorted(by: TemplateExercise.compare).compactMap { templateEx in
            guard let exercise = exercises.first(where: { $0.id == templateEx.exerciseId }) else {
                return nil
            }
            return ExerciseConfig(
                exercise: exercise,
                setCount: templateEx.setCount,
                repRangeMin: templateEx.repRangeMin,
                repRangeMax: templateEx.repRangeMax,
                notes: templateEx.notes
            )
        }

        isLoading = false
    }

    // MARK: - Error Handling

    /// Clear the current error
    func clearError() {
        error = nil
    }

    // MARK: - Reset

    /// Reset wizard to initial state
    func reset() {
        currentStep = .info
        templateName = ""
        selectedCategory = .strength
        selectedExercises = []
        exerciseConfigs = []
        error = nil
    }
}

// MARK: - Exercise Configuration Model

struct ExerciseConfig: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var setCount: Int
    var repRangeMin: Int
    var repRangeMax: Int
    var notes: String?

    var isValid: Bool {
        setCount >= 1 && setCount <= 10 &&
        repRangeMin > 0 && repRangeMax > 0 &&
        repRangeMin <= repRangeMax
    }
}

// MARK: - Errors

enum CreateTemplateError: LocalizedError {
    case invalidConfiguration
    case duplicateName

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return String(localized: "Please check all exercise configurations")
        case .duplicateName:
            return String(localized: "A template with this name already exists")
        }
    }
}
