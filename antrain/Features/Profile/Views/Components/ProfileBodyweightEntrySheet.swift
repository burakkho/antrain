import SwiftUI

/// Sheet for adding a new bodyweight entry
struct ProfileBodyweightEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: ProfileView.WeightUnit = .kg
    let viewModel: ProfileViewModel

    // Weight components
    @State private var wholeWeight: Int = 70
    @State private var decimalWeight: Int = 0  // 0-9 representing 0.0 - 0.9

    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    // Ranges
    private let kgWholeRange = 20...300
    private let lbsWholeRange = 40...660
    private let decimalRange = 0...9

    var body: some View {
        NavigationStack {
            Form {
                Section("Enter Bodyweight") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.wheel)

                    // Dual picker for weight (whole + decimal)
                    HStack(spacing: 0) {
                        Picker("Weight", selection: $wholeWeight) {
                            ForEach(weightRange, id: \.self) { weight in
                                Text("\(weight)").tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)

                        Text(".").foregroundStyle(DSColors.textSecondary)

                        Picker("Decimal", selection: $decimalWeight) {
                            ForEach(decimalRange, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)

                        Text(weightUnit == .kg ? String(localized: "kg") : String(localized: "lbs"))
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(width: 40, alignment: .leading)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("How are you feeling?", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Add Bodyweight")
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
                            await saveBodyweight()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            // Initialize with current weight if available
            if let currentWeight = viewModel.userProfile?.currentBodyweight?.weight {
                let displayWeight = weightUnit == .lbs ? currentWeight.kgToLbs() : currentWeight
                wholeWeight = Int(displayWeight)
                decimalWeight = Int((displayWeight - Double(wholeWeight)) * 10)
            }
        }
    }

    private var weightRange: ClosedRange<Int> {
        weightUnit == .kg ? kgWholeRange : lbsWholeRange
    }

    private func saveBodyweight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Combine whole and decimal parts
            let weight = Double(wholeWeight) + (Double(decimalWeight) / 10.0)

            // Convert to kg if user entered lbs (database always stores in kg)
            let weightInKg = weightUnit == .lbs ? weight.lbsToKg() : weight
            try await viewModel.addBodyweightEntry(
                weight: weightInKg,
                date: date,
                notes: notes.isEmpty ? nil : notes
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save bodyweight: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
