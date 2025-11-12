//
//  ProgramsListView.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Main view for browsing preset training programs
struct ProgramsListView: View {
    @EnvironmentObject private var deps: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProgramsListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(Text("Training Programs"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Done")) {
                    dismiss()
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProgramsListViewModel(
                    repository: deps.trainingProgramRepository
                )
                Task {
                    await viewModel?.loadPrograms()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToProgramsTab"))) { _ in
            // Dismiss this list when program is activated
            dismiss()
        }
    }

    @ViewBuilder
    private func contentView(viewModel: ProgramsListViewModel) -> some View {
        if viewModel.isLoading {
            ProgressView("Loading programs...")
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView {
                Label(String(localized: "Error Loading Programs"), systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button(String(localized: "Try Again")) {
                    Task {
                        await viewModel.loadPrograms()
                    }
                }
            }
        } else if !viewModel.hasPrograms {
            emptyState
        } else {
            programsList(viewModel: viewModel)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No Programs Available"), systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("Preset programs will appear here once loaded")
        } actions: {
            Button(String(localized: "Reload")) {
                Task {
                    await viewModel?.loadPrograms()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private func programsList(viewModel: ProgramsListViewModel) -> some View {
        List {
            // Category filter
            categoryFilter(viewModel: viewModel)

            // Search with debouncing
            Section {
                DSSearchField(
                    placeholder: "Search programs...",
                    text: Binding(
                        get: { viewModel.searchQuery },
                        set: { viewModel.searchQuery = $0 }
                    ),
                    debounceInterval: .milliseconds(300)
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listRowBackground(Color.clear)

            // User Programs
            if !viewModel.filteredUserPrograms.isEmpty {
                Section("My Programs") {
                    ForEach(viewModel.filteredUserPrograms) { program in
                        NavigationLink {
                            ProgramDetailView(program: program)
                        } label: {
                            ProgramCard(program: program)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                let program = viewModel.filteredUserPrograms[index]
                                await viewModel.deleteProgram(program)
                            }
                        }
                    }
                }
            }

            // Preset Programs
            if !viewModel.filteredPresetPrograms.isEmpty {
                Section("Preset Programs") {
                    ForEach(viewModel.filteredPresetPrograms) { program in
                        NavigationLink {
                            ProgramDetailView(program: program)
                        } label: {
                            ProgramCard(program: program)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadPrograms()
        }
    }

    @ViewBuilder
    private func categoryFilter(viewModel: ProgramsListViewModel) -> some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All
                    FilterChip(
                        title: "All",
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectCategory(nil)
                    }

                    // Categories
                    ForEach(ProgramCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

/// Filter chip component
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
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                }
                .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    NavigationStack {
        ProgramsListView()
            .environmentObject(AppDependencies.preview)
            .environment(workoutManager)
    }
}
