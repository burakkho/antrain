# Architecture - Antrain

**Yaklaşım:** Clean Architecture (Simplified 3-Layer) + MVVM + Protocol-Oriented + Dependency Injection

**Hedef:** Scalable, testable, maintainable iOS app architecture

---

## 3-Layer Clean Architecture

```
┌─────────────────────────────────────────────────┐
│         PRESENTATION LAYER                      │
│   (SwiftUI Views + ViewModels)                  │
│   • User Interface                              │
│   • User Interaction                            │
│   • State Management (@Observable)              │
└─────────────────────────────────────────────────┘
                    ↓ ↑
         (Dependency: Domain protocols)
                    ↓ ↑
┌─────────────────────────────────────────────────┐
│         DOMAIN LAYER                            │
│   (Business Logic & Protocols)                  │
│   • Entities (SwiftData Models)                 │
│   • Repository Protocols                        │
│   • Business Rules & Validation                 │
└─────────────────────────────────────────────────┘
                    ↓ ↑
         (Implementation: Concrete repositories)
                    ↓ ↑
┌─────────────────────────────────────────────────┐
│         DATA LAYER                              │
│   (Data Management)                             │
│   • Concrete Repositories                       │
│   • SwiftData Persistence                       │
│   • Libraries (Exercise/Food)                   │
└─────────────────────────────────────────────────┘
```

### Dependency Flow

**Kural:** Presentation → Domain ← Data

- **Presentation layer:** Domain protocols'e bağımlı (concrete types'a değil)
- **Data layer:** Domain protocols'ü implement eder
- **Domain layer:** Hiçbir layer'a bağımlı değil (pure business logic)

**Neden?**
- Test edilebilirlik (mock repositories kolay)
- Değişime açık (data source değişse presentation etkilenmez)
- SOLID prensipleri (Dependency Inversion)

---

## Layer Detayları

### 1. Presentation Layer

**Sorumluluklar:**
- Kullanıcıya veri gösterme
- User input alma
- Navigation management
- UI state management

**Bileşenler:**
- **Views (SwiftUI):** Sadece UI rendering, business logic YOK
- **ViewModels (@Observable):** UI state + business logic orchestration
- **Components:** Reusable UI components (Design System)

**Klasör Yapısı:**
```
Features/
├── Home/
│   ├── Views/
│   │   ├── HomeView.swift
│   │   └── Components/
│   │       ├── QuickActionButton.swift
│   │       └── RecentWorkoutRow.swift
│   └── ViewModels/
│       └── HomeViewModel.swift
│
├── Workouts/
│   ├── Views/
│   │   └── WorkoutsView.swift          # Main view with segmented control
│   ├── History/
│   │   ├── Views/
│   │   │   ├── WorkoutsOverviewView.swift  # Overview section
│   │   │   └── Components/
│   │   └── ViewModels/
│   │       └── WorkoutsViewModel.swift
│   ├── Templates/
│   │   ├── Views/
│   │   │   ├── WorkoutTemplatesView.swift  # Templates section
│   │   │   └── Components/
│   │   └── ViewModels/
│   │       └── TemplatesViewModel.swift
│   └── Programs/
│       ├── Views/
│       │   ├── WorkoutProgramsView.swift   # Programs section
│       │   └── Components/
│       │       └── ActiveProgramCard.swift
│       └── ViewModels/
│           └── ProgramProgressTimelineViewModel.swift
│
├── Profile/                                 # v1.2: New Profile tab
│   ├── Views/
│   │   ├── ProfileView.swift                # Main profile tab
│   │   └── Components/
│   │       ├── ProfileNameEditorSheet.swift
│   │       ├── ProfileHeightEditorSheet.swift
│   │       ├── ProfileGenderEditorSheet.swift
│   │       ├── ProfileDateOfBirthEditorSheet.swift
│   │       ├── ProfileActivityLevelEditorSheet.swift
│   │       ├── ProfileBodyweightEntrySheet.swift
│   │       └── ProfileBodyweightHistorySheet.swift
│   └── ViewModels/
│       └── ProfileViewModel.swift
│
├── Settings/                                # v1.2: Simplified (app preferences only)
│   └── Views/
│       └── SettingsView.swift               # fullScreenCover from Home/Profile
```

**Note:**
- WorkoutsView uses **iOS native segmented control** instead of nested TabView (iOS HIG compliance)
- **v1.2:** Profile separated from Settings - Profile is now 4th tab, Settings is fullScreenCover modal

**ViewModel Pattern:**
```swift
@Observable @MainActor
final class LiftingSessionViewModel {
    // Dependencies (injected via protocol)
    private let workoutRepository: WorkoutRepositoryProtocol
    private let exerciseLibrary: ExerciseLibraryProtocol

    // UI State
    var exercises: [WorkoutExercise] = []
    var isLoading = false
    var errorMessage: String?

    // Dependency Injection
    init(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseLibrary: ExerciseLibraryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.exerciseLibrary = exerciseLibrary
    }

    // Business logic orchestration
    func addExercise(_ exercise: Exercise) async {
        // Orchestrate repository calls
        // Update UI state
    }
}
```

**Neden `@MainActor`?** (Swift 6 Requirement)
- @Observable otomatik @MainActor değildir
- UI state updates main thread'de olmalı
- SwiftUI animation issues'ı önler
- Swift 6 strict concurrency compliance

**Kural:**
- ViewModel içinde SwiftData query YOK
- ViewModel içinde direct model manipulation YOK
- Her şey repository üzerinden

---

### 2. Domain Layer

**Sorumluluklar:**
- Business logic
- Domain models (SwiftData entities)
- Repository contracts (protocols)
- Validation rules

**Bileşenler:**
- **Models:** SwiftData @Model entities
- **Protocols/Repositories:** Repository interfaces
- **Protocols/Libraries:** Library interfaces

**Klasör Yapısı:**
```
Core/Domain/
├── Models/
│   ├── Workout/
│   │   ├── Workout.swift
│   │   ├── WorkoutSet.swift
│   │   └── WorkoutExercise.swift
│   ├── Exercise/
│   │   └── Exercise.swift
│   └── Nutrition/
│       ├── NutritionLog.swift
│       └── Meal.swift
└── Protocols/
    ├── Repositories/
    │   ├── WorkoutRepositoryProtocol.swift
    │   └── NutritionRepositoryProtocol.swift
    └── Libraries/
        ├── ExerciseLibraryProtocol.swift
        └── FoodLibraryProtocol.swift
```

**Repository Protocol Pattern:**
```swift
// Protocol definition (Domain layer)
protocol WorkoutRepositoryProtocol {
    func fetchAll() async throws -> [Workout]
    func fetch(id: UUID) async throws -> Workout?
    func save(_ workout: Workout) async throws
    func delete(_ workout: Workout) async throws
}
```

**Model Pattern:**
```swift
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: WorkoutType
    var duration: TimeInterval
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutExercise] = []

    init(date: Date, type: WorkoutType) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.duration = 0
    }

    // Business logic method
    func validate() throws {
        if type == .lifting && exercises.isEmpty {
            throw ValidationError.liftingRequiresExercises
        }
    }
}
```

---

### 3. Data Layer

**Sorumluluklar:**
- Repository protocol implementation
- SwiftData operations (CRUD)
- Library data management
- Data persistence

**Bileşenler:**
- **Repositories:** Concrete repository implementations
- **Libraries:** Exercise/Food library implementations
- **Persistence:** SwiftData ModelContainer configuration

**Klasör Yapısı:**
```
Core/Data/
├── Repositories/
│   ├── WorkoutRepository.swift
│   ├── NutritionRepository.swift
│   └── ExerciseRepository.swift
├── Libraries/
│   ├── ExerciseLibrary/
│   │   ├── ExerciseLibrary.swift
│   │   ├── BarbellExercises.swift
│   │   └── DumbbellExercises.swift
│   └── FoodLibrary/
│       ├── FoodLibrary.swift
│       └── ProteinFoods.swift
└── Persistence/
    └── PersistenceController.swift
```

**Repository Implementation Pattern:**
```swift
import SwiftData

@ModelActor
actor WorkoutRepository: WorkoutRepositoryProtocol {
    // ModelContext otomatik provide edilir via @ModelActor

    func fetchAll() async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func save(_ workout: Workout) async throws {
        try workout.validate() // Domain validation
        modelContext.insert(workout)
        try modelContext.save()
    }

    func delete(_ workout: Workout) async throws {
        modelContext.delete(workout)
        try modelContext.save()
    }
}
```

**Neden `@ModelActor`?** (Swift 6 Best Practice)
- SwiftData'nın özel actor macro'su
- ModelContext otomatik manage edilir (init gereksiz)
- Serial execution garantisi
- Background thread'de operations
- Swift 6 strict concurrency uyumlu

---

## Dependency Injection

### AppDependencies Container

**Amaç:** Tüm dependencies'i merkezi olarak yönetmek

**Konum:** `App/AppDependencies.swift`

```swift
import SwiftData

@Observable
final class AppDependencies {
    // Repositories (@ModelActor - initialized with ModelContainer)
    let workoutRepository: WorkoutRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let exerciseRepository: ExerciseRepositoryProtocol

    // Libraries
    let exerciseLibrary: ExerciseLibraryProtocol
    let foodLibrary: FoodLibraryProtocol

    init(modelContainer: ModelContainer) {
        // Initialize repositories with ModelContainer
        // @ModelActor will create its own ModelContext
        self.workoutRepository = WorkoutRepository(modelContainer: modelContainer)
        self.nutritionRepository = NutritionRepository(modelContainer: modelContainer)
        self.exerciseRepository = ExerciseRepository(modelContainer: modelContainer)

        // Initialize libraries
        self.exerciseLibrary = ExerciseLibrary()
        self.foodLibrary = FoodLibrary()
    }

    // Preview/Test initializer (mock dependencies)
    static var preview: AppDependencies {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Workout.self, Exercise.self, NutritionLog.self,
            configurations: config
        )
        return AppDependencies(modelContainer: container)
    }
}
```

### Injection via SwiftUI Environment

**App Entry Point:**
```swift
import SwiftUI
import SwiftData

@main
struct AntrainApp: App {
    let modelContainer: ModelContainer
    let dependencies: AppDependencies

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Workout.self, Exercise.self, NutritionLog.self
            )
            dependencies = AppDependencies(
                modelContainer: modelContainer  // Pass container, not context
            )
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(dependencies)
        }
    }
}
```

**View Usage:**
```swift
struct LiftingSessionView: View {
    @Environment(AppDependencies.self) private var deps
    @State private var viewModel: LiftingSessionViewModel?

    var body: some View {
        Group {
            if let viewModel {
                // Render view with viewModel
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LiftingSessionViewModel(
                    workoutRepository: deps.workoutRepository,
                    exerciseLibrary: deps.exerciseLibrary
                )
            }
        }
    }
}
```

**Neden bu pattern?**
- Environment ile dependencies tüm view hierarchy'de mevcut
- Test'te mock dependencies inject etmek kolay
- Preview'larda in-memory data kullanmak kolay

---

## Error Handling Strategy

### 1. Repository Level - `throws`

**Neden?**
- SwiftData errors propogate edilmeli
- Caller error'ı handle etme kararı verebilmeli
- Result<T, Error> yerine throws daha clean (async/await ile)

```swift
protocol WorkoutRepositoryProtocol {
    func save(_ workout: Workout) async throws
}

actor WorkoutRepository: WorkoutRepositoryProtocol {
    func save(_ workout: Workout) async throws {
        try workout.validate() // Validation error
        modelContext.insert(workout)
        try modelContext.save() // SwiftData error
    }
}
```

### 2. ViewModel Level - Error State

**Neden?**
- UI'a user-friendly error message göstermek
- Loading states ile kombine kullanmak

```swift
@Observable @MainActor
final class LiftingSessionViewModel {
    var errorMessage: String?
    var isLoading = false

    func saveWorkout() async {
        isLoading = true
        errorMessage = nil

        do {
            try await workoutRepository.save(currentWorkout)
            // Success - navigate or show confirmation
        } catch let error as ValidationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Workout kaydedilemedi. Lütfen tekrar deneyin."
        }

        isLoading = false
    }
}
```

### 3. View Level - Error Display

**Neden?**
- User'a error feedback vermek
- Retry option sunmak

```swift
struct LiftingSessionView: View {
    @State var viewModel: LiftingSessionViewModel

    var body: some View {
        // ... content
        .alert("Hata", isPresented: $viewModel.hasError) {
            Button("Tamam", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Bilinmeyen hata")
        }
    }
}
```

### Custom Error Types

```swift
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
            return message
        }
    }
}

enum RepositoryError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Veri kaydedilemedi"
        case .fetchFailed:
            return "Veri yüklenemedi"
        case .deleteFailed:
            return "Veri silinemedi"
        case .notFound:
            return "Veri bulunamadı"
        }
    }
}
```

---

## State Management

### @Observable Macro (iOS 17+, Standard in iOS 18)

**Neden kullanıyoruz?**
- ObservableObject'ten daha performanslı
- @Published gereksiz, tüm properties otomatik observable
- Boilerplate kod azalıyor

**ViewModel Pattern:**
```swift
import Observation

@Observable @MainActor
final class LiftingSessionViewModel {
    // Automatically observable - no @Published needed
    var exercises: [WorkoutExercise] = []
    var selectedExercise: Exercise?
    var isLoading = false
    var errorMessage: String?

    // Private properties NOT observable (optimization)
    private let workoutRepository: WorkoutRepositoryProtocol
    private var currentWorkout: Workout

    func addSet(reps: Int, weight: Double) async {
        // State update automatically triggers view refresh
        isLoading = true

        // ... business logic

        isLoading = false
    }
}
```

### State Lifecycle

**ViewModel Lifecycle:**
1. **Init:** View's onAppear'da oluştur
2. **Active:** User interaction'da state update
3. **Deinit:** View disappear'da otomatik cleanup

**Pattern:**
```swift
struct LiftingSessionView: View {
    @Environment(AppDependencies.self) private var deps
    @State private var viewModel: LiftingSessionViewModel?

    var body: some View {
        Group {
            if let viewModel {
                // View content
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LiftingSessionViewModel(
                    workoutRepository: deps.workoutRepository
                )
            }
        }
    }
}
```

**Neden optional @State?**
- Dependencies Environment'tan geldiği için onAppear'da init
- PreviewProvider'da farklı dependencies inject edebilme

### Loading States

**Pattern:** Enum-based state
```swift
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
}

@Observable @MainActor
final class WorkoutHistoryViewModel {
    var loadingState: LoadingState<[Workout]> = .idle

    func loadWorkouts() async {
        loadingState = .loading

        do {
            let workouts = try await repository.fetchAll()
            loadingState = .success(workouts)
        } catch {
            loadingState = .error(error)
        }
    }
}
```

---

## File Organization

### Micro-Modular Approach

**Kural:** 100-200 satır ideal, 300 satır MAX

**Neden?**
- AI readability (Claude Code ile çalışma)
- Maintainability (küçük dosyalar daha kolay anlaşılır)
- Single Responsibility Principle

**Stratejiler:**
1. **Extract Components:** View 150+ satır → alt-componentlere böl
2. **Extract Extensions:** Utilities ayrı extension file'lara
3. **Feature Folders:** Feature-based organization, katman bazlı değil

**Örnek Extraction:**
```
❌ Kötü (tek dosya 400 satır):
LiftingSessionView.swift

✅ İyi (4 dosya, her biri ~100 satır):
LiftingSessionView.swift
ExerciseCard.swift
SetRow.swift
ExerciseSelectionSheet.swift
```

### Naming Conventions

| Type | Convention | Örnek |
|------|-----------|-------|
| View | [Feature][Type]View | LiftingSessionView |
| ViewModel | [Feature]ViewModel | LiftingSessionViewModel |
| Component | DS[Type] veya [Purpose]Component | DSPrimaryButton, ExerciseCard |
| Repository | [Entity]Repository | WorkoutRepository |
| Protocol | [Entity]RepositoryProtocol | WorkoutRepositoryProtocol |
| Model | [Entity] | Workout, Exercise |

---

## Testing Strategy (Minimal MVP)

### Repository Unit Tests

```swift
@Test
func testWorkoutRepository_SaveAndFetch() async throws {
    // Arrange
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Workout.self, configurations: config)
    let repository = WorkoutRepository(modelContext: container.mainContext)

    let workout = Workout(date: Date(), type: .lifting)

    // Act
    try await repository.save(workout)
    let fetched = try await repository.fetchAll()

    // Assert
    #expect(fetched.count == 1)
    #expect(fetched.first?.type == .lifting)
}
```

### ViewModel Tests (Mock Repository)

```swift
actor MockWorkoutRepository: WorkoutRepositoryProtocol {
    var savedWorkouts: [Workout] = []

    func save(_ workout: Workout) async throws {
        savedWorkouts.append(workout)
    }

    func fetchAll() async throws -> [Workout] {
        return savedWorkouts
    }
}

@Test
func testViewModel_SaveWorkout() async throws {
    // Arrange
    let mockRepo = MockWorkoutRepository()
    let viewModel = LiftingSessionViewModel(workoutRepository: mockRepo)

    // Act
    await viewModel.saveWorkout()

    // Assert
    let saved = try await mockRepo.fetchAll()
    #expect(saved.count == 1)
}
```

---

## Swift 6 Concurrency Best Practices

### Strict Concurrency Compliance

**Xcode Setting:** Strict Concurrency Checking = **Complete**

**Swift 6 ile gelen değişiklikler:**
- Data races compile-time'da yakalanır
- Actor isolation explicit olmalı
- @MainActor enforcement daha sıkı
- Sendable conformance gereklilikleri

### Actor Isolation Rules

**Repository'ler → `@ModelActor`**
```swift
@ModelActor
actor WorkoutRepository: WorkoutRepositoryProtocol {
    // ModelContext otomatik inject
    // Background thread'de çalışır
    // Serial execution guarantee
}
```

**ViewModels → `@Observable @MainActor`**
```swift
@Observable @MainActor
final class LiftingSessionViewModel {
    // Main thread'de çalışır
    // UI updates safe
    // Animation issues yok
}
```

### Cross-Actor Communication

**Model objects Sendable değil** - PersistentIdentifier kullan:

```swift
// ❌ YANLIŞ - Workout sendable değil
let workout = Workout(...)
Task {
    await repository.save(workout) // Compile error!
}

// ✅ DOĞRU - PersistentIdentifier sendable
let id = workout.persistentModelID
Task {
    await repository.save(id)
}
```

**MVP için simplified approach:**
```swift
// Repository async method'ları direkt çağır
@Observable @MainActor
final class LiftingSessionViewModel {
    func saveWorkout() async {
        do {
            try await repository.save(currentWorkout)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### ModelContext Thread Safety

**Kural:** Her actor kendi ModelContext'ini oluşturur

```swift
@ModelActor
actor WorkoutRepository {
    // modelContext bu actor'a ait
    // Background thread'de operations
}

// MainContext (UI thread)
@main
struct AntrainApp: App {
    let modelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(modelContainer)
        }
    }
}
```

**@Query → Main thread'de çalışır (SwiftUI views'da OK)**

### Concurrency Checklist

- [ ] Repository'ler `@ModelActor` kullanıyor
- [ ] ViewModels `@Observable @MainActor` kullanıyor
- [ ] Cross-actor communication için PersistentIdentifier kullanılıyor (gerekirse)
- [ ] ModelContext her actor'da ayrı instance
- [ ] UI updates main thread'de

---

## Localization Strategy

### String Catalog (Xcode 15+ / iOS 17+, Optimized in iOS 18)

**Amaç:** Future-proof localization, şimdilik İngilizce, gelecekte Türkçe

**File:** `Resources/Localizable.xcstrings`

### Otomatik String Extraction

**SwiftUI views otomatik localizable:**
```swift
// Otomatik String Catalog'a eklenir
Text("Start Workout")
Button("Save") { }
Label("Add Exercise", systemImage: "plus")

// TextField placeholder
TextField("Exercise name", text: $name)
```

**Xcode otomatik olarak:**
1. Tüm Text, Button, Label string'lerini bulur
2. `Localizable.xcstrings` dosyasına ekler
3. Translation interface sunar

### Manuel Localization

**Kod içinde string'ler:**
```swift
let message = String(localized: "Workout saved successfully")

// Context ile (translator'lar için)
let message = String(
    localized: "You lifted \(weight) kg",
    comment: "Example: You lifted 100 kg"
)
```

### Plural Handling

**String Catalog'da "Vary by Plural" kullan:**
```swift
// SwiftUI'da
Text("\(count) exercises")

// String Catalog'da:
// - "one": "1 exercise"
// - "other": "%lld exercises"
```

### Variable Substitution

**String interpolation:**
```swift
Text("Welcome, \(userName)")
Text("You completed \(setCount) sets")

// String Catalog:
// "Welcome, %@"
// "You completed %lld sets"
```

### MVP Localization Scope

**Phase 1 (MVP - Şimdi):**
- ✅ String Catalog kullan (future-proof)
- ✅ Tüm UI strings localizable format
- ✅ İngilizce (base language)
- ❌ Türkçe translation (şimdilik boş)

**Phase 2 (Post-MVP):**
- Türkçe translation ekle
- String Catalog'da çeviri yap
- Test et

### Implementation Checklist

**MVP için:**
- [ ] `Localizable.xcstrings` dosyası oluşturuldu
- [ ] Tüm SwiftUI Text() ile yazıldı (hardcoded string yok)
- [ ] String(localized:) kod içinde kullanıldı
- [ ] Plural handling gerekli yerlerde planlandı
- [ ] Comment'ler translator'lar için eklendi (gerekli yerlerde)

**String Catalog Best Practices:**
```swift
// ✅ İYİ - Localizable
Text("Start Workout")
String(localized: "Workout saved")

// ❌ KÖTÜ - Hardcoded
Text("Start Workout") // OK ama comment ekle
let message = "Workout saved" // String(localized:) kullan

// ✅ CONTEXT İLE
String(
    localized: "\(reps) reps × \(weight) kg",
    comment: "Example: 10 reps × 100 kg"
)
```

### File Organization

```
Resources/
└── Localizable.xcstrings
    ├── Source Language: English (Base)
    └── Localizations:
        └── Turkish (Phase 2)
```

**String Catalog yapısı:**
```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "Start Workout" : {
      "localizations" : {
        "en" : { "stringUnit" : { "value" : "Start Workout" } },
        "tr" : { "stringUnit" : { "value" : "Antrenmana Başla" } }
      }
    }
  },
  "version" : "1.0"
}
```

**Not:** Xcode otomatik bu formatı manage eder, manuel JSON yazma gereksiz.

---

## Best Practices Checklist

**Before Writing Code:**
- [ ] Repository protocol defined?
- [ ] Error handling strategy planned?
- [ ] ViewModel dependencies identified?
- [ ] File size estimate < 200 lines?

**During Development:**
- [ ] Models have validation logic?
- [ ] ViewModels use protocols, not concrete types?
- [ ] Error messages user-friendly?
- [ ] Loading states implemented?

**After Feature Complete:**
- [ ] Repository unit tests written?
- [ ] ViewModel tests for critical paths?
- [ ] File sizes checked (max 300 lines)?
- [ ] SwiftUI previews working?

---

**Son Güncelleme:** 2025-02-11 (Swift 6 + Localization updates)
**Dosya Boyutu:** ~240 satır
**Swift 6 Compliance:** ✅ @ModelActor, @Observable @MainActor
**Localization:** ✅ String Catalog strategy


---

## Training Programs Extension (v2.0)

### New Domain Models

**TrainingProgram (MacroCycle):**
```swift
@Model
final class TrainingProgram {
    @Attribute(.unique) var id: UUID
    var name: String
    var programDescription: String?
    var category: ProgramCategory
    var difficulty: DifficultyLevel
    var durationWeeks: Int
    var progressionPattern: WeekProgressionPattern
    var isCustom: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var weeks: [ProgramWeek]
}
```

**ProgramWeek (MicroCycle):**
```swift
@Model
final class ProgramWeek {
    @Attribute(.unique) var id: UUID
    var weekNumber: Int
    var name: String?
    var notes: String?
    var phaseTag: TrainingPhase?
    var intensityModifier: Double
    var volumeModifier: Double
    var isDeload: Bool

    var program: TrainingProgram

    @Relationship(deleteRule: .cascade)
    var days: [ProgramDay]
}
```

**ProgramDay:**
```swift
@Model
final class ProgramDay {
    @Attribute(.unique) var id: UUID
    var dayOfWeek: Int
    var name: String?
    var notes: String?

    var week: ProgramWeek
    var template: WorkoutTemplate?  // Reference, not copy

    var intensityOverride: Double?
    var volumeOverride: Double?
    var suggestedRPE: Int?
}
```

### New Service Layer

**ProgressiveOverloadService:**
```swift
@MainActor
final class ProgressiveOverloadService {
    func suggestWorkout(
        for template: WorkoutTemplate,
        weekModifier: Double,
        previousWorkouts: [Workout]
    ) -> SuggestedWorkout

    // RPE-based algorithm:
    // RPE 1-6: +5% (too easy)
    // RPE 7-8: +2.5% (perfect)
    // RPE 9-10: -2.5% (too hard)
}
```

### Modified Existing Models

**Workout (Extended):**
```swift
@Model
final class Workout {
    // ... existing fields

    // v2.0 Addition
    var rpe: Int?  // 1-10 Rate of Perceived Exertion
}
```

**UserProfile (Extended):**
```swift
@Model
final class UserProfile {
    // ... existing fields

    // v2.0 Additions
    var activeProgram: TrainingProgram?
    var activeProgramStartDate: Date?
    var currentWeekNumber: Int?
}
```

### New Repository

**TrainingProgramRepository:**
```swift
@ModelActor
actor TrainingProgramRepository: TrainingProgramRepositoryProtocol {
    func create(_ program: TrainingProgram) async throws
    func fetchAll() async throws -> [TrainingProgram]
    func fetchById(_ id: UUID) async throws -> TrainingProgram?
    func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram]
    func update(_ program: TrainingProgram) async throws
    func delete(_ program: TrainingProgram) async throws
    func findProgramsUsingTemplate(_ template: WorkoutTemplate) async throws -> [String]
}
```

### Data Integrity Pattern

**Template Deletion Safety:**
- Multi-layer protection (repository + UI)
- Check if template is used in any program before deletion
- Display program names that use the template
- Cascade delete: Program → Week → Day (but not Template)

### Hierarchical Structure

```
TrainingProgram (MacroCycle)
  └── ProgramWeek (MicroCycle)
      └── ProgramDay (Training Day)
          └── WorkoutTemplate (Reference)
              └── Exercise (Single Source of Truth)
```

**Benefits:**
- Storage efficient (templates are references, not copies)
- Updates to templates propagate to all programs
- Template deletion prevented if used
- Clean separation of concerns

### Feature Location

```
antrain/
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── Program/
│   │   │       ├── TrainingProgram.swift
│   │   │       ├── ProgramWeek.swift
│   │   │       ├── ProgramDay.swift
│   │   │       └── [Enums].swift
│   │   └── Protocols/Repositories/
│   │       └── TrainingProgramRepositoryProtocol.swift
│   └── Data/
│       ├── Repositories/
│       │   └── TrainingProgramRepository.swift
│       ├── Services/
│       │   └── ProgressiveOverloadService.swift
│       └── Libraries/
│           └── ProgramLibrary/
└── Features/
    └── Workouts/
        └── Programs/
            ├── ViewModels/ (6 ViewModels)
            └── Views/ (19 Views & Components)
```

---

**Last Updated:** 2025-11-06
**v2.0 Training Programs Extension Added**

