//
//  SaveWorkoutAsTemplateView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Sheet for saving a completed workout as a template
struct SaveWorkoutAsTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dependencies: AppDependencies

    let workout: Workout
    let exercises: [WorkoutExercise]
    let onSaved: () -> Void

    @State private var viewModel: SaveWorkoutAsTemplateViewModel?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    formContent(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("Error", isPresented: .constant(viewModel?.error != nil)) {
                Button("OK") {
                    viewModel?.clearError()
                }
            } message: {
                if let error = viewModel?.error {
                    Text(error.localizedDescription)
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = SaveWorkoutAsTemplateViewModel(
                        workout: workout,
                        exercises: exercises,
                        templateRepository: dependencies.workoutTemplateRepository
                    )
                }
            }
        }
    }

    // MARK: - Form Content

    @ViewBuilder
    private func formContent(viewModel: SaveWorkoutAsTemplateViewModel) -> some View {
        Form {
            // Template Name Section
            Section {
                TextField("Template name", text: Binding(
                    get: { viewModel.templateName },
                    set: { viewModel.templateName = $0 }
                ))
                .autocorrectionDisabled()
            } header: {
                Text("Template Name")
            } footer: {
                Text("Give your template a descriptive name")
            }

            // Category Section
            Section {
                Picker("Category", selection: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.selectedCategory = $0 }
                )) {
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.displayName)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Category")
            } footer: {
                Text(viewModel.selectedCategory.description)
            }

            // Exercise Preview Section
            Section {
                ForEach(Array(viewModel.exerciseConfigs.enumerated()), id: \.offset) { index, config in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(config.exercise.name)
                            .font(.body)
                            .fontWeight(.medium)

                        Text("\(config.sets) sets × \(config.repMin)-\(config.repMax) reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Exercises (\(viewModel.exerciseConfigs.count))")
            } footer: {
                Text("Set and rep ranges are calculated from your completed sets")
            }
        }
    }

    // MARK: - Toolbar Content

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
            .disabled(isSaving)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                saveTemplate()
            } label: {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Save")
                }
            }
            .disabled(viewModel?.isValid != true || isSaving)
        }
    }

    // MARK: - Save Template

    private func saveTemplate() {
        Task {
            isSaving = true
            do {
                try await viewModel?.saveAsTemplate()
                dismiss()
                onSaved()
            } catch {
                // Error shown in alert
                isSaving = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var workout = Workout(date: Date(), type: .lifting)
    @Previewable @State var exercise = Exercise(
        name: "Barbell Bench Press",
        category: .barbell,
        muscleGroups: [.chest],
        equipment: .barbell,
        isCustom: false
    )
    @Previewable @State var workoutExercise = WorkoutExercise(exercise: exercise, orderIndex: 0)

    let _ = {
        workoutExercise.sets.append(WorkoutSet(reps: 10, weight: 100, isCompleted: true))
        workoutExercise.sets.append(WorkoutSet(reps: 8, weight: 110, isCompleted: true))
    }()

    SaveWorkoutAsTemplateView(
        workout: workout,
        exercises: [workoutExercise],
        onSaved: {
            print("Template saved!")
        }
    )
    .environmentObject(AppDependencies.preview)
}
