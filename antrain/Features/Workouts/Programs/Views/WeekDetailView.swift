//
//  WeekDetailView.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Detail view for a program week
struct WeekDetailView: View {
    @EnvironmentObject private var deps: AppDependencies
    @State private var viewModel: WeekDetailViewModel?

    let week: ProgramWeek

    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Week \(week.weekNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = WeekDetailViewModel(week: week)
            }
        }
    }

    @ViewBuilder
    private func contentView(viewModel: WeekDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header info
                headerSection(viewModel: viewModel)

                // Days list
                daysSection(viewModel: viewModel)

                // Notes
                if let notes = week.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func headerSection(viewModel: WeekDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Week name
            Text(week.displayName)
                .font(.title2)
                .fontWeight(.bold)

            // Phase indicator
            if let phase = week.phaseTag {
                PhaseIndicator(phase: phase, style: .default)
            }

            // Modifiers card
            if week.intensityModifier != 1.0 || week.volumeModifier != 1.0 || week.isDeload {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week Adjustments")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 20) {
                        if week.intensityModifier != 1.0 {
                            modifierItem(
                                icon: "bolt.fill",
                                label: "Intensity",
                                value: String(format: "%.0f%%", week.intensityModifier * 100),
                                color: week.intensityModifier > 1.0 ? .orange : .green
                            )
                        }

                        if week.volumeModifier != 1.0 {
                            modifierItem(
                                icon: "chart.bar.fill",
                                label: "Volume",
                                value: String(format: "%.0f%%", week.volumeModifier * 100),
                                color: week.volumeModifier > 1.0 ? .orange : .green
                            )
                        }

                        if week.isDeload {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.green)
                                Text("Deload Week")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))
                }
            }

            // Stats
            HStack(spacing: 20) {
                statItem(
                    icon: "calendar",
                    value: "\(viewModel.trainingDays)",
                    label: "Training Days"
                )

                statItem(
                    icon: "zzz",
                    value: "\(viewModel.restDays)",
                    label: "Rest Days"
                )
            }
        }
    }

    @ViewBuilder
    private func daysSection(viewModel: WeekDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Schedule")
                .font(.headline)

            ForEach(viewModel.sortedDays) { day in
                if day.isRestDay {
                    DayCard(day: day)
                } else {
                    NavigationLink {
                        DayDetailView(day: day)
                    } label: {
                        DayCard(day: day)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)

            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.1))
        }
    }

    @ViewBuilder
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func modifierItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        WeekDetailView(
            week: ProgramWeek(
                weekNumber: 3,
                name: "Hypertrophy Phase",
                notes: "Focus on controlled tempo and full range of motion. Aim for 8-12 reps on all main movements.",
                phaseTag: .hypertrophy,
                intensityModifier: 1.05,
                volumeModifier: 1.0
            )
        )
        .environmentObject(AppDependencies.preview)
    }
}
