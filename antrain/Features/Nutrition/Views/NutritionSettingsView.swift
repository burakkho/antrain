//
//  NutritionSettingsView.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Refactored: Components extracted to separate files for better modularity
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

                        Button(String(localized: "Add Weight Entry")) {
                            showBodyweightEntry = true
                        }

                        if viewModel.userProfile?.bodyweightEntries.isEmpty == false {
                            Button(String(localized: "View Weight History")) {
                                showBodyweightHistory = true
                            }
                        }
                    }
                }
                .navigationTitle(Text("Nutrition Settings"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Done")) {
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

// MARK: - Preview

#Preview {
    NutritionSettingsView()
        .environmentObject(AppDependencies.preview)
}
