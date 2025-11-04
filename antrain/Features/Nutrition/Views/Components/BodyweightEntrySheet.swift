//
//  BodyweightEntrySheet.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Extracted from NutritionSettingsView.swift for better modularity
//

import SwiftUI

/// Sheet for adding a new bodyweight entry with date and optional notes
struct BodyweightEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"
    @Bindable var viewModel: NutritionSettingsViewModel
    @State private var weight: Double = 70.0
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Enter Bodyweight") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(weightUnit == "Kilograms" ? "kg" : "lbs")
                            .foregroundStyle(DSColors.textSecondary)
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
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveBodyweight()
                        }
                    }
                    .disabled(isSaving || weight <= 0)
                }
            }
        }
    }

    private func saveBodyweight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Convert to kg if user entered lbs (database always stores in kg)
            let weightInKg = weightUnit == "Pounds" ? weight.lbsToKg() : weight
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

#Preview {
    @Previewable @State var viewModel = NutritionSettingsViewModel(
        userProfileRepository: AppDependencies.preview.userProfileRepository
    )

    BodyweightEntrySheet(viewModel: viewModel)
}
