//
//  TemplateExerciseSelectionView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Step 2: Multi-select exercise picker with reorder
struct TemplateExerciseSelectionView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @Bindable var viewModel: CreateTemplateViewModel

    @State private var showExercisePicker = false
    @State private var allExercises: [Exercise] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Selected exercises count badge
            if !viewModel.selectedExercises.isEmpty {
                selectedCountBadge
                    .padding()
            }

            if isLoading {
                // Loading state
                loadingView
            } else if viewModel.selectedExercises.isEmpty {
                // Empty state
                emptyState
            } else {
                // Selected exercises list (reorderable)
                List {
                    ForEach(viewModel.selectedExercises) { exercise in
                        ExerciseRow(exercise: exercise) {
                            viewModel.removeExercise(exercise)
                        }
                    }
                    .onMove { from, to in
                        viewModel.moveExercises(from: from, to: to)
                    }
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(.active))
            }

            // Add exercises button (sticky at bottom)
            addExercisesButton
                .padding()
                .padding(.bottom, 80) // Extra padding for navigation buttons
        }
        .sheet(isPresented: $showExercisePicker) {
            ExerciseMultiPickerSheet(
                selectedExercises: $viewModel.selectedExercises,
                allExercises: allExercises
            )
        }
        .alert("Error Loading Exercises", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
            Button("Retry") {
                Task {
                    await loadExercises()
                }
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await loadExercises()
        }
    }

    // MARK: - Selected Count Badge

    private var selectedCountBadge: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("\(viewModel.selectedExercises.count) exercises selected")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading exercises...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Exercises Selected")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Tap the button below to add exercises to your template")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Add Exercises Button

    private var addExercisesButton: some View {
        Button {
            showExercisePicker = true
        } label: {
            HStack {
                Image(systemName: viewModel.selectedExercises.isEmpty ? "plus.circle.fill" : "plus.circle")
                Text(viewModel.selectedExercises.isEmpty ? "Add Exercises" : "Add More Exercises")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Load Exercises

    private func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            allExercises = try await dependencies.exerciseRepository.fetchAll()
            print("✅ Loaded \(allExercises.count) exercises")
        } catch {
            print("❌ Failed to load exercises: \(error)")
            errorMessage = "Failed to load exercises. Please check your connection and try again."
        }

        isLoading = false
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: Exercise
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Drag indicator
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text(exercise.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let primary = exercise.primaryMuscleGroup {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(primary.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Exercise Multi Picker Sheet

private struct ExerciseMultiPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExercises: [Exercise]
    let allExercises: [Exercise]

    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedMuscleGroup: MuscleGroup?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding()

                Divider()

                // Filter chips
                filterSection
                    .padding(.vertical, 8)

                Divider()

                // Exercise list
                if allExercises.isEmpty {
                    emptyExercisesView
                } else if filteredExercises.isEmpty {
                    noResultsView
                } else {
                    List {
                        ForEach(filteredExercises) { exercise in
                            ExercisePickerRow(
                                exercise: exercise,
                                isSelected: selectedExercises.contains(where: { $0.id == exercise.id })
                            ) {
                                toggleExercise(exercise)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search exercises", text: $searchText)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Category filters
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty States

    private var emptyExercisesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("No Exercises Available")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Please ensure exercises are loaded in the app")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Results Found")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Filtered Exercises

    private var filteredExercises: [Exercise] {
        var result = allExercises

        // Search filter
        if !searchText.isEmpty {
            result = result.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Muscle group filter
        if let muscle = selectedMuscleGroup {
            result = result.filter { $0.muscleGroups.contains(muscle) }
        }

        return result
    }

    // MARK: - Toggle Exercise

    private func toggleExercise(_ exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }
}

// MARK: - Exercise Picker Row

private struct ExercisePickerRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .green : .secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(exercise.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let primary = exercise.primaryMuscleGroup {
                            Text("•")
                                .foregroundStyle(.tertiary)
                            Text(primary.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                    in: Capsule()
                )
        }
    }
}

// MARK: - Preview

#Preview {
    TemplateExerciseSelectionView(
        viewModel: CreateTemplateViewModel(
            templateRepository: AppDependencies.preview.workoutTemplateRepository,
            exerciseRepository: AppDependencies.preview.exerciseRepository
        )
    )
    .environmentObject(AppDependencies.preview)
}
