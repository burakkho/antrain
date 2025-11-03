import SwiftUI

/// Lifting session view with exercise tracking
struct LiftingSessionView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss

    let initialTemplate: WorkoutTemplate?

    @State private var viewModel: LiftingSessionViewModel?
    @State private var showCancelConfirmation = false
    @State private var showTemplateSelector = false
    @State private var isKeyboardMode = false
    @State private var showModeToast = false
    @State private var modeToastMessage = ""

    init(initialTemplate: WorkoutTemplate? = nil) {
        self.initialTemplate = initialTemplate
    }

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

                // Mode toggle button (center)
                ToolbarItem(placement: .principal) {
                    Button {
                        isKeyboardMode.toggle()
                        modeToastMessage = isKeyboardMode ? "Keyboard Mode" : "Swipe Mode"
                        showModeToast = true

                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()

                        // Hide toast after 1.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showModeToast = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isKeyboardMode ? "keyboard" : "hand.tap.fill")
                            Text(isKeyboardMode ? "Keyboard" : "Swipe")
                                .font(.caption)
                        }
                        .foregroundStyle(isKeyboardMode ? .blue : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isKeyboardMode ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                        .clipShape(Capsule())
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

                    // Load initial template if provided
                    if let template = initialTemplate {
                        Task {
                            await viewModel?.loadFromTemplate(
                                template,
                                templateRepository: appDependencies.workoutTemplateRepository
                            )
                        }
                    }
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
            .sheet(isPresented: $showTemplateSelector) {
                TemplateQuickSelectorView { template in
                    if let viewModel {
                        Task {
                            await viewModel.loadFromTemplate(
                                template,
                                templateRepository: appDependencies.workoutTemplateRepository
                            )
                        }
                    }
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
            .overlay(alignment: .top) {
                // Toast notification for mode switching
                if showModeToast {
                    Text(modeToastMessage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3), value: showModeToast)
        }
    }

    // MARK: - Empty State

    private func emptyState(viewModel: LiftingSessionViewModel) -> some View {
        VStack(spacing: 32) {
            DSEmptyState(
                icon: "dumbbell",
                title: "No Exercises Yet",
                message: "Start your workout from a template or add exercises manually.",
                actionTitle: "Add Exercise",
                action: {
                    viewModel.showExerciseSelection = true
                }
            )

            // Divider with "OR"
            HStack {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
                Text("OR")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
            }
            .padding(.horizontal, 40)

            // Start from Template button
            Button {
                showTemplateSelector = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                    Text("Start from Template")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Exercises List

    private func exercisesList(viewModel: LiftingSessionViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(viewModel.exercises) { workoutExercise in
                    ExerciseCard(
                        workoutExercise: workoutExercise,
                        isKeyboardMode: isKeyboardMode,
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
        .scrollDisabled(!isKeyboardMode) // Disable scroll in swipe mode
        .background(DSColors.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview {
    LiftingSessionView()
        .environmentObject(AppDependencies.preview)
}
