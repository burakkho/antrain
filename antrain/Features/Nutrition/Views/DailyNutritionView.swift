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
    // Prevent circular updates when programmatically changing values
    @State private var isUpdating = false

    // Calculation mode
    @State private var calculationMode: CalculationMode = .macroToCalorie
    // TDEE Calculator
    @State private var showTDEECalculator = false
    @State private var selectedGoalType: TDEECalculator.GoalType = .maintain
    // Original goals for difference indicator
    @State private var originalGoals: (calories: Double, protein: Double, carbs: Double, fats: Double)?
    // Onboarding wizard
    @State private var showOnboarding = false

    enum EditedField {
        case calories, protein, carbs, fats
    }

    enum CalculationMode: String, CaseIterable {
        case macroToCalorie = "Macros → Calories"
        case calorieToMacro = "Calories → Macros"
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Calculation Mode Selector
                Section {
                    Picker("Calculation Mode", selection: $calculationMode) {
                        ForEach(CalculationMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Calculation Mode")
                } footer: {
                    Text(calculationMode == .macroToCalorie ?
                         "Enter macros and calories will be calculated automatically" :
                         "Enter calories and macros will be scaled proportionally")
                        .font(DSTypography.caption)
                }

                // MARK: - TDEE Calculator
                Section {
                    if hasMissingData {
                        // Show inline setup for missing data
                        InlineProfileSetup(
                            profile: viewModel.userProfile,
                            onSave: {
                                // Profile is already updated, just trigger UI refresh
                            }
                        )
                    } else if canCalculateTDEE {
                        // Show full TDEE calculator
                        Button(action: { showTDEECalculator.toggle() }) {
                            HStack {
                                Image(systemName: "calculator")
                                Text("Calculate from TDEE")
                                Spacer()
                                Image(systemName: showTDEECalculator ? "chevron.up" : "chevron.down")
                            }
                        }

                        if showTDEECalculator {
                            tdeeCalculatorView
                        }
                    }
                } header: {
                    Text("Smart Calculator")
                }

                // MARK: - Preset Picker
                Section {
                    MacroPresetPicker(
                        currentCalories: Double(calories) ?? 2000,
                        onPresetSelected: { protein, carbs, fats in
                            applyPreset(protein: protein, carbs: carbs, fats: fats)
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
                        TextField("", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: calories) { oldValue, newValue in
                                guard !isUpdating else { return }
                                guard lastEditedField == .calories else {
                                    lastEditedField = .calories
                                    return
                                }
                                isUpdating = true
                                defer { isUpdating = false }
                                handleCalorieChange(newValue)
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
                                guard !isUpdating else { return }
                                guard lastEditedField == .protein else {
                                    lastEditedField = .protein
                                    return
                                }
                                isUpdating = true
                                defer { isUpdating = false }
                                handleMacroChange()
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
                                guard !isUpdating else { return }
                                guard lastEditedField == .carbs else {
                                    lastEditedField = .carbs
                                    return
                                }
                                isUpdating = true
                                defer { isUpdating = false }
                                handleMacroChange()
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
                                guard !isUpdating else { return }
                                guard lastEditedField == .fats else {
                                    lastEditedField = .fats
                                    return
                                }
                                isUpdating = true
                                defer { isUpdating = false }
                                handleMacroChange()
                            }
                        Text("g")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                // MARK: - Visual Feedback
                if let proteinValue = Double(protein),
                   let carbsValue = Double(carbs),
                   let fatsValue = Double(fats),
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
                if let original = originalGoals,
                   let cal = Double(calories),
                   let pro = Double(protein),
                   let car = Double(carbs),
                   let fat = Double(fats) {
                    Section {
                        goalDifferenceView(
                            original: original,
                            new: (cal, pro, car, fat)
                        )
                    } header: {
                        Text("Changes from Current")
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
                let cal = profile.dailyCalorieGoal
                let pro = profile.dailyProteinGoal
                let car = profile.dailyCarbsGoal
                let fat = profile.dailyFatsGoal

                calories = String(Int(cal))
                protein = String(Int(pro))
                carbs = String(Int(car))
                fats = String(Int(fat))

                // Store original goals for difference indicator
                originalGoals = (cal, pro, car, fat)

                // Check if should show onboarding wizard
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedNutritionOnboarding")
                if !hasCompletedOnboarding && hasMissingData {
                    showOnboarding = true
                }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            NutritionGoalsOnboardingWizard(
                viewModel: viewModel,
                onComplete: { tdee, recommendedCalories, macros in
                    // Apply recommended values
                    applyTDEERecommendation(
                        calories: recommendedCalories,
                        macros: macros
                    )
                }
            )
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

    // MARK: - Helper Views

    /// Check if user has required data for TDEE calculation
    private var canCalculateTDEE: Bool {
        guard let profile = viewModel.userProfile else { return false }
        return profile.age != nil &&
               profile.height != nil &&
               profile.gender != nil &&
               profile.activityLevel != nil &&
               profile.currentBodyweight != nil
    }

    /// Check if user has any missing profile data
    private var hasMissingData: Bool {
        guard let profile = viewModel.userProfile else { return true }
        return profile.age == nil ||
               profile.height == nil ||
               profile.gender == nil ||
               profile.activityLevel == nil ||
               profile.currentBodyweight == nil
    }

    /// TDEE Calculator View
    @ViewBuilder
    private var tdeeCalculatorView: some View {
        if let profile = viewModel.userProfile,
           let age = profile.age,
           let height = profile.height,
           let gender = profile.gender,
           let activityLevel = profile.activityLevel,
           let weight = profile.currentBodyweight?.weight {

            // Convert UserProfile.ActivityLevel to TDEECalculator.ActivityLevel
            let tdeeActivityLevel = TDEECalculator.ActivityLevel(
                rawValue: activityLevel.rawValue
            ) ?? .moderatelyActive

            let tdee = TDEECalculator.calculateTDEE(
                weight: weight,
                height: height,
                age: age,
                gender: gender,
                activityLevel: tdeeActivityLevel
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Your TDEE: \(Int(tdee)) kcal/day")
                    .font(DSTypography.body)
                    .fontWeight(.bold)

                Picker("Goal", selection: $selectedGoalType) {
                    ForEach(TDEECalculator.GoalType.allCases) { goalType in
                        Text(goalType.rawValue).tag(goalType)
                    }
                }
                .pickerStyle(.segmented)

                let recommendedCals = TDEECalculator.recommendedCalories(
                    tdee: tdee,
                    goal: selectedGoalType
                )

                let recommendedMacros = TDEECalculator.recommendedMacros(
                    calories: recommendedCals,
                    weight: weight,
                    goal: selectedGoalType
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended for \(selectedGoalType.rawValue):")
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
                            applyTDEERecommendation(
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

    /// Apply TDEE recommendation
    private func applyTDEERecommendation(
        calories: Double,
        macros: (protein: Double, carbs: Double, fats: Double)
    ) {
        isUpdating = true
        defer { isUpdating = false }

        self.calories = String(Int(calories))
        self.protein = String(Int(macros.protein))
        self.carbs = String(Int(macros.carbs))
        self.fats = String(Int(macros.fats))
    }

    /// Apply preset macro ratio
    private func applyPreset(protein: Double, carbs: Double, fats: Double) {
        isUpdating = true
        defer { isUpdating = false }

        self.protein = String(Int(protein))
        self.carbs = String(Int(carbs))
        self.fats = String(Int(fats))

        // Recalculate calories
        let calculatedCalories = (protein * 4) + (carbs * 4) + (fats * 9)
        self.calories = String(Int(calculatedCalories))
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

// MARK: - Preview

#Preview {
    DailyNutritionView()
        .environmentObject(AppDependencies.preview)
}
