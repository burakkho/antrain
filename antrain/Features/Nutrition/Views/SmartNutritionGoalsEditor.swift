//
//  SmartNutritionGoalsEditor.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Smart nutrition goals editor with TDEE calculator and macro presets
struct SmartNutritionGoalsEditor: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies

    @State private var viewModel: NutritionGoalsEditorViewModel?

    var body: some View {
        if let vm = viewModel {
            editorContent(viewModel: vm)
        } else {
            DSLoadingView()
                .onAppear {
                    // Initialize ViewModel
                    if viewModel == nil {
                        viewModel = NutritionGoalsEditorViewModel(
                            userProfileRepository: appDependencies.userProfileRepository
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private func editorContent(viewModel vm: NutritionGoalsEditorViewModel) -> some View {
        @Bindable var viewModel = vm
        NavigationStack {
            Form {
                // MARK: - Calculation Mode Selector
                Section {
                    Picker("Calculation Mode", selection: $viewModel.calculationMode) {
                        ForEach(NutritionGoalsEditorViewModel.CalculationMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Calculation Mode")
                } footer: {
                    Text(viewModel.calculationMode == .macroToCalorie ?
                         "Enter macros and calories will be calculated automatically" :
                         "Enter calories and macros will be scaled proportionally")
                        .font(DSTypography.caption)
                }

                // MARK: - TDEE Calculator
                Section {
                    if viewModel.hasMissingData {
                        // Show inline setup for missing data
                        InlineProfileSetup(
                            profile: viewModel.userProfile,
                            onSave: {
                                // Profile is already updated, just trigger UI refresh
                                Task {
                                    await viewModel.loadCurrentGoals()
                                }
                            }
                        )
                    } else if viewModel.canCalculateTDEE {
                        // Show full TDEE calculator
                        Button(action: { viewModel.showTDEECalculator.toggle() }) {
                            HStack {
                                Image(systemName: "calculator")
                                Text("Calculate from TDEE")
                                Spacer()
                                Image(systemName: viewModel.showTDEECalculator ? "chevron.up" : "chevron.down")
                            }
                        }

                        if viewModel.showTDEECalculator {
                            tdeeCalculatorView(viewModel: viewModel)
                        }
                    }
                } header: {
                    Text("Smart Calculator")
                }

                // MARK: - Preset Picker
                Section {
                    MacroPresetPicker(
                        currentCalories: Double(viewModel.calories) ?? 2000,
                        onPresetSelected: { protein, carbs, fats in
                            viewModel.applyPreset(protein: protein, carbs: carbs, fats: fats)
                        }
                    )
                } header: {
                    Text("Quick Presets")
                }

                // MARK: - Daily Goals Input
                Section("Daily Goals") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("", text: $viewModel.calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.calories) { oldValue, newValue in
                                guard !viewModel.isUpdating else { return }
                                guard viewModel.lastEditedField == .calories else {
                                    viewModel.lastEditedField = .calories
                                    return
                                }
                                viewModel.isUpdating = true
                                defer { viewModel.isUpdating = false }
                                viewModel.handleCalorieChange(newValue)
                            }
                        Text("kcal")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("", text: $viewModel.protein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.protein) { oldValue, newValue in
                                guard !viewModel.isUpdating else { return }
                                guard viewModel.lastEditedField == .protein else {
                                    viewModel.lastEditedField = .protein
                                    return
                                }
                                viewModel.isUpdating = true
                                defer { viewModel.isUpdating = false }
                                viewModel.handleMacroChange()
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("", text: $viewModel.carbs)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.carbs) { oldValue, newValue in
                                guard !viewModel.isUpdating else { return }
                                guard viewModel.lastEditedField == .carbs else {
                                    viewModel.lastEditedField = .carbs
                                    return
                                }
                                viewModel.isUpdating = true
                                defer { viewModel.isUpdating = false }
                                viewModel.handleMacroChange()
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Fats")
                        Spacer()
                        TextField("", text: $viewModel.fats)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: viewModel.fats) { oldValue, newValue in
                                guard !viewModel.isUpdating else { return }
                                guard viewModel.lastEditedField == .fats else {
                                    viewModel.lastEditedField = .fats
                                    return
                                }
                                viewModel.isUpdating = true
                                defer { viewModel.isUpdating = false }
                                viewModel.handleMacroChange()
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                // MARK: - Visual Feedback
                if let proteinValue = Double(viewModel.protein),
                   let carbsValue = Double(viewModel.carbs),
                   let fatsValue = Double(viewModel.fats),
                   proteinValue > 0 || carbsValue > 0 || fatsValue > 0 {
                    Section {
                        MacroVisualFeedbackCompact(
                            protein: proteinValue,
                            carbs: carbsValue,
                            fats: fatsValue
                        )
                    } header: {
                        Text("Macro Distribution")
                    }
                }

                // MARK: - Goal Difference
                if let original = viewModel.originalGoals,
                   let cal = Double(viewModel.calories),
                   let pro = Double(viewModel.protein),
                   let car = Double(viewModel.carbs),
                   let fat = Double(viewModel.fats) {
                    Section {
                        goalDifferenceView(
                            original: original,
                            new: (cal, pro, car, fat)
                        )
                    } header: {
                        Text("Changes from Current")
                    }
                }

                if let errorMessage = viewModel.errorMessage {
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
                            do {
                                try await viewModel.saveGoals()
                                dismiss()
                            } catch {
                                // Error is already set in viewModel
                            }
                        }
                    }
                    .disabled(viewModel.isSaving || !viewModel.isValid)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCurrentGoals()
            }
        }
        .sheet(isPresented: $viewModel.showOnboarding) {
            NutritionGoalsOnboardingWizard(
                userProfileRepository: appDependencies.userProfileRepository,
                onComplete: { tdee, recommendedCalories, macros in
                    // Apply recommended values
                    viewModel.applyTDEERecommendation(
                        calories: recommendedCalories,
                        macros: macros
                    )
                }
            )
        }
    }

    // MARK: - Helper Views

    /// TDEE Calculator View
    @ViewBuilder
    private func tdeeCalculatorView(viewModel vm: NutritionGoalsEditorViewModel) -> some View {
        @Bindable var viewModel = vm
        if let data = viewModel.getTDEECalculationData() {
            let tdee = TDEECalculator.calculateTDEE(
                weight: data.weight,
                height: data.height,
                age: data.age,
                gender: data.gender,
                activityLevel: data.activityLevel
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Your TDEE: \(Int(tdee)) kcal/day")
                    .font(DSTypography.body)
                    .fontWeight(.bold)

                Picker("Goal", selection: $viewModel.selectedGoalType) {
                    ForEach(TDEECalculator.GoalType.allCases) { goalType in
                        Text(goalType.rawValue).tag(goalType)
                    }
                }
                .pickerStyle(.segmented)

                let recommendedCals = TDEECalculator.recommendedCalories(
                    tdee: tdee,
                    goal: viewModel.selectedGoalType
                )

                let recommendedMacros = TDEECalculator.recommendedMacros(
                    calories: recommendedCals,
                    weight: data.weight,
                    goal: viewModel.selectedGoalType
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended for \(viewModel.selectedGoalType.rawValue):")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Int(recommendedCals)) kcal")
                                .font(DSTypography.body)
                            Text("P: \(Int(recommendedMacros.protein))g • C: \(Int(recommendedMacros.carbs))g • F: \(Int(recommendedMacros.fats))g")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                        Spacer()
                        Button("Apply") {
                            viewModel.applyTDEERecommendation(
                                calories: recommendedCals,
                                macros: recommendedMacros
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }

    /// Goal difference view
    @ViewBuilder
    private func goalDifferenceView(
        original: (calories: Double, protein: Double, carbs: Double, fats: Double),
        new: (Double, Double, Double, Double)
    ) -> some View {
        VStack(spacing: 8) {
            DifferenceRow(
                name: "Calories",
                original: original.calories,
                new: new.0,
                unit: "kcal"
            )
            DifferenceRow(
                name: "Protein",
                original: original.protein,
                new: new.1,
                unit: "g"
            )
            DifferenceRow(
                name: "Carbs",
                original: original.carbs,
                new: new.2,
                unit: "g"
            )
            DifferenceRow(
                name: "Fats",
                original: original.fats,
                new: new.3,
                unit: "g"
            )
        }
    }
}

/// Row showing difference between original and new value
private struct DifferenceRow: View {
    let name: String
    let original: Double
    let new: Double
    let unit: String

    private var difference: Double {
        new - original
    }

    private var differenceColor: Color {
        if difference > 0 { return .green }
        if difference < 0 { return .red }
        return DSColors.textSecondary
    }

    var body: some View {
        HStack {
            Text(name)
                .font(DSTypography.body)
            Spacer()
            if abs(difference) > 0.5 {
                Text(difference > 0 ? "+\(Int(difference))" : "\(Int(difference))")
                    .font(DSTypography.body)
                    .fontWeight(.bold)
                    .foregroundStyle(differenceColor)
                Image(systemName: difference > 0 ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundStyle(differenceColor)
            } else {
                Text("No change")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }
}
