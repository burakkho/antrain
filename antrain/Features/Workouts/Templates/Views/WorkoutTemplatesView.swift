import SwiftUI

/// Templates view for managing and browsing workout templates
struct WorkoutTemplatesView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: TemplatesViewModel?

    // Sheet states
    @State private var showTemplateSelector = false
    @State private var showCreateTemplate = false
    @State private var selectedTemplate: WorkoutTemplate?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
DSLoadingView(message: "Loading templates...")
                    } else if let error = viewModel.error {
                        DSErrorView(
                            errorMessage: LocalizedStringKey(error.localizedDescription),
                            retryAction: {
                                Task {
                                    await viewModel.fetchTemplates()
                                }
                            }
                        )
                    } else {
                        contentView(viewModel: viewModel)
                    }
                } else {
                    DSLoadingView(message: "Loading templates...")
                }
            }
            .navigationTitle(Text("Templates"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateTemplate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showTemplateSelector) {
                TemplateQuickSelectorView { template in
                    selectedTemplate = template
                    workoutManager.showFullScreen = true
                }
                .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showCreateTemplate) {
                CreateTemplateFlow {
                    Task {
                        await viewModel?.fetchTemplates()
                    }
                }
                .environmentObject(appDependencies)
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TemplatesViewModel(
                        repository: appDependencies.workoutTemplateRepository,
                        trainingProgramRepository: appDependencies.trainingProgramRepository
                    )
                    Task {
                        await viewModel?.fetchTemplates()
                    }
                }
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(viewModel: TemplatesViewModel) -> some View {
        if viewModel.templates.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    // Quick Actions
                    quickActionsSection

                    // Search Bar
                    searchSection(viewModel: viewModel)

                    // Category Filter
                    categoryFilterSection(viewModel: viewModel)

                    // Templates List
                    templatesListSection(viewModel: viewModel)
                }
                .padding(.vertical, DSSpacing.md)
            }
            .refreshable {
                await viewModel.fetchTemplates()
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick Actions")
                .font(DSTypography.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, DSSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    TemplateQuickCard(
                        icon: "play.fill",
                        title: "Start",
                        subtitle: "From Template"
                    ) {
                        showTemplateSelector = true
                    }

                    TemplateQuickCard(
                        icon: "plus.circle.fill",
                        title: "Create",
                        subtitle: "New Template"
                    ) {
                        showCreateTemplate = true
                    }

                    TemplateQuickCard(
                        icon: "dumbbell.fill",
                        title: "Quick Start",
                        subtitle: "Empty Workout"
                    ) {
                        workoutManager.showFullScreen = true
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    // MARK: - Search Section

    private func searchSection(viewModel: TemplatesViewModel) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.textSecondary)

            TextField("Search templates...", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ))
            .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Category Filter Section

    private func categoryFilterSection(viewModel: TemplatesViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(TemplateCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    // MARK: - Templates List Section

    @ViewBuilder
    private func templatesListSection(viewModel: TemplatesViewModel) -> some View {
        if viewModel.filteredTemplates.isEmpty {
            ContentUnavailableView {
                Label(String(localized: "No Templates Found"), systemImage: "doc.text.magnifyingglass")
            } description: {
                Text("Try adjusting your search or filter")
            }
            .padding(.top, DSSpacing.xl)
        } else {
            LazyVStack(spacing: DSSpacing.sm) {
                ForEach(viewModel.filteredTemplates) { template in
                    NavigationLink(destination: TemplateDetailView(template: template)) {
                        TemplateCard(template: template)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        DSEmptyState(
            icon: "doc.text",
            title: "No Templates Yet",
            message: "Create your first template to save time on future workouts.",
            actionTitle: "Create Template",
            action: {
                showCreateTemplate = true
            }
        )
    }
}

// MARK: - Template Quick Card

private struct TemplateQuickCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(DSColors.primary)
                    .frame(height: 32)

                VStack(spacing: 2) {
                    Text(title)
                        .font(DSTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColors.textPrimary)

                    Text(subtitle)
                        .font(DSTypography.caption2)
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .frame(width: 100)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? DSColors.primary : DSColors.cardBackground)
                }
                .foregroundStyle(isSelected ? .white : DSColors.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    WorkoutTemplatesView()
        .environmentObject(AppDependencies.preview)
}
