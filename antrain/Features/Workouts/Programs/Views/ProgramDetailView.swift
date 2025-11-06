//
//  ProgramDetailView.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Detail view for a training program
struct ProgramDetailView: View {
    @EnvironmentObject private var deps: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProgramDetailViewModel?
    @State private var showWorkoutPreview = false
    @State private var previewDay: ProgramDay?
    @State private var showShareSheet = false
    @State private var showSuccessAlert = false

    let program: TrainingProgram

    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProgramDetailViewModel(
                    program: program,
                    programRepository: deps.trainingProgramRepository,
                    userProfileRepository: deps.userProfileRepository
                )
            }
        }
    }

    @ViewBuilder
    private func contentView(viewModel: ProgramDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header info
                headerSection(viewModel: viewModel)

                // Action buttons
                actionButtons(viewModel: viewModel)

                // Weeks list
                weeksSection(viewModel: viewModel)
            }
            .padding()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .confirmationDialog(
            "Activate Program?",
            isPresented: Binding(
                get: { viewModel.showActivateConfirmation },
                set: { viewModel.showActivateConfirmation = $0 }
            )
        ) {
            Button("Activate") {
                Task {
                    await viewModel.activateProgram()
                    if viewModel.errorMessage == nil {
                        showSuccessAlert = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will replace your current active program.")
        }
        .alert("Program Activated!", isPresented: $showSuccessAlert) {
            Button("Go to Programs") {
                // Send notification to switch to Programs tab
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToProgramsTab"), object: nil)
                // Dismiss all sheets to go back to main view
                dismiss()
            }
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your program has been activated successfully. Check the Programs tab to see your schedule and start today's workout!")
        }
        .sheet(isPresented: $showWorkoutPreview) {
            NavigationStack {
                if let previewDay = previewDay,
                   let template = previewDay.template,
                   let week = previewDay.week {
                    WorkoutPreviewView(
                        programDay: previewDay,
                        template: template,
                        weekModifier: week.intensityModifier
                    )
                    .navigationTitle(previewDay.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showWorkoutPreview = false
                            }
                        }
                    }
                } else {
                    // Error state when template is not available
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)

                        Text("Şablon Bulunamadı", comment: "Error: Template not found")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Bu gün için antrenman şablonu yüklenemedi. Bu durum şablon silindiğinde veya düzgün oluşturulmadığında meydana gelebilir.",
                             comment: "Error message explaining why template couldn't be loaded")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            showWorkoutPreview = false
                        } label: {
                            Text("Kapat", comment: "Button: Close")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                    .padding()
                    .navigationTitle(String(localized: "Önizleme", comment: "Title: Preview"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(String(localized: "Tamam", comment: "Button: Done")) {
                                showWorkoutPreview = false
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ProgramShareView(program: program)
        }
    }

    @ViewBuilder
    private func headerSection(viewModel: ProgramDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category & Difficulty
            HStack {
                Label {
                    Text(program.category.displayName)
                } icon: {
                    Image(systemName: program.category.iconName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.secondary)

                Label {
                    Text(program.difficulty.displayName)
                } icon: {
                    Image(systemName: program.difficulty.iconName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            // Description
            if let description = program.programDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // Stats
            HStack(spacing: 20) {
                statItem(
                    icon: "calendar",
                    value: "\(program.durationWeeks)",
                    label: "Weeks"
                )

                statItem(
                    icon: "figure.strengthtraining.traditional",
                    value: String(format: "%.0f", program.trainingDaysPerWeek),
                    label: "Days/Week"
                )

                statItem(
                    icon: "clock",
                    value: formatDuration(program.estimatedTotalDuration),
                    label: "Total Time"
                )
            }

            // Progression pattern
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                Text(program.progressionPattern.displayName)
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
            }
        }
    }

    @ViewBuilder
    private func actionButtons(viewModel: ProgramDetailViewModel) -> some View {
        VStack(spacing: 12) {
            // Activate button
            Button {
                viewModel.showActivateConfirmation = true
            } label: {
                if viewModel.isActivating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Activate Program", systemImage: "play.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(viewModel.isActivating)

            // Preview workout button (Phase 6)
            if let firstDay = viewModel.firstWorkoutDay {
                Button {
                    previewDay = firstDay
                    showWorkoutPreview = true
                } label: {
                    Label("Preview First Workout", systemImage: "eye")
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func weeksSection(viewModel: ProgramDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Program Schedule")
                .font(.headline)

            ForEach(viewModel.sortedWeeks) { week in
                NavigationLink {
                    WeekDetailView(week: week)
                } label: {
                    WeekCard(week: week)
                }
                .buttonStyle(.plain)
            }
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

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        if hours < 1 {
            let minutes = Int(duration) / 60
            return "\(minutes)m"
        }
        return "\(hours)h"
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(
            program: TrainingProgram(
                name: "PPL 6-Day Split",
                programDescription: "Push/Pull/Legs split for hypertrophy",
                category: .bodybuilding,
                difficulty: .intermediate,
                durationWeeks: 12,
                progressionPattern: .linear
            )
        )
        .environmentObject(AppDependencies.preview)
    }
}
