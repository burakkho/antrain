//
//  FoodSearchView.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Food search and selection view
struct FoodSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: String = "Kilograms"

    @Bindable var viewModel: FoodSearchViewModel
    let onSelect: (FoodItem, Double) -> Void

    @State private var selectedFood: FoodItem?
    @State private var amount: String = "100"

    var body: some View {
        NavigationStack {
            Group {
                if selectedFood != nil {
                    amountInputView
                } else {
                    searchView(viewModel: viewModel)
                }
            }
            .navigationTitle(selectedFood == nil ? "Search Food" : "Add Amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if selectedFood != nil {
                            selectedFood = nil
                            amount = "100"
                        } else {
                            dismiss()
                        }
                    }
                }

                if selectedFood != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addFood()
                        }
                        .disabled(amount.isEmpty || Double(amount) == nil)
                    }
                }
            }
        }
    }

    // MARK: - Search View
    @ViewBuilder
    private func searchView(viewModel: FoodSearchViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBarView(viewModel: viewModel)

            Divider()

            // Results
            if viewModel.isLoading {
                DSLoadingView()
            } else if let error = viewModel.errorMessage {
                DSErrorView(
                    errorMessage: error,
                    retryAction: {
                        Task {
                            await viewModel.search()
                        }
                    }
                )
            } else if viewModel.searchResults.isEmpty {
                DSEmptyState(
                    icon: "magnifyingglass",
                    title: "No Foods Found",
                    message: "Try a different search term"
                )
            } else {
                List(viewModel.searchResults, id: \.id) { food in
                    FoodSearchRow(food: food)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFood = food
                        }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Amount Input View
    @ViewBuilder
    private var amountInputView: some View {
        if let food = selectedFood {
            VStack(spacing: DSSpacing.lg) {
                // Food info
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text(food.name)
                        .font(DSTypography.title2)
                        .foregroundStyle(DSColors.textPrimary)

                    Text("Per 100g: \(Int(food.calories)) kcal • P: \(Int(food.protein))g C: \(Int(food.carbs))g F: \(Int(food.fats))g")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(DSColors.backgroundSecondary)
                .cornerRadius(DSCornerRadius.md)

                // Amount input
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(weightUnit == "Pounds" ? "Amount (ounces)" : "Amount (grams)")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    TextField("100", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(DSTypography.title2)
                }

                // Calculated nutrition
                if let amountValue = Double(amount) {
                    // Convert to grams if user entered ounces
                    let amountInGrams = weightUnit == "Pounds" ? amountValue.ozToGrams() : amountValue
                    let (cal, pro, car, fat) = food.nutritionFor(amount: amountInGrams)

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        let displayUnit = weightUnit == "Pounds" ? "oz" : "g"
                        Text("Nutrition for \(Int(amountValue))\(displayUnit)")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)

                        HStack(spacing: DSSpacing.lg) {
                            MacroLabel(title: "Calories", value: Int(cal), unit: "kcal")
                            MacroLabel(title: "Protein", value: Int(pro), unit: "g")
                            MacroLabel(title: "Carbs", value: Int(car), unit: "g")
                            MacroLabel(title: "Fats", value: Int(fat), unit: "g")
                        }
                    }
                    .padding()
                    .background(DSColors.backgroundSecondary)
                    .cornerRadius(DSCornerRadius.md)
                }

                Spacer()
            }
            .padding(DSSpacing.md)
        }
    }

    // MARK: - Actions
    private func addFood() {
        guard let food = selectedFood,
              let amountValue = Double(amount) else {
            return
        }

        // Convert to grams if user entered ounces (database stores in grams)
        let amountInGrams = weightUnit == "Pounds" ? amountValue.ozToGrams() : amountValue

        onSelect(food, amountInGrams)
        dismiss()
    }
}

// MARK: - Food Search Row
private struct FoodSearchRow: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(food.name)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textPrimary)

            Text("\(Int(food.calories)) kcal • P: \(Int(food.protein))g C: \(Int(food.carbs))g F: \(Int(food.fats))g")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(.vertical, DSSpacing.xxs)
    }
}

// MARK: - Search Bar View
private struct SearchBarView: View {
    @Bindable var viewModel: FoodSearchViewModel

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.textSecondary)

            TextField("Search foods...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchQuery) { _, _ in
                    Task {
                        await viewModel.search()
                    }
                }

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                    Task {
                        await viewModel.loadInitialFoods()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColors.backgroundSecondary)
        .cornerRadius(DSCornerRadius.sm)
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Macro Label
private struct MacroLabel: View {
    let title: String
    let value: Int
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            Text(title)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)

            Text(unit)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview("Search View") {
    let dependencies = AppDependencies.preview

    return FoodSearchView(
        viewModel: FoodSearchViewModel(
            nutritionRepository: dependencies.nutritionRepository
        ),
        onSelect: { food, amount in
            print("Selected: \(food.name), \(amount)g")
        }
    )
}

#Preview("Amount Input") {
    let dependencies = AppDependencies.preview

    struct PreviewWrapper: View {
        @State private var viewModel: FoodSearchViewModel

        init(dependencies: AppDependencies) {
            _viewModel = State(initialValue: FoodSearchViewModel(
                nutritionRepository: dependencies.nutritionRepository
            ))
        }

        var body: some View {
            FoodSearchView(
                viewModel: viewModel,
                onSelect: { food, amount in
                    print("Selected: \(food.name), \(amount)g")
                }
            )
            .onAppear {
                Task {
                    await viewModel.loadInitialFoods()
                }
            }
        }
    }

    return PreviewWrapper(dependencies: dependencies)
}
