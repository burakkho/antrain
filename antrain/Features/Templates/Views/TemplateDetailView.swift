//
//  TemplateDetailView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Detailed view of a workout template
struct TemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @EnvironmentObject private var dependencies: AppDependencies

    let template: WorkoutTemplate

    @State private var viewModel: TemplateDetailViewModel?
    @State private var showDeleteConfirmation = false
    @State private var showDuplicateSheet = false
    @State private var duplicateName = ""
    @State private var showEditView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let viewModel {
                    // Template Header
                    templateHeader(template: viewModel.template)

                    Divider()

                    // Exercises Section
                    exercisesSection(viewModel: viewModel)

                    Divider()

                    // Metadata Section
                    metadataSection(template: viewModel.template)

                    // Action Buttons
                    actionButtons(viewModel: viewModel)
                }
            }
            .padding()
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel?.isPreset == false {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showEditView = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button {
                            showDuplicateSheet = true
                            duplicateName = "\(template.name) \(String(localized: "Copy"))"
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showDuplicateSheet = true
                        duplicateName = "\(template.name) \(String(localized: "Copy"))"
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                }
            }
        }
        .alert("Delete Template", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel?.deleteTemplate()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(template.name)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showDuplicateSheet) {
            duplicateTemplateSheet
        }
        .sheet(isPresented: $showEditView) {
            if let viewModel {
                CreateTemplateFlow(editingTemplate: viewModel.template) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = TemplateDetailViewModel(
                    template: template,
                    repository: dependencies.workoutTemplateRepository
                )
            }
        }
    }

    // MARK: - Template Header

    @ViewBuilder
    private func templateHeader(template: WorkoutTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: template.category.icon)
                        .font(.subheadline)
                    Text(template.category.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(template.category.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    template.category.color.opacity(0.15),
                    in: Capsule()
                )

                if template.isPreset {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("Preset")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Color.yellow.opacity(0.15),
                        in: Capsule()
                    )
                }
            }

            // Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "list.bullet",
                    value: "\(template.exerciseCount)",
                    label: String(localized: "exercises")
                )

                StatItem(
                    icon: "clock",
                    value: template.estimatedDurationFormatted,
                    label: String(localized: "duration")
                )
            }
        }
    }

    // MARK: - Exercises Section

    @ViewBuilder
    private func exercisesSection(viewModel: TemplateDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises")
                .font(.headline)

            if viewModel.sortedExercises.isEmpty {
                Text("No exercises added yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.sortedExercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseRow(exercise: exercise, index: index + 1)
                    }
                }
            }
        }
    }

    // MARK: - Metadata Section

    @ViewBuilder
    private func metadataSection(template: WorkoutTemplate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                MetadataRow(
                    label: "Created",
                    value: template.createdAt.formatted(date: .abbreviated, time: .omitted)
                )

                if let lastUsed = template.lastUsedAt {
                    MetadataRow(
                        label: "Last Used",
                        value: lastUsed.formatted(date: .abbreviated, time: .omitted)
                    )
                } else {
                    MetadataRow(
                        label: "Last Used",
                        value: "Never"
                    )
                }

                MetadataRow(
                    label: "Times Used",
                    value: "\(template.usageCount)"
                )
            }
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private func actionButtons(viewModel: TemplateDetailViewModel) -> some View {
        VStack(spacing: 12) {
            // Start Workout button
            Button {
                workoutManager.showFullScreen = true
            } label: {
                Label("Start Workout", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top)
    }

    // MARK: - Duplicate Sheet

    private var duplicateTemplateSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Template name", text: $duplicateName)
                } header: {
                    Text("New Template Name")
                } footer: {
                    Text("This will create a copy of '\(template.name)' that you can customize.")
                }
            }
            .navigationTitle("Duplicate Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDuplicateSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Duplicate") {
                        Task {
                            try? await viewModel?.duplicateTemplate(newName: duplicateName)
                            showDuplicateSheet = false
                        }
                    }
                    .disabled(duplicateName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Supporting Components

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ExerciseRow: View {
    let exercise: TemplateExercise
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // Exercise number
            Text("\(index)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                // Exercise name
                Text(exercise.exerciseName)
                    .font(.body)
                    .fontWeight(.medium)

                // Configuration
                Text(exercise.configurationFormatted)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Notes (if any)
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .italic()
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TemplateDetailView(
            template: WorkoutTemplate(
                name: "PPL - Push",
                category: .hypertrophy,
                isPreset: true,
                exercises: []
            )
        )
    }
    .environmentObject(AppDependencies.preview)
}
