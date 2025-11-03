//
//  TemplatesListView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Main view for displaying workout templates list
struct TemplatesListView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: TemplatesViewModel?
    @State private var showCreateTemplate = false
    @State private var templateToDelete: WorkoutTemplate?
    @State private var templateToDuplicate: WorkoutTemplate?
    @State private var duplicateName = ""
    @State private var searchText = ""

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
            .navigationTitle("Templates")
            .toolbar {
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
            .alert("Delete Template", isPresented: .constant(templateToDelete != nil)) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        Task {
                            await viewModel?.deleteTemplate(template)
                        }
                    }
                    templateToDelete = nil
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete '\(template.name)'?")
                }
            }
            .alert("Duplicate Template", isPresented: .constant(templateToDuplicate != nil)) {
                TextField("Template name", text: $duplicateName)
                Button("Cancel", role: .cancel) {
                    templateToDuplicate = nil
                    duplicateName = ""
                }
                Button("Duplicate") {
                    if let template = templateToDuplicate, !duplicateName.isEmpty {
                        Task {
                            await viewModel?.duplicateTemplate(template, newName: duplicateName)
                        }
                    }
                    templateToDuplicate = nil
                    duplicateName = ""
                }
            } message: {
                if let template = templateToDuplicate {
                    Text("Create a copy of '\(template.name)'")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = TemplatesViewModel(repository: dependencies.workoutTemplateRepository)
                    await viewModel?.fetchTemplates()
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading templates...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Templates Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your first workout template to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showCreateTemplate = true
            } label: {
                Label("Create Template", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Templates List

    @ViewBuilder
    private func templatesList(viewModel: TemplatesViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search templates", text: $viewModel.searchText)
                    .autocorrectionDisabled()

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                            ForEach(viewModel.userTemplates.sorted()) { template in
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
                                            duplicateName = "\(template.name) Copy"
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
                            ForEach(viewModel.presetTemplates.sorted()) { template in
                                NavigationLink {
                                    TemplateDetailView(template: template)
                                } label: {
                                    TemplateCard(
                                        template: template,
                                        onDelete: nil, // Cannot delete presets
                                        onDuplicate: {
                                            templateToDuplicate = template
                                            duplicateName = "\(template.name) Copy"
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
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No templates in this category")
                .font(.headline)

            Button("Clear Filter") {
                viewModel?.clearFilter()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    TemplatesListView()
        .environment(AppDependencies.preview)
}
