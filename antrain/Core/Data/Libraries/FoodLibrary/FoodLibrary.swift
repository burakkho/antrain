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
                   VegetableFoods.all +
                   Fruits.all +
                   TurkishFoods.all +
                   PackagedFoods.all +
                   InternationalFoods.all

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

    // MARK: - Duplicate Detection

    #if DEBUG
    /// Check for duplicate foods in the library
    /// - Returns: Array of duplicate food names
    func checkForDuplicates() -> [String] {
        let allDTOs = ProteinFoods.all +
                      CarbFoods.all +
                      FatFoods.all +
                      VegetableFoods.all +
                      Fruits.all +
                      TurkishFoods.all +
                      PackagedFoods.all +
                      InternationalFoods.all

        var seen: [String: FoodDTO] = [:]
        var duplicates: [String] = []

        for food in allDTOs {
            let normalizedName = food.name.lowercased().trimmingCharacters(in: .whitespaces)

            if seen[normalizedName] != nil {
                duplicates.append(food.name)
            } else {
                seen[normalizedName] = food
            }
        }

        return duplicates
    }

    /// Print duplicate detection report
    func printDuplicateReport() {
        let duplicates = checkForDuplicates()

        if duplicates.isEmpty {
            print("✅ No duplicates found in food library")
        } else {
            print("⚠️ Found \(duplicates.count) duplicate(s):")
            duplicates.forEach { print("  - \($0)") }
        }
    }
    #endif
}
