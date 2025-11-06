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
                        prRepository: appDependencies.prRepository,
                        prDetectionService: appDependencies.prDetectionService
                    )
                    viewModel = vm
                    Task { await vm.loadData() }
                }
            }
        }
    }

    // MARK: - Content View (Native List Style)

    @ViewBuilder
    private func contentView(viewModel: WorkoutSummaryViewModel) -> some View {
        List {
            // PR Detection Section
            if viewModel.hasNewPRs {
                prSection(viewModel: viewModel)
            }

            // Main Stats
            statsSection(viewModel: viewModel)

            // Comparison (if available)
            if viewModel.hasPreviousWorkout {
                comparisonSection(viewModel: viewModel)
            }

            // Muscle Groups
            if !viewModel.muscleGroupStats.isEmpty {
                muscleGroupSection(viewModel: viewModel)
            }

            // Exercise Details
            exerciseDetailsSection(viewModel: viewModel)

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

    // MARK: - PR Section (Native)

    @ViewBuilder
    private func prSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            ForEach(viewModel.detectedPRs, id: \.id) { pr in
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(pr.exerciseName)
                            .font(.body)

                        Text("\(Int(pr.actualWeight)) kg × \(pr.reps)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("New PR")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.yellow)

                        Text("\(Int(pr.estimated1RM)) kg 1RM")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Personal Records")
        }
    }

    // MARK: - Stats Section (Native Grid)

    @ViewBuilder
    private func statsSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            VStack(spacing: 12) {
                // Row 1
                HStack(spacing: 12) {
                    statBox(title: "Exercises", value: "\(viewModel.exerciseCount)", icon: "dumbbell.fill")
                    statBox(title: "Sets", value: "\(viewModel.totalSets)", icon: "list.number")
                }

                // Row 2
                HStack(spacing: 12) {
                    statBox(title: "Duration", value: viewModel.durationDisplay, icon: "clock.fill")
                    statBox(title: "Volume", value: String(format: "%.0f kg", viewModel.totalVolume), icon: "scalemass.fill")
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        } header: {
            Text("Overview")
        }
    }

    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Comparison Section

    @ViewBuilder
    private func comparisonSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            if let volumeChange = viewModel.volumeChange {
                comparisonRow(
                    title: "Volume",
                    value: String(format: "%+.0f kg", volumeChange),
                    isPositive: volumeChange > 0
                )
            }

            if let comparison = viewModel.workoutComparison {
                comparisonRow(
                    title: "Sets",
                    value: "\(comparison.setsChange > 0 ? "+" : "")\(comparison.setsChange)",
                    isPositive: comparison.setsChange > 0
                )

                comparisonRow(
                    title: "Duration",
                    value: formatDurationChange(comparison.durationChange),
                    isPositive: comparison.durationChange < 0
                )
            }
        } header: {
            Label("vs Last Workout", systemImage: "chart.line.uptrend.xyaxis")
        }
    }

    private func comparisonRow(title: String, value: String, isPositive: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Label {
                Text(value)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .imageScale(.small)
            }
            .foregroundStyle(isPositive ? .green : .red)
        }
    }

    // MARK: - Muscle Group Section

    @ViewBuilder
    private func muscleGroupSection(viewModel: WorkoutSummaryViewModel) -> some View {
        Section {
            ForEach(viewModel.muscleGroupStats.prefix(5), id: \.muscleGroup) { stat in
                HStack {
                    Text(stat.muscleGroup.displayName)
                        .foregroundStyle(.primary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f kg", stat.volume))
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text("\(stat.sets) sets")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }

    // MARK: - Exercise Details

    @ViewBuilder
    private func exerciseDetailsSection(viewModel: WorkoutSummaryViewModel) -> some View {
        ForEach(exercises) { workoutExercise in
            Section {
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("Set \(index + 1)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)

                        Text("\(set.reps)")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 30, alignment: .trailing)

                        Text("×")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("\(Int(set.weight)) kg")
                            .font(.body)
                            .fontWeight(.medium)

                        Spacer()

                        if set.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .imageScale(.small)
                        }
                    }
                }

                // Total Volume
                HStack {
                    Text("Total Volume")
                        .font(.callout)
                        .fontWeight(.medium)

                    Spacer()

                    Text(String(format: "%.0f kg", workoutExercise.sets.reduce(0.0) { $0 + $1.volume }))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            } header: {
                Text(workoutExercise.exercise?.name ?? "Unknown")
            }
        }
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
        // Note: Don't call viewModel.saveWorkout() here!
        // The onSave callback (from LiftingSessionView) already handles saving.
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

    // MARK: - Helpers

    private func formatDurationChange(_ duration: TimeInterval) -> String {
        let minutes = Int(abs(duration)) / 60
        let sign = duration < 0 ? "-" : "+"
        return "\(sign)\(minutes) min"
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
