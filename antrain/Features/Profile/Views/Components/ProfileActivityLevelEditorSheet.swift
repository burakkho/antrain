import SwiftUI

/// Sheet for editing user's activity level
struct ProfileActivityLevelEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedActivityLevel: UserProfile.ActivityLevel = .moderatelyActive
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Activity Level", selection: $selectedActivityLevel) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                    .font(DSTypography.body)
                                Text(activityLevelDescription(level))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Your Activity Level")
                } footer: {
                    Text("Your activity level is used to calculate your TDEE (Total Daily Energy Expenditure) for personalized calorie recommendations.")
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
            .navigationTitle(Text("Edit Activity Level"))
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
                            await saveActivityLevel()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedActivityLevel = viewModel.userProfile?.activityLevel ?? .moderatelyActive
        }
    }

    private func activityLevelDescription(_ level: UserProfile.ActivityLevel) -> String {
        // Map to TDEECalculator.ActivityLevel to get description
        if let tdeeLevel = TDEECalculator.ActivityLevel(rawValue: level.rawValue) {
            return tdeeLevel.description
        }
        return ""
    }

    private func saveActivityLevel() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateActivityLevel(selectedActivityLevel)
            dismiss()
        } catch {
            errorMessage = "Failed to save activity level: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
