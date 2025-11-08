# Domain Models - Antrain

**Amaç:** Tüm SwiftData modellerinin özellikleri, ilişkileri, validasyonları ve business rules.

**Format:** Hybrid (teknik terimler İngilizce, açıklamalar Türkçe)

---

## Workout Domain

### Workout

**Amaç:** Bir antrenman seansını temsil eder (lifting, cardio veya metcon)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| date | Date | - | Required | Antrenman başlangıç zamanı |
| type | WorkoutType | - | Required | .lifting / .cardio / .metcon |
| duration | TimeInterval | - | >= 0 | Saniye cinsinden, otomatik hesaplanabilir |
| notes | String? | - | Max 500 char | Kullanıcı notları |
| exercises | [WorkoutExercise] | @Relationship(deleteRule: .cascade) | Lifting için gerekli | Egzersiz listesi |
| cardioType | String? | - | Optional | Cardio tipi (run, bike, row, etc.) |
| cardioDistance | Double? | - | >= 0 | Mesafe (km) |
| cardioPace | Double? | - | >= 0 | Tempo (dk/km) |
| metconType | String? | - | Optional | MetCon tipi (AMRAP, EMOM, For Time) |
| metconRounds | Int? | - | >= 0 | Tamamlanan round sayısı |
| metconResult | String? | - | Max 200 char | Sonuç açıklaması |

**İlişkiler:**
- `1:N WorkoutExercise` (cascade delete) - Workout silinince exercises de silinir

**QuickLogData İmplementasyonu:**
> **Not:** MVP için basitleştirme amacıyla, cardio ve MetCon verileri ayrı bir model yerine
> doğrudan Workout modeline embedded optional property'ler olarak eklenmiştir.
> Bu yaklaşım daha az ilişki yönetimi ve daha basit kod anlamına gelir.
> Gelecek versiyonlarda ayrı bir QuickLogData modeline çıkarılabilir.

**Business Rules:**
```swift
// Validation logic
func validate() throws {
    switch type {
    case .lifting:
        guard !exercises.isEmpty else {
            throw ValidationError.liftingRequiresExercises
        }
    case .cardio:
        guard cardioType != nil else {
            throw ValidationError.cardioTypeRequired
        }
    case .metcon:
        guard metconType != nil else {
            throw ValidationError.metconTypeRequired
        }
    }
}
```

**Edge Cases:**
- ❌ Aynı anda 2 active workout olamaz (state management ile kontrol)
- ⚠️ Kullanıcı workout ortasında app'i kapatırsa → draft/unsaved workout recovery
- ⚠️ Duration 0 olabilir (kullanıcı manuel girmediyse)

---

### WorkoutType

**Enum:** Antrenman tiplerini tanımlar

```swift
enum WorkoutType: String, Codable {
    case lifting    // Real-time tracking
    case cardio     // Post-workout quick log
    case metcon     // Post-workout quick log
}
```

**UX Mapping:**
- `.lifting` → LiftingSessionView (real-time tracking)
- `.cardio` → CardioLogView (quick entry)
- `.metcon` → MetConLogView (quick entry)

---

### WorkoutExercise

**Amaç:** Bir workout içindeki egzersiz (Exercise library'den referans + sets)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| exercise | Exercise | @Relationship(deleteRule: .nullify) | Required | Exercise library'den |
| sets | [WorkoutSet] | @Relationship(deleteRule: .cascade) | Min 1 | Set listesi |
| orderIndex | Int | - | >= 0 | Egzersiz sırası |
| workout | Workout | Inverse relationship | Required | Parent workout |

**İlişkiler:**
- `N:1 Exercise` (no cascade) - Exercise silinirse → exercise = nil, placeholder göster
- `1:N WorkoutSet` (cascade delete)
- `N:1 Workout` (inverse)

**Business Rules:**
- Minimum 1 set gerekli
- orderIndex workout içinde unique olmalı

**Edge Cases:**
- ⚠️ Exercise library'den silinmiş exercise → UI'da "Deleted Exercise" placeholder
- 💡 Sets empty array olamaz

---

### WorkoutSet

**Amaç:** Bir egzersizin tek bir seti (reps + weight + completion state)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| reps | Int | - | > 0 | Tekrar sayısı |
| weight | Double | - | >= 0 | Kg cinsinden (0 = bodyweight) |
| isCompleted | Bool | - | - | Set tamamlandı mı? |
| notes | String? | - | Max 200 char | Set notu (opsiyonel) |
| restTime | TimeInterval? | - | >= 0 | Saniye (MVP scope dışı) |
| workoutExercise | WorkoutExercise | Inverse relationship | Required | Parent exercise |

**İlişkiler:**
- `N:1 WorkoutExercise` (inverse)

**Business Rules:**
- `weight = 0` → bodyweight exercise olarak yorumlanır
- `isCompleted = false` → incomplete set (workout draft)

**Computed Properties:**
```swift
var volume: Double {
    return Double(reps) * weight
}

var oneRepMax: Double {
    // Brzycki formula: weight / (1.0278 - 0.0278 * reps)
    return weight / (1.0278 - 0.0278 * Double(reps))
}
```

---

### Exercise (Library Model)

**Amaç:** Egzersiz kütüphanesi (preset + custom)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String | - | Required, max 100 char | Egzersiz adı |
| category | ExerciseCategory | - | Required | Barbell, dumbbell, bodyweight, cardio, metcon |
| muscleGroups | [MuscleGroup] | - | Min 1 | Hedef kas grupları |
| equipment | Equipment | - | Required | Gerekli ekipman |
| isCustom | Bool | - | - | Kullanıcı tarafından mı eklendi? |
| version | Int | - | >= 1 | Library versioning için |

**Business Rules:**
- Preset exercises: `isCustom = false`, library update'le değişebilir
- Custom exercises: `isCustom = true`, kullanıcıya ait, silinebilir

**Enums:**
```swift
enum ExerciseCategory: String, Codable {
    case barbell, dumbbell, bodyweight, machine, cable
    case cardio, metcon
}

enum MuscleGroup: String, Codable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves
    case core, fullBody
}

enum Equipment: String, Codable {
    case barbell, dumbbell, none, machine, cable
    case kettlebell, plate, band
}
```

---

### QuickLogData

**Amaç:** Cardio ve MetCon workout'ları için post-workout data

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| cardioType | CardioType? | - | Cardio için gerekli | Run, bike, row, etc. |
| distance | Double? | - | > 0 | Km cinsinden |
| pace | Double? | - | > 0 | Min/km cinsinden |
| metconType | MetConType? | - | MetCon için gerekli | AMRAP, EMOM, For Time |
| rounds | Int? | - | > 0 | Tamamlanan round sayısı |
| result | String? | - | Max 200 char | Serbest format sonuç |

**Enums:**
```swift
enum CardioType: String, Codable {
    case run, bike, row, swim, walk, elliptical, ski
}

enum MetConType: String, Codable {
    case amrap      // As Many Rounds As Possible
    case emom       // Every Minute On the Minute
    case forTime    // For Time (timed completion)
}
```

**Business Rules:**
- Cardio workout: `cardioType != nil`
- MetCon workout: `metconType != nil`
- Distance ve pace optional ama ikisi de varsa consistency check

---

## Template Domain

### WorkoutTemplate

**Amaç:** Workout şablonları (preset + custom) - Kullanıcıların favori workout'larını kaydetmesini sağlar

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String | - | Required, max 100 char, unique | Şablon adı |
| category | TemplateCategory | - | Required | Strength, hypertrophy, calisthenics, vb. |
| isPreset | Bool | - | - | Preset mi yoksa kullanıcı şablonu mu? |
| createdAt | Date | - | Required | Oluşturulma tarihi |
| lastUsedAt | Date? | - | Optional | Son kullanım tarihi |
| exercises | [TemplateExercise] | @Relationship(deleteRule: .cascade) | Min 1 | Şablondaki egzersizler |

**İlişkiler:**
- `1:N TemplateExercise` (cascade delete) - Template silinince exercises de silinir

**Computed Properties:**
```swift
var exerciseCount: Int {
    exercises.count
}

var estimatedDuration: TimeInterval {
    // Rough estimate: 3 minutes per set + 1 minute per exercise
    let totalSets = exercises.reduce(0) { $0 + $1.setCount }
    return TimeInterval(totalSets * 180 + exercises.count * 60)
}
```

**Business Rules:**
- Template adı unique olmalı (case-insensitive)
- Preset templates silinemez ve düzenlenemez
- Minimum 1 egzersiz gerekli
- lastUsedAt workout başlatıldığında güncellenir

**Static Methods:**
```swift
static func compare(_ lhs: WorkoutTemplate, _ rhs: WorkoutTemplate) -> Bool {
    // Preset templates önce, sonra alfabetik
    if lhs.isPreset != rhs.isPreset {
        return lhs.isPreset
    }
    return lhs.name < rhs.name
}
```

**Validation:**
```swift
func validate() throws {
    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ValidationError.nameRequired
    }
    guard exercises.count >= 1 else {
        throw ValidationError.minimumOneExercise
    }
}
```

**Edge Cases:**
- ⚠️ Preset template düzenleme isteği → kopyasını oluştur
- ⚠️ Template'deki exercise silinirse → UUID ile lookup başarısız olur, warning göster
- 💡 Duplication: `duplicate(newName:)` method ile deep copy

---

### TemplateExercise

**Amaç:** Template içindeki bir egzersiz (Exercise referansı + set/rep konfigürasyonu)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| order | Int | - | >= 0 | Egzersiz sırası |
| exerciseId | UUID | - | Required | Exercise library'den UUID |
| exerciseName | String | - | Required | Exercise adı (denormalized) |
| setCount | Int | - | 1-10 | Önerilen set sayısı |
| repRangeMin | Int | - | > 0 | Minimum tekrar sayısı |
| repRangeMax | Int | - | >= repRangeMin | Maximum tekrar sayısı |
| notes | String? | - | Max 200 char | Egzersiz notları |
| template | WorkoutTemplate | Inverse relationship | Required | Parent template |

**İlişkiler:**
- `N:1 WorkoutTemplate` (inverse)

**Business Rules:**
- `exerciseId` Exercise library'deki bir egzersize referans
- `exerciseName` denormalized olarak saklanır (exercise silinse bile adı görünsün)
- `repRangeMin <= repRangeMax`
- `setCount` 1-10 arasında olmalı

**Static Methods:**
```swift
static func compare(_ lhs: TemplateExercise, _ rhs: TemplateExercise) -> Bool {
    return lhs.order < rhs.order
}
```

**Edge Cases:**
- ⚠️ Exercise library'den silinmiş egzersiz → exerciseName ile göster, UUID lookup başarısız
- 💡 Order değerleri template içinde unique olmalı
- ⚠️ RepRange validation: min <= max kontrolü

---

### TemplateCategory

**Enum:** Template kategorileri

```swift
enum TemplateCategory: String, Codable, CaseIterable {
    case strength       // Powerlifting, strength focused
    case hypertrophy    // Muscle building, volume focused
    case calisthenics   // Bodyweight movements
    case weightlifting  // Olympic lifting
    case beginner       // Beginner-friendly programs
    case custom         // User-defined category
}
```

**Computed Properties:**
```swift
var icon: String {
    switch self {
    case .strength: return "figure.strengthtraining.traditional"
    case .hypertrophy: return "figure.strengthtraining.functional"
    case .calisthenics: return "figure.gymnastics"
    case .weightlifting: return "figure.strengthtraining"
    case .beginner: return "figure.walk"
    case .custom: return "star.fill"
    }
}

var color: Color {
    switch self {
    case .strength: return .red
    case .hypertrophy: return .blue
    case .calisthenics: return .green
    case .weightlifting: return .orange
    case .beginner: return .purple
    case .custom: return .gray
    }
}

var displayName: String {
    switch self {
    case .strength: return "Strength"
    case .hypertrophy: return "Hypertrophy"
    case .calisthenics: return "Calisthenics"
    case .weightlifting: return "Weightlifting"
    case .beginner: return "Beginner"
    case .custom: return "Custom"
    }
}
```

**UX Mapping:**
- Kategori filtreleme chip'lerinde kullanılır
- Yeni template oluştururken seçilir
- Preset templates otomatik kategorilendirilir

---

## Nutrition Domain

### NutritionLog

**Amaç:** Bir günün nutrition kaydı (günlük macro takibi)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| date | Date | @Attribute(.unique) | Required | Gün (time component ignore) |
| meals | [Meal] | @Relationship(deleteRule: .cascade) | - | Günlük öğünler |

**İlişkiler:**
- `1:N Meal` (cascade delete)

**Computed Properties:**
```swift
var totalCalories: Double {
    meals.reduce(0) { $0 + $1.totalCalories }
}

var totalProtein: Double {
    meals.reduce(0) { $0 + $1.totalProtein }
}

var totalCarbs: Double {
    meals.reduce(0) { $0 + $1.totalCarbs }
}

var totalFats: Double {
    meals.reduce(0) { $0 + $1.totalFats }
}
```

**Business Rules:**
- Her gün için sadece 1 NutritionLog olabilir (date unique constraint)
- date component'i time'sız (Calendar.startOfDay)

---

### Meal

**Amaç:** Bir öğün (breakfast, lunch, dinner, snack)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String | - | Required | "Breakfast", "Lunch", "Dinner", "Snack" |
| timestamp | Date | - | Required | Öğün zamanı |
| foodEntries | [FoodEntry] | @Relationship(deleteRule: .cascade) | - | Öğündeki yiyecekler |
| nutritionLog | NutritionLog | Inverse relationship | Required | Parent log |

**İlişkiler:**
- `1:N FoodEntry` (cascade delete)
- `N:1 NutritionLog` (inverse)

**Computed Properties:**
```swift
var totalCalories: Double {
    foodEntries.reduce(0) { $0 + $1.calories }
}

var totalProtein: Double {
    foodEntries.reduce(0) { $0 + $1.protein }
}

var totalCarbs: Double {
    foodEntries.reduce(0) { $0 + $1.carbs }
}

var totalFats: Double {
    foodEntries.reduce(0) { $0 + $1.fats }
}
```

**Predefined Meal Types:**
- Breakfast (Kahvaltı)
- Lunch (Öğle Yemeği)
- Dinner (Akşam Yemeği)
- Snack (Atıştırmalık)

---

### FoodItem (Library Model)

**Amaç:** Yiyecek kütüphanesi (preset + custom)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String | - | Required, max 100 char | Yiyecek adı |
| brand | String? | - | Max 50 char | Marka (opsiyonel) |
| calories | Double | - | >= 0 | Per 100g |
| protein | Double | - | >= 0 | Per 100g (gram) |
| carbs | Double | - | >= 0 | Per 100g (gram) |
| fats | Double | - | >= 0 | Per 100g (gram) |
| servingSize | Double | - | > 0 | Default serving (gram) |
| category | FoodCategory | - | Required | Protein, carb, fat, vegetable, other |
| isCustom | Bool | - | - | Kullanıcı tarafından mı eklendi? |
| isFavorite | Bool | - | - | Favorilere eklendi mi? (MVP Phase 2) |
| version | Int | - | >= 1 | Library versioning için |

**Enums:**
```swift
enum FoodCategory: String, Codable {
    case protein, carb, fat, vegetable, fruit, dairy, other
}
```

**Business Rules:**
- Tüm nutrition values **100g baz**ında
- Custom foods silinebilir, preset foods silinemez

---

### FoodEntry

**Amaç:** Bir öğündeki yiyecek girişi (FoodItem + serving amount)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| foodItem | FoodItem | @Relationship(deleteRule: .nullify) | Required | Food library'den |
| servingAmount | Double | - | > 0 | Gram cinsinden miktar |
| meal | Meal | Inverse relationship | Required | Parent meal |

**İlişkiler:**
- `N:1 FoodItem` (no cascade) - FoodItem silinirse → foodItem = nil, placeholder göster
- `N:1 Meal` (inverse)

**Computed Properties:**
```swift
// 100g bazından actual serving'e çevir
var calories: Double {
    (foodItem.calories / 100) * servingAmount
}

var protein: Double {
    (foodItem.protein / 100) * servingAmount
}

var carbs: Double {
    (foodItem.carbs / 100) * servingAmount
}

var fats: Double {
    (foodItem.fats / 100) * servingAmount
}
```

**Edge Cases:**
- ⚠️ FoodItem library'den silinirse → UI'da "Deleted Food" placeholder

---

### MacroPreset

**Amaç:** Önceden tanımlı makro dağılımı şablonları (Balanced, Keto, High Protein, etc.)

**Location:** `/Core/Domain/Models/Nutrition/MacroPreset.swift`

| Property | Type | Notlar |
|----------|------|--------|
| id | UUID | Identifiable conformance |
| name | String | Preset adı (e.g., "Balanced", "Keto") |
| proteinPercent | Double | Protein yüzdesi (0.0-1.0) |
| carbsPercent | Double | Karbonhidrat yüzdesi (0.0-1.0) |
| fatsPercent | Double | Yağ yüzdesi (0.0-1.0) |
| description | String | Açıklama (e.g., "30% P / 40% C / 30% F - General fitness") |

**Pure Functions:**
```swift
func calculateMacros(calories: Double) -> (protein: Double, carbs: Double, fats: Double)
```

**Predefined Presets:**
- **Balanced**: 30% P / 40% C / 30% F - General fitness
- **High Protein**: 40% P / 30% C / 30% F - Muscle building
- **Keto**: 30% P / 5% C / 65% F - Ketogenic diet
- **Low Carb**: 35% P / 20% C / 45% F - Fat loss
- **Endurance**: 20% P / 55% C / 25% F - Cardio performance

**Conformances:**
- `Identifiable`, `Sendable`

**Design Notes:**
- Pure domain model, zero dependencies
- Calculation logic içerir (Domain layer'a uygun)
- View layer'dan Domain layer'a taşındı (Clean Architecture compliance)

---

### MacroCalculator

**Amaç:** Macro ↔ Calorie dönüşümleri için pure calculation functions

**Location:** `/Core/Domain/Extensions/MacroCalculator.swift`

**Static Functions:**

| Function | Açıklama |
|----------|----------|
| `calculateCalories(protein:carbs:fats:)` | Macro gramlarından toplam kalori hesaplar |
| `scaleMacrosToCalories(currentProtein:currentCarbs:currentFats:targetCalories:)` | Macro'ları hedef kaloriye proportional scale eder |
| `calculateMacroPercentages(protein:carbs:fats:)` | Macro dağılımını yüzde olarak hesaplar |
| `validateMacroPercentages(proteinPercent:carbsPercent:fatsPercent:tolerance:)` | Yüzdelerin toplamının %100 olduğunu validate eder |

**Constants:**
```swift
static let caloriesPerGramProtein: Double = 4.0
static let caloriesPerGramCarbs: Double = 4.0
static let caloriesPerGramFats: Double = 9.0
```

**Design Notes:**
- Pure functions, zero dependencies
- Fully testable
- Used by ViewModels for calculations
- Domain layer extension (Clean Architecture compliance)

---

### TDEECalculator

**Amaç:** TDEE (Total Daily Energy Expenditure) hesaplamaları ve makro önerileri

**Location:** `/Core/Domain/Extensions/TDEECalculator.swift`

**Activity Levels:**
- Sedentary (1.2x multiplier)
- Lightly Active (1.375x)
- Moderately Active (1.55x)
- Very Active (1.725x)
- Extremely Active (1.9x)

**Goal Types:**
- Aggressive Cut (-500 kcal)
- Cut (-300 kcal)
- Maintain (0 kcal)
- Lean Bulk (+200 kcal)
- Bulk (+400 kcal)

**Static Functions:**
```swift
static func calculateBMR(weight:height:age:gender:) -> Double
static func calculateTDEE(weight:height:age:gender:activityLevel:) -> Double
static func recommendedCalories(tdee:goal:) -> Double
static func recommendedMacros(calories:weight:goal:) -> (protein: Double, carbs: Double, fats: Double)
```

**Design Notes:**
- Uses Mifflin-St Jeor formula for BMR
- Gender-specific calculations
- Goal-based macro recommendations

---

## Nutrition ViewModels

### NutritionGoalsEditorViewModel

**Amaç:** Nutrition goals düzenleme iş mantığı

**Location:** `/Features/Nutrition/ViewModels/NutritionGoalsEditorViewModel.swift`

**Dependencies:**
- `UserProfileRepositoryProtocol`

**State Properties:**
| Property | Type | Açıklama |
|----------|------|----------|
| calories | String | Kalori input (String for TextField) |
| protein | String | Protein input |
| carbs | String | Carbs input |
| fats | String | Fats input |
| isSaving | Bool | Save state |
| errorMessage | String? | Error message |
| userProfile | UserProfile? | Current user profile |
| lastEditedField | EditedField? | Track last edited field |
| isUpdating | Bool | Prevent circular updates |
| calculationMode | CalculationMode | Macro→Calorie or Calorie→Macro |
| showTDEECalculator | Bool | Show/hide TDEE section |
| selectedGoalType | TDEECalculator.GoalType | Selected goal |
| originalGoals | (calories, protein, carbs, fats)? | Original values for diff |

**Business Logic:**
```swift
func loadCurrentGoals() async
func handleMacroChange() // Uses MacroCalculator
func handleCalorieChange(_ newCalorieString: String) // Uses MacroCalculator
func applyTDEERecommendation(calories:macros:)
func applyPreset(protein:carbs:fats:)
func saveGoals() async throws
func getTDEECalculationData() -> (age, height, gender, activityLevel, weight)?
```

**Design Notes:**
- Extracted from SmartNutritionGoalsEditor View (565 lines of business logic)
- Uses MacroCalculator for all calculations
- Repository access through dependency injection
- @Observable @MainActor for SwiftUI integration

---

### NutritionOnboardingViewModel

**Amaç:** First-time nutrition goals onboarding wizard iş mantığı

**Location:** `/Features/Nutrition/ViewModels/NutritionOnboardingViewModel.swift`

**Dependencies:**
- `UserProfileRepositoryProtocol`

**State Properties:**
| Property | Type | Açıklama |
|----------|------|----------|
| currentStep | Int | Current wizard step (0-4) |
| dateOfBirth | Date | User's date of birth |
| height | Double | Height in cm |
| weight | Double | Weight in kg |
| gender | UserProfile.Gender | User's gender |
| activityLevel | UserProfile.ActivityLevel | Activity level |
| selectedGoal | TDEECalculator.GoalType | Selected goal |
| isSaving | Bool | Save state |
| errorMessage | String? | Error message |
| totalSteps | Int | Total wizard steps (5) |

**Business Logic:**
```swift
func nextStep()
func previousStep()
func completeOnboarding() async throws -> (tdee, recommendedCalories, macros)
```

**Design Notes:**
- Extracted from NutritionGoalsOnboardingWizard View
- Orchestrates profile update, weight entry, TDEE calculation
- Manages UserDefaults for onboarding completion
- Returns calculated recommendations to View

---

### DailyNutritionViewModel

**Amaç:** Daily nutrition tracking state management

**Location:** `/Features/Nutrition/ViewModels/DailyNutritionViewModel.swift`

**Dependencies:**
- `NutritionRepositoryProtocol`
- `UserProfileRepositoryProtocol`

**State Properties:**
| Property | Type | Açıklama |
|----------|------|----------|
| currentDate | Date | Selected date |
| nutritionLog | NutritionLog? | Current day's log |
| userProfile | UserProfile? | User profile |
| isLoading | Bool | Loading state |
| errorMessage | String? | Error message |
| dailyCaloriesGoal | Double | Daily calorie goal |
| dailyProteinGoal | Double | Daily protein goal |
| dailyCarbsGoal | Double | Daily carbs goal |
| dailyFatsGoal | Double | Daily fats goal |

**Computed Properties:**
```swift
var totalCalories: Double
var totalProtein: Double
var totalCarbs: Double
var totalFats: Double
var caloriesProgress: Double
var proteinProgress: Double
var carbsProgress: Double
var fatsProgress: Double
```

**Business Logic:**
```swift
func loadGoals() async
func updateNutritionGoals(calories:protein:carbs:fats:) async throws
func loadTodayLog() async
func addFood(to:food:amount:) async
func removeFood(from:foodEntryId:) async
func getMeal(for:) -> Meal
func changeDate(to:) async
```

---

## User Domain

### UserProfile

**Amaç:** Kullanıcı profili ve günlük makro hedefleri

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String? | - | Max 50 char | Kullanıcı adı (opsiyonel) |
| dailyCalorieGoal | Double | - | > 0 | Günlük kalori hedefi |
| dailyProteinGoal | Double | - | >= 0 | Gram cinsinden |
| dailyCarbsGoal | Double | - | >= 0 | Gram cinsinden |
| dailyFatsGoal | Double | - | >= 0 | Gram cinsinden |
| bodyweightHistory | [BodyweightEntry] | @Relationship(deleteRule: .cascade) | - | Kilo geçmişi |

**İlişkiler:**
- `1:N BodyweightEntry` (cascade delete)

**Business Rules:**
- Uygulama genelinde **sadece 1 UserProfile** olabilir (singleton pattern)
- İlk launch'ta default values ile oluşturulur

**Default Values:**
```swift
static var defaultProfile: UserProfile {
    UserProfile(
        dailyCalorieGoal: 2000,
        dailyProteinGoal: 150,
        dailyCarbsGoal: 200,
        dailyFatsGoal: 65
    )
}
```

**UI Integration (v1.2):**
- **ProfileView**: Main view in Profile tab (4th tab in MainTabView)
  - Displays all profile fields with edit buttons
  - Manages bodyweight tracking UI
  - Toolbar Settings button → SettingsView (fullScreenCover)

**Component Mapping:**
- `name` → ProfileNameEditorSheet (TextField)
- `height` → ProfileHeightEditorSheet (decimal input with unit conversion)
- `gender` → ProfileGenderEditorSheet (Picker)
- `dateOfBirth` → ProfileDateOfBirthEditorSheet (DatePicker graphical)
- `activityLevel` → ProfileActivityLevelEditorSheet (Picker with descriptions)
- `bodyweightEntries` → ProfileBodyweightEntrySheet (add), ProfileBodyweightHistorySheet (view/delete)

**ViewModel:**
- ProfileViewModel manages UserProfile CRUD operations
- Loads profile on view appear
- All updates are async/await with error handling

---

### BodyweightEntry

**Amaç:** Kullanıcının kilo kaydı (manual entry)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| date | Date | - | Required | Ölçüm tarihi |
| weight | Double | - | > 0 | Kg cinsinden |
| userProfile | UserProfile | Inverse relationship | Required | Parent profile |

**İlişkiler:**
- `N:1 UserProfile` (inverse)

**Business Rules:**
- Aynı gün için birden fazla entry olabilir (son entry geçerli sayılır)
- Chart için günlük average hesaplanabilir

---

## SwiftData Relationships Summary

| Parent | Child | Relationship | Delete Rule | Rationale |
|--------|-------|--------------|-------------|-----------|
| Workout | WorkoutExercise | 1:N | Cascade | Workout silinince exercises de silinmeli |
| Workout | QuickLogData | 1:1? | Cascade | Quick log data workout'a ait |
| WorkoutExercise | WorkoutSet | 1:N | Cascade | Exercise silinince setler de silinmeli |
| WorkoutExercise | Exercise (Library) | N:1 | Nullify | Library item silinse workout'ı etkilemez |
| NutritionLog | Meal | 1:N | Cascade | Log silinince meals de silinmeli |
| Meal | FoodEntry | 1:N | Cascade | Meal silinince entries de silinmeli |
| FoodEntry | FoodItem (Library) | N:1 | Nullify | Library item silinse meal'ı etkilemez |
| UserProfile | BodyweightEntry | 1:N | Cascade | Profile silinince history de silinmeli |

---

## Validation Strategy

**Approach:** Model-level validation methods

```swift
protocol Validatable {
    func validate() throws
}

enum ValidationError: LocalizedError {
    case emptyField(String)
    case invalidValue(String)
    case businessRuleViolation(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) boş olamaz"
        case .invalidValue(let message):
            return "Geçersiz değer: \(message)"
        case .businessRuleViolation(let message):
            return "İş kuralı ihlali: \(message)"
        }
    }
}
```

**Usage:** ViewModel'de save etmeden önce validate()

---

## PersonalRecord

**Amaç:** Kullanıcının egzersizlerdeki kişisel rekorlarını (PR) saklar ve takip eder.

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| exerciseId | UUID | - | Required | Egzersizin benzersiz ID'si |
| exerciseName | String | - | Required | Egzersiz adı (snapshot) |
| date | Date | - | Required | PR elde edildiği tarih |
| weight | Double | - | > 0 | Kilogram cinsinden ağırlık |
| reps | Int | - | > 0 | Tekrar sayısı |
| oneRepMax | Double | - | > 0 | Hesaplanan 1RM (Brzycki formülü) |

**İlişkiler:**
- İlişkisiz model (denormalized) - Exercise'a doğrudan referans yok
- Exercise silininse PR'lar kalır (historical record)

**Business Rules:**
```swift
// 1RM Calculation (Brzycki Formula)
func calculateOneRepMax() -> Double {
    if reps == 1 {
        return weight
    }
    return weight * (36.0 / (37.0 - Double(reps)))
}

// PR Detection
func isPR(for exercise: Exercise, in context: ModelContext) -> Bool {
    let existingPRs = fetchPRs(for: exercise.id, in: context)
    let currentMax = calculateOneRepMax()
    return existingPRs.allSatisfy { $0.oneRepMax < currentMax }
}
```

**Özellikler:**
- ✅ Otomatik PR tespiti (PRDetectionService)
- ✅ 1RM hesaplaması (OneRepMaxCalculator extension)
- ✅ Egzersiz bazında en iyi performans takibi
- ✅ Tarihsel kayıt (exercise silinse bile PR kalır)

**Edge Cases:**
- ⚠️ Aynı exercise için birden fazla PR olabilir (tarih bazlı)
- ⚠️ exerciseName snapshot olarak saklanır (name değişirse PR'da eski isim kalır)

---

**Son Güncelleme:** 2025-11-03
**Dosya Boyutu:** ~260 satır
**Token Efficiency:** Table-heavy, minimal prose
