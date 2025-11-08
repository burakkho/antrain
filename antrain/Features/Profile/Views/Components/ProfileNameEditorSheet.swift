import SwiftUI

/// Sheet for editing user's name
struct ProfileNameEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var name: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Name") {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Name")
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
                            await saveName()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            name = viewModel.userProfile?.name ?? ""
        }
    }

    private func saveName() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateName(name)
            dismiss()
        } catch {
            errorMessage = "Failed to save name: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
