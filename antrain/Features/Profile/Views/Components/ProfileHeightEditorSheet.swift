import SwiftUI

/// Sheet for editing user's height
struct ProfileHeightEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: ProfileView.WeightUnit = .kg
    let viewModel: ProfileViewModel
    @State private var height: Double = 170.0
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Height") {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $height, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(weightUnit == .kg ? String(localized: "cm") : String(localized: "in"))
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Height")
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
                            await saveHeight()
                        }
                    }
                    .disabled(isSaving || height <= 0)
                }
            }
        }
        .onAppear {
            if let currentHeight = viewModel.userProfile?.height {
                // Convert from cm if user uses imperial
                height = weightUnit == .lbs ? currentHeight.cmToInches() : currentHeight
            }
        }
    }

    private func saveHeight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Convert to cm if user entered inches (database always stores in cm)
            let heightInCm = weightUnit == .lbs ? height.inchesToCm() : height
            try await viewModel.updateHeight(heightInCm)
            dismiss()
        } catch {
            errorMessage = "Failed to save height: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
