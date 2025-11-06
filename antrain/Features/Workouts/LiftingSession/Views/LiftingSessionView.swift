import SwiftUI
import Combine

/// Lifting session view with exercise tracking
struct LiftingSessionView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss

    let workoutManager: ActiveWorkoutManager?
    let existingViewModel: LiftingSessionViewModel?
    let initialTemplate: WorkoutTemplate?
    let programDay: ProgramDay?

    @State private var viewModel: LiftingSessionViewModel?
    @State private var showCancelConfirmation = false
    @State private var showTemplateSelector = false
    @State private var isKeyboardMode = true
    @State private var showModeToast = false
    @State private var modeToastMessage = ""
    @State private var durationUpdateTrigger = 0

    init(
        workoutManager: ActiveWorkoutManager? = nil,
        existingViewModel: LiftingSessionViewModel? = nil,
        initialTemplate: WorkoutTemplate? = nil,
        programDay: ProgramDay? = nil
    ) {
        self.workoutManager = workoutManager
        self.existingViewModel = existingViewModel
        self.initialTemplate = initialTemplate
        self.programDay = programDay
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
                    Button(viewModel?.hasData == true ? "Minimize" : "Cancel") {
                        if viewModel?.hasData == true {
                            // Minimize workout
                            workoutManager?.minimizeWorkout()
                        } else {
                            // No data, just dismiss
                            workoutManager?.cancelWorkout()
                            dismiss()
                        }
                    }
                }

                // Mode toggle button (center)
                ToolbarItem(placement: .principal) {
                    Button {
                        // Smooth animation for mode switch
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isKeyboardMode.toggle()
                        }

                        // Update toast message
                        modeToastMessage = isKeyboardMode ? "Keyboard Mode" : "Swipe Mode"

                        // Show toast with animation
                        withAnimation(.spring(response: 0.3)) {
                            showModeToast = true
                        }

                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()

                        // Hide toast after 1.5 seconds
                        Task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            withAnimation(.spring(response: 0.3)) {
                                showModeToast = false
                            }
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
                        Menu {
                            Button("Finish Workout") {
                                viewModel.showSummary = true
                            }

                            Button("Discard Workout", role: .destructive) {
                                showCancelConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .task {
                if viewModel == nil {
                    // Use existing view model or create new
                    if let existingViewModel {
                        viewModel = existingViewModel
                    } else {
                        let newViewModel = LiftingSessionViewModel(
                            workoutRepository: appDependencies.workoutRepository,
                            exerciseRepository: appDependencies.exerciseRepository,
                            prDetectionService: appDependencies.prDetectionService,
                            progressiveOverloadService: appDependencies.progressiveOverloadService,
                            userProfileRepository: appDependencies.userProfileRepository
                        )

                        // Load initial template if provided (BEFORE setting viewModel)
                        if let template = initialTemplate {
                            await newViewModel.loadFromTemplate(
                                template,
                                templateRepository: appDependencies.workoutTemplateRepository,
                                programDay: programDay
                            )
                            // Clear pending template and program day after loading
                            workoutManager?.pendingTemplate = nil
                            workoutManager?.pendingProgramDay = nil
                        }

                        // Set viewModel AFTER template is loaded
                        viewModel = newViewModel

                        // Register with workout manager
                        workoutManager?.startWorkout(
                            workout: newViewModel.workout,
                            viewModel: newViewModel
                        )
                    }
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                // Update duration display every second
                durationUpdateTrigger += 1
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
                            workoutManager?.finishWorkout()
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
                    workoutManager?.cancelWorkout()
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
                // Workout Statistics Header
                WorkoutStatsHeaderView(
                    title: viewModel.workoutTitle,
                    duration: viewModel.duration,
                    volume: viewModel.totalVolume,
                    completedExercises: viewModel.completedExercisesCount,
                    totalExercises: viewModel.totalExercisesCount
                )
                .padding(.horizontal, DSSpacing.md)
                .id(durationUpdateTrigger) // Force update every second

                ForEach(viewModel.exercises) { workoutExercise in
                    ExerciseCard(
                        workoutExercise: workoutExercise,
                        isKeyboardMode: isKeyboardMode,
                        suggestion: workoutExercise.exercise.map { viewModel.getSuggestion(for: $0.id) } ?? nil,
                        onAddSet: {
                            viewModel.addSet(to: workoutExercise)
                        },
                        onUpdateSet: { set, reps, weight in
                            viewModel.updateSet(set, reps: reps, weight: weight)
                        },
                        onToggleSet: { set in
                            viewModel.toggleSetCompletion(set)
                        },
                        onCompleteAllSets: {
                            withAnimation {
                                viewModel.completeAllSetsForExercise(workoutExercise)
                            }
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
        .scrollDismissesKeyboard(.interactively) // iOS 16+ native scroll-to-dismiss
        .background(DSColors.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview {
    LiftingSessionView()
        .environmentObject(AppDependencies.preview)
}
