//
//  DailyNutritionView.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Daily nutrition tracking view
struct DailyNutritionView: View {
    @EnvironmentObject private var appDependencies: AppDependencies

    @State private var viewModel: DailyNutritionViewModel?
    @State private var foodSearchViewModel: FoodSearchViewModel?
    @State private var selectedMealType: Meal.MealType?
    @State private var showNutritionGoalsEditor = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Nutrition")
                .navigationBarTitleDisplayMode(.large)
                .sheet(item: $selectedMealType) { mealType in
                    if let foodVM = foodSearchViewModel {
                        FoodSearchView(viewModel: foodVM) { food, amount, unit in
                            Task {
                                await viewModel?.addFood(to: mealType, food: food, amount: amount, unit: unit)
                            }
                        }
                    } else {
                        DSLoadingView()
                    }
                }
                .sheet(isPresented: $showNutritionGoalsEditor) {
                    if viewModel != nil {
                        SmartNutritionGoalsEditor()
                            .environmentObject(appDependencies)
                    }
                }
        }
        .onAppear {
            // ViewModels'i SENKRON oluştur (hemen hazır)
            if viewModel == nil {
                viewModel = DailyNutritionViewModel(
                    nutritionRepository: appDependencies.nutritionRepository,
                    userProfileRepository: appDependencies.userProfileRepository
                )
            }
            if foodSearchViewModel == nil {
                foodSearchViewModel = FoodSearchViewModel(nutritionRepository: appDependencies.nutritionRepository)
            }

            // Load data
            Task {
                async let logLoad: () = viewModel?.loadTodayLog() ?? ()
                async let foodLoad: () = foodSearchViewModel?.loadInitialFoods() ?? ()

                await logLoad
                await foodLoad
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                DSLoadingView()
            } else if let error = viewModel.errorMessage {
                DSErrorView(
                    errorMessage: LocalizedStringKey(error),
                    retryAction: {
                        Task {
                            await viewModel.loadTodayLog()
                        }
                    }
                )
            } else {
                contentView(viewModel: viewModel)
            }
        } else {
            DSLoadingView()
        }
    }

    // MARK: - Content View
    @ViewBuilder
    private func contentView(viewModel: DailyNutritionViewModel) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Date selector
                dateSelector(viewModel: viewModel)

                // Macro progress section
                macroProgressSection(viewModel: viewModel)

                // Meals section
                mealsSection(viewModel: viewModel)
            }
            .padding(DSSpacing.md)
        }
    }

    // MARK: - Date Selector
    @ViewBuilder
    private func dateSelector(viewModel: DailyNutritionViewModel) -> some View {
        HStack {
            Button(action: {
                Task {
                    let yesterday = Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: viewModel.currentDate
                    ) ?? viewModel.currentDate
                    await viewModel.changeDate(to: yesterday)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(DSColors.primary)
            }

            Spacer()

            Text(formattedDate(viewModel.currentDate))
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            Spacer()

            Button(action: {
                Task {
                    let tomorrow = Calendar.current.date(
                        byAdding: .day,
                        value: 1,
                        to: viewModel.currentDate
                    ) ?? viewModel.currentDate
                    await viewModel.changeDate(to: tomorrow)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(DSColors.primary)
            }
            .disabled(Calendar.current.isDateInToday(viewModel.currentDate))
        }
        .padding(.horizontal, DSSpacing.sm)
    }

    // MARK: - Macro Progress Section
    @ViewBuilder
    private func macroProgressSection(viewModel: DailyNutritionViewModel) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    Text("Daily Progress")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)

                    Spacer()

                    Button(action: { showNutritionGoalsEditor = true }) {
                        Text("Edit Goals")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.primary)
                    }
                }

                // Calories
                MacroProgressBar(
                    title: "Calories",
                    current: viewModel.totalCalories,
                    goal: viewModel.dailyCaloriesGoal,
                    color: DSColors.primary,
                    unit: "kcal"
                )

                // Protein
                MacroProgressBar(
                    title: "Protein",
                    current: viewModel.totalProtein,
                    goal: viewModel.dailyProteinGoal,
                    color: .red,
                    unit: "g"
                )

                // Carbs
                MacroProgressBar(
                    title: "Carbs",
                    current: viewModel.totalCarbs,
                    goal: viewModel.dailyCarbsGoal,
                    color: .orange,
                    unit: "g"
                )

                // Fats
                MacroProgressBar(
                    title: "Fats",
                    current: viewModel.totalFats,
                    goal: viewModel.dailyFatsGoal,
                    color: .yellow,
                    unit: "g"
                )
            }
        }
    }

    // MARK: - Meals Section
    @ViewBuilder
    private func mealsSection(viewModel: DailyNutritionViewModel) -> some View {
        VStack(spacing: DSSpacing.md) {
            ForEach([Meal.MealType.breakfast, .lunch, .dinner, .snack], id: \.self) { mealType in
                MealCard(
                    meal: viewModel.getMeal(for: mealType),
                    onAddFood: {
                        selectedMealType = mealType
                    },
                    onRemoveFood: { entry in
                        Task {
                            await viewModel.removeFood(from: mealType, foodEntryId: entry.id)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return String(localized: "Today")
        } else if Calendar.current.isDateInYesterday(date) {
            return String(localized: "Yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

#Preview {
    DailyNutritionView()
        .environmentObject(AppDependencies.preview)
}

