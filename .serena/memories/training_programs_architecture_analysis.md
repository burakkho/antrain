# Training Programs v2.0 - Mimari Analiz

## Mevcut Uygulama Mimarisi

### 1. Clean Architecture (3-Layer)
- **Presentation Layer**: SwiftUI Views + ViewModels (@Observable @MainActor)
- **Domain Layer**: SwiftData Models + Repository Protocols + Business Logic
- **Data Layer**: Concrete Repositories (@ModelActor) + Libraries + Services

### 2. Dependency Injection Pattern
- **AppDependencies.swift**: Merkezi DI container (ObservableObject)
- Repositories: @ModelActor ile background thread'de
- ViewModels: @Observable @MainActor ile main thread'de
- Environment injection: `.environment(AppDependencies.self)`

### 3. Mevcut Repository'ler
✅ WorkoutRepository
✅ ExerciseRepository
✅ NutritionRepository
✅ UserProfileRepository
✅ PersonalRecordRepository
✅ WorkoutTemplateRepository

### 4. Dosya Organizasyonu
```
Core/
├── Domain/
│   ├── Models/ (SwiftData @Model classes)
│   │   ├── Workout/
│   │   ├── Nutrition/
│   │   ├── User/
│   │   └── Template/
│   ├── Protocols/Repositories/
│   ├── Extensions/ (Calculator'lar)
│   └── State/ (ActiveWorkoutManager)
├── Data/
│   ├── Repositories/ (@ModelActor implementations)
│   ├── Libraries/ (ExerciseLibrary, FoodLibrary, TemplateLibrary)
│   └── Services/ (PRDetectionService)
└── DesignSystem/
    └── Components/

Features/
├── Home/
├── Workouts/
│   ├── LiftingSession/
│   ├── QuickLog/
│   └── History/
├── Templates/
├── Nutrition/
└── Settings/
```

### 5. Template Library Pattern (Referans)
- **TemplateLibrary**: Hazır template'ler (DTO pattern)
- **TemplateDTO**: Swift structs ile tanımlı
- **TemplateLibrary.swift**: Convert DTO → Model
- Seed logic: PersistenceController içinde

### 6. SwiftData Patterns
- **@Model**: Domain models
- **@Relationship**: Cascade delete rules
- **@ModelActor**: Repository implementations
- **PersistenceController**: ModelContainer management + seeding

## Training Programs v2.0 İçin Plan

### Yeni Eklenecek Domain Models
```
Core/Domain/Models/Program/
├── TrainingProgram.swift
├── ProgramWeek.swift
├── ProgramDay.swift
├── ProgramCategory.swift
├── DifficultyLevel.swift
├── TrainingPhase.swift
└── WeekProgressionPattern.swift
```

### Yeni Repository
```
Core/Data/Repositories/
└── TrainingProgramRepository.swift (@ModelActor)

Core/Domain/Protocols/Repositories/
└── TrainingProgramRepositoryProtocol.swift
```

### Yeni Service
```
Core/Data/Services/
└── ProgressiveOverloadService.swift (@MainActor)
```

### Yeni Program Library
```
Core/Data/Libraries/ProgramLibrary/
├── ProgramLibrary.swift
├── ProgramDTO.swift
├── Strength/
│   ├── StartingStrength.swift
│   └── StrongLifts5x5.swift
├── Hypertrophy/
│   ├── PPL6Day.swift
│   └── PHAT.swift
└── Beginner/
    └── BeginnerFullBody.swift
```

### Yeni Feature
```
Features/Programs/
├── ViewModels/
│   ├── ProgramsListViewModel.swift
│   ├── ProgramDetailViewModel.swift
│   ├── CreateProgramViewModel.swift
│   └── WeekDetailViewModel.swift
└── Views/
    ├── ProgramsListView.swift
    ├── ProgramDetailView.swift
    ├── CreateProgramFlow.swift
    ├── WeekDetailView.swift
    └── Components/
        ├── ProgramCard.swift
        ├── WeekCard.swift
        ├── DayCard.swift
        └── PhaseIndicator.swift
```

### Mevcut Model Değişiklikleri
- **Workout.swift**: `rpe: Int?` field ekle
- **UserProfile.swift**: 
  - `activeProgram: TrainingProgram?`
  - `activeProgramStartDate: Date?`
  - `currentWeekNumber: Int?`

### AppDependencies Güncellemesi
```swift
// Eklenecek
let trainingProgramRepository: TrainingProgramRepositoryProtocol
let progressiveOverloadService: ProgressiveOverloadService
```

### Template Deletion Safety (Kritik)
- WorkoutTemplateRepository'ye check ekle
- ProgramDay'lerde kullanılan template'ler silinemez
- UI'da disabled state + warning dialog

## Implementasyon Stratejisi

### Phase 1: Domain Models (2-3 gün)
1. Enum'lar (ProgramCategory, DifficultyLevel, TrainingPhase, WeekProgressionPattern)
2. TrainingProgram model
3. ProgramWeek model
4. ProgramDay model
5. Workout + UserProfile güncellemeleri

### Phase 2: Repository & Services (2-3 gün)
1. TrainingProgramRepositoryProtocol
2. TrainingProgramRepository (@ModelActor)
3. ProgressiveOverloadService
4. AppDependencies güncelle
5. WorkoutTemplateRepository deletion check

### Phase 3: Basic UI (3 gün)
1. ViewModels (ProgramsList, ProgramDetail, WeekDetail)
2. Components (ProgramCard, WeekCard, DayCard)
3. Main Views (List, Detail, Week)
4. MainTabView'e Programs tab ekle

### Phase 4: Creation Wizard (3-4 gün)
1. CreateProgramViewModel (multi-step state)
2. Wizard views (Step1-4)
3. Template selector
4. Progression pattern visualizer

### Phase 5: Preset Programs (2 gün)
1. ProgramLibrary structure (DTO pattern)
2. 10-15 preset program tanımları
3. Seed logic implementation
4. PersistenceController'a ekle

### Phase 6: Active Tracking (2-3 gün)
1. UserProfile extension (activate/deactivate logic)
2. HomeView'e active program card
3. Activation flow
4. LiftingSessionView integration
5. Progress tracking

## Localization Strategy
- Her phase'de `Localizable.xcstrings` güncelle
- Enum displayName'ler localized
- UI strings `String(localized:)` kullan
- Comment'ler translator'lar için ekle

## Testing Strategy
- Repository unit tests (in-memory ModelContainer)
- ViewModel tests (mock repositories)
- Business logic tests (RPE algorithm, progression patterns)
- UI tests (creation flow, activation)

## Key Design Decisions
1. ✅ 100% Local, Zero Cloud (SwiftData only)
2. ✅ Simple Week Structure (no Mesocycle model)
3. ✅ Hybrid Progressive Overload (RPE-based suggestions)
4. ✅ Reference Templates (ProgramDay → WorkoutTemplate)
5. ✅ Pattern-Based Week Progression
6. ✅ Active Program in UserProfile (SwiftData relationship)
7. ✅ Workout-Level RPE Tracking
8. ✅ Multi-Layer Delete Safety (Repository + UI)

## Cascade Delete Rules
```
TrainingProgram (delete)
  ├─▶ ProgramWeek (cascade delete)
  │     └─▶ ProgramDay (cascade delete)
  │           └─▶ WorkoutTemplate (REFERENCE, not deleted)
```

## Potential Issues & Solutions
1. **Template Deletion**: Repository check + UI validation
2. **Deep Nesting Performance**: Optimize fetch descriptors, add pagination
3. **Cross-Actor Communication**: Use PersistentIdentifier if needed
4. **Progressive Overload Accuracy**: Extensive testing, user can override

## Success Metrics
- User can create program < 2 minutes
- User can activate program < 10 seconds
- Workout suggestions accurate 90%+
- Zero template deletion bugs
- All unit tests passing (>95% coverage)
