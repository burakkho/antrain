//
//  NutritionSettingsView.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Nutrition-specific settings: Goals and Bodyweight Tracking
struct NutritionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    @State private var viewModel: NutritionSettingsViewModel?
    @State private var showNutritionGoalsEditor = false
    @State private var showBodyweightEntry = false
    @State private var showBodyweightHistory = false

    var body: some View {
        NavigationStack {
            if let viewModel {
                @Bindable var viewModel = viewModel
                Form {
                    // Nutrition Goals Section
                    Section("Daily Nutrition Goals") {
                        Button(action: { showNutritionGoalsEditor = true }) {
                            VStack(spacing: DSSpacing.xs) {
                                HStack {
                                    Text("Calories")
                                    Spacer()
                                    Text("\(Int(viewModel.userProfile?.dailyCalorieGoal ?? 2000)) kcal")
                                        .foregroundStyle(DSColors.textSecondary)
                                }

                                HStack {
                                    Text("Protein")
                                    Spacer()
                                    Text("\(Int(viewModel.userProfile?.dailyProteinGoal ?? 150))g")
                                        .foregroundStyle(DSColors.textSecondary)
                                }

                                HStack {
                                    Text("Carbs")
                                    Spacer()
                                    Text("\(Int(viewModel.userProfile?.dailyCarbsGoal ?? 200))g")
                                        .foregroundStyle(DSColors.textSecondary)
                                }

                                HStack {
                                    Text("Fats")
                                    Spacer()
                                    Text("\(Int(viewModel.userProfile?.dailyFatsGoal ?? 65))g")
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)

                        Text("Tap to edit your daily nutrition goals")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    // Bodyweight & BMI Section
                    Section("Body Metrics") {
                        // Current Weight
                        if let currentWeight = viewModel.userProfile?.currentBodyweight {
                            HStack {
                                Text("Current Weight")
                                Spacer()
                                Text(currentWeight.weight.formattedWeight(unit: weightUnit))
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .font(DSTypography.body)
                        } else {
                            Text("No bodyweight entries yet")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }

                        // BMI Calculation
                        if let bmi = viewModel.calculateBMI() {
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                HStack {
                                    Text("BMI")
                                    Spacer()
                                    Text(String(format: "%.1f", bmi))
                                        .foregroundStyle(DSColors.textSecondary)
                                }

                                HStack {
                                    Text("Category")
                                    Spacer()
                                    Text(viewModel.bmiCategory(bmi))
                                        .foregroundStyle(viewModel.bmiCategoryColor(bmi))
                                        .fontWeight(.medium)
                                }
                            }
                            .font(DSTypography.body)
                        }

                        Button("Add Weight Entry") {
                            showBodyweightEntry = true
                        }

                        if viewModel.userProfile?.bodyweightEntries.isEmpty == false {
                            Button("View Weight History") {
                                showBodyweightHistory = true
                            }
                        }
                    }
                }
                .navigationTitle("Nutrition Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showNutritionGoalsEditor) {
                    NutritionGoalsEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightEntry) {
                    BodyweightEntrySheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightHistory) {
                    BodyweightHistoryView(viewModel: viewModel)
                }
            } else {
                DSLoadingView(message: "Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = NutritionSettingsViewModel(
                    userProfileRepository: appDependencies.userProfileRepository
                )
                Task {
                    await viewModel?.loadProfile()
                }
            }
        }
    }
}

// MARK: - Nutrition Goals Editor Sheet

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
                        Text("kcal")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: $protein, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: $carbs, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Fats")
                        Spacer()
                        TextField("Fats", value: $fats, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
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
            .navigationTitle("Edit Goals")
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

// MARK: - Bodyweight Entry Sheet

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

// MARK: - Bodyweight History View

struct BodyweightHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"
    @Bindable var viewModel: NutritionSettingsViewModel
    @State private var entries: [BodyweightEntry] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    DSLoadingView(message: "Loading history...")
                } else if entries.isEmpty {
                    DSEmptyState(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "No History Yet",
                        message: "Add your first bodyweight entry to start tracking"
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                HStack {
                                    Text(entry.date, style: .date)
                                        .font(DSTypography.body)
                                    Spacer()
                                    Text(entry.weight.formattedWeight(unit: weightUnit))
                                        .font(DSTypography.headline)
                                        .foregroundStyle(DSColors.primary)
                                }

                                if let notes = entry.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                            }
                            .padding(.vertical, DSSpacing.xxs)
                        }
                        .onDelete { indexSet in
                            Task {
                                await deleteEntries(at: indexSet)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Weight History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadHistory()
            }
        }
    }

    private func loadHistory() async {
        isLoading = true
        do {
            entries = try await viewModel.getBodyweightHistory()
            isLoading = false
        } catch {
            print("Failed to load bodyweight history: \(error)")
            isLoading = false
        }
    }

    private func deleteEntries(at indexSet: IndexSet) async {
        for index in indexSet {
            let entry = entries[index]
            do {
                try await viewModel.deleteBodyweightEntry(entry)
            } catch {
                print("Failed to delete entry: \(error)")
            }
        }
        await loadHistory()
    }
}

// MARK: - Preview

#Preview {
    NutritionSettingsView()
        .environmentObject(AppDependencies.preview)
}
