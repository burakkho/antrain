//
//  FoodLibrary.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Food library - provides preset food items
final class FoodLibrary {
    /// Get all preset foods
    func getAllPresetFoods() -> [FoodItem] {
        let dtos = ProteinFoods.all +
                   CarbFoods.all +
                   FatFoods.all +
                   VegetableFoods.all

        return dtos.map { $0.toModel() }
    }

    /// Search foods by query
    func searchFoods(query: String) -> [FoodItem] {
        let all = getAllPresetFoods()

        if query.isEmpty {
            return all.sorted { $0.name < $1.name }
        }

        return all.filter { food in
            food.name.localizedCaseInsensitiveContains(query)
        }.sorted { $0.name < $1.name }
    }
}
