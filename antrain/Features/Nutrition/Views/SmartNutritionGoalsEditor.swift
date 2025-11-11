//
//  SmartNutritionGoalsEditor.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Refactored: Modern UI with sliders and visual feedback
//

import SwiftUI

/// Smart nutrition goals editor with interactive sliders and visual charts
struct SmartNutritionGoalsEditor: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies

    @State private var viewModel: NutritionGoalsEditorViewModel?

    var body: some View {
        if let vm = viewModel {
            content(viewModel: vm)
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
    private func content(viewModel vm: NutritionGoalsEditorViewModel) -> some View {
        @Bindable var viewModel = vm
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    // MARK: - TDEE Calculator
                    if viewModel.hasMissingData {
                        inlineProfileSetupSection(viewModel: vm)
                    } else if viewModel.canCalculateTDEE {
                        tdeeCalculatorSection(viewModel: vm)
                    }

                    // MARK: - Macro Sliders
                    macroSlidersSection(viewModel: viewModel)

                    // MARK: - Visual Distribution
                    visualDistributionSection(viewModel: viewModel)

                    // MARK: - Goal Difference
                    if let original = viewModel.originalGoals {
                        goalDifferenceSection(
                            original: original,
                            new: (viewModel.calories, viewModel.protein, viewModel.carbs, viewModel.fats)
                        )
                    }

                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                            .padding()
                    }
                }
                .padding(DSSpacing.md)
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
        .sheet(isPresented: Binding(
            get: {
                // Double-check: Only show wizard if flag is not set
                // This prevents wizard from appearing after onboarding
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedNutritionOnboarding")
                return viewModel.showOnboarding && !hasCompletedOnboarding
            },
            set: { viewModel.showOnboarding = $0 }
        )) {
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

    // MARK: - Sections

    @ViewBuilder
    private func inlineProfileSetupSection(viewModel: NutritionGoalsEditorViewModel) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Label("Complete Your Profile", systemImage: "person.circle")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.primary)

                Text("Add your profile information to get personalized nutrition recommendations")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)

                if let profile = viewModel.userProfile {
                    InlineProfileSetup(
                        profile: profile,
                        onSave: {
                            Task {
                                await viewModel.loadCurrentGoals()
                            }
                        }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func tdeeCalculatorSection(viewModel vm: NutritionGoalsEditorViewModel) -> some View {
        @Bindable var viewModel = vm
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Button(action: { viewModel.showTDEECalculator.toggle() }) {
                    HStack {
                        Image(systemName: "plus.forwardslash.minus")
                            .foregroundStyle(DSColors.primary)
                        Text("Calculate from TDEE")
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColors.textPrimary)
                        Spacer()
                        Image(systemName: viewModel.showTDEECalculator ? "chevron.up" : "chevron.down")
                            .foregroundStyle(DSColors.textTertiary)
                    }
                }

                if viewModel.showTDEECalculator {
                    Divider()
                    tdeeCalculatorView(viewModel: vm)
                }
            }
        }
    }

    @ViewBuilder
    private func macroSlidersSection(viewModel: NutritionGoalsEditorViewModel) -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: DSSpacing.md) {
            Text("Daily Macros")
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            MacroSliderField(
                title: "Protein",
                value: $viewModel.protein,
                range: 0...500,
                step: 5,
                unit: "g",
                color: .red
            )

            MacroSliderField(
                title: "Carbs",
                value: $viewModel.carbs,
                range: 0...500,
                step: 5,
                unit: "g",
                color: .orange
            )

            MacroSliderField(
                title: "Fats",
                value: $viewModel.fats,
                range: 0...200,
                step: 1,
                unit: "g",
                color: .yellow
            )
        }
    }

    @ViewBuilder
    private func visualDistributionSection(viewModel: NutritionGoalsEditorViewModel) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Text("Macro Distribution")
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            MacroDistributionChart(
                protein: viewModel.protein,
                carbs: viewModel.carbs,
                fats: viewModel.fats,
                totalCalories: Int(viewModel.calories)
            )
        }
    }

    @ViewBuilder
    private func goalDifferenceSection(
        original: (calories: Double, protein: Double, carbs: Double, fats: Double),
        new: (Double, Double, Double, Double)
    ) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Changes from Current")
                    .font(DSTypography.headline)
                    .foregroundStyle(DSColors.textPrimary)

                Divider()

                GoalDifferenceRow(
                    name: "Calories",
                    original: original.calories,
                    new: new.0,
                    unit: "kcal"
                )
                GoalDifferenceRow(
                    name: "Protein",
                    original: original.protein,
                    new: new.1,
                    unit: "g"
                )
                GoalDifferenceRow(
                    name: "Carbs",
                    original: original.carbs,
                    new: new.2,
                    unit: "g"
                )
                GoalDifferenceRow(
                    name: "Fats",
                    original: original.fats,
                    new: new.3,
                    unit: "g"
                )
            }
        }
    }

    // MARK: - TDEE Calculator View

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

            VStack(alignment: .leading, spacing: DSSpacing.md) {
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

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Recommended for \(viewModel.selectedGoalType.rawValue):")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text("\(Int(recommendedCals)) kcal")
                                .font(DSTypography.body)
                                .fontWeight(.semibold)
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
}

// MARK: - Preview

#Preview {
    SmartNutritionGoalsEditor()
        .environmentObject(AppDependencies.preview)
}
