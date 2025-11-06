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
    let onSelect: (FoodItem, Double, ServingUnit) -> Void

    @State private var selectedFood: FoodItem?
    @State private var selectedUnit: ServingUnit?  // Will be set immediately when food is selected
    @State private var amount: String = "1"

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
                            selectedUnit = nil
                            amount = "1"
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
            // Search bar with debouncing to prevent UI hang
            DSSearchField(
                placeholder: "Search foods...",
                text: Binding(
                    get: { viewModel.searchQuery },
                    set: { viewModel.searchQuery = $0 }
                ),
                debounceInterval: .milliseconds(300),
                onDebounced: { _ in
                    Task {
                        await viewModel.search()
                    }
                }
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)

            Divider()

            // Results
            if viewModel.isLoading {
                DSLoadingView()
            } else if let error = viewModel.errorMessage {
                DSErrorView(
                    errorMessage: LocalizedStringKey(error),
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

                // Unit Picker (always show since every food has units now)
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Unit")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(food.getSortedUnits(), id: \.id) { unit in
                            Text(unit.fullDisplayText(using: weightUnit))
                                .tag(unit as ServingUnit?)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Amount input
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Amount")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    HStack {
                        TextField("1", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .font(DSTypography.title2)

                        if let unit = selectedUnit {
                            Text(unit.displayDescription(weightUnit: weightUnit))
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.textSecondary)
                                .frame(minWidth: 40, alignment: .leading)
                        }
                    }
                }

                // Calculated nutrition (selectedUnit is guaranteed to be set)
                if let amountValue = Double(amount), let unit = selectedUnit {
                    let amountInGrams = amountValue * unit.gramsPerUnit
                    let (cal, pro, car, fat) = food.nutritionFor(amount: amountInGrams)

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("= \(Int(amountInGrams))g")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textTertiary)

                        Divider()

                        Text("Nutritional Values")
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
            .onAppear {
                // Set default unit when food is selected (guaranteed to return a unit)
                selectedUnit = food.getDefaultUnit()
            }
            .onChange(of: selectedFood) { _, newFood in
                // Reset unit when food changes
                if let food = newFood {
                    selectedUnit = food.getDefaultUnit()
                }
            }
        }
    }

    // MARK: - Actions
    private func addFood() {
        guard let food = selectedFood,
              let amountValue = Double(amount),
              let unit = selectedUnit else {
            return
        }

        onSelect(food, amountValue, unit)
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

// MARK: - Search Bar View (Deprecated - Use DSSearchField instead)
// Removed: SearchBarView replaced with DSSearchField for better performance

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
#Preview {
    FoodSearchView(
        viewModel: FoodSearchViewModel(
            nutritionRepository: AppDependencies.preview.nutritionRepository
        ),
        onSelect: { food, amount, unit in
            print("Selected: \(food.name), \(amount) \(unit.unitDescription)")
        }
    )
}
