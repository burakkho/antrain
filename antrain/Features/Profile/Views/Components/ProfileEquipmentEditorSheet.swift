import SwiftUI

/// Sheet for editing available equipment
struct ProfileEquipmentEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedEquipment: UserProfile.Equipment = .gym
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Available Equipment", selection: $selectedEquipment) {
                        ForEach(UserProfile.Equipment.allCases, id: \.self) { equipment in
                            VStack(alignment: .leading) {
                                Text(equipment.rawValue)
                                    .font(DSTypography.body)
                                Text(equipmentDescription(equipment))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .tag(equipment)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Your Training Setup")
                } footer: {
                    Text("Help AI Coach recommend exercises based on your available equipment.")
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
            .navigationTitle("Edit Equipment")
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
                            await saveEquipment()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedEquipment = viewModel.userProfile?.availableEquipment ?? .gym
        }
    }

    private func equipmentDescription(_ equipment: UserProfile.Equipment) -> String {
        switch equipment {
        case .gym:
            return "Full commercial gym with all equipment"
        case .home:
            return "Home setup with barbells, dumbbells, rack, bench"
        case .minimal:
            return "Dumbbells, resistance bands, bodyweight"
        }
    }

    private func saveEquipment() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateAvailableEquipment(selectedEquipment)
            dismiss()
        } catch {
            errorMessage = "Failed to save equipment: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
