import SwiftUI

/// Sheet for editing user's fitness level
struct ProfileFitnessLevelEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedFitnessLevel: UserProfile.FitnessLevel = .intermediate
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Fitness Level", selection: $selectedFitnessLevel) {
                        ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                    .font(DSTypography.body)
                                Text(fitnessLevelDescription(level))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Your Fitness Level")
                } footer: {
                    Text("Help AI Coach tailor recommendations to your experience level.")
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
            .navigationTitle("Edit Fitness Level")
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
                            await saveFitnessLevel()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedFitnessLevel = viewModel.userProfile?.fitnessLevel ?? .intermediate
        }
    }

    private func fitnessLevelDescription(_ level: UserProfile.FitnessLevel) -> String {
        switch level {
        case .beginner:
            return "Less than 1 year of consistent training"
        case .intermediate:
            return "1-3 years of consistent training"
        case .advanced:
            return "3+ years of consistent training"
        }
    }

    private func saveFitnessLevel() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateFitnessLevel(selectedFitnessLevel)
            dismiss()
        } catch {
            errorMessage = "Failed to save fitness level: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
