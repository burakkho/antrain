//
//  TurkishFoods.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Turkish foods and dishes (per 100g)
struct TurkishFoods {
    static let all: [FoodDTO] = [
        // Turkish Breakfast
        FoodDTO(
            name: String(localized: "Menemen"),
            calories: 143, protein: 7.2, carbs: 6.4, fats: 10.5,
            servingSize: 200,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Simit"),
            calories: 290, protein: 8.5, carbs: 51, fats: 6,
            servingSize: 120,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 120, description: String(localized: "simit"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Cheese Börek"),
            calories: 312, protein: 11, carbs: 28, fats: 17,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Spinach Börek"),
            calories: 245, protein: 8, carbs: 26, fats: 12,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 100, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Gözleme (Cheese)"),
            calories: 235, protein: 9, carbs: 30, fats: 9,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Poğaça"),
            calories: 340, protein: 8, carbs: 45, fats: 14,
            servingSize: 80,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 80, description: String(localized: "poğaça"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Açma"),
            calories: 310, protein: 7, carbs: 48, fats: 10,
            servingSize: 90,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 90, description: String(localized: "açma"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Dairy
        FoodDTO(
            name: String(localized: "Ayran"),
            calories: 38, protein: 1.7, carbs: 3.5, fats: 1.8,
            servingSize: 250,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Süzme Yogurt (Strained)"),
            calories: 97, protein: 10, carbs: 3.5, fats: 4.5,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .tablespoon, gramsPerUnit: 20, description: String(localized: "tbsp"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Beyaz Peynir (White Cheese)"),
            calories: 260, protein: 17, carbs: 1.5, fats: 21,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tulum Cheese"),
            calories: 345, protein: 22, carbs: 2, fats: 28,
            servingSize: 30,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 30, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Main Dishes
        FoodDTO(
            name: String(localized: "Köfte (Meatballs)"),
            calories: 250, protein: 20, carbs: 8, fats: 15,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "köfte"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Adana Kebab"),
            calories: 280, protein: 18, carbs: 3, fats: 22,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "skewer"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Urfa Kebab"),
            calories: 245, protein: 19, carbs: 2, fats: 18,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "skewer"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tavuk Şiş (Chicken Shish)"),
            calories: 165, protein: 26, carbs: 2, fats: 6,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 150, description: String(localized: "skewer"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Döner Kebab"),
            calories: 217, protein: 18, carbs: 5, fats: 14,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "İskender Kebab"),
            calories: 195, protein: 16, carbs: 12, fats: 10,
            servingSize: 300,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 300, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lahmacun"),
            calories: 235, protein: 10, carbs: 30, fats: 8,
            servingSize: 120,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 120, description: String(localized: "lahmacun"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pide (Cheese)"),
            calories: 270, protein: 11, carbs: 32, fats: 11,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 150, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Pide (Ground Meat)"),
            calories: 285, protein: 14, carbs: 30, fats: 12,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .slice, gramsPerUnit: 150, description: String(localized: "slice"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Soups
        FoodDTO(
            name: String(localized: "Mercimek Çorbası (Lentil Soup)"),
            calories: 85, protein: 4.5, carbs: 14, fats: 1.5,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Ezogelin Soup"),
            calories: 95, protein: 5, carbs: 16, fats: 1.8,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Yayla Soup"),
            calories: 78, protein: 4, carbs: 8, fats: 3.5,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tarhana Soup"),
            calories: 92, protein: 4, carbs: 17, fats: 1.2,
            servingSize: 250,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Home Cooking
        FoodDTO(
            name: String(localized: "Kuru Fasulye (White Bean Stew)"),
            calories: 110, protein: 6.5, carbs: 17, fats: 2,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "İmam Bayıldı"),
            calories: 145, protein: 2.5, carbs: 12, fats: 10,
            servingSize: 200,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 200, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Dolma (Stuffed Vine Leaves)"),
            calories: 125, protein: 3, carbs: 16, fats: 5.5,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "dolma"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sarma (Stuffed Cabbage)"),
            calories: 135, protein: 5, carbs: 15, fats: 6,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "sarma"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Karnıyarık"),
            calories: 185, protein: 7, carbs: 14, fats: 12,
            servingSize: 200,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 200, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Mücver (Zucchini Fritters)"),
            calories: 168, protein: 5, carbs: 15, fats: 10,
            servingSize: 100,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 70, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Desserts
        FoodDTO(
            name: String(localized: "Baklava"),
            calories: 428, protein: 5.5, carbs: 51, fats: 23,
            servingSize: 60,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 60, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Künefe"),
            calories: 315, protein: 7, carbs: 42, fats: 14,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sütlaç (Rice Pudding)"),
            calories: 122, protein: 3.5, carbs: 21, fats: 2.8,
            servingSize: 150,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "bowl"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kazandibi"),
            calories: 185, protein: 4.5, carbs: 28, fats: 6.5,
            servingSize: 120,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 120, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Lokum (Turkish Delight)"),
            calories: 321, protein: 0, carbs: 81, fats: 0,
            servingSize: 25,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 25, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Revani"),
            calories: 325, protein: 5, carbs: 52, fats: 11,
            servingSize: 80,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 80, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Tulumba"),
            calories: 355, protein: 3.5, carbs: 58, fats: 12,
            servingSize: 50,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 50, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "İrmik Helvası (Semolina Halva)"),
            calories: 385, protein: 6, carbs: 48, fats: 19,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 100, description: String(localized: "serving"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Street Food & Snacks
        FoodDTO(
            name: String(localized: "Kumpir (Baked Potato with Toppings)"),
            calories: 165, protein: 4.5, carbs: 26, fats: 5,
            servingSize: 300,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 300, description: String(localized: "portion"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Midye Dolma (Stuffed Mussels)"),
            calories: 138, protein: 8, carbs: 18, fats: 3.5,
            servingSize: 100,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 30, description: String(localized: "mussel"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kokoreç"),
            calories: 245, protein: 16, carbs: 8, fats: 16,
            servingSize: 150,
            category: .protein,
            servingUnits: [
                ServingUnitDTO(unitType: .serving, gramsPerUnit: 150, description: String(localized: "sandwich"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Kestane (Roasted Chestnuts)"),
            calories: 213, protein: 2.4, carbs: 46, fats: 1.4,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 100, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Çiğ Köfte"),
            calories: 158, protein: 5, carbs: 28, fats: 3,
            servingSize: 100,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .piece, gramsPerUnit: 40, description: String(localized: "piece"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),

        // Turkish Beverages (non-water)
        FoodDTO(
            name: String(localized: "Turkish Tea"),
            calories: 1, protein: 0, carbs: 0.3, fats: 0,
            servingSize: 150,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 150, description: String(localized: "glass"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Turkish Coffee"),
            calories: 2, protein: 0.1, carbs: 0.4, fats: 0,
            servingSize: 70,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 70, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Şalgam Suyu (Turnip Juice)"),
            calories: 12, protein: 0.5, carbs: 2.5, fats: 0,
            servingSize: 250,
            category: .vegetable,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 250, description: String(localized: "glass"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Boza"),
            calories: 68, protein: 1.5, carbs: 13, fats: 0.5,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "glass"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        ),
        FoodDTO(
            name: String(localized: "Sahlep"),
            calories: 95, protein: 2, carbs: 18, fats: 2,
            servingSize: 200,
            category: .carb,
            servingUnits: [
                ServingUnitDTO(unitType: .cup, gramsPerUnit: 200, description: String(localized: "cup"), isDefault: true, orderIndex: 0),
                ServingUnitDTO(unitType: .gram, gramsPerUnit: 1, description: String(localized: "g"), isDefault: false, orderIndex: 1)
            ]
        )
    ]
}
