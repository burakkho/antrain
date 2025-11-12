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
| rating | Int? | - | 1-5 | Kullanıcı antrenman puanı (opsiyonel) |
| exercises | [WorkoutExercise] | @Relationship(deleteRule: .cascade) | Lifting için gerekli | Egzersiz listesi |
| programId | UUID? | - | Optional | Hangi TrainingProgram'a ait |
| programDayId | UUID? | - | Optional | Hangi ProgramDay'e ait |
| programDayNumber | Int? | - | Optional | Programdaki gün numarası |
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

### WorkoutComparison (Helper Struct)

**Amaç:** İki antrenmanı karşılaştırarak ilerlemeyi gösterir.
**Not:** Bu bir SwiftData modeli değildir, `WorkoutSummaryView` gibi view'larda kullanılan bir yardımcı `struct`'tır.

---

## Program Domain

### TrainingProgram

**Amaç:** Sıralı antrenman günlerinden oluşan bir antrenman programı.

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| name | String | - | Required, max 100 char | Program adı |
| programDescription | String? | - | Optional | Program açıklaması |
| category | ProgramCategory | - | Required | Program kategorisi |
| difficulty | DifficultyLevel | - | Required | Zorluk seviyesi |
| totalDays | Int | - | 1-365 | Toplam gün sayısı |
| isCustom | Bool | - | - | Kullanıcı programı mı, preset mi? |
| createdAt | Date | - | Required | Oluşturulma tarihi |
| lastUsedAt | Date? | - | Optional | Son kullanım tarihi |
| days | [ProgramDay] | @Relationship(deleteRule: .cascade) | Min 1 | Program günleri |

**İlişkiler:**
- `1:N ProgramDay` (cascade delete)

**Business Rules:**
- Program adı unique olmalı.
- `totalDays` 1 ile 365 arasında olmalı.
- En az bir `ProgramDay` içermeli.

---

### ProgramDay

**Amaç:** Bir program içindeki, bir antrenman şablonuna referans içeren gün.

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| dayNumber | Int | - | >= 1 | Programdaki gün sırası |
| name | String? | - | Optional | "Push Day", "Upper Body" gibi |
| notes | String? | - | Max 500 char | Gün için notlar |
| program | TrainingProgram? | Inverse relationship | Required | Parent program |
| template | WorkoutTemplate? | @Relationship(deleteRule: .nullify) | Optional | İlişkili antrenman şablonu (nil = rest day) |

**İlişkiler:**
- `N:1 TrainingProgram` (inverse)
- `N:1 WorkoutTemplate` (nullify) - Template silinirse bu alan nil olur.

**Computed Properties:**
- `isRestDay`: `template` nil ise `true` döner.

---

### ProgramCategory

**Enum:** Antrenman programı kategorileri.

```swift
enum ProgramCategory: String, Codable, CaseIterable, Sendable {
    case powerlifting, bodybuilding, strength, calisthenics
    case strengthTraining, crossfit, generalFitness, sportSpecific
}
```

---

### DifficultyLevel

**Enum:** Antrenman programı zorluk seviyesi.

```swift
enum DifficultyLevel: String, Codable, CaseIterable, Sendable {
    case beginner, intermediate, advanced
}
```

---

### TrainingPhase

**Enum:** Antrenman periyodizasyon fazları.

```swift
enum TrainingPhase: String, Codable, CaseIterable, Sendable {
    case hypertrophy, strength, peaking, deload, testing
}
```

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

**Business Rules:**
- Template adı unique olmalı (case-insensitive)
- Preset templates silinemez ve düzenlenemez
- Minimum 1 egzersiz gerekli

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

---

### TemplateCategory

**Enum:** Template kategorileri

```swift
enum TemplateCategory: String, Codable, CaseIterable {
    case strength, hypertrophy, calisthenics, weightlifting, beginner, custom
}
```

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

**Business Rules:**
- Her gün için sadece 1 NutritionLog olabilir (date unique constraint)

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
| servingUnits | [ServingUnit] | @Relationship(deleteRule: .cascade) | - | Alternatif porsiyon birimleri |
| category | FoodCategory | - | Required | Protein, carb, fat, vegetable, other |
| isCustom | Bool | - | - | Kullanıcı tarafından mı eklendi? |
| isFavorite | Bool | - | - | Favorilere eklendi mi? (MVP Phase 2) |
| version | Int | - | >= 1 | Library versioning için |

**İlişkiler:**
- `1:N ServingUnit` (cascade delete)

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

---

### ServingUnit

**Amaç:** Gıda ürünleri için porsiyon birimleri (örn: kase, adet, ölçek).

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| unitType | ServingUnitType | - | Required | Birim tipi (gram, cup, piece, etc.) |
| gramsPerUnit | Double | - | > 0 | Birim başına gram miktarı |
| unitDescription | String | - | Required | "1 kase", "1 adet" gibi |
| isDefault | Bool | - | - | Bu ürün için varsayılan birim mi? |
| orderIndex | Int | - | >= 0 | UI'da gösterim sırası |
| foodItem | FoodItem? | Inverse relationship | Required | Parent food item |

**İlişkiler:**
- `N:1 FoodItem` (inverse)

**Enum:**
```swift
enum ServingUnitType: String, Codable, CaseIterable {
    case serving, gram, ounce, cup, tablespoon, teaspoon, piece, slice, scoop, container
}
```

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
| workoutId | UUID? | - | Optional | PR'ın yapıldığı workout'un ID'si |

**İlişkiler:**
- İlişkisiz model (denormalized) - Exercise'a doğrudan referans yok
- Exercise silininse PR'lar kalır (historical record)

---

## AI Coach Domain (v1.3)

### ChatMessage

**Amaç:** Bir chat mesajını temsil eder (kullanıcı veya AI'dan)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| content | String | - | Required, max 10000 char | Mesaj içeriği |
| isFromUser | Bool | - | Required | true: kullanıcı, false: AI |
| timestamp | Date | - | Required | Mesaj zamanı |
| isSending | Bool | @Transient | - | UI state only (persisted değil) |
| conversation | ChatConversation? | Inverse relationship | Optional | Parent conversation |

**İlişkiler:**
- `N:1 ChatConversation` (inverse)

---

### ChatConversation

**Amaç:** Bir chat conversation'ı temsil eder (tüm mesajları içerir)

| Property | Type | SwiftData | Validasyon | Notlar |
|----------|------|-----------|-----------|--------|
| id | UUID | @Attribute(.unique) | Required | Otomatik oluşur |
| createdAt | Date | - | Required | Conversation oluşturma zamanı |
| lastMessageAt | Date? | - | Optional | Son mesaj zamanı |
| messages | [ChatMessage] | @Relationship(deleteRule: .cascade) | - | Tüm mesajlar |

**İlişkiler:**
- `1:N ChatMessage` (cascade delete) - Conversation silinince messages de silinir

**Business Rules:**
- Uygulama genelinde **tek bir ChatConversation** olabilir (singleton pattern)

---

### WorkoutContext (DTO)

**Amaç:** AI'a gönderilecek kullanıcı context'ini aggregate eder (SwiftData model değil, DTO)
**Location:** `/antrain/Core/Domain/Models/AICoach/WorkoutContext.swift`

---

### GeminiAPIError (Enum)

**Amaç:** API hata tiplerini tanımlar.
**Location:** `/antrain/Core/Data/Services/Protocols/GeminiAPIServiceProtocol.swift`

---

### ChatHistoryItem (DTO)

**Amaç:** Gemini API'ya gönderilen chat history için lightweight DTO.
**Location:** `/antrain/Features/AICoach/ViewModels/AICoachViewModel.swift`

---

## SwiftData Relationships Summary

| Parent | Child | Relationship | Delete Rule | Rationale |
|--------|-------|--------------|-------------|-----------|
| Workout | WorkoutExercise | 1:N | Cascade | Workout silinince exercises de silinmeli |
| WorkoutExercise | WorkoutSet | 1:N | Cascade | Exercise silinince setler de silinmeli |
| WorkoutExercise | Exercise (Library) | N:1 | Nullify | Library item silinse workout'ı etkilemez |
| NutritionLog | Meal | 1:N | Cascade | Log silinince meals de silinmeli |
| Meal | FoodEntry | 1:N | Cascade | Meal silinince entries de silinmeli |
| FoodEntry | FoodItem (Library) | N:1 | Nullify | Library item silinse meal'ı etkilemez |
| FoodItem | ServingUnit | 1:N | Cascade | Food item silinince porsiyonları da silinmeli |
| UserProfile | BodyweightEntry | 1:N | Cascade | Profile silinince history de silinmeli |
| TrainingProgram | ProgramDay | 1:N | Cascade | Program silinince günleri de silinmeli |
| ProgramDay | WorkoutTemplate | N:1 | Nullify | Template silinse program günü etkilenmez |

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

**Son Güncelleme:** 2025-11-12
**v1.4 Program Domain Added**