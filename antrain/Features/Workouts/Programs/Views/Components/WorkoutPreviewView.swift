//
//  WorkoutPreviewView.swift
//  antrain
//
//  Workout preview for program days
//

import SwiftUI

/// Preview view for a program day's workout
struct WorkoutPreviewView: View {
    let programDay: ProgramDay
    let template: WorkoutTemplate
    let weekModifier: Double

    var body: some View {
        List {
            // Day info section
            Section {
                if let notes = programDay.notes {
                    Label {
                        Text(notes)
                            .font(.body)
                    } icon: {
                        Image(systemName: "note.text")
                    }
                }

                // Intensity modifier
                HStack {
                    Label("Intensity", systemImage: "speedometer")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(weekModifier * 100))%")
                        .fontWeight(.semibold)
                        .foregroundStyle(weekModifier >= 1.0 ? Color.primary : Color.orange)
                }

                // Suggested RPE
                if let rpe = programDay.suggestedRPE {
                    HStack {
                        Label("Target RPE", systemImage: "gauge")
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("\(rpe)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
            } header: {
                Text("Day Info", comment: "Section header for day information")
            }

            // Template info
            Section {
                HStack {
                    Label("Template", systemImage: "doc.text")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(template.name)
                        .fontWeight(.medium)
                }

                HStack {
                    Label("Exercises", systemImage: "list.bullet")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(template.exerciseCount)")
                        .fontWeight(.medium)
                }

                HStack {
                    Label("Total Sets", systemImage: "number")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(template.exercises.reduce(0) { $0 + $1.setCount })")
                        .fontWeight(.medium)
                }
            } header: {
                Text("Template Overview", comment: "Section header for template overview")
            }

            // Exercises
            Section {
                ForEach(template.exercises.sorted(by: TemplateExercise.compare)) { templateExercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(templateExercise.exerciseName)
                            .font(.headline)

                        HStack(spacing: 16) {
                            Label {
                                Text("\(templateExercise.setCount) sets")
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "square.stack.3d.up")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)

                            Label {
                                if templateExercise.repRangeMin == templateExercise.repRangeMax {
                                    Text("\(templateExercise.repRangeMin) reps")
                                        .font(.subheadline)
                                } else {
                                    Text("\(templateExercise.repRangeMin)-\(templateExercise.repRangeMax) reps")
                                        .font(.subheadline)
                                }
                            } icon: {
                                Image(systemName: "repeat")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }

                        if let notes = templateExercise.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Exercises", comment: "Section header for exercises list")
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Preview

#Preview {
    let template = WorkoutTemplate(
        name: "Push Day",
        category: .strength,
        isPreset: true
    )

    let programDay = ProgramDay(
        dayOfWeek: 1,
        name: "Push",
        notes: "Focus on progressive overload"
    )
    programDay.suggestedRPE = 8
    programDay.template = template

    return NavigationStack {
        WorkoutPreviewView(
            programDay: programDay,
            template: template,
            weekModifier: 1.0
        )
        .navigationTitle("Preview")
    }
}
