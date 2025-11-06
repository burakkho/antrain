import SwiftUI

/// Cardio quick log view
/// Post-workout entry for cardio sessions (distance, duration, pace)
struct CardioLogView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"
    @State private var viewModel: CardioLogViewModel?

    // Computed pace unit text
    private var paceUnitText: String {
        weightUnit == "Pounds" ? String(localized: "min/mile") : String(localized: "min/km")
    }

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
                let vm = CardioLogViewModel(workoutRepository: appDependencies.workoutRepository)
                vm.weightUnit = weightUnit
                viewModel = vm
            }
        }
        .onChange(of: weightUnit) { _, newValue in
            // Update viewModel when unit changes
            viewModel?.weightUnit = newValue
        }
    }

    @ViewBuilder
    private func formContent(viewModel: CardioLogViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Form {
                    // Cardio Type
                    Section("Cardio Type") {
                        Picker("Type", selection: $viewModel.cardioType) {
                            ForEach(CardioType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Distance
                    Section("Distance (Optional)") {
                        HStack {
                            TextField("Distance", value: $viewModel.distance, format: .number.precision(.fractionLength(0...2)))
                                .keyboardType(.decimalPad)
                                .onChange(of: viewModel.distance) { _, newValue in
                                    // Convert to km if user entered miles
                                    if weightUnit == "Pounds" {
                                        viewModel.distanceInKm = newValue.milesToKm()
                                    } else {
                                        viewModel.distanceInKm = newValue
                                    }
                                }
                            Text(Double.distanceUnitSymbol(weightUnit))
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    // Duration
                    Section("Duration") {
                        HStack {
                            TextField("Minutes", value: $viewModel.durationMinutes, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.durationMinutes) { _, _ in
                                    viewModel.updateDuration()
                                }
                            Text(String(localized: "min"))
                                .foregroundStyle(DSColors.textSecondary)
                        }

                        HStack {
                            TextField("Seconds", value: $viewModel.durationSeconds, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.durationSeconds) { _, _ in
                                    viewModel.updateDuration()
                                }
                            Text(String(localized: "sec"))
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    // Pace (optional manual or auto-calculated)
                    Section("Pace (Optional)") {
                        if let calculatedPace = viewModel.calculatedPace {
                            HStack {
                                Text("Auto-calculated")
                                    .foregroundStyle(DSColors.textSecondary)
                                Spacer()
                                Text(String(format: "%.2f \(paceUnitText)", calculatedPace))
                                    .font(DSTypography.headline)
                            }
                        }

                        HStack {
                            TextField("Manual Pace", value: $viewModel.pace, format: .number.precision(.fractionLength(0...2)))
                                .keyboardType(.decimalPad)
                            Text(paceUnitText)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    // Notes
                    Section("Notes (Optional)") {
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
        .navigationTitle("Log Cardio")
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
    CardioLogView()
        .environmentObject(AppDependencies.preview)
}
