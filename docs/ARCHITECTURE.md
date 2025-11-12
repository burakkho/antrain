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
├── AICoach/                                 # v1.3: AI Fitness Coach
│   ├── Views/
│   │   ├── AICoachView.swift                # Main AI Coach tab
│   │   └── Components/
│   │       ├── ChatMessageBubble.swift       # Message bubble UI
│   │       ├── ChatInputField.swift          # Chat input with send button
│   │       ├── QuickActionChips.swift        # Quick suggestion chips
│   │       ├── TypewriterTextView.swift      # Typewriter animation for AI
│   │       ├── TypingIndicator.swift         # "AI is typing..." indicator
│   │       └── ErrorBanner.swift             # Error message banner
│   └── ViewModels/
│       └── AICoachViewModel.swift           # Chat state + API orchestration
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
│   ├── Nutrition/
│   │   ├── NutritionLog.swift
│   │   └── Meal.swift
│   └── AICoach/                            # v1.3: AI Coach models
│       ├── ChatMessage.swift                # SwiftData @Model for messages
│       ├── ChatConversation.swift           # SwiftData @Model for conversation
│       └── WorkoutContext.swift             # DTO for AI context building
└── Protocols/
    ├── Repositories/
    │   ├── WorkoutRepositoryProtocol.swift
    │   ├── NutritionRepositoryProtocol.swift
    │   └── ChatRepositoryProtocol.swift     # v1.3: Chat persistence
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
│   ├── ExerciseRepository.swift
│   └── ChatRepository.swift                # v1.3: Chat message persistence
├── Libraries/
│   ├── ExerciseLibrary/
│   │   ├── ExerciseLibrary.swift
│   │   ├── BarbellExercises.swift
│   │   └── DumbbellExercises.swift
│   └── FoodLibrary/
│       ├── FoodLibrary.swift
│       └── ProteinFoods.swift
├── Services/                                # v1.3: External API services
│   ├── GeminiAPIService.swift               # Gemini 2.5 Flash-Lite API
│   ├── GeminiConfig.swift                   # API config + prompts
│   ├── Protocols/
│   │   └── GeminiAPIServiceProtocol.swift
│   └── WorkoutContextBuilder.swift          # Builds AI context from user data
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

## View Layer Refactoring & Component Architecture

### Refactoring Phase 1 (November 2025)

**Goal:** Transform large, monolithic SwiftUI views into maintainable, component-based architecture following atomic design principles.

**Success Metrics:**
- ✅ 5 critical files refactored (-50% average line count)
- ✅ 20 reusable components created
- ✅ 2 Design System components added (cross-feature reusability)
- ✅ Total reduction: -1,376 lines of code
- ✅ Zero regressions (all builds successful)

### Refactored Files Summary

| File | Before | After | Reduction | Components Created |
|------|--------|-------|-----------|-------------------|
| `WorkoutsOverviewView.swift` | 679 | 345 | -49% | 3 |
| `SettingsView.swift` | 522 | 239 | -54% | 2 + ViewModel updates |
| `DayDetailView.swift` | 520 | 182 | -65% | 5 (2 Design System) |
| `TemplatesListView.swift` | 501 | 320 | -36% | N/A (preview optimization) |
| `WorkoutSummaryView.swift` | 496 | 256 | -48% | 5 |
| **TOTAL** | **2,718** | **1,342** | **-50%** | **20 components** |

### Component Creation Strategy

**Two-Tier Component Organization:**

1. **Design System Components** (`Shared/DesignSystem/Components/`)
   - Cross-feature reusability
   - Generic, configurable components
   - Consistent UI patterns across app

2. **Feature Components** (`Features/[Feature]/Views/Components/`)
   - Feature-specific logic
   - Business domain knowledge
   - Composed from Design System components when possible

### Design System Components Added

**1. StatItemView.swift** (45 lines)
```swift
/// Reusable stat item view with icon, value, and label
struct StatItemView: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = DSColors.primary
}
```
**Usage:** Profile stats, workout stats, nutrition dashboard, program metrics

**2. ModifierChipView.swift** (67 lines)
```swift
/// Reusable modifier chip for displaying intensity/volume adjustments
struct ModifierChipView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
}
```
**Usage:** Training program modifiers, workout intensity indicators, deload week markers

### Feature Components Created

#### WorkoutsOverviewView Extraction (3 components)

**1. CalendarItemCardView.swift** (168 lines)
- Calendar item rendering with swipe actions
- Handles completed/planned/rest day states
- Delete workout, start workout, preview program day

**2. WorkoutListView.swift** (165 lines)
- Workout list with filtering and pagination
- Supports lifting/cardio/MetCon filters
- Configurable item limit

**3. QuickActionsCard.swift** (39 lines)
- Quick workout start buttons
- Lifting, Cardio, MetCon shortcuts

#### SettingsView Extraction (2 components + ViewModel)

**1. NotificationSettingsSection.swift** (144 lines)
- Notification preferences UI
- Toggle controls for workout reminders, PR celebrations

**2. DataManagementSection.swift** (68 lines)
- Import/Export UI
- PR recalculation trigger
- CSV file handling

**ViewModel Enhancement:**
- Moved import/export logic from view to `SettingsViewModel`
- Added toast management for user feedback
- Clean separation of concerns

#### DayDetailView Extraction (5 components)

**1. DayInfoCard.swift** (147 lines)
- Program day header information
- Week context, day name, notes

**2. TemplateExerciseList.swift** (101 lines)
- Exercise list for program day
- Set/rep/weight/RPE display

**3. WeekContextCard.swift** (46 lines)
- Week-level metadata
- Phase tags, deload indicators
- Intensity/volume modifiers

**Plus Design System components:** StatItemView, ModifierChipView (listed above)

#### WorkoutSummaryView Extraction (5 components)

**1. PRSectionView.swift** (43 lines)
- Personal record detection display
- Celebration UI for new PRs

**2. WorkoutStatsGrid.swift** (64 lines)
- Main workout statistics grid
- Exercise count, sets, duration, volume

**3. ComparisonSection.swift** (68 lines)
- Workout vs previous workout comparison
- Volume, sets, duration changes with trend indicators

**4. MuscleGroupSection.swift** (38 lines)
- Muscle group breakdown
- Volume and set count per muscle group

**5. ExerciseDetailsList.swift** (98 lines)
- Exercise-by-exercise breakdown
- Set details with type indicators (warmup, dropset, etc.)
- Per-exercise volume calculation

### Component Naming Conventions Established

| Type | Pattern | Example |
|------|---------|---------|
| Design System | `[Purpose]View` | `StatItemView`, `ModifierChipView` |
| Feature Component | `[Feature][Purpose]View/Card/Section/Row` | `CalendarItemCardView`, `MuscleGroupSection` |
| List Components | `[Entity]ListView` | `WorkoutListView`, `ExerciseDetailsList` |
| Private SubComponents | `private struct [Name]Row` | `SummarySetRow`, `SetRow` |

**Naming Conflict Resolution:**
- Use feature-specific prefixes for private components (`SummarySetRow` instead of generic `SetRow`)
- Avoid generic names that may conflict across features

### Refactoring Best Practices Learned

**1. Component Extraction Triggers:**
- File exceeds 300 lines
- More than 3 `@ViewBuilder` helper methods
- Preview section exceeds 100 lines
- Complex state management in single view
- Repeated UI patterns across features

**2. Preview Optimization:**
- Extract preview mock data to separate files for complex objects
- Use minimal previews (25 lines max)
- Leverage `@Previewable` macro for dynamic state

**3. State Management:**
- Keep component state minimal
- Pass bindings for editable state
- Use callbacks for actions (closure-based)
- Avoid @EnvironmentObject in components (use dependency injection)

**4. Component Boundaries:**
- Each component should have a single responsibility
- Components should be testable in isolation
- Aim for 40-150 lines per component
- Extract sub-components when logic branches significantly

**5. Build Validation:**
- Build after each component extraction
- Fix naming conflicts immediately
- Verify type names (singular vs plural)
- Test swipe actions, navigation, and state updates

### Future Refactoring Targets (Post-v1.2)

Files identified for Phase 2 refactoring (200-400 lines):

1. `NutritionLogView.swift` (377 lines)
2. `NutritionDashboardView.swift` (330 lines)
3. `LiftingSessionView.swift` (319 lines)
4. `ProgramDetailView.swift` (309 lines)
5. `ExerciseEditorView.swift` (275 lines)

**Strategy:** Same component extraction approach, prioritize by active development frequency.

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

## AI Fitness Coach Feature (v1.3)

### Overview

AI Coach feature integrates Google Gemini 2.5 Flash-Lite API to provide personalized fitness coaching based on user's workout history, nutrition data, active programs, and personal records.

**Key Features:**
- Real-time chat with AI fitness coach
- Context-aware coaching (workout history, PRs, nutrition, active programs)
- Typewriter animation for AI responses
- Quick action chips for common questions
- Persistent chat history (SwiftData)
- Language auto-detection (Turkish/English)

### Architecture Components

```
┌─────────────────────────────────────────────┐
│         PRESENTATION LAYER                   │
│   AICoachView + AICoachViewModel            │
│   • Chat UI                                  │
│   • User input handling                      │
│   • Message display                          │
└─────────────────────────────────────────────┘
                    ↓ ↑
         (Dependencies via AppDependencies)
                    ↓ ↑
┌─────────────────────────────────────────────┐
│         DOMAIN LAYER                         │
│   Models: ChatMessage, WorkoutContext        │
│   Protocols: ChatRepositoryProtocol,         │
│              GeminiAPIServiceProtocol        │
└─────────────────────────────────────────────┘
                    ↓ ↑
         (Implementation)
                    ↓ ↑
┌─────────────────────────────────────────────┐
│         DATA LAYER                           │
│   • ChatRepository (SwiftData persistence)   │
│   • GeminiAPIService (API calls)            │
│   • WorkoutContextBuilder (context builder)  │
└─────────────────────────────────────────────┘
```

### Data Flow

**User Sends Message:**
```
1. User types message in ChatInputField
2. AICoachViewModel.sendMessage() called
3. ViewModel adds user message to messages array
4. ChatRepository.saveMessage() persists user message
5. WorkoutContextBuilder builds context from:
   - Recent workouts (30 days)
   - Detailed workout data (last 5 workouts)
   - Personal records
   - Active training program (current + next week)
   - Nutrition summary (7 days)
   - User profile data
6. GeminiAPIService.sendMessage() sends:
   - User message
   - WorkoutContext
   - Chat history (last 10 messages)
   - isNewUser flag
7. Gemini API returns response
8. ViewModel displays AI message with typewriter effect
9. ChatRepository.saveMessage() persists AI message
```

### Models

**ChatMessage (SwiftData):**
```swift
@Model
final class ChatMessage {
    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var conversation: ChatConversation?

    @Transient var isSending: Bool // UI state only
}
```

**ChatConversation (SwiftData):**
```swift
@Model
final class ChatConversation {
    var id: UUID
    var createdAt: Date
    var lastMessageAt: Date?

    @Relationship(deleteRule: .cascade)
    var messages: [ChatMessage] = []
}
```

**WorkoutContext (DTO):**
- Aggregates user data for AI context
- Converts to formatted string for prompt
- See `MODELS.md` for detailed structure

### Services

**GeminiAPIService:**
```swift
@MainActor
final class GeminiAPIService: GeminiAPIServiceProtocol {
    func sendMessage(
        _ message: String,
        context: WorkoutContext,
        chatHistory: [ChatHistoryItem],
        isNewUser: Bool
    ) async throws -> String
}
```

**Key Features:**
- Language auto-detection (NaturalLanguage framework)
- API key obfuscation (Base64)
- Error handling (rate limits, network errors, API errors)
- Timeout handling (30s)
- Chat history management (last 10 messages)

**WorkoutContextBuilder:**
```swift
@MainActor
final class WorkoutContextBuilder {
    func buildContext() async throws -> WorkoutContext
}
```

**Context Building:**
- Fetches last 30 days of workouts
- Fetches last 5 detailed workouts
- Fetches all personal records
- Fetches active training program (current + next week)
- Calculates volume trends, training frequency
- Fetches 7-day nutrition summary
- Includes user profile data

### Repository

**ChatRepository (@ModelActor):**
```swift
@ModelActor
actor ChatRepository: ChatRepositoryProtocol {
    func fetchOrCreateConversation() async throws -> ChatConversation
    func saveMessage(content: String, isFromUser: Bool) async throws -> ChatMessage
    func fetchAllMessages() async throws -> [ChatMessage]
    func clearHistory() async throws
}
```

**Design Decisions:**
- `@ModelActor` for thread-safe SwiftData access
- Single conversation per user (app-wide chat history)
- Cascade delete for messages (conversation deletion)

### ViewModel

**AICoachViewModel:**
```swift
@Observable @MainActor
final class AICoachViewModel {
    // Dependencies
    private let chatRepository: ChatRepositoryProtocol
    private let geminiAPIService: GeminiAPIServiceProtocol
    private let workoutContextBuilder: WorkoutContextBuilder

    // State
    var messages: [ChatMessage] = []
    var userInput: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var currentAIMessage: String = "" // For typewriter effect
    var showTypewriter: Bool = false

    // Business Logic
    func sendMessage() async
    func loadChatHistory() async
    func clearChat() async
}
```

**State Management:**
- `@Observable` for SwiftUI reactivity
- `@MainActor` for UI thread safety
- Error handling with user-friendly messages
- Loading states for async operations

### UI Components

**AICoachView:**
- ScrollView with chat messages
- ChatInputField at bottom
- QuickActionChips for suggestions
- ErrorBanner for API errors

**ChatMessageBubble:**
- User messages: right-aligned, blue
- AI messages: left-aligned, gray
- Timestamp display
- TypewriterTextView for AI messages

**TypewriterTextView:**
- Animates AI response character-by-character
- Configurable speed (0.02s per char)
- Smooth animation for better UX

**TypingIndicator:**
- "AI is typing..." animated dots
- Shows while API request in progress

### Gemini API Configuration

**Model:** `gemini-2.5-flash-lite`
- Fast inference (< 3s typically)
- 1M token context window
- 64K token output limit
- Multimodal support (not used in MVP)

**System Prompt:**
- Single comprehensive prompt (no onboarding variant)
- Persona: Balanced Expert (scientific yet supportive)
- Language-agnostic (responds in user's language)
- Context-aware (deload weeks, program phases, nutrition)
- Data-driven advice (references actual user metrics)

**API Configuration:**
```swift
temperature: 0.7     // Balanced creativity
topK: 40
topP: 0.95
maxOutputTokens: 2048
```

### Error Handling

**Error Types:**
```swift
enum GeminiAPIError: LocalizedError {
    case messageEmpty
    case messageTooLong(limit: Int)
    case invalidAPIKey
    case rateLimitExceeded(retryAfter: Int)
    case serverError(statusCode: Int)
    case timeout
    case noInternetConnection
    case invalidResponse
    case unknown(Error)
}
```

**User-Facing Messages:**
- Network errors: "Check your internet connection"
- Rate limits: "Too many requests, wait X seconds"
- API errors: "Temporary error occurred, try again"
- Validation: "Message too long (max 1000 chars)"

### Security

**API Key Storage:**
- Base64 obfuscation (not encryption)
- Decoded at runtime
- Validated on app launch (checks "AIza" prefix)
- Future: Move to Keychain for production

**Data Privacy:**
- Chat history stored locally (SwiftData)
- No cloud backup of messages
- User data sent to Gemini API (see Terms of Service)

### Performance Optimizations

**Context Building:**
- Parallel async fetches where possible
- Minimal data queries (last 30 days only)
- Cached user profile data

**Chat History:**
- Only last 10 messages sent to API (token efficiency)
- Full history stored locally
- Efficient SwiftData queries

**UI Performance:**
- Typewriter effect skippable (tap to complete)
- ScrollView auto-scroll to bottom
- Lazy loading for long chat histories

### Testing Strategy

**Unit Tests:**
- WorkoutContextBuilder (context building logic)
- GeminiAPIService (API request/response parsing)
- ChatRepository (SwiftData operations)

**Integration Tests:**
- ViewModel + Repository interaction
- API service with mock responses

**UI Tests:**
- Chat flow (send/receive messages)
- Error handling display
- Quick action chips

### Future Enhancements (Post-v1.3)

**Planned Features:**
- Voice input/output
- Image-based form analysis (Gemini multimodal)
- Workout plan generation
- Nutrition meal suggestions
- Chat conversation branching
- Export chat history

**Technical Debt:**
- Move API key to Keychain
- Implement proper error retry logic
- Add offline queueing for messages
- Optimize context building (caching)

---

**Last Updated:** 2025-11-10
**v1.2+ View Layer Refactoring Documentation Added**
**v2.0 Training Programs Extension Added**
**v1.3 AI Fitness Coach Feature Added**

