import SwiftUI

/// Sheet for editing user's gender
struct ProfileGenderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedGender: UserProfile.Gender = .preferNotToSay
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Gender") {
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Gender")
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
                            await saveGender()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedGender = viewModel.userProfile?.gender ?? .preferNotToSay
        }
    }

    private func saveGender() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateGender(selectedGender)
            dismiss()
        } catch {
            errorMessage = "Failed to save gender: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
