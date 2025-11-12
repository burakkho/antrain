# Training Programs Architecture (v2.0 - Day-Based System)

> **Status:** ✅ Implemented
> **Current Release:** v2.0
> **Last Updated:** 2025-11-11
> **System:** Day-Based (Sequential Progression)

## Overview

Training Programs feature enables users to follow structured, day-based workout plans with built-in progressive overload and auto-regulation. This document outlines the complete architecture of the **day-based training program system** - a simplified, more flexible approach compared to traditional week-based periodization.

---

## Core Concepts

### Hierarchy (Day-Based System)

```
TrainingProgram
  └── ProgramDay (1 to totalDays, sequential)
      └── WorkoutTemplate (Reference)
          └── Exercise (Single Source of Truth)
```

**Key Difference:** No week abstraction. Programs are defined as a sequence of days from Day 1 to Day N.

### Example Flow

```
84-Day PPL Program (Push/Pull/Legs)
  ├── Day 1: Push Day (template: "PPL Push")
  ├── Day 2: Pull Day (template: "PPL Pull")
  ├── Day 3: Legs Day (template: "PPL Legs")
  ├── Day 4: Rest
  ├── Day 5: Push Day (template: "PPL Push")
  ├── Day 6: Pull Day (template: "PPL Pull")
  ├── Day 7: Legs Day (template: "PPL Legs")
  ├── Day 8: Rest
  ├── ...
  └── Day 84: Final workout
```

**Progression:** Automatic day-by-day progression after each workout completion.

---

## Key Design Decisions

### 1. 100% Local, Zero Cloud
- **Decision:** No HealthKit integration, pure SwiftData
- **Rationale:** Preserves core privacy principle
- **Trade-off:** No Apple Training Load, but full control over analytics

### 2. Day-Based Sequential Structure (Simplified)
- **Decision:** Program → Day (no Week/Mesocycle abstraction)
- **Rationale:** Simpler mental model, more flexible, easier maintenance
- **Benefit:** Programs progress day-by-day (1→2→3→...→N)
- **Trade-off:** No built-in week-level periodization, but gained simplicity

### 3. Auto-Progression on Workout Completion
- **Decision:** Automatic advancement to next day after finishing workout
- **Rationale:** Seamless user experience, no manual tracking
- **Implementation:** `WorkoutSummaryViewModel.saveWorkout()` → `UserProfile.progressToNextDay()`

### 4. Hybrid Progressive Overload
- **Decision:** Auto-suggest based on previous workouts, user can override
- **Rationale:** Balance between automation and control
- **Implementation:** Progressive overload service with manual override

### 5. Reference Templates (Single Source of Truth)
- **Decision:** ProgramDay references WorkoutTemplate
- **Rationale:** Storage efficient, template updates propagate
- **Safety:** Prevent template deletion if used in programs

### 6. Active Program in UserProfile
- **Decision:** UserProfile stores `activeProgram`, `currentDayNumber`, `activeProgramStartDate`
- **Rationale:** Apple's recommended pattern, SwiftData native
- **Benefit:** Automatic persistence, relationship management

### 7. Program Completion Detection
- **Decision:** "Celebrate and Ask" when user completes final day
- **Rationale:** Reward user, offer program restart or new program
- **Implementation:** Check `currentDayNumber > totalDays` in save flow

### 8. Multi-Layer Delete Safety
- **Decision:** Repository business logic + UI validation
- **Rationale:** Data integrity + user-friendly warnings
- **Implementation:** Check program usage before deletion

---

## Domain Models

### TrainingProgram

```swift
@Model
final class TrainingProgram {
    @Attribute(.unique) var id: UUID
    var name: String
    var programDescription: String?
    var category: ProgramCategory
    var difficulty: DifficultyLevel
    var totalDays: Int              // Total program duration in days
    var isCustom: Bool
    var createdAt: Date
    var lastUsedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.program)
    var days: [ProgramDay]
}
```

**Responsibilities:**
- Container for entire program
- Metadata (name, category, difficulty)
- Total duration tracking (in days, not weeks)
- Lifecycle management

**Key Changes from v1:**
- `durationWeeks: Int` → `totalDays: Int`
- `weeks: [ProgramWeek]` → `days: [ProgramDay]`
- Direct day relationship (no week intermediate)

### ProgramDay

```swift
@Model
final class ProgramDay {
    @Attribute(.unique) var id: UUID
    var dayNumber: Int              // 1-indexed sequential day (1 to totalDays)
    var name: String?               // Optional custom name (e.g., "Upper Power")
    var notes: String?              // Day-specific instructions

    var program: TrainingProgram
    var template: WorkoutTemplate?  // nil = rest day

    // Computed properties
    var isRestDay: Bool { template == nil }
    var hasWorkout: Bool { template != nil }
    var displayName: String {
        if let customName = name, !customName.isEmpty {
            return customName
        }
        if let template = template {
            return template.name
        }
        return "Rest Day"
    }
}
```

**Responsibilities:**
- Daily workout assignment
- Template reference
- Rest day identification
- Display formatting

**Key Changes from v1:**
- `dayOfWeek: Int` → `dayNumber: Int` (1-indexed sequential)
- Removed `week: ProgramWeek` relationship
- Removed `intensityOverride`, `volumeOverride` (no day-level modifiers)
- Removed `suggestedRPE` (moved to progressive overload service)

### Supporting Enums

```swift
enum ProgramCategory: String, Codable, CaseIterable {
    case powerlifting
    case bodybuilding
    case strengthTraining
    case crossfit
    case generalFitness
    case sportSpecific

    var displayName: String { /* localized */ }
    var iconName: String { /* SF Symbol */ }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var displayName: String { /* localized */ }
    var iconName: String { /* SF Symbol */ }
}
```

**Removed Enums (v2.0):**
- `TrainingPhase` - No week-level phase tagging in day-based system
- `WeekProgressionPattern` - No pattern-based progression, simple sequential progression

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

The core of the auto-suggestion logic remains RPE-based at the micro-level (workout to workout).

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
```
*Note: Macro-level progression (e.g., week-to-week modifiers) has been removed in the day-based system for simplicity.*

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

The relationships are configured to ensure that deleting a program also deletes its dependent days.

```
TrainingProgram (delete)
  └─▶ ProgramDay (cascade delete)
        └─▶ WorkoutTemplate (REFERENCE, not deleted)
```

---

## Active Program Tracking

### UserProfile Integration

```swift
@Model
final class UserProfile {
    // ... existing fields

    // v2.0 Addition
    /// Currently active training program
    @Relationship(deleteRule: .nullify)
    var activeProgram: TrainingProgram?
    /// Date when the active program was started
    var activeProgramStartDate: Date?
    /// Current day number in the active program (1-indexed)
    var currentDayNumber: Int?
}
```

### Today's Workout Logic

The logic to retrieve the current day's workout is now greatly simplified. It directly uses the `currentDayNumber` stored in the `UserProfile`.

```swift
extension UserProfile {
    /// Get current day's workout from the active program
    /// - Returns: ProgramDay for current day number, or nil if no active program
    func getTodaysWorkout() -> ProgramDay? {
        guard let activeProgram = activeProgram,
              let dayNumber = currentDayNumber else {
            return nil
        }

        return activeProgram.day(number: dayNumber)
    }

    /// Progress to the next day in the active program
    /// - Returns: True if progressed, false if program is complete
    @discardableResult
    func progressToNextDay() -> Bool {
        guard let current = currentDayNumber,
              let program = activeProgram else {
            return false
        }

        if current < program.totalDays {
            currentDayNumber = current + 1
            return true
        } else {
            // Program is complete
            return false
        }
    }
}
```

---

## File Structure

```
antrain/
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Program/                    ← UPDATED
│   │   │   │   ├── TrainingProgram.swift
│   │   │   │   ├── ProgramDay.swift
│   │   │   │   ├── ProgramCategory.swift
│   │   │   │   └── DifficultyLevel.swift
│   │   │   ├── Workout/
│   │   │   │   └── Workout.swift
│   │   │   └── User/
│   │   │       └── UserProfile.swift       ← MODIFIED (add activeProgram, currentDayNumber)
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
│               └── ... (program files)
└── Features/
    └── Workouts/
        └── Programs/                     ← NEW FEATURE LOCATION
            ├── ViewModels/
            │   ├── ProgramsListViewModel.swift
            │   ├── ProgramDetailViewModel.swift
            │   └── ...
            └── Views/
                ├── ProgramsListView.swift
                ├── ProgramDetailView.swift
                └── Components/
                    ├── ProgramCard.swift
                    └── ...
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
