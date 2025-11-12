//
//  NutritionGoalsEditorSheet.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Extracted from NutritionSettingsView.swift for better modularity
//

import SwiftUI

/// Sheet for editing daily nutrition goals (calories, protein, carbs, fats)
struct NutritionGoalsEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NutritionSettingsViewModel
    @State private var calories: Double = 2000
    @State private var protein: Double = 150
    @State private var carbs: Double = 200
    @State private var fats: Double = 65
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Goals") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $calories, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(String(localized: "kcal"))
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: $protein, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(String(localized: "g"))
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: $carbs, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(String(localized: "g"))
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Fats")
                        Spacer()
                        TextField("Fats", value: $fats, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(String(localized: "g"))
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
            .navigationTitle(Text("Edit Goals"))
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
                            await saveGoals()
                        }
                    }
                    .disabled(isSaving || calories <= 0)
                }
            }
        }
        .onAppear {
            calories = viewModel.userProfile?.dailyCalorieGoal ?? 2000
            protein = viewModel.userProfile?.dailyProteinGoal ?? 150
            carbs = viewModel.userProfile?.dailyCarbsGoal ?? 200
            fats = viewModel.userProfile?.dailyFatsGoal ?? 65
        }
    }

    private func saveGoals() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateNutritionGoals(
                calories: calories,
                protein: protein,
                carbs: carbs,
                fats: fats
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save goals: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

#Preview {
    @Previewable @State var viewModel = NutritionSettingsViewModel(
        userProfileRepository: AppDependencies.preview.userProfileRepository
    )

    NutritionGoalsEditorSheet(viewModel: viewModel)
}
