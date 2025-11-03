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
| quickLogData | QuickLogData? | @Relationship(deleteRule: .cascade) | Cardio/MetCon için gerekli | Hızlı log datası |

**İlişkiler:**
- `1:N WorkoutExercise` (cascade delete) - Workout silinince exercises de silinir
- `1:1 QuickLogData?` (cascade delete) - Sadece cardio/metcon için

**Business Rules:**
```swift
// Validation logic
func validate() throws {
    switch type {
    case .lifting:
        guard !exercises.isEmpty else {
            throw ValidationError.liftingRequiresExercises
        }
    case .cardio, .metcon:
        guard quickLogData != nil else {
            throw ValidationError.quickLogRequired
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

**Son Güncelleme:** 2025-02-11
**Dosya Boyutu:** ~220 satır
**Token Efficiency:** Table-heavy, minimal prose
