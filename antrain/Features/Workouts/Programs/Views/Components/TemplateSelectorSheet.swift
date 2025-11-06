//
//  TemplateSelectorSheet.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Sheet for selecting a workout template
struct TemplateSelectorSheet: View {
    @EnvironmentObject private var deps: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var templates: [WorkoutTemplate] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @Binding var selectedTemplate: WorkoutTemplate?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading templates...")
                } else if templates.isEmpty {
                    emptyState
                } else {
                    templateList
                }
            }
            .navigationTitle("Select Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if selectedTemplate != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            selectedTemplate = nil
                            dismiss()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search templates")
            .onAppear {
                loadTemplates()
            }
        }
    }

    @ViewBuilder
    private var templateList: some View {
        List(filteredTemplates) { template in
            Button {
                selectedTemplate = template
                dismiss()
            } label: {
                templateRow(template)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func templateRow(_ template: WorkoutTemplate) -> some View {
        HStack(spacing: 12) {
            // Selection indicator
            Image(systemName: selectedTemplate?.id == template.id ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(selectedTemplate?.id == template.id ? Color.accentColor : .secondary)

            // Template info
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Label("\(template.exerciseCount) exercises", systemImage: "dumbbell.fill")
                        .font(.caption)

                    if template.estimatedDuration > 0 {
                        Label(formatDuration(template.estimatedDuration), systemImage: "clock")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)

                // Exercise preview
                if !template.exercises.isEmpty {
                    Text(template.exercises.prefix(3).map { $0.exerciseName }.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Preset badge
            if template.isPreset {
                Text("Preset")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    }
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(selectedTemplate?.id == template.id ? Color.accentColor.opacity(0.05) : Color.clear)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Templates", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Create a template in the Templates tab to use it in programs")
        }
    }

    private var filteredTemplates: [WorkoutTemplate] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter { template in
            template.name.localizedCaseInsensitiveContains(searchText) ||
            template.exercises.contains { $0.exerciseName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func loadTemplates() {
        Task {
            do {
                templates = try await deps.workoutTemplateRepository.fetchAllTemplates()
                isLoading = false
            } catch {
                print("Error loading templates: \(error)")
                isLoading = false
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
    }
}

#Preview {
    TemplateSelectorSheet(selectedTemplate: .constant(nil))
        .environmentObject(AppDependencies.preview)
}
