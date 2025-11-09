import SwiftUI

/// Sheet for editing user's date of birth
struct ProfileDateOfBirthEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Date of Birth",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                    if let age = calculateAge(from: selectedDate) {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(age) \(String(localized: "years old"))")
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                } header: {
                    Text("Your Date of Birth")
                } footer: {
                    Text("Your age is used to calculate your TDEE (Total Daily Energy Expenditure) for personalized calorie recommendations.")
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
            .navigationTitle("Edit Date of Birth")
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
                            await saveDateOfBirth()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            if let dateOfBirth = viewModel.userProfile?.dateOfBirth {
                selectedDate = dateOfBirth
            }
        }
    }

    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }

    private func saveDateOfBirth() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateDateOfBirth(selectedDate)
            dismiss()
        } catch {
            errorMessage = "Failed to save date of birth: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
