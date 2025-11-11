import SwiftUI

/// Sheet for editing user's fitness goals (multi-select)
struct ProfileFitnessGoalsEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedGoals: Set<UserProfile.FitnessGoal> = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(UserProfile.FitnessGoal.allCases, id: \.self) { goal in
                        Button(action: {
                            HapticManager.shared.light()
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.rawValue)
                                        .font(DSTypography.body)
                                        .foregroundStyle(DSColors.textPrimary)
                                    Text(goalDescription(goal))
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                                Spacer()
                                if selectedGoals.contains(goal) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(DSColors.primary)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(DSColors.textTertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Select Your Goals (Multiple)")
                } footer: {
                    Text("Choose one or more goals to help AI Coach personalize your training.")
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
            .navigationTitle("Edit Fitness Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveFitnessGoals()
                        }
                    }
                    .disabled(isSaving || selectedGoals.isEmpty)
                }
            }
        }
        .onAppear {
            selectedGoals = Set(viewModel.userProfile?.fitnessGoals ?? [])
        }
    }

    private func goalDescription(_ goal: UserProfile.FitnessGoal) -> String {
        switch goal {
        case .muscleGain:
            return "Build muscle mass and size"
        case .fatLoss:
            return "Reduce body fat percentage"
        case .strength:
            return "Increase maximum strength"
        case .endurance:
            return "Improve cardiovascular fitness"
        }
    }

    private func saveFitnessGoals() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateFitnessGoals(Array(selectedGoals))
            dismiss()
        } catch {
            errorMessage = "Failed to save fitness goals: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
