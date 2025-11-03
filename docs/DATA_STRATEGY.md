# Data Strategy - Antrain

**Amaç:** Exercise ve Food library'lerinin yönetimi, seed data, versioning, custom items

---

## Library vs User Data

### Library Data (Preset)
- **Exercise Library:** 150+ preset exercises
- **Food Library:** 100+ preset foods
- **Characteristics:**
  - `isCustom = false`
  - Read-only (kullanıcı silemez/düzenleyemez)
  - Version controlled (library update'le değişebilir)
  - App bundle içinde tanımlı

### User Data (Custom)
- **Custom Exercises:** Kullanıcının eklediği egzersizler
- **Custom Foods:** Kullanıcının eklediği yiyecekler
- **Characteristics:**
  - `isCustom = true`
  - CRUD allowed (kullanıcı silebilir/düzenleyebilir)
  - Persist in SwiftData
  - No versioning

---

## Exercise Library Structure

### Storage Strategy: **Swift Code (Structs)**

**Neden code, JSON değil?**
- Type-safe (compile-time validation)
- No runtime parsing errors
- Easy to maintain and search
- Claude Code ile kolay generate edilebilir

### File Organization

```
Core/Data/Libraries/ExerciseLibrary/
├── ExerciseLibrary.swift           # Main library interface
├── ExerciseDTO.swift                # DTO → Model mapping
├── BarbellExercises.swift           # Barbell exercise data (~30 exercises)
├── DumbbellExercises.swift          # Dumbbell exercise data (~30 exercises)
├── BodyweightExercises.swift        # Bodyweight exercise data (~30 exercises)
├── MachineExercises.swift           # Machine exercise data (~20 exercises)
├── CardioExercises.swift            # Cardio exercise data (~20 exercises)
└── MetConExercises.swift            # MetCon exercise data (~20 exercises)
```

**Her dosya ~100-150 satır** (micro-modular approach)

### Exercise DTO Pattern

```swift
// ExerciseDTO.swift
struct ExerciseDTO {
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let equipment: Equipment
    let version: Int = 1

    func toModel() -> Exercise {
        Exercise(
            name: name,
            category: category,
            muscleGroups: muscleGroups,
            equipment: equipment,
            isCustom: false,
            version: version
        )
    }
}
```

### Example Exercise Data File

```swift
// BarbellExercises.swift
struct BarbellExercises {
    static let all: [ExerciseDTO] = [
        ExerciseDTO(
            name: "Barbell Squat",
            category: .barbell,
            muscleGroups: [.quads, .glutes, .core],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Bench Press",
            category: .barbell,
            muscleGroups: [.chest, .triceps, .shoulders],
            equipment: .barbell
        ),
        ExerciseDTO(
            name: "Barbell Deadlift",
            category: .barbell,
            muscleGroups: [.back, .hamstrings, .glutes],
            equipment: .barbell
        ),
        // ... ~30 barbell exercises
    ]
}
```

### ExerciseLibrary Interface

```swift
// ExerciseLibrary.swift
protocol ExerciseLibraryProtocol {
    func getAllPresetExercises() -> [Exercise]
    func searchExercises(query: String, category: ExerciseCategory?) -> [Exercise]
}

final class ExerciseLibrary: ExerciseLibraryProtocol {
    private lazy var presetExercises: [Exercise] = {
        let dtos = BarbellExercises.all +
                   DumbbellExercises.all +
                   BodyweightExercises.all +
                   MachineExercises.all +
                   CardioExercises.all +
                   MetConExercises.all

        return dtos.map { $0.toModel() }
    }()

    func getAllPresetExercises() -> [Exercise] {
        return presetExercises
    }

    func searchExercises(query: String, category: ExerciseCategory?) -> [Exercise] {
        var results = presetExercises

        if let category {
            results = results.filter { $0.category == category }
        }

        if !query.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }

        return results.sorted { $0.name < $1.name }
    }
}
```

---

## Food Library Structure

### Storage Strategy: **Swift Code (Structs)**

Same rationale as Exercise Library (type-safe, maintainable)

### File Organization

```
Core/Data/Libraries/FoodLibrary/
├── FoodLibrary.swift                # Main library interface
├── FoodDTO.swift                    # DTO → Model mapping
├── ProteinFoods.swift               # ~25 protein sources
├── CarbFoods.swift                  # ~25 carb sources
├── FatFoods.swift                   # ~20 fat sources
├── VegetableFoods.swift             # ~20 vegetables
└── FruitFoods.swift                 # ~10 fruits
```

### Food DTO Pattern

```swift
// FoodDTO.swift
struct FoodDTO {
    let name: String
    let brand: String?
    let calories: Double    // per 100g
    let protein: Double     // per 100g
    let carbs: Double       // per 100g
    let fats: Double        // per 100g
    let servingSize: Double // default serving (grams)
    let category: FoodCategory
    let version: Int = 1

    func toModel() -> FoodItem {
        FoodItem(
            name: name,
            brand: brand,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats,
            servingSize: servingSize,
            category: category,
            isCustom: false,
            isFavorite: false,
            version: version
        )
    }
}
```

### Example Food Data File

```swift
// ProteinFoods.swift
struct ProteinFoods {
    static let all: [FoodDTO] = [
        FoodDTO(
            name: "Tavuk Göğsü",
            brand: nil,
            calories: 165,
            protein: 31.0,
            carbs: 0.0,
            fats: 3.6,
            servingSize: 150,
            category: .protein
        ),
        FoodDTO(
            name: "Yumurta",
            brand: nil,
            calories: 155,
            protein: 13.0,
            carbs: 1.1,
            fats: 11.0,
            servingSize: 50,
            category: .protein
        ),
        // ... ~25 protein foods
    ]
}
```

---

## Seed Data Loading Strategy

### Initial Seed (First Launch)

**Workflow:**
1. App launch → Check if library already populated
2. If empty → Load preset exercises/foods into SwiftData
3. Mark as seeded (UserDefaults flag)

**Implementation:**
```swift
// PersistenceController.swift
actor PersistenceController {
    static let shared = PersistenceController()

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Workout.self, Exercise.self, FoodItem.self, NutritionLog.self
            )
            modelContext = modelContainer.mainContext

            // Seed libraries on first launch
            Task {
                await seedLibrariesIfNeeded()
            }
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    func seedLibrariesIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededLibraries")

        guard !hasSeeded else { return }

        // Seed exercises
        let exerciseLibrary = ExerciseLibrary()
        let presetExercises = exerciseLibrary.getAllPresetExercises()

        for exercise in presetExercises {
            modelContext.insert(exercise)
        }

        // Seed foods
        let foodLibrary = FoodLibrary()
        let presetFoods = foodLibrary.getAllPresetFoods()

        for food in presetFoods {
            modelContext.insert(food)
        }

        do {
            try modelContext.save()
            UserDefaults.standard.set(true, forKey: "hasSeededLibraries")
            print("✅ Libraries seeded successfully")
        } catch {
            print("❌ Failed to seed libraries: \(error)")
        }
    }
}
```

**Neden SwiftData'ya insert ediyoruz?**
- Kullanıcı custom items ekleyebilir (aynı modelde)
- Search performansı (SwiftData query optimizations)
- Offline-first (network gereksiz)

---

## Custom Items Strategy

### User Flow: Add Custom Exercise

```
[Exercise Selection View]
    │
    ├─ Tap "Add Custom Exercise"
    │
    ▼
[Custom Exercise Form]
    │
    ├─ Name: TextField
    ├─ Category: Picker
    ├─ Muscle Groups: Multi-select
    ├─ Equipment: Picker
    │
    ├─ Tap "Save"
    │
    ▼
[Exercise Saved with isCustom = true]
```

### Repository Pattern

```swift
protocol ExerciseRepositoryProtocol {
    func fetchAll() async throws -> [Exercise]
    func fetchPresetOnly() async throws -> [Exercise]
    func fetchCustomOnly() async throws -> [Exercise]
    func save(_ exercise: Exercise) async throws
    func delete(_ exercise: Exercise) async throws // Only if isCustom = true
}

actor ExerciseRepository: ExerciseRepositoryProtocol {
    private let modelContext: ModelContext

    func save(_ exercise: Exercise) async throws {
        try exercise.validate()
        modelContext.insert(exercise)
        try modelContext.save()
    }

    func delete(_ exercise: Exercise) async throws {
        guard exercise.isCustom else {
            throw RepositoryError.cannotDeletePreset
        }
        modelContext.delete(exercise)
        try modelContext.save()
    }
}
```

---

## Versioning Strategy

### Library Version Tracking

**Purpose:** Future library updates (add new exercises/foods, fix macros)

**Model:**
```swift
@Model
final class Exercise {
    // ... other properties
    var version: Int  // Library version

    // Preset: version from library
    // Custom: version = 0 (not versioned)
}
```

### Future Update Strategy (Post-MVP)

**Scenario:** App update ile yeni exercise'lar eklemek

**Approach:**
1. Increment library version (e.g., v1 → v2)
2. On app launch, check library version
3. If outdated, insert new items
4. Never modify existing preset items (data integrity)

```swift
func updateLibraryIfNeeded() async {
    let currentVersion = UserDefaults.standard.integer(forKey: "libraryVersion")
    let latestVersion = 2

    if currentVersion < latestVersion {
        // Insert new exercises from v2
        // ...
        UserDefaults.standard.set(latestVersion, forKey: "libraryVersion")
    }
}
```

**MVP:** Library versioning yapısı var ama update logic Phase 2

---

## Preview/Mock Data Strategy

### SwiftUI Previews

**In-Memory ModelContainer:**
```swift
extension ModelContainer {
    static var preview: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Workout.self, Exercise.self, FoodItem.self,
            configurations: config
        )

        // Insert sample data
        let context = container.mainContext

        let sampleExercise = Exercise(
            name: "Bench Press",
            category: .barbell,
            muscleGroups: [.chest],
            equipment: .barbell,
            isCustom: false,
            version: 1
        )
        context.insert(sampleExercise)

        return container
    }
}
```

**Usage in Preview:**
```swift
#Preview {
    LiftingSessionView()
        .modelContainer(.preview)
        .environment(AppDependencies.preview)
}
```

---

## Search & Filtering Strategy

### Exercise Search

**Index Fields:** name, category, muscleGroups

**Search Logic:**
```swift
func searchExercises(
    query: String,
    category: ExerciseCategory?,
    muscleGroup: MuscleGroup?
) async throws -> [Exercise] {
    var predicate: Predicate<Exercise>?

    if let category {
        predicate = #Predicate { $0.category == category }
    }

    if !query.isEmpty {
        let searchPredicate = #Predicate<Exercise> {
            $0.name.localizedStandardContains(query)
        }
        predicate = predicate.map { $0 && searchPredicate } ?? searchPredicate
    }

    let descriptor = FetchDescriptor<Exercise>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.name)]
    )

    return try modelContext.fetch(descriptor)
}
```

### Food Search

Same pattern as exercises, filter by name and category

---

## Data Integrity Rules

| Rule | Enforcement | Rationale |
|------|-------------|-----------|
| Preset items cannot be deleted | Repository logic | Prevent user mistakes |
| Preset items cannot be edited | UI disabled | Maintain consistency |
| Custom items fully editable | No restrictions | User ownership |
| Library version monotonically increasing | Update logic | Migration safety |
| Exercise referenced in workout not deletable | Soft delete or prevent | Data integrity |

---

**Son Güncelleme:** 2025-02-11
**Dosya Boyutu:** ~180 satır
**Token Efficiency:** Code examples, clear structure
