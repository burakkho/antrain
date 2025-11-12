//
//  TemplateQuickSelectorView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Quick template selector sheet for starting workouts
struct TemplateQuickSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dependencies: AppDependencies

    let onSelect: (WorkoutTemplate) -> Void

    @State private var viewModel: TemplatesViewModel?
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                if let viewModel, !viewModel.templates.isEmpty {
                    searchBar
                        .padding()
                }

                // Templates list
                Group {
                    if let viewModel {
                        if viewModel.isLoading {
                            loadingView
                        } else if viewModel.isEmpty {
                            emptyView
                        } else if filteredTemplates.isEmpty {
                            noResultsView
                        } else {
                            templatesList
                        }
                    } else {
                        loadingView
                    }
                }
            }
            .navigationTitle(Text("Select Template"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
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

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search templates", text: $searchText)
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
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading templates...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Templates")
                .font(.headline)

            Text("Create a template first to use this feature")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - No Results View

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No templates found")
                .font(.headline)

            Button(String(localized: "Clear Search")) {
                searchText = ""
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    // MARK: - Templates List

    private var templatesList: some View {
        List {
            // Recent templates (last 3 used)
            if !searchText.isEmpty == false, let recentTemplates = recentTemplates, !recentTemplates.isEmpty {
                Section {
                    ForEach(recentTemplates) { template in
                        TemplateQuickRow(template: template) {
                            onSelect(template)
                            dismiss()
                        }
                    }
                } header: {
                    Text("Recently Used")
                }
            }

            // All templates (grouped by user/preset)
            if let viewModel {
                if !viewModel.userTemplates.isEmpty {
                    Section {
                        ForEach(viewModel.userTemplates.sorted(by: WorkoutTemplate.compare)) { template in
                            TemplateQuickRow(template: template) {
                                onSelect(template)
                                dismiss()
                            }
                        }
                    } header: {
                        Text("My Templates")
                    }
                }

                if !viewModel.presetTemplates.isEmpty {
                    Section {
                        ForEach(viewModel.presetTemplates.sorted(by: WorkoutTemplate.compare)) { template in
                            TemplateQuickRow(template: template) {
                                onSelect(template)
                                dismiss()
                            }
                        }
                    } header: {
                        Text("Presets")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Computed Properties

    private var filteredTemplates: [WorkoutTemplate] {
        guard let viewModel else { return [] }

        if searchText.isEmpty {
            return viewModel.templates
        }

        return viewModel.templates.filter { template in
            template.name.localizedCaseInsensitiveContains(searchText) ||
            template.category.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var recentTemplates: [WorkoutTemplate]? {
        guard let viewModel else { return nil }

        let withLastUsed = viewModel.templates.filter { $0.lastUsedAt != nil }
        let sorted = withLastUsed.sorted { ($0.lastUsedAt ?? Date.distantPast) > ($1.lastUsedAt ?? Date.distantPast) }
        return Array(sorted.prefix(3))
    }
}

// MARK: - Template Quick Row

private struct TemplateQuickRow: View {
    let template: WorkoutTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: template.category.icon)
                    .font(.title3)
                    .foregroundStyle(template.category.color)
                    .frame(width: 40, height: 40)
                    .background(template.category.color.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(template.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.tertiary)

                        Text("\(template.exerciseCount) exercises")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if template.isPreset {
                            Text("•")
                                .foregroundStyle(.tertiary)
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TemplateQuickSelectorView { template in
        print("Selected: \(template.name)")
    }
    .environmentObject(AppDependencies.preview)
}
