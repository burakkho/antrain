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
        .alert(Text("Error"), isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button(String(localized: "OK")) {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .confirmationDialog(
            Text("Activate Program?"),
            isPresented: Binding(
                get: { viewModel.showActivateConfirmation },
                set: { viewModel.showActivateConfirmation = $0 }
            )
        ) {
            Button(String(localized: "Activate")) {
                Task {
                    await viewModel.activateProgram()
                    if viewModel.errorMessage == nil {
                        showSuccessAlert = true
                    }
                }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text("This will replace your current active program.")
        }
        .alert(Text("Program Activated!"), isPresented: $showSuccessAlert) {
            Button(String(localized: "Go to Programs")) {
                // Send notification to switch to Programs tab
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToProgramsTab"), object: nil)
                // Dismiss all sheets to go back to main view
                dismiss()
            }
            Button(String(localized: "OK")) {
                dismiss()
            }
        } message: {
            Text("Your program has been activated successfully. Check the Programs tab to see your schedule and start today's workout!")
        }
        .sheet(isPresented: $showWorkoutPreview) {
            NavigationStack {
                if let previewDay = previewDay,
                   let template = previewDay.template {
                    WorkoutPreviewView(
                        programDay: previewDay,
                        template: template,
                        weekModifier: 1.0  // No week-based modifiers in day-based system
                    )
                    .navigationTitle(previewDay.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(String(localized: "Done")) {
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

                        Text("Template not found", comment: "Error: Template not found")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("The workout template for today could not be loaded. This can happen if the template was deleted or was not created properly.",
                             comment: "Error message explaining why template couldn't be loaded")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            showWorkoutPreview = false
                        } label: {
                            Text("Close", comment: "Button: Close")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                    .padding()
                    .navigationTitle(String(localized: "Preview", comment: "Title: Preview"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(String(localized: "Done", comment: "Button: Done")) {
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
    func headerSection(viewModel: ProgramDetailViewModel) -> some View {
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
                    value: "\(program.totalDays)",
                    label: String(localized: "Days")
                )

                statItem(
                    icon: "clock",
                    value: formatDuration(program.estimatedTotalDuration),
                    label: String(localized: "Total Time")
                )
            }
        }
    }

    @ViewBuilder
    func actionButtons(viewModel: ProgramDetailViewModel) -> some View {
        VStack(spacing: 12) {
            // Activate button
            Button {
                viewModel.showActivateConfirmation = true
            } label: {
                if viewModel.isActivating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label(String(localized: "Activate Program"), systemImage: "play.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(viewModel.isActivating)


        }
    }

    @ViewBuilder
    func weeksSection(viewModel: ProgramDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Program Schedule")
                .font(.headline)

            ForEach(viewModel.sortedDays) { day in
                NavigationLink {
                    DayDetailView(day: day)
                } label: {
                    DayCard(day: day)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    func statItem(icon: String, value: String, label: String) -> some View {
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

    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        if hours < 1 {
            let minutes = Int(duration) / 60
            return "\(minutes)\(String(localized: "m"))"
        }
        return "\(hours)\(String(localized: "h"))"
    }
}

#Preview {
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    NavigationStack {
        ProgramDetailView(
            program: TrainingProgram(
                name: "PPL 6-Day Split",
                programDescription: "Push/Pull/Legs split for hypertrophy",
                category: .bodybuilding,
                difficulty: .intermediate,
                totalDays: 84  // 12 weeks = 84 days
            )
        )
        .environmentObject(AppDependencies.preview)
        .environment(workoutManager)
    }
}
