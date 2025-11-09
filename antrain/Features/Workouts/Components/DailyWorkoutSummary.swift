//
//  DailyWorkoutSummary.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Reusable workout summary component
/// Shows top Personal Records (PRs)
/// Used in both WorkoutHistoryView and HomeView
struct DailyWorkoutSummary: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    @State private var topPRs: [PersonalRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// Number of top PRs to display
    var limit: Int = 5

    var body: some View {
        NavigationLink(destination: PersonalRecordsAnalysisView().environmentObject(appDependencies)) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Header
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(DSColors.primary)
                        Text("Personal Records")
                            .font(DSTypography.title3)
                            .foregroundStyle(DSColors.textPrimary)

                        Spacer()

                        // Chevron indicator
                        if !topPRs.isEmpty && !isLoading {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(DSColors.textTertiary)
                        }
                    }

                    if isLoading {
                        // Loading state
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.md)
                    } else if let errorMessage {
                        // Error state
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                            .padding(.vertical, DSSpacing.sm)
                    } else if topPRs.isEmpty {
                        // Empty state
                        VStack(spacing: DSSpacing.xs) {
                            Text("No PRs yet")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.textSecondary)

                            Text("Complete a lifting workout to set your first PR!")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                    } else {
                        // PR list
                        VStack(spacing: DSSpacing.xs) {
                            ForEach(topPRs) { pr in
                                PRRow(pr: pr, weightUnit: weightUnit)
                            }
                        }
                    }
                }
                .padding(DSSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            loadTopPRs()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
            loadTopPRs()
        }
    }

    // MARK: - Load PRs

    private func loadTopPRs() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                topPRs = try await appDependencies.personalRecordRepository.getTopPRs(limit: limit)
                isLoading = false
            } catch {
                errorMessage = "Failed to load PRs"
                isLoading = false
            }
        }
    }
}

// MARK: - PR Row

private struct PRRow: View {
    let pr: PersonalRecord
    let weightUnit: String

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Exercise name
            Text(pr.exerciseName)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textPrimary)
                .lineLimit(1)

            Spacer()

            // Weight
            VStack(alignment: .trailing, spacing: DSSpacing.xxs) {
                Text(pr.formattedWeight(weightUnit: weightUnit))
                    .font(DSTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColors.primary)

                Text(pr.relativeDate)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
        .padding(.vertical, DSSpacing.xxs)
    }
}

// MARK: - Preview

#Preview("With PRs") {
    DailyWorkoutSummary()
        .environmentObject(AppDependencies.preview)
        .padding()
}

#Preview("Empty State") {
    DailyWorkoutSummary()
        .environmentObject(AppDependencies.preview)
        .padding()
}
