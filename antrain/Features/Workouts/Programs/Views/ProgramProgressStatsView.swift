//
//  ProgramProgressStatsView.swift
//  antrain
//
//  Progress and statistics view for active training program
//

import SwiftUI
import Charts

/// Comprehensive progress and stats view for active program
struct ProgramProgressStatsView: View {
    @EnvironmentObject private var deps: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProgramProgressStatsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
                        DSLoadingView(message: "Loading stats")
                    } else if let error = viewModel.errorMessage {
                        errorView(error: error)
                    } else {
                        contentView(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Progress & Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ProgramProgressStatsViewModel(
                        userProfileRepository: deps.userProfileRepository,
                        workoutRepository: deps.workoutRepository
                    )
                    Task {
                        await viewModel?.loadData()
                    }
                }
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(viewModel: ProgramProgressStatsViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Program header
                if let program = viewModel.program {
                    programHeaderSection(program: program, viewModel: viewModel)
                }

                // Overall stats cards
                overallStatsSection(viewModel: viewModel)

                // Adherence chart
                adherenceChartSection(viewModel: viewModel)

                // Volume progression chart
                volumeProgressionSection(viewModel: viewModel)

                // Weekly comparison
                weeklyComparisonSection(viewModel: viewModel)
            }
            .padding(DSSpacing.md)
        }
        .background(DSColors.backgroundPrimary)
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - Program Header

    @ViewBuilder
    private func programHeaderSection(program: TrainingProgram, viewModel: ProgramProgressStatsViewModel) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(program.name)
                    .font(DSTypography.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.textPrimary)

                HStack {
                    Label(program.category.displayName, systemImage: program.category.iconName)
                    Text("•")
                    Label(program.difficulty.displayName, systemImage: program.difficulty.iconName)
                }
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)

                Divider()

                // Progress bar
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack {
                        Text("Week \(viewModel.currentWeek) of \(viewModel.totalWeeks)")
                            .font(DSTypography.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(Int(viewModel.completionPercentage))%")
                            .font(DSTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColors.primary)
                    }

                    ProgressView(value: Double(viewModel.currentWeek), total: Double(viewModel.totalWeeks))
                        .tint(DSColors.primary)
                }
            }
        }
    }

    // MARK: - Overall Stats

    @ViewBuilder
    private func overallStatsSection(viewModel: ProgramProgressStatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Overall Statistics")
                .font(DSTypography.title3)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
                statCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.totalWorkoutsCompleted)",
                    label: String(localized: "Workouts Done"),
                    color: .green
                )

                statCard(
                    icon: "target",
                    value: String(format: "%.0f%%", viewModel.adherencePercentage),
                    label: String(localized: "Adherence"),
                    color: viewModel.adherencePercentage >= 80 ? .green : viewModel.adherencePercentage >= 60 ? .orange : .red
                )

                statCard(
                    icon: "flame.fill",
                    value: "\(viewModel.currentStreak)",
                    label: String(localized: "Day Streak"),
                    color: .orange
                )

                statCard(
                    icon: "list.bullet",
                    value: "\(viewModel.totalExercisesPerformed)",
                    label: String(localized: "Exercises Done"),
                    color: .yellow
                )

                statCard(
                    icon: "scalemass.fill",
                    value: formatWeight(viewModel.totalVolume),
                    label: String(localized: "Total Volume"),
                    color: .blue
                )

                statCard(
                    icon: "figure.strengthtraining.traditional",
                    value: "\(viewModel.uniqueExercises)",
                    label: String(localized: "Unique Exercises"),
                    color: .purple
                )
            }
        }
    }

    @ViewBuilder
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        DSCard {
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(value)
                    .font(DSTypography.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.textPrimary)

                Text(label)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
        }
    }

    // MARK: - Adherence Chart

    @ViewBuilder
    private func adherenceChartSection(viewModel: ProgramProgressStatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Weekly Adherence")
                .font(DSTypography.title3)
                .fontWeight(.semibold)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if !viewModel.volumeByWeek.isEmpty {
                        Chart(viewModel.volumeByWeek) { data in
                            BarMark(
                                x: .value("Week", "W\(data.weekNumber)"),
                                y: .value("Adherence", data.adherence)
                            )
                            .foregroundStyle(adherenceColor(data.adherence))
                            .cornerRadius(DSCornerRadius.sm)
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let percentage = value.as(Double.self) {
                                        Text("\(Int(percentage))%")
                                    }
                                }
                            }
                        }
                        .frame(height: 200)

                        // Legend
                        HStack(spacing: DSSpacing.md) {
                            legendItem(color: .green, label: "≥80%")
                            legendItem(color: .orange, label: "60-79%")
                            legendItem(color: .red, label: "<60%")
                        }
                        .font(DSTypography.caption)
                    } else {
                        Text("No data available")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
        }
    }

    // MARK: - Volume Progression

    @ViewBuilder
    private func volumeProgressionSection(viewModel: ProgramProgressStatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Volume Progression")
                .font(DSTypography.title3)
                .fontWeight(.semibold)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    if !viewModel.volumeByWeek.isEmpty {
                        Chart(viewModel.volumeByWeek) { data in
                            LineMark(
                                x: .value("Week", data.weekNumber),
                                y: .value("Volume", data.volume)
                            )
                            .foregroundStyle(DSColors.primary)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            PointMark(
                                x: .value("Week", data.weekNumber),
                                y: .value("Volume", data.volume)
                            )
                            .foregroundStyle(DSColors.primary)
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let week = value.as(Int.self) {
                                        Text("W\(week)")
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let volume = value.as(Double.self) {
                                        Text(formatWeight(volume))
                                    }
                                }
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Text("No data available")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
        }
    }

    // MARK: - Weekly Comparison

    @ViewBuilder
    private func weeklyComparisonSection(viewModel: ProgramProgressStatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Week-by-Week Breakdown")
                .font(DSTypography.title3)
                .fontWeight(.semibold)

            ForEach(viewModel.weeklyComparison) { week in
                weekComparisonCard(week: week)
            }
        }
    }

    @ViewBuilder
    private func weekComparisonCard(week: WeekComparisonData) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Week \(week.weekNumber)")
                            .font(DSTypography.headline)
                            .fontWeight(.semibold)

                        Text(week.weekName)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    Spacer()

                    if let phase = week.phase {
                        PhaseIndicator(phase: phase, style: .compact)
                    }
                }

                Divider()

                // Stats
                HStack(spacing: DSSpacing.lg) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workouts")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(week.workoutsCompleted)/\(week.workoutsPlanned)")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Adherence")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(Int(week.adherence))%")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(adherenceColor(week.adherence))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Volume")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text(formatWeight(week.totalVolume))
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sets")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text("\(week.totalSets)")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Error View

    @ViewBuilder
    private func errorView(error: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Unable to Load Stats")
                .font(DSTypography.title2)
                .fontWeight(.bold)

            Text(error)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await viewModel?.loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Helpers

    private func adherenceColor(_ adherence: Double) -> Color {
        if adherence >= 80 {
            return .green
        } else if adherence >= 60 {
            return .orange
        } else {
            return .red
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight >= 1000 {
            return String(format: "%.1fk", weight / 1000)
        }
        return "\(Int(weight))"
    }
}

// MARK: - Preview

#Preview {
    ProgramProgressStatsView()
        .environmentObject(AppDependencies.preview)
}
