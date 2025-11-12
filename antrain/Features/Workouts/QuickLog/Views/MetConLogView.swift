import SwiftUI

/// MetCon quick log view
/// Post-workout entry for MetCon/HIIT workouts (AMRAP, EMOM, For Time)
struct MetConLogView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MetConLogViewModel?

    var body: some View {
        NavigationStack {
            if let viewModel {
                formContent(viewModel: viewModel)
            } else {
                DSLoadingView(message: "Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MetConLogViewModel(workoutRepository: appDependencies.workoutRepository)
            }
        }
    }

    @ViewBuilder
    private func formContent(viewModel: MetConLogViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Form {
            // MetCon Type
            Section {
                Picker("Type", selection: $viewModel.metconType) {
                    ForEach(MetConType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)

                Text(viewModel.metconType.description)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            } header: {
                Text("MetCon Type")
            }

            // Duration
            Section {
                DSTimeField(title: "", duration: $viewModel.duration)
            } header: {
                Text("Duration")
            }

            // Rounds (for AMRAP/EMOM)
            if viewModel.metconType == .amrap || viewModel.metconType == .emom {
                Section {
                    HStack {
                        TextField("Rounds", value: $viewModel.rounds, format: .number)
                            .keyboardType(.numberPad)
                        Text("rounds")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                } header: {
                    Text("Rounds Completed")
                }
            }

            // Workout Description
            Section {
                TextField(
                    "21-15-9\nthruster\npull up",
                    text: $viewModel.workoutDescription,
                    axis: .vertical
                )
                .lineLimit(5...10)
                .font(DSTypography.body)
            } header: {
                Text("Workout Description")
            } footer: {
                Text("Describe the exercises and rep scheme")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Score
            Section {
                TextField(
                    scorePlaceholder(for: viewModel.metconType),
                    text: $viewModel.score,
                    axis: .vertical
                )
                .lineLimit(2...4)
                .font(DSTypography.body)
            } header: {
                Text("Score")
            } footer: {
                Text(scoreFooter(for: viewModel.metconType))
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Save Button
            Section {
                DSPrimaryButton(
                    title: "Save Workout",
                    action: {
                        Task {
                            do {
                                try await viewModel.saveWorkout()
                                dismiss()
                            } catch {
                                // Error handled by viewModel
                            }
                        }
                    },
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.canSave
                )
            }

            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.error)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Text("Log MetCon"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Cancel")) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func scorePlaceholder(for type: MetConType) -> String {
        switch type {
        case .forTime:
            return "12:34"
        case .amrap:
            return "8 rounds + 5 reps"
        case .emom:
            return "Completed all rounds"
        case .tabata:
            return "8 rounds completed"
        case .chipper:
            return "15:23"
        case .other:
            return "Your result"
        }
    }

    private func scoreFooter(for type: MetConType) -> String {
        switch type {
        case .forTime:
            return "Enter your completion time"
        case .amrap:
            return "Total rounds and reps completed"
        case .emom:
            return "Describe your performance"
        case .tabata:
            return "Rounds completed or performance notes"
        case .chipper:
            return "Your completion time"
        case .other:
            return "Enter your result or performance"
        }
    }
}

#Preview {
    MetConLogView()
        .environmentObject(AppDependencies.preview)
}
