import SwiftUI

/// Exercise selection modal with search
struct ExerciseSelectionView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Exercise) -> Void

    @State private var searchText = ""
    @State private var exercises: [Exercise] = []
    @State private var isLoading = false

    // Filter states
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedMuscleGroup: MuscleGroup?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                Divider()

                // Filter chips
                filterSection

                Divider()

                // Exercise list or empty state
                Group {
                    if isLoading {
                        DSLoadingView(message: "Loading exercises...")
                    } else if filteredExercises.isEmpty {
                        DSEmptyState(
                            icon: "magnifyingglass",
                            title: "No Exercises Found",
                            message: searchText.isEmpty && selectedCategory == nil && selectedMuscleGroup == nil
                                ? "Exercise library is empty"
                                : "No exercises match your filters"
                        )
                    } else {
                        exerciseList
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExercises()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.textSecondary)

            TextField("Search exercises", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    DSFilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )

                    ForEach([ExerciseCategory.barbell, .dumbbell, .bodyweight, .weightlifting, .machine, .cable], id: \.self) { category in
                        DSFilterChip(
                            title: category.rawValue.capitalized,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }

            // Muscle group filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    DSFilterChip(
                        title: "All",
                        isSelected: selectedMuscleGroup == nil,
                        action: { selectedMuscleGroup = nil }
                    )

                    ForEach([MuscleGroup.chest, .back, .shoulders, .biceps, .triceps, .quads, .hamstrings, .glutes, .core, .fullBody], id: \.self) { muscle in
                        DSFilterChip(
                            title: muscle.rawValue.capitalized,
                            isSelected: selectedMuscleGroup == muscle,
                            action: {
                                selectedMuscleGroup = selectedMuscleGroup == muscle ? nil : muscle
                            }
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
        .padding(.vertical, DSSpacing.sm)
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        List(filteredExercises) { exercise in
            Button {
                onSelect(exercise)
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(exercise.name)
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textPrimary)

                        Text(exercise.category.rawValue.capitalized)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "plus.circle")
                        .foregroundStyle(DSColors.primary)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Filtered Exercises (AND Logic)

    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            // Search filter
            let matchesSearch = searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)

            // Category filter
            let matchesCategory = selectedCategory == nil || exercise.category == selectedCategory

            // Muscle group filter
            let matchesMuscleGroup = selectedMuscleGroup == nil || exercise.muscleGroups.contains(selectedMuscleGroup!)

            // AND logic: all filters must pass
            return matchesSearch && matchesCategory && matchesMuscleGroup
        }
    }

    // MARK: - Load Exercises

    private func loadExercises() {
        isLoading = true

        Task {
            do {
                exercises = try await appDependencies.exerciseRepository.fetchAll()
            } catch {
                // Handle error
                exercises = []
            }
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    ExerciseSelectionView { _ in }
        .environmentObject(AppDependencies.preview)
}
