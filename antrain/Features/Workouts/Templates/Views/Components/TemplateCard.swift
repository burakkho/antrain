//
//  TemplateCard.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Card component for displaying workout template in list
struct TemplateCard: View {
    let template: WorkoutTemplate
    let onDelete: (() -> Void)?
    let onDuplicate: (() -> Void)?
    let onStartWorkout: (() -> Void)?

    init(
        template: WorkoutTemplate,
        onDelete: (() -> Void)? = nil,
        onDuplicate: (() -> Void)? = nil,
        onStartWorkout: (() -> Void)? = nil
    ) {
        self.template = template
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
        self.onStartWorkout = onStartWorkout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with category badge
            HStack {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: template.category.icon)
                        .font(.caption2)
                    Text(template.category.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(template.category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    template.category.color.opacity(0.15),
                    in: Capsule()
                )

                Spacer()

                // Preset indicator
                if template.isPreset {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            // Template name
            Text(template.name)
                .font(.headline)
                .foregroundStyle(.primary)

            // Metadata row
            HStack(spacing: 16) {
                // Exercise count
                Label {
                    Text("\(template.exerciseCount) \(String(localized: "exercises"))")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "list.bullet")
                }

                // Estimated duration
                Label {
                    Text(template.estimatedDurationFormatted)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "clock")
                }
            }
            .foregroundStyle(.secondary)

            // Last used date (if available)
            if let lastUsed = template.lastUsedAt {
                Text("Last used: \(lastUsed, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        // Leading swipe action: Start Workout
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if let onStartWorkout {
                Button {
                    onStartWorkout()
                } label: {
                    Label(String(localized: "Start"), systemImage: "play.fill")
                }
                .tint(.green)
            }
        }
        // Trailing swipe actions: Delete & Duplicate
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // Delete action (only for non-preset templates)
Label(String(localized: "Delete"), systemImage: "trash")

            // Duplicate action
            if let onDuplicate {
                    Label(String(localized: "Duplicate"), systemImage: "doc.on.doc")
            }
        }
        // Context menu (long press)
        .contextMenu {
            // Start Workout
            if let onStartWorkout {
                Button {
                    onStartWorkout()
                } label: {
                    Label(String(localized: "Start Workout"), systemImage: "play.fill")
                }
            }

            Divider()

            // Duplicate
            if let onDuplicate {
                Button {
                    onDuplicate()
                } label: {
                    Label(String(localized: "Duplicate"), systemImage: "doc.on.doc")
                }
            }

            // Delete (only for non-preset)
            if !template.isPreset, let onDelete {
                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(String(localized: "Delete"), systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("User Template") {
    List {
        TemplateCard(
            template: WorkoutTemplate(
                name: "My Push Day",
                category: .hypertrophy,
                exercises: []
            )
        )
    }
    .listStyle(.plain)
}

#Preview("Preset Template") {
    List {
        TemplateCard(
            template: WorkoutTemplate(
                name: "PPL - Push",
                category: .hypertrophy,
                isPreset: true,
                exercises: []
            )
        )
    }
    .listStyle(.plain)
}
