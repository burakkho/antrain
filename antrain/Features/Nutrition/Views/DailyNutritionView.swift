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
                        FoodSearchView(viewModel: foodVM) { food, amount in
                            Task {
                                await viewModel?.addFood(to: mealType, food: food, amount: amount)
                            }
                        }
                    } else {
                        DSLoadingView()
                    }
                }
                .sheet(isPresented: $showNutritionGoalsEditor) {
                    if let vm = viewModel {
                        SmartNutritionGoalsEditor(viewModel: vm)
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
                    errorMessage: error,
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
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Smart Nutrition Goals Editor

struct SmartNutritionGoalsEditor: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: DailyNutritionViewModel

    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    // Track which field user is editing
    @State private var lastEditedField: EditedField? = nil

    enum EditedField {
        case calories, protein, carbs, fats
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter your protein, carbs, and fats - calories will be calculated automatically. Or adjust calories to scale all macros proportionally.")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                } header: {
                    Text("How it works")
                }

                Section("Daily Goals") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: calories) { oldValue, newValue in
                                if lastEditedField != .calories {
                                    lastEditedField = .calories
                                    handleCalorieChange(newValue)
                                }
                            }
                        Text("kcal")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("", text: $protein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: protein) { oldValue, newValue in
                                if lastEditedField != .protein {
                                    lastEditedField = .protein
                                    handleMacroChange()
                                }
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("", text: $carbs)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: carbs) { oldValue, newValue in
                                if lastEditedField != .carbs {
                                    lastEditedField = .carbs
                                    handleMacroChange()
                                }
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    HStack {
                        Text("Fats")
                        Spacer()
                        TextField("", text: $fats)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: fats) { oldValue, newValue in
                                if lastEditedField != .fats {
                                    lastEditedField = .fats
                                    handleMacroChange()
                                }
                            }
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
                    .disabled(isSaving || !isValid)
                }
            }
        }
        .onAppear {
            // Load current values
            if let profile = viewModel.userProfile {
                calories = String(Int(profile.dailyCalorieGoal))
                protein = String(Int(profile.dailyProteinGoal))
                carbs = String(Int(profile.dailyCarbsGoal))
                fats = String(Int(profile.dailyFatsGoal))
            }
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        guard let cal = Double(calories),
              let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return false
        }
        return cal > 0 && pro > 0 && car > 0 && fat > 0
    }

    // MARK: - Smart Calculation Logic

    /// When user changes macros, calculate calories automatically
    /// Formula: Protein(4) + Carbs(4) + Fats(9)
    private func handleMacroChange() {
        guard let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return
        }

        // Calculate calories from macros
        let calculatedCalories = (pro * 4) + (car * 4) + (fat * 9)
        calories = String(Int(calculatedCalories))
    }

    /// When user changes calories, scale macros proportionally
    private func handleCalorieChange(_ newCalorieString: String) {
        guard let newCalories = Double(newCalorieString),
              let currentCalories = calculateCurrentCalories(),
              currentCalories > 0,
              newCalories > 0 else {
            return
        }

        // Calculate scaling factor
        let scaleFactor = newCalories / currentCalories

        // Scale all macros
        if let pro = Double(protein) {
            protein = String(Int(pro * scaleFactor))
        }
        if let car = Double(carbs) {
            carbs = String(Int(car * scaleFactor))
        }
        if let fat = Double(fats) {
            fats = String(Int(fat * scaleFactor))
        }
    }

    /// Calculate current calories from macros
    private func calculateCurrentCalories() -> Double? {
        guard let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            return nil
        }
        return (pro * 4) + (car * 4) + (fat * 9)
    }

    // MARK: - Save

    private func saveGoals() async {
        guard let cal = Double(calories),
              let pro = Double(protein),
              let car = Double(carbs),
              let fat = Double(fats) else {
            errorMessage = "Please enter valid numbers for all fields"
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateNutritionGoals(
                calories: cal,
                protein: pro,
                carbs: car,
                fats: fat
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save goals: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Preview

#Preview {
    DailyNutritionView()
        .environmentObject(AppDependencies.preview)
}
