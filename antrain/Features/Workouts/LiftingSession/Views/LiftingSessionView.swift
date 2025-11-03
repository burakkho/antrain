import SwiftUI

/// Lifting session view with exercise tracking
struct LiftingSessionView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: LiftingSessionViewModel?
    @State private var showCancelConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.exercises.isEmpty {
                        emptyState(viewModel: viewModel)
                    } else {
                        exercisesList(viewModel: viewModel)
                    }
                } else {
                    // Show loading while viewModel is being initialized
                    DSLoadingView(message: "Starting workout...")
                }
            }
            .navigationTitle("Lifting Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel?.hasData == true {
                            showCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if let viewModel, viewModel.canSave {
                        Button("Finish") {
                            viewModel.showSummary = true
                        }
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = LiftingSessionViewModel(
                        workoutRepository: appDependencies.workoutRepository,
                        exerciseRepository: appDependencies.exerciseRepository,
                        prDetectionService: appDependencies.prDetectionService
                    )
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showExerciseSelection ?? false },
                set: { viewModel?.showExerciseSelection = $0 }
            )) {
                if let viewModel {
                    ExerciseSelectionView { exercise in
                        viewModel.addExercise(exercise)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showSummary ?? false },
                set: { viewModel?.showSummary = $0 }
            )) {
                if let viewModel {
                    WorkoutSummaryView(
                        workout: viewModel.workout,
                        exercises: viewModel.exercises,
                        onSave: { notes in
                            await viewModel.saveWorkout(notes: notes)
                            dismiss()
                        },
                        onCancel: {
                            viewModel.showSummary = false
                        }
                    )
                }
            }
            .confirmationDialog(
                "Discard Workout?",
                isPresented: $showCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your workout data will be lost.")
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(viewModel: LiftingSessionViewModel) -> some View {
        DSEmptyState(
            icon: "dumbbell",
            title: "No Exercises Yet",
            message: "Add your first exercise to start tracking your workout.",
            actionTitle: "Add Exercise",
            action: {
                viewModel.showExerciseSelection = true
            }
        )
    }

    // MARK: - Exercises List

    private func exercisesList(viewModel: LiftingSessionViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(viewModel.exercises) { workoutExercise in
                    ExerciseCard(
                        workoutExercise: workoutExercise,
                        onAddSet: {
                            viewModel.addSet(to: workoutExercise)
                        },
                        onUpdateSet: { set, reps, weight in
                            viewModel.updateSet(set, reps: reps, weight: weight)
                        },
                        onCompleteSet: { set in
                            viewModel.completeSet(set)
                        },
                        onDeleteSet: { set in
                            viewModel.removeSet(set, from: workoutExercise)
                        },
                        onDeleteExercise: {
                            viewModel.removeExercise(workoutExercise)
                        }
                    )
                }

                // Add Exercise Button
                Button(action: {
                    viewModel.showExerciseSelection = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(DSSpacing.md)
                    .background(DSColors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
                }
            }
            .padding(DSSpacing.md)
        }
        .background(DSColors.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview {
    LiftingSessionView()
        .environmentObject(AppDependencies.preview)
}
