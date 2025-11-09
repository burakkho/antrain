//
//  DayDetailView.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import SwiftUI

/// Detail view for a program day showing workout plan
struct DayDetailView: View {
    @EnvironmentObject private var deps: AppDependencies
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: DayDetailViewModel?

    let day: ProgramDay

    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(day.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !day.isRestDay {
                    startWorkoutButton
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DayDetailViewModel(day: day)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func contentView(viewModel: DayDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                // Day info card
                DayInfoCard(day: day, viewModel: viewModel)

                // Template preview
                if !day.isRestDay, let template = day.template {
                    TemplateExerciseList(
                        template: template,
                        exercises: viewModel.sortedExercises
                    )
                }

                // Notes
                if let notes = day.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                }

                // Week context
                if let week = day.week {
                    WeekContextCard(week: week)
                }
            }
            .padding()
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Label("Notes", systemImage: "note.text")
                .font(DSTypography.headline)

            Text(notes)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textSecondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: DSSpacing.sm)
                        .fill(Color.blue.opacity(0.1))
                }
        }
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutButton: some View {
        Button {
            if let template = day.template {
                workoutManager.startWorkoutFromProgram(template, programDay: day)
            }
        } label: {
            Label("Start", systemImage: "play.fill")
                .font(DSTypography.body)
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Previews

#Preview("Training Day") {
    NavigationStack {
        DayDetailView(
            day: {
                let template = WorkoutTemplate(
                    name: "PPL Push",
                    category: .hypertrophy
                )

                let ex1 = TemplateExercise(
                    order: 0,
                    exerciseId: UUID(),
                    exerciseName: "Barbell Bench Press",
                    setCount: 4,
                    repRangeMin: 5,
                    repRangeMax: 8,
                    notes: "Controlled tempo, full ROM"
                )
                let ex2 = TemplateExercise(
                    order: 1,
                    exerciseId: UUID(),
                    exerciseName: "Barbell Overhead Press",
                    setCount: 3,
                    repRangeMin: 8,
                    repRangeMax: 12
                )
                let ex3 = TemplateExercise(
                    order: 2,
                    exerciseId: UUID(),
                    exerciseName: "Dumbbell Incline Bench Press",
                    setCount: 3,
                    repRangeMin: 8,
                    repRangeMax: 12
                )

                template.exercises = [ex1, ex2, ex3]

                let week = ProgramWeek(
                    weekNumber: 3,
                    name: "Hypertrophy Phase",
                    phaseTag: .hypertrophy,
                    intensityModifier: 1.05
                )

                let day = ProgramDay(
                    dayOfWeek: 2,
                    name: "Push Day",
                    notes: "Focus on progressive overload. Track all weights.",
                    template: template,
                    suggestedRPE: 8
                )
                day.week = week

                return day
            }()
        )
        .environmentObject(AppDependencies.preview)
    }
}

#Preview("Rest Day") {
    NavigationStack {
        DayDetailView(
            day: ProgramDay(
                dayOfWeek: 1,
                notes: "Light stretching and mobility work recommended"
            )
        )
        .environmentObject(AppDependencies.preview)
    }
}
