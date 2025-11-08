//
//  ProgramCard.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Card view for displaying a training program
struct ProgramCard: View {
    let program: TrainingProgram
    var isActive: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Category icon
                Image(systemName: program.category.iconName)
                    .font(.title2)
                    .foregroundStyle(program.category == .powerlifting ? .red :
                                   program.category == .bodybuilding ? .blue :
                                   program.category == .strengthTraining ? .orange : .green)

                VStack(alignment: .leading, spacing: 2) {
                    Text(program.name)
                        .font(.headline)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(program.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)

                        Text(program.difficulty.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            // Description
            if let description = program.programDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Stats
            HStack(spacing: 16) {
                // Duration
                Label {
                    Text("\(program.durationWeeks) weeks")
                        .font(.caption)
                } icon: {
                    Image(systemName: "calendar")
                }

                // Training days
                Label {
                    Text(String(format: "%.0f days/week", program.trainingDaysPerWeek))
                        .font(.caption)
                } icon: {
                    Image(systemName: "figure.strengthtraining.traditional")
                }
            }
            .foregroundStyle(.secondary)

            // Preset badge
            if !program.isCustom {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("Preset Program")
                        .font(.caption2)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}

#Preview("Custom Program") {
    ProgramCard(
        program: TrainingProgram(
            name: "My Custom PPL",
            programDescription: "Push/Pull/Legs split designed for hypertrophy",
            category: .bodybuilding,
            difficulty: .intermediate,
            durationWeeks: 12,
            isCustom: true
        )
    )
    .padding()
}

#Preview("Preset Program - Active") {
    ProgramCard(
        program: TrainingProgram(
            name: "Starting Strength",
            programDescription: "Classic linear progression program for beginners",
            category: .strengthTraining,
            difficulty: .beginner,
            durationWeeks: 12,
            isCustom: false
        ),
        isActive: true
    )
    .padding()
}
