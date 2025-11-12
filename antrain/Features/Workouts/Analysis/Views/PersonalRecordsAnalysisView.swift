import SwiftUI

/// Personal Records Analysis view with stats, filters, and expandable PR cards
struct PersonalRecordsAnalysisView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"
    @State private var viewModel: PersonalRecordsViewModel?
    @State private var expandedExerciseName: String?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading {
DSLoadingView(message: "Loading personal records...")
                } else if let errorMessage = viewModel.errorMessage {
                    DSErrorView(
                        errorMessage: LocalizedStringKey(errorMessage),
                        retryAction: {
                            Task {
                                await viewModel.loadData()
                            }
                        }
                    )
                } else {
                    contentView(viewModel: viewModel)
                }
            } else {
                DSLoadingView(message: "Loading personal records...")
            }
        }
        .navigationTitle(Text("Personal Records"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if viewModel == nil {
                viewModel = PersonalRecordsViewModel(
                    personalRecordRepository: appDependencies.personalRecordRepository,
                    exerciseRepository: appDependencies.exerciseRepository
                )
                Task {
                    await viewModel?.loadData()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
            Task {
                await viewModel?.loadData()
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(viewModel: PersonalRecordsViewModel) -> some View {
        if viewModel.allPRs.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: DSSpacing.md) {
                    // Stats Section
                    statsSection(viewModel: viewModel)

                    // Filters Section
                    filtersSection(viewModel: viewModel)

                    // PR Cards Section
                    if viewModel.filteredPRs.isEmpty {
                        filteredEmptyState
                    } else {
                        prCardsSection(viewModel: viewModel)
                    }
                }
                .padding(.vertical, DSSpacing.md)
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Empty States

    private var emptyState: some View {
        DSEmptyState(
            icon: "trophy",
            title: "No Personal Records",
            message: "Complete lifting workouts to start tracking your PRs!"
        )
    }

    private var filteredEmptyState: some View {
        DSEmptyState(
            icon: "magnifyingglass",
            title: "No Results",
            message: "Try adjusting your filters or search terms."
        )
        .padding(.top, DSSpacing.xl)
    }

    // MARK: - Stats Section

    private func statsSection(viewModel: PersonalRecordsViewModel) -> some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                StatCard(
                    title: "Total PRs",
                    value: "\(viewModel.totalPRsCount)",
                    icon: "trophy.fill",
                    color: DSColors.primary
                )

                StatCard(
                    title: "Last 30 Days",
                    value: "\(viewModel.last30DaysPRs)",
                    icon: "calendar",
                    color: .orange
                )
            }

            HStack(spacing: DSSpacing.sm) {
                StatCard(
                    title: "Last 7 Days",
                    value: "\(viewModel.last7DaysPRs)",
                    icon: "flame.fill",
                    color: .red
                )

                StatCard(
                    title: "Avg/Week",
                    value: String(format: "%.1f", viewModel.averagePRsPerWeek),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Filters Section

    private func filtersSection(viewModel: PersonalRecordsViewModel) -> some View {
        VStack(spacing: DSSpacing.sm) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DSColors.textTertiary)

                TextField("Search exercises...", text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ))
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textPrimary)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColors.textTertiary)
                    }
                }
            }
            .padding(DSSpacing.sm)
            .background {
                RoundedRectangle(cornerRadius: DSCornerRadius.md)
                    .fill(.regularMaterial)
            }
            .padding(.horizontal, DSSpacing.md)

            // Date range picker
            Picker("Date Range", selection: Binding(
                get: { viewModel.selectedDateRange },
                set: { viewModel.selectedDateRange = $0 }
            )) {
                ForEach(DateRange.allCases) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DSSpacing.md)

            // Muscle group filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    MuscleGroupFilterChip(
                        label: "All",
                        isSelected: viewModel.selectedMuscleGroup == nil,
                        onTap: { viewModel.selectedMuscleGroup = nil }
                    )

                    ForEach(MuscleGroup.allCases, id: \.self) { muscleGroup in
                        MuscleGroupFilterChip(
                            label: muscleGroup.displayName,
                            isSelected: viewModel.selectedMuscleGroup == muscleGroup,
                            onTap: { viewModel.selectedMuscleGroup = muscleGroup }
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    // MARK: - PR Cards Section

    private func prCardsSection(viewModel: PersonalRecordsViewModel) -> some View {
        LazyVStack(spacing: DSSpacing.sm) {
            ForEach(viewModel.sortedExerciseNames, id: \.self) { exerciseName in
                if let prHistory = viewModel.groupedPRs[exerciseName] {
                    ExercisePRCard(
                        exerciseName: exerciseName,
                        prHistory: prHistory,
                        weightUnit: weightUnit,
                        isExpanded: expandedExerciseName == exerciseName,
                        onTap: {
                            withAnimation {
                                if expandedExerciseName == exerciseName {
                                    expandedExerciseName = nil
                                } else {
                                    expandedExerciseName = exerciseName
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .navigationDestination(for: UUID.self) { workoutId in
            WorkoutDetailWrapper(workoutId: workoutId)
                .environmentObject(appDependencies)
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(DSTypography.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(DSColors.textPrimary)

            Text(title)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

// MARK: - Muscle Group Filter Chip

private struct MuscleGroupFilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(DSTypography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : DSColors.textPrimary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background {
                    Capsule()
                        .fill(isSelected ? DSColors.primary : Color.primary.opacity(0.1))
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PersonalRecordsAnalysisView()
            .environmentObject(AppDependencies.preview)
    }
}
