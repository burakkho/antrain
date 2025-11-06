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
                dayInfoCard(viewModel: viewModel)

                // Template preview
                if !day.isRestDay, let template = day.template {
                    templatePreviewSection(template: template, viewModel: viewModel)
                }

                // Notes
                if let notes = day.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                }

                // Week context
                if let week = day.week {
                    weekContextSection(week: week)
                }
            }
            .padding()
        }
    }

    // MARK: - Day Info Card

    @ViewBuilder
    private func dayInfoCard(viewModel: DayDetailViewModel) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                // Day of week
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(DSColors.primary)
                    Text(day.dayOfWeekName)
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)
                }

                Divider()

                // Workout stats
                if !day.isRestDay {
                    HStack(spacing: DSSpacing.xl) {
                        statItem(
                            icon: "dumbbell.fill",
                            value: "\(viewModel.sortedExercises.count)",
                            label: "Exercises"
                        )

                        statItem(
                            icon: "number",
                            value: "\(viewModel.totalSets)",
                            label: "Sets"
                        )

                        if let duration = day.template?.estimatedDurationFormatted {
                            statItem(
                                icon: "clock",
                                value: duration,
                                label: "Duration"
                            )
                        }
                    }

                    // RPE target
                    if let rpeText = viewModel.rpeText,
                       let rpeDescription = viewModel.rpeDescription {
                        Divider()

                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .foregroundStyle(DSColors.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Target Intensity")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                                Text(rpeText)
                                    .font(DSTypography.body)
                                    .fontWeight(.semibold)
                                Text(rpeDescription)
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                        }
                    }

                    // Modifiers
                    if viewModel.hasModifiers {
                        Divider()

                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("Adjustments")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)

                            HStack(spacing: DSSpacing.md) {
                                if let intensityText = viewModel.intensityModifierText {
                                    modifierChip(
                                        icon: "bolt.fill",
                                        label: "Intensity",
                                        value: intensityText,
                                        color: day.effectiveIntensityModifier > 1.0 ? .orange : .green
                                    )
                                }

                                if let volumeText = viewModel.volumeModifierText {
                                    modifierChip(
                                        icon: "chart.bar.fill",
                                        label: "Volume",
                                        value: volumeText,
                                        color: day.effectiveVolumeModifier > 1.0 ? .orange : .green
                                    )
                                }

                                if day.week?.isDeload == true {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Deload")
                                            .font(DSTypography.caption)
                                            .foregroundStyle(DSColors.textSecondary)
                                    }
                                    .padding(.horizontal, DSSpacing.sm)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background {
                                        RoundedRectangle(cornerRadius: DSSpacing.xs)
                                            .fill(Color.green.opacity(0.1))
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Rest day
                    HStack(spacing: DSSpacing.md) {
                        Image(systemName: "zzz")
                            .font(.title)
                            .foregroundStyle(DSColors.textSecondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rest Day")
                                .font(DSTypography.title3)
                                .foregroundStyle(DSColors.textSecondary)
                            Text("Active recovery and restoration")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textTertiary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Template Preview

    @ViewBuilder
    private func templatePreviewSection(template: WorkoutTemplate, viewModel: DayDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Workout Plan")
                .font(DSTypography.headline)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Template header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(DSTypography.body)
                                .fontWeight(.semibold)
                            Text(template.category.displayName)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(DSColors.textTertiary)
                    }

                    Divider()

                    // Exercise list
                    ForEach(viewModel.sortedExercises) { exercise in
                        exerciseRow(exercise: exercise)

                        if exercise != viewModel.sortedExercises.last {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func exerciseRow(exercise: TemplateExercise) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Exercise order
            Text("\(exercise.order + 1)")
                .font(DSTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textSecondary)
                .frame(width: 24, height: 24)
                .background {
                    Circle()
                        .fill(DSColors.primary.opacity(0.1))
                }

            // Exercise name and details
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exerciseName)
                    .font(DSTypography.body)

                HStack(spacing: DSSpacing.xs) {
                    Text("\(exercise.setCount) sets")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    Text("•")
                        .foregroundStyle(DSColors.textTertiary)

                    if exercise.repRangeMin == exercise.repRangeMax {
                        Text("\(exercise.repRangeMin) reps")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    } else {
                        Text("\(exercise.repRangeMin)-\(exercise.repRangeMax) reps")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                // Exercise notes
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textTertiary)
                        .italic()
                }
            }

            Spacer()
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

    // MARK: - Week Context

    @ViewBuilder
    private func weekContextSection(week: ProgramWeek) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Week Context")
                .font(DSTypography.headline)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    HStack {
                        Text("Week \(week.weekNumber)")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)

                        if let phase = week.phaseTag {
                            Spacer()
                            PhaseIndicator(phase: phase, style: .compact)
                        }
                    }

                    if let weekName = week.name, !weekName.isEmpty {
                        Text(weekName)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    if let weekNotes = week.notes, !weekNotes.isEmpty {
                        Divider()
                        Text(weekNotes)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(DSColors.primary)
            Text(value)
                .font(DSTypography.body)
                .fontWeight(.semibold)
            Text(label)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func modifierChip(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: DSSpacing.xs)
                .fill(color.opacity(0.1))
        }
    }

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

#Preview("With Modifiers") {
    NavigationStack {
        DayDetailView(
            day: {
                let template = WorkoutTemplate(
                    name: "531 Squat",
                    category: .strength
                )

                let ex1 = TemplateExercise(
                    order: 0,
                    exerciseId: UUID(),
                    exerciseName: "Barbell Back Squat",
                    setCount: 3,
                    repRangeMin: 3,
                    repRangeMax: 5
                )

                template.exercises = [ex1]

                let week = ProgramWeek(
                    weekNumber: 4,
                    intensityModifier: 0.9,
                    volumeModifier: 0.7,
                    isDeload: true
                )

                let day = ProgramDay(
                    dayOfWeek: 4,
                    template: template,
                    intensityOverride: 0.85,
                    suggestedRPE: 6
                )
                day.week = week

                return day
            }()
        )
        .environmentObject(AppDependencies.preview)
    }
}
