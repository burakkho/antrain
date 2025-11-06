# Training Programs Architecture (v2.0)

> **Status:** Planning Phase
> **Target Release:** v2.0
> **Last Updated:** 2025-11-05

## Overview

Training Programs feature enables users to follow structured, multi-week workout plans with built-in periodization, progressive overload, and auto-regulation. This document outlines the complete architecture for implementing professional-grade training program management.

---

## Core Concepts

### Hierarchy

```
TrainingProgram (MacroCycle)
  └── ProgramWeek (MicroCycle)
      └── ProgramDay (Training Day)
          └── WorkoutTemplate (Reference)
              └── Exercise (Single Source of Truth)
```

### Example Flow

```
12-Week Powerlifting Program
  ├── Week 1 [Hypertrophy Phase]
  │   ├── Monday: Push Day (template reference)
  │   ├── Tuesday: Pull Day (template reference)
  │   ├── Wednesday: Leg Day (template reference)
  │   └── ...
  ├── Week 2 [Hypertrophy Phase]
  │   └── ... (same templates, +2.5% intensity)
  ├── ...
  └── Week 12 [Deload Week]
      └── ... (same templates, 60% intensity)
```

---

## Key Design Decisions

### 1. 100% Local, Zero Cloud
- **Decision:** No HealthKit integration, pure SwiftData
- **Rationale:** Preserves core privacy principle
- **Trade-off:** No Apple Training Load, but full control over analytics

### 2. Simple Weekly Structure (MVP)
- **Decision:** Program → Week → Day (no Mesocycle model)
- **Rationale:** Faster implementation, sufficient for 90% of users
- **Future:** Can add Mesocycle in v2.1 if needed

### 3. Hybrid Progressive Overload
- **Decision:** Auto-suggest based on RPE, user can override
- **Rationale:** Balance between automation and control
- **Implementation:** RPE-based algorithm with manual override

### 4. Reference Templates (Single Source of Truth)
- **Decision:** ProgramDay references WorkoutTemplate
- **Rationale:** Storage efficient, template updates propagate
- **Safety:** Prevent template deletion if used in programs

### 5. Pattern-Based Week Progression
- **Decision:** User selects progression pattern (linear, wave, etc.)
- **Rationale:** Flexible, supports various training methodologies
- **Examples:** "3 weeks up, 1 deload", "4 weeks linear"

### 6. Active Program in UserProfile
- **Decision:** UserProfile.activeProgram: TrainingProgram?
- **Rationale:** Apple's recommended pattern, SwiftData native
- **Benefit:** Automatic persistence, relationship management

### 7. Workout-Level RPE Tracking
- **Decision:** Add `Workout.rpe: Int?` field
- **Rationale:** Simple post-workout assessment, MVP-friendly
- **Future:** Set-level RPE can be added in v2.1

### 8. Multi-Layer Delete Safety
- **Decision:** Repository business logic + UI validation
- **Rationale:** Data integrity + user-friendly warnings
- **Implementation:** Check program usage before deletion

---

## Domain Models

### TrainingProgram (MacroCycle)

```swift
@Model
final class TrainingProgram {
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String?
    var category: ProgramCategory
    var difficulty: DifficultyLevel
    var durationWeeks: Int
    var isCustom: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var weeks: [ProgramWeek]
}
```

**Responsibilities:**
- Container for entire program
- Metadata (name, category, difficulty)
- Lifecycle management

### ProgramWeek (MicroCycle)

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

**Responsibilities:**
- Weekly plan container
- Progressive overload modifiers
- Phase tagging (hypertrophy, strength, peaking)
- Deload week marking

### ProgramDay

```swift
@Model
final class ProgramDay {
    @Attribute(.unique) var id: UUID
    var dayOfWeek: Int
    var name: String?
    var notes: String?

    var week: ProgramWeek
    var template: WorkoutTemplate?

    var intensityOverride: Double?
    var volumeOverride: Double?
    var suggestedRPE: Int?
}
```

**Responsibilities:**
- Daily workout assignment
- Template reference
- Day-specific overrides

### Supporting Enums

```swift
enum ProgramCategory: String, Codable, CaseIterable {
    case powerlifting
    case bodybuilding
    case strengthTraining
    case crossfit
    case generalFitness
    case sportSpecific
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}

enum TrainingPhase: String, Codable, CaseIterable {
    case hypertrophy
    case strength
    case peaking
    case deload
    case testing
}

enum WeekProgressionPattern: String, Codable, CaseIterable {
    case linear              // Consistent increase
    case wave               // Up/down pattern
    case threeOneDeload     // 3 weeks up, 1 deload
    case fourOneDeload      // 4 weeks up, 1 deload
    case custom             // User-defined
}
```

---

## Architecture Patterns

### Repository Pattern

Following existing pattern with `@ModelActor`:

```swift
@ModelActor
actor TrainingProgramRepository: TrainingProgramRepositoryProtocol {
    func create(_ program: TrainingProgram) async throws
    func fetchAll() async throws -> [TrainingProgram]
    func fetchById(_ id: UUID) async throws -> TrainingProgram?
    func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram]
    func update(_ program: TrainingProgram) async throws
    func delete(_ program: TrainingProgram) async throws
    func seedPresetPrograms() async throws
}
```

### ViewModel Pattern

Following existing `@Observable @MainActor` pattern:

```swift
@Observable
@MainActor
final class ProgramsListViewModel {
    private(set) var programs: [TrainingProgram] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private let repository: TrainingProgramRepositoryProtocol

    func loadPrograms() async
    func deleteProgram(_ program: TrainingProgram) async
}
```

### Service Layer

```swift
@MainActor
final class ProgressiveOverloadService {
    func suggestWorkout(
        for template: WorkoutTemplate,
        weekModifier: Double,
        previousWorkouts: [Workout]
    ) -> SuggestedWorkout

    private func calculateSuggestion(
        baseWeight: Double,
        lastWeight: Double,
        lastRPE: Int?,
        weekModifier: Double
    ) -> ExerciseSuggestion
}
```

---

## Progressive Overload Algorithm

### RPE-Based Auto-Suggestion

```swift
switch lastRPE {
case 1...6:
    // Too easy - bigger jump
    suggestedWeight = lastWeight * 1.05  // +5%

case 7...8:
    // Perfect - small increment
    suggestedWeight = lastWeight * 1.025  // +2.5%

case 9...10:
    // Too hard - maintain or reduce
    suggestedWeight = lastWeight * 0.975  // -2.5%
}

// Apply week modifier
finalSuggestion = suggestedWeight * weekModifier
```

### Week Progression Patterns

**Linear Pattern:**
```
Week 1: 1.0x
Week 2: 1.025x (+2.5%)
Week 3: 1.05x (+5%)
Week 4: 1.075x (+7.5%)
```

**3-1 Deload Pattern:**
```
Week 1: 1.0x
Week 2: 1.025x
Week 3: 1.05x
Week 4: 0.6x (deload)
Week 5: 1.075x
Week 6: 1.10x
Week 7: 1.125x
Week 8: 0.6x (deload)
```

**Wave Pattern:**
```
Week 1: 1.0x
Week 2: 1.05x
Week 3: 0.95x
Week 4: 1.10x
Week 5: 1.0x
Week 6: 1.15x
```

---

## Data Integrity

### Template Deletion Safety

**Multi-Layer Protection:**

1. **Repository Layer (Business Logic)**
```swift
func deleteTemplate(_ template: WorkoutTemplate) async throws {
    // Check if used in programs
    let programs = try await findProgramsUsingTemplate(template)
    guard programs.isEmpty else {
        throw TemplateError.usedInPrograms(programNames: programs.map { $0.name })
    }

    // Check if preset
    guard !template.isPreset else {
        throw TemplateError.cannotDeletePreset
    }

    modelContext.delete(template)
    try modelContext.save()
}
```

2. **UI Layer (User Experience)**
```swift
Button(role: .destructive) {
    // Pre-check
    if viewModel.isTemplateUsedInPrograms(template) {
        showUsageWarning = true
    } else {
        showDeleteConfirmation = true
    }
} label: {
    Label("Delete", systemImage: "trash")
}
.disabled(viewModel.isTemplateUsedInPrograms(template))
```

### Cascade Delete Rules

```
TrainingProgram (delete)
  ├─▶ ProgramWeek (cascade delete)
  │     └─▶ ProgramDay (cascade delete)
  │           └─▶ WorkoutTemplate (REFERENCE, not deleted)
```

---

## Active Program Tracking

### UserProfile Integration

```swift
@Model
final class UserProfile {
    // ... existing fields

    // v2.0 Addition
    var activeProgram: TrainingProgram?  // SwiftData relationship
    var activeProgramStartDate: Date?
    var currentWeekNumber: Int?
}
```

### Today's Workout Logic

```swift
func getTodaysWorkout() -> ProgramDay? {
    guard let activeProgram = userProfile.activeProgram,
          let startDate = userProfile.activeProgramStartDate else {
        return nil
    }

    let today = Date()
    let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: today).day ?? 0
    let currentWeek = (daysSinceStart / 7) + 1
    let currentDayOfWeek = Calendar.current.component(.weekday, from: today)

    return activeProgram.weeks
        .first { $0.weekNumber == currentWeek }?
        .days
        .first { $0.dayOfWeek == currentDayOfWeek }
}
```

---

## File Structure

```
antrain/
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Program/                    ← NEW
│   │   │   │   ├── TrainingProgram.swift
│   │   │   │   ├── ProgramWeek.swift
│   │   │   │   ├── ProgramDay.swift
│   │   │   │   ├── TrainingPhase.swift
│   │   │   │   ├── ProgramCategory.swift
│   │   │   │   ├── DifficultyLevel.swift
│   │   │   │   └── WeekProgressionPattern.swift
│   │   │   ├── Workout/
│   │   │   │   └── Workout.swift           ← MODIFIED (add rpe field)
│   │   │   └── User/
│   │   │       └── UserProfile.swift       ← MODIFIED (add activeProgram)
│   │   └── Protocols/
│   │       └── Repositories/
│   │           └── TrainingProgramRepositoryProtocol.swift
│   └── Data/
│       ├── Repositories/
│       │   └── TrainingProgramRepository.swift
│       ├── Services/
│       │   └── ProgressiveOverloadService.swift
│       └── Libraries/
│           └── ProgramLibrary/
│               ├── ProgramLibrary.swift
│               ├── ProgramDTO.swift
│               ├── Strength/
│               │   ├── StartingStrength.swift
│               │   └── StrongLifts5x5.swift
│               ├── Hypertrophy/
│               │   ├── PPL6Day.swift
│               │   └── PHAT.swift
│               └── Beginner/
│                   └── BeginnerFullBody.swift
└── Features/
    └── Programs/                           ← NEW FEATURE
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

---

## Dependencies

### AppDependencies Updates

```swift
final class AppDependencies: ObservableObject {
    // ... existing repositories

    // v2.0 Additions
    let trainingProgramRepository: TrainingProgramRepositoryProtocol
    let progressiveOverloadService: ProgressiveOverloadService

    init(modelContainer: ModelContainer) {
        // ... existing init

        self.trainingProgramRepository = TrainingProgramRepository(modelContainer: modelContainer)
        self.progressiveOverloadService = ProgressiveOverloadService(
            workoutRepository: workoutRepository
        )
    }
}
```

---

## Localization

All user-facing strings must be localized:

```swift
// Example localization keys
"program.title" = "Training Programs"
"program.create" = "Create Program"
"program.category.powerlifting" = "Powerlifting"
"program.difficulty.beginner" = "Beginner"
"program.phase.hypertrophy" = "Hypertrophy"
"program.week.deload" = "Deload Week"
"program.error.templateUsed" = "Template is used in %d programs"
```

---

## Testing Strategy

### Unit Tests
- Progressive overload algorithm
- Week progression patterns
- RPE-based suggestion logic
- Date calculations (today's workout)

### Integration Tests
- Repository CRUD operations
- Template-Program relationship integrity
- Active program state management

### UI Tests
- Program creation flow
- Week/day navigation
- Template selection
- Delete safety warnings

---

## Performance Considerations

### SwiftData Optimization
- Use `@Relationship` for efficient fetching
- Implement pagination for program lists (100+ programs)
- Cache active program in memory

### Background Thread Safety
- All repository operations on background actor
- ViewModels on `@MainActor`
- No main thread blocking

---

## Future Enhancements (v2.1+)

### Mesocycle Support
Add explicit training blocks for advanced periodization.

### 1RM Tracking
Track estimated 1RM per exercise, percentage-based programming.

### Auto-Regulation
Advanced fatigue management, automatic deload recommendations.

### Community Programs
Share/import programs, marketplace, ratings.

### Apple Watch Integration
Sync program schedule, workout reminders.

### Analytics
Program adherence, volume/intensity trends, PR frequency.

---

## References

- [Implementation Plan](./IMPLEMENTATION_PLAN.md)
- [API Design](./API_DESIGN.md)
- [SwiftData Best Practices](https://developer.apple.com/documentation/swiftdata)
- [MVVM Architecture](../ARCHITECTURE.md)

---

**Document Version:** 1.0
**Authors:** Development Team
**Review Status:** Draft
