# Food Library Documentation

## Overview

Antrain includes a comprehensive food library with **140+ preset food items** covering all major food categories. The library is designed to support various dietary preferences and international cuisines, with a focus on accuracy and ease of use.

## Statistics

| Category | Count | Description |
|----------|-------|-------------|
| **Protein Foods** | 41 | Meat, poultry, seafood, eggs, dairy, legumes, tofu, protein powders |
| **Carbohydrate Foods** | 38 | Rice, pasta, bread, potatoes, cereals, grains |
| **Vegetables & Fruits** | 44 | Leafy greens, cruciferous, root vegetables, fruits |
| **Fat Foods** | 23 | Nuts, seeds, oils, nut butters, dairy fats |
| **Total** | **146** | Comprehensive nutrition database |

## Library Structure

The food library is organized into four main Swift files:

```
Core/Data/Libraries/FoodLibrary/
├── FoodLibrary.swift      # Main library interface
├── ProteinFoods.swift     # 41 protein sources
├── CarbFoods.swift        # 38 carbohydrate sources
├── VegetableFoods.swift   # 44 vegetables & fruits
└── FatFoods.swift         # 23 fat sources
```

## Protein Foods (41 items)

### Poultry (4)
- Chicken Breast, Chicken Thigh
- Turkey Breast, Ground Turkey

### Meat (8)
- Lean Beef (95%), Ground Beef (85%)
- Beef Tenderloin, Meatballs
- Pork Tenderloin, Lamb
- Turkey Salami, Turkish Sausage (Sucuk)

### Seafood (10)
- Salmon, Tuna, Tilapia, Cod
- Trout, Sea Bass, Mackerel, Anchovy
- Shrimp, Sardines

### Eggs & Dairy (8)
- Whole Egg, Egg Whites
- Greek Yogurt (Plain), Cottage Cheese (Low Fat)
- Cheddar Cheese, Mozzarella Cheese
- Lor Cheese, Kashar Cheese

### Legumes (5)
- Lentils (Cooked), Chickpeas (Cooked)
- Black Beans (Cooked), Kidney Beans (Cooked)
- Edamame

### Plant-Based Protein (3)
- Tofu (Firm), Tempeh, Seitan

### Protein Supplements (4)
- Whey Protein Powder
- Casein Protein Powder
- Pea Protein Powder
- Protein Bar

## Carbohydrate Foods (38 items)

### Rice & Grains (7)
- White Rice (Cooked), Brown Rice (Cooked), Basmati Rice (Cooked)
- Sushi Rice (Cooked)
- Quinoa (Cooked), Oats (Dry), Bulgur (Cooked)

### Pasta & Noodles (3)
- Whole Wheat Pasta (Cooked)
- White Pasta (Cooked)
- Rice Noodles (Cooked)

### Bread (7)
- Whole Wheat Bread, White Bread
- Rye Bread, Bran Bread
- Sourdough Bread, Pita Bread, Bagel

### Potatoes (4)
- Sweet Potato (Baked)
- White Potato (Baked)
- Red Potato (Boiled)
- French Fries

### Cereals (3)
- Corn Flakes, Granola, Muesli

### Breakfast Items (3)
- Waffle, Pancake, Crepe

### Snacks (6)
- Couscous (Cooked)
- Tortilla (Corn), Tortilla (Flour)
- Crackers, Pretzels
- Granola Bar, Popcorn, Rice Cake

## Vegetables & Fruits (44 items)

### Leafy Greens (4)
- Spinach, Kale, Lettuce, Arugula

### Cruciferous Vegetables (4)
- Broccoli, Cauliflower
- Brussels Sprouts, Cabbage

### Root Vegetables (3)
- Carrot, Beet, Radish

### Other Vegetables (12)
- Bell Pepper (Red), Cucumber, Tomato
- Zucchini, Eggplant, Mushrooms
- Asparagus, Green Beans
- Okra, Peas (Fresh), Corn (Fresh)
- Onion, Garlic, Leek

### Fruits (21)
- Apple, Banana, Orange
- Strawberry, Blueberry, Grape
- Watermelon, Pineapple, Mango
- Peach, Pear
- Kiwi, Grapefruit, Melon
- Cherry, Apricot, Plum, Fig

## Fat Foods (23 items)

### Nuts (6)
- Almonds, Walnuts, Cashews
- Peanuts, Pistachios, Hazelnuts

### Nut Butters (2)
- Peanut Butter, Almond Butter

### Seeds (4)
- Chia Seeds, Flax Seeds
- Sunflower Seeds, Pumpkin Seeds

### Oils (4)
- Olive Oil, Coconut Oil
- Avocado Oil, Soybean Oil

### Dairy Fats (4)
- Butter, Margarine
- Labneh, Cream Cheese

### Other (3)
- Avocado
- Dark Chocolate (70%)
- Coconut (Fresh)

## Features

### Serving Units
Each food item includes multiple serving units for flexibility:
- **Weight-based**: gram, ounce
- **Volume-based**: cup, tablespoon, teaspoon
- **Count-based**: piece, slice
- **Specialized**: scoop (protein powder), container (yogurt), ear (corn)

### Nutritional Information
All foods include per 100g values:
- Calories (kcal)
- Protein (g)
- Carbohydrates (g)
- Fats (g)

### Localization
All food names are localized in:
- 🇬🇧 English
- 🇹🇷 Turkish (Türkçe)
- 🇪🇸 Spanish (Español)

## Usage

### Adding Foods to Meals
1. Select a meal type (Breakfast, Lunch, Dinner, Snack)
2. Search for food items by name
3. Select serving unit (gram, cup, piece, etc.)
4. Enter amount
5. Nutrition values calculated automatically

### Custom Foods
Users can create custom food items with:
- Custom name
- Brand (optional)
- Nutritional values per 100g
- Custom serving units
- Category assignment

### Favorites
Mark frequently used foods as favorites for quick access.

## Data Sources

Nutritional data is compiled from:
- USDA FoodData Central
- International food composition databases
- Product packaging information
- Verified nutritional references

## Version History

### v1.2.1 (Current) - 2025-11-08
**Added 35 new food items:**

#### Protein (11 new)
- Trout, Sea Bass, Mackerel, Anchovy
- Beef Tenderloin, Meatballs
- Turkey Salami, Turkish Sausage (Sucuk)
- Lor Cheese, Kashar Cheese
- Protein Bar

#### Carbohydrates (10 new)
- Rye Bread, Bran Bread
- Waffle, Pancake, Crepe
- Granola Bar, Popcorn, Rice Cake
- French Fries
- Sushi Rice (Cooked)

#### Vegetables & Fruits (13 new)
- **Vegetables**: Okra, Peas (Fresh), Corn (Fresh), Onion, Garlic, Leek
- **Fruits**: Kiwi, Grapefruit, Melon, Cherry, Apricot, Plum, Fig

#### Fats (6 new)
- Hazelnuts
- Butter, Margarine
- Labneh, Cream Cheese
- Soybean Oil

**Total Library Size:** 146 items (up from 105)

### v1.1.0 - 2025-02-11
- Initial food library with 105 items
- Serving unit system implementation
- Multi-unit support per food item

## Future Enhancements

### Planned Features
- 🔜 Barcode scanning for packaged foods
- 🔜 Recipe builder with ingredient summation
- 🔜 Meal copying across days
- 🔜 Food library expansion to 250+ items
- 🔜 International cuisine additions
- 🔜 Restaurant menu items

### User Requests
- Turkish cuisine specialties (dolma, börek, etc.)
- Fast food chain items (McDonald's, Burger King)
- Regional food varieties
- Branded product database

## Contributing

While this is a portfolio project, feedback on food accuracy or suggestions for additions are welcome:
- 📧 Email: burakkho@gmail.com
- 🐛 Report issues: [GitHub Issues](https://github.com/burakkho/antrain/issues)

## Technical Implementation

### Data Structure
```swift
struct FoodDTO {
    let name: String              // Localized
    let brand: String?            // Optional brand
    let calories: Double          // per 100g
    let protein: Double           // per 100g (grams)
    let carbs: Double             // per 100g (grams)
    let fats: Double              // per 100g (grams)
    let servingSize: Double       // default serving (grams)
    let category: FoodCategory    // protein, carb, fat, vegetable, fruit
    let servingUnits: [ServingUnitDTO]
    let version: Int              // for future migrations
}
```

### Serving Unit System
```swift
struct ServingUnitDTO {
    let unitType: ServingUnitType // gram, cup, piece, etc.
    let gramsPerUnit: Double      // conversion to grams
    let description: String       // localized display text
    let isDefault: Bool           // default selection
    let orderIndex: Int           // display order
}
```

### Categories
```swift
enum FoodCategory: String, Codable {
    case protein
    case carb
    case fat
    case vegetable
    case fruit
}
```

## License

This food library data is part of the Antrain project, licensed under MIT License.

---

**Last Updated:** 2025-11-08
**Library Version:** 1.2.1
**Total Items:** 146
