//
//  CreateTemplateFlow.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Multi-step wizard for creating workout templates
struct CreateTemplateFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dependencies: AppDependencies

    @State private var viewModel: CreateTemplateViewModel
    @State private var showCancelConfirmation = false
    @State private var isSaving = false

    let onComplete: () -> Void

    init(editingTemplate: WorkoutTemplate? = nil, onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        // Will be properly initialized in task
        _viewModel = State(initialValue: CreateTemplateViewModel(
            templateRepository: AppDependencies.preview.workoutTemplateRepository,
            exerciseRepository: AppDependencies.preview.exerciseRepository,
            editingTemplate: editingTemplate
        ))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                Divider()

                // Current step view
                stepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

                Divider()

                // Navigation buttons
                navigationButtons
                    .padding()
            }
            .navigationTitle(viewModel.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges {
                            showCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Discard Changes?", isPresented: $showCancelConfirmation) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    self.viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .task {
                // Initialize viewModel with proper dependencies
                self.viewModel = CreateTemplateViewModel(
                    templateRepository: dependencies.workoutTemplateRepository,
                    exerciseRepository: dependencies.exerciseRepository,
                    editingTemplate: self.viewModel.editingTemplate
                )

                // Load template data if editing
                if self.viewModel.isEditing {
                    await self.viewModel.loadTemplateForEdit()
                }
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: 12) {
            // Step dots
            HStack(spacing: 8) {
                ForEach(CreateTemplateViewModel.Step.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 10, height: 10)
                }
            }

            // Step title and progress
            VStack(spacing: 4) {
                Text(viewModel.currentStep.title)
                    .font(.headline)

                Text("Step \(viewModel.currentStep.progress)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    // MARK: - Step View

    @ViewBuilder
    private var stepView: some View {
        Group {
            switch viewModel.currentStep {
            case .info:
                TemplateInfoView(viewModel: viewModel)
            case .exercises:
                TemplateExerciseSelectionView(viewModel: viewModel)
            case .configuration:
                TemplateSetConfigView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Back button
            if !viewModel.isFirstStep {
                Button {
                    withAnimation {
                        viewModel.previousStep()
                    }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Continue / Create button
            Button {
                if viewModel.isLastStep {
                    saveTemplate()
                } else {
                    withAnimation {
                        viewModel.nextStep()
                    }
                }
            } label: {
                Group {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label(
                            viewModel.isLastStep ? (viewModel.isEditing ? "Update" : "Create") : "Continue",
                            systemImage: viewModel.isLastStep ? "checkmark" : "chevron.right"
                        )
                        .symbolVariant(viewModel.isLastStep ? .circle.fill : .none)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canContinue ? Color.accentColor : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canContinue || isSaving)
        }
    }

    // MARK: - Save Template

    private func saveTemplate() {
        Task {
            isSaving = true
            do {
                try await viewModel.saveTemplate()
                dismiss()
                onComplete()
            } catch {
                // Error shown in alert
                isSaving = false
            }
        }
    }

    // MARK: - Helpers

    private var hasChanges: Bool {
        !viewModel.templateName.isEmpty ||
        !viewModel.selectedExercises.isEmpty ||
        !viewModel.exerciseConfigs.isEmpty
    }
}

// MARK: - Preview

#Preview("Create New") {
    CreateTemplateFlow {
        print("Template created!")
    }
    .environmentObject(AppDependencies.preview)
}

#Preview("Edit Existing") {
    let template = WorkoutTemplate(
        name: "My Push Day",
        category: .hypertrophy,
        exercises: []
    )

    CreateTemplateFlow(editingTemplate: template) {
        print("Template updated!")
    }
    .environmentObject(AppDependencies.preview)
}
