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
                    Section("MetCon Type") {
                        Picker("Type", selection: $viewModel.metconType) {
                            ForEach(MetConType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)

                        Text(viewModel.metconType.description)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    // Duration
                    Section("Duration") {
                        HStack {
                            TextField("Minutes", value: $viewModel.durationMinutes, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.durationMinutes) { _, _ in
                                    viewModel.updateDuration()
                                }
                            Text("min")
                                .foregroundStyle(DSColors.textSecondary)
                        }

                        HStack {
                            TextField("Seconds", value: $viewModel.durationSeconds, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.durationSeconds) { _, _ in
                                    viewModel.updateDuration()
                                }
                            Text("sec")
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    // Rounds (for AMRAP/EMOM)
                    if viewModel.metconType == .amrap || viewModel.metconType == .emom {
                        Section("Rounds Completed") {
                            HStack {
                                TextField("Rounds", value: $viewModel.rounds, format: .number)
                                    .keyboardType(.numberPad)
                                Text("rounds")
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                        }
                    }

                    // Result / Notes
                    Section("Result / WOD Description") {
                        TextField(
                            viewModel.metconType == .forTime
                                ? "Time to complete (e.g., 12:34)"
                                : "Describe the workout and your performance",
                            text: $viewModel.result,
                            axis: .vertical
                        )
                        .lineLimit(5...10)
                    }

                    // Additional Notes
                    Section("Additional Notes (Optional)") {
                        TextField("How did it feel?", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)
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

                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.error)
                        }
                    }
        }
        .navigationTitle("Log MetCon")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    MetConLogView()
        .environmentObject(AppDependencies.preview)
}
