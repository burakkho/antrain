//
//  SeedingView.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Loading screen shown during first app launch while seeding sample data
/// Extracted from MainTabView for better code organization and testability
struct SeedingView: View {
    let viewModel: SeedingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App logo or icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
                .symbolEffect(.bounce, options: .repeat(2))

            Text("antrain")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)

            // Progress section
            ProgressSection(
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.totalSteps,
                percentage: viewModel.progressPercentage,
                message: viewModel.seedingProgress
            )

            Spacer()

            // Estimated time (simple calculation)
            if viewModel.shouldShowEstimate {
                EstimatedTimeView(seconds: viewModel.estimatedSeconds)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Progress Section

private struct ProgressSection: View {
    let currentStep: Int
    let totalSteps: Int
    let percentage: Double
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            // Step indicator
            HStack(spacing: 4) {
                Text("Step")
                Text("\(currentStep)")
                    .fontWeight(.bold)
                    .foregroundStyle(.accent)
                Text("of")
                Text("\(totalSteps)")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Progress bar
            ProgressView(value: percentage)
                .progressViewStyle(.linear)
                .tint(.accent)
                .frame(maxWidth: 300)
                .scaleEffect(y: 1.5)

            // Percentage
            Text("\(Int(percentage * 100))%")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            // Current task
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(minHeight: 44)
        }
    }
}

// MARK: - Estimated Time View

private struct EstimatedTimeView: View {
    let seconds: Int

    var body: some View {
        if seconds > 0 {
            Text("About \(seconds) seconds remaining...")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var viewModel = SeedingViewModel()

    SeedingView(viewModel: viewModel)
}
