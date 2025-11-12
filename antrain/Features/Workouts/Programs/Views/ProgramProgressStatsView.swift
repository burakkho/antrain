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
            .navigationTitle(Text("Progress & Stats"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) {
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
                        Text("Day \(viewModel.currentDay) of \(viewModel.totalDays)")
                            .font(DSTypography.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(Int(viewModel.completionPercentage))%")
                            .font(DSTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColors.primary)
                    }

                    ProgressView(value: Double(viewModel.currentDay), total: Double(viewModel.totalDays))
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

            Button(String(localized: "Try Again")) {
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
