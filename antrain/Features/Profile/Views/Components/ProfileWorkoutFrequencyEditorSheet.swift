import SwiftUI

/// Sheet for editing weekly workout frequency
struct ProfileWorkoutFrequencyEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedFrequency: Int = 3
    @State private var isSaving = false
    @State private var errorMessage: String?

    let frequencyOptions = Array(1...7)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Weekly Frequency", selection: $selectedFrequency) {
                        ForEach(frequencyOptions, id: \.self) { frequency in
                            VStack(alignment: .leading) {
                                Text("\(frequency) \(frequency == 1 ? "time" : "times") per week")
                                    .font(DSTypography.body)
                                Text(frequencyDescription(frequency))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .tag(frequency)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Weekly Workout Frequency")
                } footer: {
                    Text("How many times per week do you plan to train?")
                        .font(DSTypography.caption)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle(Text("Edit Workout Frequency"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        Task {
                            await saveWorkoutFrequency()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedFrequency = viewModel.userProfile?.weeklyWorkoutFrequency ?? 3
        }
    }

    private func frequencyDescription(_ frequency: Int) -> String {
        switch frequency {
        case 1...2:
            return "Minimal, recovery focused"
        case 3:
            return "Moderate, balanced approach"
        case 4...5:
            return "High, serious training"
        case 6...7:
            return "Very high, elite level"
        default:
            return ""
        }
    }

    private func saveWorkoutFrequency() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateWeeklyWorkoutFrequency(selectedFrequency)
            dismiss()
        } catch {
            errorMessage = "Failed to save workout frequency: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
