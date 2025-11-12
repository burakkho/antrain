import SwiftUI

/// Sheet for editing user's height
struct ProfileHeightEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: ProfileView.WeightUnit = .kg
    let viewModel: ProfileViewModel

    // Metric system (cm)
    @State private var centimeters: Int = 170

    // Imperial system (feet + inches)
    @State private var feet: Int = 5
    @State private var inches: Int = 7

    @State private var isSaving = false
    @State private var errorMessage: String?

    // Ranges
    private let cmRange = 100...250
    private let feetRange = 3...8
    private let inchesRange = 0...11

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if weightUnit == .kg {
                        // Metric: Single picker for cm
                        Picker("Height", selection: $centimeters) {
                            ForEach(cmRange, id: \.self) { cm in
                                Text("\(cm) cm").tag(cm)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    } else {
                        // Imperial: Dual picker for feet and inches
                        HStack(spacing: 0) {
                            Picker("Feet", selection: $feet) {
                                ForEach(feetRange, id: \.self) { ft in
                                    Text("\(ft)").tag(ft)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)

                            Text("ft").foregroundStyle(DSColors.textSecondary)

                            Picker("Inches", selection: $inches) {
                                ForEach(inchesRange, id: \.self) { inch in
                                    Text("\(inch)").tag(inch)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)

                            Text("in").foregroundStyle(DSColors.textSecondary)
                        }
                    }
                } header: {
                    Text("Your Height")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle(Text("Edit Height"))
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
                            await saveHeight()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            if let currentHeight = viewModel.userProfile?.height {
                if weightUnit == .lbs {
                    // Convert cm to feet and inches
                    let totalInches = currentHeight.cmToInches()
                    feet = Int(totalInches) / 12
                    inches = Int(totalInches) % 12
                } else {
                    // Use cm directly
                    centimeters = Int(currentHeight)
                }
            }
        }
    }

    private func saveHeight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Convert to cm (database always stores in cm)
            let heightInCm: Double
            if weightUnit == .lbs {
                // Convert feet and inches to cm
                let totalInches = Double(feet * 12 + inches)
                heightInCm = totalInches.inchesToCm()
            } else {
                heightInCm = Double(centimeters)
            }

            try await viewModel.updateHeight(heightInCm)
            dismiss()
        } catch {
            errorMessage = "Failed to save height: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
