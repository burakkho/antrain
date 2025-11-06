# Training Programs Implementation Plan (v2.0)

> **Status:** Implementation In Progress - Phase 5 Complete
> **Estimated Duration:** 2-3 weeks
> **Last Updated:** 2025-11-06

## Overview

This document outlines the step-by-step implementation plan for the Training Programs feature. The implementation is divided into 6 phases, designed to deliver incremental value while maintaining code quality and architecture standards.

---

## Phase Summary

| Phase | Duration | Focus | Deliverables |
|-------|----------|-------|--------------|
| Phase 1 | 2-3 days | Domain Models | Core models, enums, validation |
| Phase 2 | 2-3 days | Repository & Services | Data layer, business logic |
| Phase 3 | 3 days | Basic UI | List, detail, navigation |
| Phase 4 | 3-4 days | Program Creation | Multi-step wizard |
| Phase 5 | 2 days | Preset Programs | Seed data, library |
| Phase 6 | 2-3 days | Active Tracking | State management, today's workout |

**Total Estimated Time:** 14-18 days (2-3 weeks)

---

## Phase 1: Domain Models & Enums

**Duration:** 2-3 days
**Dependencies:** None
**Status:** ✅ Complete

### Objectives

Create all domain models and supporting types for Training Programs.

### Tasks

#### 1.1 Create Supporting Enums (Day 1 - Morning)

**Files to Create:**
- `Core/Domain/Models/Program/ProgramCategory.swift`
- `Core/Domain/Models/Program/DifficultyLevel.swift`
- `Core/Domain/Models/Program/TrainingPhase.swift`
- `Core/Domain/Models/Program/WeekProgressionPattern.swift`

**Checklist:**
- [ ] Create `ProgramCategory` enum with all categories
- [ ] Create `DifficultyLevel` enum (beginner, intermediate, advanced)
- [ ] Create `TrainingPhase` enum (hypertrophy, strength, peaking, deload, testing)
- [ ] Create `WeekProgressionPattern` enum with patterns
- [ ] Add localization keys for all enum cases
- [ ] Write unit tests for enum conformances

**Acceptance Criteria:**
- All enums conform to `String, Codable, CaseIterable`
- Display names localized
- Build successful, no warnings

---

#### 1.2 Create TrainingProgram Model (Day 1 - Afternoon)

**File to Create:**
- `Core/Domain/Models/Program/TrainingProgram.swift`

**Checklist:**
- [ ] Define `@Model` class with all properties
- [ ] Add `@Relationship` for weeks (cascade delete)
- [ ] Implement initializer
- [ ] Add computed properties (totalWeeks, etc.)
- [ ] Add validation logic
- [ ] Add duplicate() method
- [ ] Write unit tests

**Acceptance Criteria:**
- SwiftData model compiles
- Relationships properly configured
- Validation catches invalid data
- Unit tests pass

---

#### 1.3 Create ProgramWeek Model (Day 2 - Morning)

**File to Create:**
- `Core/Domain/Models/Program/ProgramWeek.swift`

**Checklist:**
- [ ] Define `@Model` class
- [ ] Add relationship to `TrainingProgram`
- [ ] Add `@Relationship` for days (cascade delete)
- [ ] Implement progressive overload modifiers
- [ ] Add phase tagging
- [ ] Add deload flag
- [ ] Write unit tests

**Acceptance Criteria:**
- Relationships work correctly
- Modifiers default to 1.0
- Phase tagging optional
- Unit tests pass

---

#### 1.4 Create ProgramDay Model (Day 2 - Afternoon)

**File to Create:**
- `Core/Domain/Models/Program/ProgramDay.swift`

**Checklist:**
- [ ] Define `@Model` class
- [ ] Add relationship to `ProgramWeek`
- [ ] Add optional reference to `WorkoutTemplate`
- [ ] Add day-specific overrides
- [ ] Add suggested RPE field
- [ ] Write unit tests

**Acceptance Criteria:**
- Template reference optional (nullable)
- Overrides optional
- Relationship to week works
- Unit tests pass

---

#### 1.5 Modify Existing Models (Day 3)

**Files to Modify:**
- `Core/Domain/Models/Workout/Workout.swift`
- `Core/Domain/Models/User/UserProfile.swift`

**Workout.swift Changes:**
```swift
@Model
final class Workout {
    // ... existing fields

    // v2.0 Addition
    var rpe: Int?  // 1-10 Rate of Perceived Exertion
}
```

**UserProfile.swift Changes:**
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

**Checklist:**
- [ ] Add `rpe` field to Workout model
- [ ] Add active program fields to UserProfile
- [ ] Update validation logic if needed
- [ ] Write migration tests
- [ ] Update existing unit tests

**Acceptance Criteria:**
- Models compile without errors
- SwiftData relationships work
- Existing tests still pass
- New fields properly persisted

---

### Phase 1 Deliverables

- [x] All enum types created and localized
- [x] TrainingProgram model complete
- [x] ProgramWeek model complete
- [x] ProgramDay model complete
- [x] Workout model updated with RPE
- [x] UserProfile updated with active program
- [x] All unit tests passing
- [x] Build successful

---

## Phase 2: Repository & Services

**Duration:** 2-3 days
**Dependencies:** Phase 1 complete
**Status:** ✅ Complete

### Objectives

Implement data layer and business logic for Training Programs.

### Tasks

#### 2.1 Create Repository Protocol (Day 1 - Morning)

**File to Create:**
- `Core/Domain/Protocols/Repositories/TrainingProgramRepositoryProtocol.swift`

**Checklist:**
- [ ] Define protocol with all CRUD methods
- [ ] Add fetch methods (by category, difficulty, etc.)
- [ ] Add preset seeding methods
- [ ] Add template usage check methods
- [ ] Follow existing repository protocol patterns

**Acceptance Criteria:**
- Protocol follows existing patterns
- All async methods properly defined
- Error types documented

---

#### 2.2 Implement Repository (Day 1 - Afternoon + Day 2)

**File to Create:**
- `Core/Data/Repositories/TrainingProgramRepository.swift`

**Checklist:**
- [ ] Create `@ModelActor` class
- [ ] Implement CRUD operations
- [ ] Implement fetch methods
- [ ] Add validation in create/update
- [ ] Implement template usage checker
- [ ] Add preset seeding logic
- [ ] Write integration tests

**Key Methods:**
```swift
func create(_ program: TrainingProgram) async throws
func fetchAll() async throws -> [TrainingProgram]
func fetchById(_ id: UUID) async throws -> TrainingProgram?
func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram]
func fetchUserPrograms() async throws -> [TrainingProgram]
func fetchPresetPrograms() async throws -> [TrainingProgram]
func update(_ program: TrainingProgram) async throws
func delete(_ program: TrainingProgram) async throws
func findProgramsUsingTemplate(_ template: WorkoutTemplate) async throws -> [TrainingProgram]
func seedPresetPrograms() async throws
```

**Acceptance Criteria:**
- All methods implemented
- SwiftData operations work correctly
- Integration tests pass
- Thread-safe with @ModelActor

---

#### 2.3 Create Progressive Overload Service (Day 3)

**File to Create:**
- `Core/Data/Services/ProgressiveOverloadService.swift`

**Checklist:**
- [ ] Create `@MainActor` service class
- [ ] Implement RPE-based suggestion algorithm
- [ ] Implement week modifier application
- [ ] Add workout history analysis
- [ ] Create suggestion data structures
- [ ] Write unit tests for algorithm

**Key Methods:**
```swift
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
```

**RPE Algorithm:**
- RPE 1-6: +5% weight increase
- RPE 7-8: +2.5% weight increase
- RPE 9-10: -2.5% weight decrease

**Acceptance Criteria:**
- Algorithm produces reasonable suggestions
- Unit tests cover all RPE ranges
- Edge cases handled (no history, first workout)

---

#### 2.4 Update AppDependencies (Day 3 - End)

**File to Modify:**
- `App/AppDependencies.swift`

**Changes:**
```swift
final class AppDependencies: ObservableObject {
    // ... existing

    let trainingProgramRepository: TrainingProgramRepositoryProtocol
    let progressiveOverloadService: ProgressiveOverloadService

    init(modelContainer: ModelContainer) {
        // ... existing

        self.trainingProgramRepository = TrainingProgramRepository(
            modelContainer: modelContainer
        )
        self.progressiveOverloadService = ProgressiveOverloadService(
            workoutRepository: workoutRepository
        )
    }
}
```

**Checklist:**
- [ ] Add repository property
- [ ] Add service property
- [ ] Initialize in init method
- [ ] Update preview dependencies
- [ ] Verify compile

**Acceptance Criteria:**
- Dependencies inject correctly
- Preview still works
- Build successful

---

#### 2.5 Update WorkoutTemplateRepository (Day 3 - End)

**File to Modify:**
- `Core/Data/Repositories/WorkoutTemplateRepository.swift`

**Add Template Usage Check:**
```swift
func deleteTemplate(_ template: WorkoutTemplate) async throws {
    // NEW: Check if used in programs
    let programs = try await appDependencies.trainingProgramRepository
        .findProgramsUsingTemplate(template)

    guard programs.isEmpty else {
        throw WorkoutTemplateRepositoryError.usedInPrograms(
            programNames: programs.map { $0.name }
        )
    }

    // Existing deletion logic
    guard !template.isPreset else {
        throw WorkoutTemplateRepositoryError.cannotDeletePreset
    }

    modelContext.delete(template)
    try modelContext.save()
}
```

**Checklist:**
- [ ] Add program usage check
- [ ] Add new error case
- [ ] Update unit tests
- [ ] Test delete prevention

**Acceptance Criteria:**
- Template deletion blocked if used
- Error message includes program names
- Tests verify constraint

---

### Phase 2 Deliverables

- [x] Repository protocol defined
- [x] Repository implementation complete
- [x] Progressive overload service implemented
- [x] AppDependencies updated
- [x] Template deletion safety added
- [x] All integration tests passing
- [x] Build successful

---

## Phase 3: Basic UI

**Duration:** 3 days
**Dependencies:** Phase 2 complete
**Status:** ✅ Complete

### Objectives

Create basic UI for viewing and navigating programs.

### Tasks

#### 3.1 Create ViewModels (Day 1)

**Files to Create:**
- `Features/Programs/ViewModels/ProgramsListViewModel.swift`
- `Features/Programs/ViewModels/ProgramDetailViewModel.swift`
- `Features/Programs/ViewModels/WeekDetailViewModel.swift`

**ProgramsListViewModel:**
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
    func filterByCategory(_ category: ProgramCategory?)
}
```

**Checklist:**
- [ ] Implement all ViewModels
- [ ] Follow existing ViewModel patterns
- [ ] Add error handling
- [ ] Add loading states
- [ ] Write unit tests

---

#### 3.2 Create UI Components (Day 1-2)

**Files to Create:**
- `Features/Programs/Views/Components/ProgramCard.swift`
- `Features/Programs/Views/Components/WeekCard.swift`
- `Features/Programs/Views/Components/DayCard.swift`
- `Features/Programs/Views/Components/PhaseIndicator.swift`

**ProgramCard Design:**
```
┌────────────────────────────────┐
│ 💪 PPL 6-Day Split             │
│ Bodybuilding • Intermediate    │
│                                │
│ 12 weeks • 6 days/week         │
│ ████████░░░░ 42%               │
└────────────────────────────────┘
```

**Checklist:**
- [ ] Create all component views
- [ ] Match existing design system
- [ ] Use DS colors, spacing, typography
- [ ] Add previews for each component
- [ ] Test dark mode

---

#### 3.3 Create Main Views (Day 2-3)

**Files to Create:**
- `Features/Programs/Views/ProgramsListView.swift`
- `Features/Programs/Views/ProgramDetailView.swift`
- `Features/Programs/Views/WeekDetailView.swift`

**ProgramsListView Layout:**
```
Navigation Bar: "Programs"
  ├─ Filter: [All | Powerlifting | Bodybuilding | ...]
  ├─ Search Bar
  └─ + Create Program

My Programs:
  - Program Card 1
  - Program Card 2

Preset Programs:
  - Preset Card 1
  - Preset Card 2
```

**Checklist:**
- [ ] Implement all main views
- [ ] Add navigation
- [ ] Add search/filter
- [ ] Add empty states
- [ ] Add error states
- [ ] Add loading states
- [ ] Test on different screen sizes

---

#### 3.4 Add to Main Tab View (Day 3 - End)

**File to Modify:**
- `App/MainTabView.swift`

**Add Programs Tab:**
```swift
TabView {
    // ... existing tabs

    NavigationStack {
        ProgramsListView()
            .environmentObject(appDependencies)
    }
    .tabItem {
        Label("Programs", systemImage: "calendar.day.timeline.leading")
    }
}
```

**Checklist:**
- [ ] Add Programs tab
- [ ] Choose appropriate SF Symbol
- [ ] Test tab navigation
- [ ] Verify dependency injection

---

### Phase 3 Deliverables

- [x] All ViewModels implemented
- [x] All UI components created
- [x] All main views implemented
- [x] Programs tab added
- [x] Navigation working
- [x] All previews functional
- [x] Build successful

---

## Phase 4: Program Creation Wizard

**Duration:** 3-4 days
**Dependencies:** Phase 3 complete
**Status:** ✅ Complete

### Objectives

Multi-step wizard for creating custom programs.

### Tasks

#### 4.1 Create Wizard ViewModel (Day 1)

**File to Create:**
- `Features/Programs/ViewModels/CreateProgramViewModel.swift`

**State Management:**
```swift
@Observable
@MainActor
final class CreateProgramViewModel {
    // Step 1: Basic Info
    var name: String = ""
    var description: String = ""
    var category: ProgramCategory = .generalFitness
    var difficulty: DifficultyLevel = .beginner
    var durationWeeks: Int = 12

    // Step 2: Progression Pattern
    var progressionPattern: WeekProgressionPattern = .linear
    var baseIntensity: Double = 1.0
    var weeklyIncrement: Double = 0.025

    // Step 3: Weekly Schedule
    var weeklySchedule: [Int: WorkoutTemplate?] = [:]  // dayOfWeek: template

    // State
    var currentStep: Int = 1
    private(set) var isCreating = false
    private(set) var error: Error?

    func nextStep()
    func previousStep()
    func createProgram() async throws
}
```

**Checklist:**
- [ ] Implement state machine for steps
- [ ] Add validation for each step
- [ ] Implement program creation logic
- [ ] Handle errors gracefully
- [ ] Write unit tests

---

#### 4.2 Create Wizard Views (Day 1-2)

**Files to Create:**
- `Features/Programs/Views/CreateProgramFlow.swift` (Main coordinator)
- `Features/Programs/Views/CreateProgram/Step1BasicInfo.swift`
- `Features/Programs/Views/CreateProgram/Step2Progression.swift`
- `Features/Programs/Views/CreateProgram/Step3Schedule.swift`
- `Features/Programs/Views/CreateProgram/PreviewView.swift`

**Step Flow:**
```
Step 1: Basic Info
  - Name
  - Description
  - Category
  - Difficulty
  - Duration (weeks)
  [Next]

Step 2: Progression Pattern
  - Pattern selection (Linear, Wave, 3-1 Deload, etc.)
  - Base intensity
  - Weekly increment
  - Preview graph
  [Back] [Next]

Step 3: Weekly Schedule
  - For each day of week:
    - Select template (optional)
    - Add notes
  [Back] [Next]

Step 4: Preview
  - Show full program structure
  - Week-by-week breakdown
  - Edit button for each section
  [Back] [Create Program]
```

**Checklist:**
- [ ] Implement all step views
- [ ] Add step indicator UI
- [ ] Implement navigation between steps
- [ ] Add validation feedback
- [ ] Add preview functionality
- [ ] Test complete flow

---

#### 4.3 Template Selector Component (Day 3)

**File to Create:**
- `Features/Programs/Views/Components/TemplateSelectorSheet.swift`

**Features:**
- Search templates
- Filter by category
- Preview template exercises
- Select/deselect

**Checklist:**
- [ ] Implement template search
- [ ] Add category filter
- [ ] Show exercise preview
- [ ] Handle selection
- [ ] Add empty state

---

#### 4.4 Progression Pattern Visualizer (Day 3-4)

**File to Create:**
- `Features/Programs/Views/Components/ProgressionPatternChart.swift`

**Features:**
- Visual graph of intensity over weeks
- Show deload weeks
- Preview pattern before selection

**Checklist:**
- [ ] Implement chart view (Swift Charts)
- [ ] Show intensity progression
- [ ] Highlight deload weeks
- [ ] Add interaction (hover/tap for details)

---

### Phase 4 Deliverables

- [x] Wizard ViewModel complete (CreateProgramViewModel)
- [x] All wizard steps implemented (Step1-4 views)
- [x] Template selector working (TemplateSelectorSheet)
- [x] Progression visualizer functional (Swift Charts integration)
- [x] Complete flow tested
- [x] Validation working (per-step validation)
- [x] Build successful
- [x] Integrated with WorkoutsView and ProgramsListView

---

## Phase 5: Preset Programs

**Duration:** 2 days
**Dependencies:** Phase 4 complete
**Status:** ✅ Complete

### Objectives

Create library of preset programs with seed data.

### Tasks

#### 5.1 Create Program Library Structure (Day 1 - Morning)

**Files to Create:**
- `Core/Data/Libraries/ProgramLibrary/ProgramLibrary.swift`
- `Core/Data/Libraries/ProgramLibrary/ProgramDTO.swift`

**ProgramDTO Pattern:**
```swift
struct ProgramDTO {
    let id: UUID
    let name: String
    let description: String
    let category: ProgramCategory
    let difficulty: DifficultyLevel
    let weeks: [WeekDTO]
}

struct WeekDTO {
    let weekNumber: Int
    let phaseTag: TrainingPhase?
    let intensityModifier: Double
    let isDeload: Bool
    let days: [DayDTO]
}

struct DayDTO {
    let dayOfWeek: Int
    let templateName: String  // Reference by name
}
```

**Checklist:**
- [ ] Create DTO structures
- [ ] Add conversion to models
- [ ] Follow template library pattern

---

#### 5.2 Create Preset Programs (Day 1 - Afternoon + Day 2)

**Files to Create:**
- `Core/Data/Libraries/ProgramLibrary/Strength/StartingStrength.swift`
- `Core/Data/Libraries/ProgramLibrary/Strength/StrongLifts5x5.swift`
- `Core/Data/Libraries/ProgramLibrary/Hypertrophy/PPL6Day.swift`
- `Core/Data/Libraries/ProgramLibrary/Hypertrophy/PHAT.swift`
- `Core/Data/Libraries/ProgramLibrary/Beginner/BeginnerFullBody.swift`

**Program List (Minimum 10-15):**

**Beginner:**
- Starting Strength (3 days/week, 12 weeks)
- StrongLifts 5×5 (3 days/week, 12 weeks)
- Beginner Full Body (3 days/week, 8 weeks)

**Strength:**
- Texas Method (3 days/week, 12 weeks)
- 5/3/1 Boring But Big (4 days/week, 12 weeks)
- nSuns 531 (5 days/week, 12 weeks)

**Hypertrophy:**
- PPL 6-Day Split (6 days/week, 12 weeks)
- PHAT (5 days/week, 12 weeks)
- PHUL (4 days/week, 12 weeks)
- Upper/Lower 4-Day (4 days/week, 12 weeks)

**Powerlifting:**
- 12-Week Powerlifting Peak (4 days/week)
- Sheiko Intermediate (4 days/week, 16 weeks)

**Bodybuilding:**
- Bro Split (5 days/week, 12 weeks)
- Arnold Split (6 days/week, 12 weeks)

**CrossFit:**
- CrossFit Strength Bias (5 days/week, 8 weeks)

**Checklist:**
- [ ] Research each program structure
- [ ] Create accurate DTOs
- [ ] Map to existing templates
- [ ] Add proper progression patterns
- [ ] Add program descriptions
- [ ] Test conversions

---

#### 5.3 Implement Seeding (Day 2 - End)

**Update Repository:**
```swift
func seedPresetPrograms() async throws {
    let hasPresets = try await hasPresetPrograms()
    guard !hasPresets else { return }

    let templateFinder: (String) -> WorkoutTemplate? = { name in
        // Fetch template by name from repository
    }

    let presets = await MainActor.run {
        ProgramLibrary().convertToModels(templateFinder: templateFinder)
    }

    for preset in presets {
        modelContext.insert(preset)
    }

    try modelContext.save()
}
```

**Checklist:**
- [ ] Implement seeding logic
- [ ] Handle template references
- [ ] Test idempotency (don't re-seed)
- [ ] Add to app initialization

---

### Phase 5 Deliverables

- [x] Program library structure created
- [x] 10-15 preset programs defined
- [x] Seeding logic implemented
- [x] Programs appear in app
- [x] Template references correct
- [x] Build successful

---

## Phase 6: Active Program Tracking

**Duration:** 2-3 days
**Dependencies:** Phase 5 complete
**Status:** ⚠️ Partial (50%)

### Objectives

Enable users to activate programs and get daily workout suggestions.

### Tasks

#### 6.1 Implement Active Program Logic (Day 1)

**Update UserProfile:**
```swift
extension UserProfile {
    func activateProgram(_ program: TrainingProgram) {
        self.activeProgram = program
        self.activeProgramStartDate = Date()
        self.currentWeekNumber = 1
    }

    func deactivateProgram() {
        self.activeProgram = nil
        self.activeProgramStartDate = nil
        self.currentWeekNumber = nil
    }

    func getTodaysWorkout() -> ProgramDay? {
        // Implementation from architecture doc
    }

    func progressToNextWeek() {
        guard let current = currentWeekNumber else { return }
        currentWeekNumber = current + 1
    }
}
```

**Checklist:**
- [x] Add activation/deactivation methods
- [x] Implement today's workout logic
- [x] Add week progression logic
- [ ] Write unit tests

---

#### 6.2 Update Home View (Day 1-2)

**File to Modify:**
- `Features/Home/Views/HomeView.swift`

**Add Active Program Card:**
```
┌─────────────────────────────────────┐
│ 🎯 Active Program                   │
│ PPL 6-Day Split                     │
│ Week 5/12 • Strength Phase          │
│                                     │
│ Today: Push Day                     │
│ [Start Workout]                     │
│                                     │
│ Progress: ████████░░░░ 42%          │
└─────────────────────────────────────┘
```

**Checklist:**
- [x] Create active program card component
- [ ] Show current week/phase
- [ ] Show today's workout
- [ ] Add "Start Workout" button
- [ ] Handle no active program state

**Note:** ActiveProgramCard created but not yet integrated into HomeView

---

#### 6.3 Program Activation Flow (Day 2)

**Add to ProgramDetailView:**
```swift
// Activation button
Button {
    viewModel.activateProgram()
} label: {
    Label("Start This Program", systemImage: "play.fill")
}
.buttonStyle(.borderedProminent)

// Confirmation dialog
.confirmationDialog(
    "Activate Program?",
    isPresented: $showActivateConfirmation
) {
    Button("Activate") {
        Task { await viewModel.activateProgram() }
    }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("This will replace your current active program.")
}
```

**Checklist:**
- [ ] Add activation button
- [ ] Show confirmation if replacing active
- [ ] Update UI after activation
- [ ] Handle errors

---

#### 6.4 Workout Integration (Day 2-3)

**Update LiftingSessionView:**
- When starting from active program, pre-fill with suggestions
- Show week/day context
- Apply progressive overload suggestions

**Checklist:**
- [ ] Detect workout started from program
- [ ] Pre-fill exercises from template
- [ ] Apply week intensity modifiers
- [ ] Show suggested weights (from ProgressiveOverloadService)
- [ ] Allow user to accept/override suggestions

---

#### 6.5 Progress Tracking (Day 3)

**Add to ProgramDetailView:**
- Week-by-week completion status
- Mark weeks as completed
- Show adherence percentage
- Visual progress indicators

**Checklist:**
- [ ] Track workout completions
- [ ] Mark weeks as completed
- [ ] Calculate adherence rate
- [ ] Show visual progress

---

### Phase 6 Deliverables

- [x] Active program state management
- [ ] Home view shows active program (component created, not integrated)
- [x] Activation flow complete (in ProgramDetailView)
- [ ] Workout integration working (not started)
- [ ] Progress tracking implemented (not started)
- [x] Build successful
- [ ] All features tested end-to-end

**Current Status:** 50% - State management complete, UI integration pending

---

## Testing Strategy

### Unit Tests
- [ ] Domain model validation
- [ ] RPE algorithm correctness
- [ ] Week progression patterns
- [ ] Date calculations
- [ ] Template reference safety

### Integration Tests
- [ ] Repository CRUD operations
- [ ] Template-Program relationships
- [ ] Active program state persistence
- [ ] Workout-Program integration

### UI Tests
- [ ] Program creation flow
- [ ] Template selection
- [ ] Program activation
- [ ] Today's workout display
- [ ] Delete safety warnings

### Manual Testing Checklist
- [ ] Create custom program
- [ ] Activate program
- [ ] Start workout from program
- [ ] Complete workout with RPE
- [ ] Verify next workout suggestions
- [ ] Progress through weeks
- [ ] Try to delete used template
- [ ] Deactivate program
- [ ] Delete program

---

## Rollout Plan

### Alpha (Internal Testing)
- Phases 1-3 complete
- Basic viewing functionality
- No preset programs yet

### Beta (Early Access)
- Phases 1-5 complete
- Full CRUD functionality
- Preset programs available
- No active tracking yet

### v2.0 Release
- All 6 phases complete
- Full feature set
- Comprehensive testing done
- Documentation updated

---

## Risk Mitigation

### Technical Risks

**Risk:** SwiftData relationship performance with deep nesting
- **Mitigation:** Profile early, optimize fetch descriptors
- **Contingency:** Add pagination, caching layer

**Risk:** Template deletion breaks programs
- **Mitigation:** Multi-layer constraint checking (done in design)
- **Contingency:** Snapshot backup as fallback

**Risk:** Progressive overload algorithm produces bad suggestions
- **Mitigation:** Extensive unit testing, manual review
- **Contingency:** User can always override

### Schedule Risks

**Risk:** Phase takes longer than estimated
- **Mitigation:** Daily progress tracking, early issue identification
- **Contingency:** Reduce scope of current phase, defer to future

**Risk:** Blocking bugs discovered
- **Mitigation:** Incremental testing after each phase
- **Contingency:** Roll back to previous stable phase

---

## Success Metrics

### Technical Metrics
- All unit tests passing (>95% coverage)
- All integration tests passing
- Build time < 30 seconds
- No memory leaks
- SwiftData fetch times < 100ms

### Feature Metrics
- User can create program in < 2 minutes
- User can activate program in < 10 seconds
- Workout suggestions accurate 90% of time
- Zero template deletion bugs

---

## Post-Implementation

### Code Review
- [ ] Architecture review
- [ ] Code quality review
- [ ] Performance review
- [ ] Security review

### Documentation
- [ ] Update CHANGELOG.md
- [ ] Update README.md
- [ ] Create user guide
- [ ] Update API documentation

### Deployment
- [ ] Merge to main branch
- [ ] Tag v2.0 release
- [ ] Update App Store listing
- [ ] Announce release

---

## References

- [Architecture Document](./TRAINING_PROGRAMS.md)
- [API Design](./API_DESIGN.md)
- [Testing Strategy](../TESTING.md)

---

**Document Version:** 1.0
**Next Review:** After Phase 1 completion
**Status:** Ready for Implementation
