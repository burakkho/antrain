//
//  FoodSearchViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Manages food search and selection state
@Observable @MainActor
final class FoodSearchViewModel {
    // MARK: - Dependencies
    private let nutritionRepository: NutritionRepositoryProtocol

    // MARK: - State
    var searchQuery: String = ""
    var searchResults: [FoodItem] = []
    var isLoading = true  // Start as loading
    var errorMessage: String?

    // MARK: - Initialization
    init(nutritionRepository: NutritionRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Actions
    func search() async {
        isLoading = true
        errorMessage = nil

        do {
            searchResults = try await nutritionRepository.searchFoods(query: searchQuery)
            isLoading = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
    }

    func loadInitialFoods() async {
        // Load all foods initially (empty query)
        searchQuery = ""
        await search()
    }
}
