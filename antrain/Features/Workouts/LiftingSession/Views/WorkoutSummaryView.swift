//
//  WorkoutSummaryView.swift
//  antrain
//
//  iOS native styled workout summary
//

import SwiftUI

/// Enhanced workout summary view with iOS native styling
struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies

    let workout: Workout
    let exercises: [WorkoutExercise]
    let onSave: (String?) async -> Void
    let onCancel: () -> Void

    @State private var viewModel: WorkoutSummaryViewModel?
    @State private var showSaveAsTemplate = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView("Analyzing workout...")
                    } else {
                        contentView(viewModel: viewModel)
                    }
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showSaveAsTemplate = true
                        } label: {
                            Label("Save as Template", systemImage: "doc.badge.plus")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Workout", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showSaveAsTemplate) {
                SaveWorkoutAsTemplateView(
                    workout: workout,
                    exercises: exercises,
                    onSaved: {}
                )
            }
            .confirmationDialog(
                "Delete Workout?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    Task { await deleteWorkout() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This workout will be permanently deleted.")
            }
            .onAppear {
                if viewModel == nil {
                    let vm = WorkoutSummaryViewModel(
                        workout: workout,
                        exercises: exercises,
                        workoutRepository: appDependencies.workoutRepository,
                        prRepository: appDependencies.personalRecordRepository,
                        prDetectionService: appDependencies.prDetectionService
                    )
                    viewModel = vm
                    Task { await vm.loadData() }
                }
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(viewModel: WorkoutSummaryViewModel) -> some View {
        List {
            // PR Detection Section
            if viewModel.hasNewPRs {
                PRSectionView(detectedPRs: viewModel.detectedPRs)
            }

            // Main Stats
            WorkoutStatsGrid(
                exerciseCount: viewModel.exerciseCount,
                totalSets: viewModel.totalSets,
                durationDisplay: viewModel.durationDisplay,
                totalVolume: viewModel.totalVolume
            )

            // Comparison (if available)
            if viewModel.hasPreviousWorkout {
                ComparisonSection(
                    volumeChange: viewModel.volumeChange,
                    workoutComparison: viewModel.workoutComparison
                )
            }

            // Muscle Groups
            if !viewModel.muscleGroupStats.isEmpty {
                MuscleGroupSection(muscleGroupStats: viewModel.muscleGroupStats)
            }

            // Exercise Details
            ExerciseDetailsList(exercises: exercises)

            // Rating
            ratingSection(viewModel: viewModel)

            // Notes
            notesSection(viewModel: viewModel)

            // Save Button
            Section {
                Button {
                    Task { await saveWorkout(viewModel: viewModel) }
                } label: {
                    if viewModel.isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Workout")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Rating Section

    @ViewBuilder
    private func ratingSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            HStack {
                Spacer()
                ForEach(1...5, id: \.self) { star in
                    Button {
                        viewModel.rating = star
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: (viewModel.rating ?? 0) >= star ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle((viewModel.rating ?? 0) >= star ? .yellow : .secondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
        } header: {
            Text("Rate Workout")
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private func notesSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            TextField("How did it go?", text: Binding(
                get: { viewModel.notes },
                set: { viewModel.notes = $0 }
            ), axis: .vertical)
            .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }

    // MARK: - Actions

    private func saveWorkout(viewModel: WorkoutSummaryViewModel) async {
        await onSave(viewModel.notes.isEmpty ? nil : viewModel.notes)
        dismiss()
    }

    private func deleteWorkout() async {
        guard let viewModel else { return }
        do {
            try await viewModel.deleteWorkout()
            dismiss()
        } catch {
            viewModel.errorMessage = "Failed to delete workout"
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var deps = AppDependencies.preview

    let exercise = Exercise(
        name: "Barbell Squat",
        category: .barbell,
        muscleGroups: [.quads, .glutes],
        equipment: .barbell,
        isCustom: false,
        version: 1
    )

    let workoutExercise = WorkoutExercise(exercise: exercise, orderIndex: 0)
    let _ = {
        workoutExercise.sets = [
            WorkoutSet(reps: 10, weight: 100, isCompleted: true),
            WorkoutSet(reps: 8, weight: 110, isCompleted: true),
            WorkoutSet(reps: 6, weight: 120, isCompleted: true)
        ]
    }()

    let workout = Workout(date: Date(), type: .lifting)
    let _ = {
        workout.duration = 2400
        workout.addExercise(workoutExercise)
    }()

    return WorkoutSummaryView(
        workout: workout,
        exercises: [workoutExercise],
        onSave: { _ in },
        onCancel: {}
    )
    .environmentObject(deps)
}
