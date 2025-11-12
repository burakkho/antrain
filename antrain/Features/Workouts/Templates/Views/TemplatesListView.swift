//
//  TemplatesListView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Main view for displaying workout templates list
struct TemplatesListView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: TemplatesViewModel?
    @State private var showCreateTemplate = false
    @State private var templateToDelete: WorkoutTemplate?
    @State private var templateToDuplicate: WorkoutTemplate?
    @State private var duplicateName = ""
    @State private var searchText = ""

    // Template deletion safety
    @State private var showUsageWarning = false
    @State private var templateUsagePrograms: [String] = []

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.isEmpty {
                        emptyStateView
                    } else {
                        templatesList(viewModel: viewModel)
                    }
                } else {
                    loadingView
                }
            }
            .navigationTitle(Text("Templates"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateTemplate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTemplate) {
                CreateTemplateFlow {
                    Task {
                        await viewModel?.fetchTemplates()
                    }
                }
            }
            .alert(Text("Delete Template"), isPresented: .constant(templateToDelete != nil)) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    handleTemplateDeletion()
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete '\(template.name)'?")
                }
            }
            .alert(Text("Cannot Delete Template"), isPresented: $showUsageWarning) {
                Button("OK", role: .cancel) {
                    templateUsagePrograms = []
                }
            } message: {
                usageWarningMessage
            }
            .alert(Text("Duplicate Template"), isPresented: .constant(templateToDuplicate != nil)) {
                TextField("Template name", text: $duplicateName)
                Button("Cancel", role: .cancel) {
                    resetDuplicateState()
                }
                Button(String(localized: "Duplicate")) {
                    handleTemplateDuplication()
                }
            } message: {
                if let template = templateToDuplicate {
                    Text("Create a copy of '\(template.name)'")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = TemplatesViewModel(
                        repository: dependencies.workoutTemplateRepository,
                        trainingProgramRepository: dependencies.trainingProgramRepository
                    )
                    await viewModel?.fetchTemplates()
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text(String(localized: "Loading templates..."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        DSEmptyState(
            icon: "doc.text.magnifyingglass",
            title: "No Templates Yet",
            message: "Create your first workout template to get started",
            actionTitle: "Create Template",
            action: { showCreateTemplate = true }
        )
    }

    // MARK: - Templates List

    @ViewBuilder
    private func templatesList(viewModel: TemplatesViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar with debouncing
            DSSearchField(
                placeholder: "Search templates",
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ),
                debounceInterval: .milliseconds(300)
            )
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Category filter
            TemplateCategoryFilterView(
                selectedCategory: viewModel.selectedCategory,
                onSelect: { category in
                    viewModel.selectCategory(category)
                }
            )
            .padding(.vertical, 8)

            // Templates list
            if viewModel.isFilteredEmpty {
                filteredEmptyStateView
            } else {
                List {
                    // User Templates Section
                    if !viewModel.userTemplates.isEmpty {
                        Section {
                            ForEach(viewModel.userTemplates.sorted(by: WorkoutTemplate.compare)) { template in
                                NavigationLink {
                                    TemplateDetailView(template: template)
                                } label: {
                                    TemplateCard(
                                        template: template,
                                        onDelete: {
                                            templateToDelete = template
                                        },
                                        onDuplicate: {
                                            templateToDuplicate = template
                                            duplicateName = "\(template.name) \(String(localized: "Copy"))"
                                        },
                                        onStartWorkout: {
                                            workoutManager.startWorkoutFromTemplate(template)
                                            dismiss()
                                        }
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("My Templates")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }

                    // Preset Templates Section
                    if !viewModel.presetTemplates.isEmpty {
                        Section {
                            ForEach(viewModel.presetTemplates.sorted(by: WorkoutTemplate.compare)) { template in
                                NavigationLink {
                                    TemplateDetailView(template: template)
                                } label: {
                                    TemplateCard(
                                        template: template,
                                        onDelete: nil, // Cannot delete presets
                                        onDuplicate: {
                                            templateToDuplicate = template
                                            duplicateName = "\(template.name) \(String(localized: "Copy"))"
                                        },
                                        onStartWorkout: {
                                            workoutManager.startWorkoutFromTemplate(template)
                                            dismiss()
                                        }
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("Preset Templates")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }

    // MARK: - Filtered Empty State

    private var filteredEmptyStateView: some View {
        DSEmptyState(
            icon: "magnifyingglass",
            title: "No Templates Found",
            message: "No templates match your current filter or search",
            actionTitle: "Clear Filter",
            action: { viewModel?.clearFilter() }
        )
    }

    // MARK: - Alert Helpers

    private var usageWarningMessage: Text {
        if templateUsagePrograms.count == 1 {
            return Text("This template is used in the program '\(templateUsagePrograms[0])'. Remove it from the program first.")
        } else {
            let programList = templateUsagePrograms.joined(separator: ", ")
            return Text("This template is used in \(templateUsagePrograms.count) programs: \(programList). Remove it from these programs first.")
        }
    }

    private func handleTemplateDeletion() {
        guard let template = templateToDelete else { return }

        Task {
            // Check if template is used in programs first
            let programNames = await viewModel?.checkTemplateUsage(template) ?? []

            if !programNames.isEmpty {
                // Template is used - show warning
                templateUsagePrograms = programNames
                showUsageWarning = true
            } else {
                // Safe to delete
                await viewModel?.deleteTemplate(template)
            }
        }
        templateToDelete = nil
    }

    private func handleTemplateDuplication() {
        guard let template = templateToDuplicate, !duplicateName.isEmpty else {
            resetDuplicateState()
            return
        }

        Task {
            await viewModel?.duplicateTemplate(template, newName: duplicateName)
        }
        resetDuplicateState()
    }

    private func resetDuplicateState() {
        templateToDuplicate = nil
        duplicateName = ""
    }
}

// MARK: - Preview

#Preview("Templates List") {
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    NavigationStack {
        TemplatesListView()
            .environmentObject(AppDependencies.preview)
            .environment(workoutManager)
    }
}

#Preview("Empty State") {
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    NavigationStack {
        DSEmptyState(
            icon: "doc.text.magnifyingglass",
            title: "No Templates Yet",
            message: "Create your first workout template to get started",
            actionTitle: "Create Template",
            action: { }
        )
    }
    .environment(workoutManager)
}
