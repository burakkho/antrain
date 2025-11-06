# Workout Templates Feature - Comprehensive Plan

**Feature Version:** v1.1
**Planning Date:** 2025-11-03
**Status:** 📋 Planning Phase
**Priority:** High

---

## 📋 Executive Summary

Workout Templates feature allows users to create, save, and reuse workout routines. Users can start lifting sessions from pre-defined templates, modify them during workouts, and access a comprehensive preset library of professional routines.

### Key Capabilities

- ✅ Create custom workout templates
- ✅ Comprehensive preset template library (categorized)
- ✅ Start lifting sessions from templates
- ✅ Quick access from HomeView
- ✅ Save completed workouts as templates
- ✅ Template duplication and modification
- ✅ Category-based organization
- ❌ NO rest timer (out of scope)
- ❌ NO progress tracking (v1.2 future scope)

---

## 🎯 User Stories

### Primary User Stories

**US-1: Create Template from Scratch**
```
AS A user
I WANT TO create a workout template from scratch
SO THAT I can save my routine for future use

Acceptance Criteria:
- Multi-step wizard UI (Name → Exercises → Set Configuration)
- Can add multiple exercises in order
- Can specify set count and rep range per exercise
- Template saved to "My Templates" category
```

**US-2: Start Workout from Template**
```
AS A user
I WANT TO start a lifting session from a template
SO THAT I don't have to add exercises manually every time

Acceptance Criteria:
- Can select template from HomeView quick action
- Can select template at lifting session start
- All exercises pre-loaded with suggested sets/reps
- Can modify exercises during workout (one-off, doesn't save to template)
```

**US-3: Save Workout as Template**
```
AS A user
I WANT TO save a completed workout as a template
SO THAT I can reuse the same routine

Acceptance Criteria:
- "Save as Template" option after workout completion
- Prompts for template name and category
- Saved with exercises and set/rep configuration
```

**US-4: Browse Preset Templates**
```
AS A user
I WANT TO browse professional preset templates
SO THAT I can follow proven workout programs

Acceptance Criteria:
- Categorized preset library (Strength, Hypertrophy, Calisthenics, etc.)
- Preset templates are copied when selected (becomes user's template)
- Comprehensive library designed by personal trainer
```

**US-5: Duplicate & Modify Templates**
```
AS A user
I WANT TO duplicate an existing template
SO THAT I can create variations of my routines

Acceptance Criteria:
- Swipe action to duplicate
- Creates editable copy with "(Copy)" suffix
- All exercises and configurations preserved
```

---

## 🏗 Architecture & Design

### Domain Model: WorkoutTemplate

```swift
@Model
final class WorkoutTemplate {
    // Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var category: TemplateCategory
    var isPreset: Bool  // Preset templates (read-only source)

    // Metadata
    var createdAt: Date
    var lastUsedAt: Date?

    // Exercises
    @Relationship(deleteRule: .cascade)
    var exercises: [TemplateExercise]

    // Computed
    var exerciseCount: Int {
        exercises.count
    }

    var estimatedDuration: TimeInterval {
        // Calculate based on exercises and sets
        Double(exercises.reduce(0) { $0 + $1.setCount }) * 120 // 2 min per set
    }
}
```

### Domain Model: TemplateExercise

```swift
@Model
final class TemplateExercise {
    @Attribute(.unique) var id: UUID
    var order: Int  // Exercise order in template

    // Exercise Reference (Reference approach - exercises are read-only)
    var exerciseId: UUID
    var exerciseName: String  // Snapshot for display

    // Set Configuration
    var setCount: Int  // Recommended sets (3, 4, 5, etc.)
    var repRangeMin: Int  // Min reps (e.g., 8)
    var repRangeMax: Int  // Max reps (e.g., 12)

    // Notes
    var notes: String?  // e.g., "Dropset on last set", "Superset with X"

    // Relationship
    var template: WorkoutTemplate?
}
```

### Enum: TemplateCategory

```swift
enum TemplateCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case calisthenics = "Calisthenics"
    case weightlifting = "Weightlifting"
    case beginner = "Beginner"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .strength: return "figure.strengthtraining.traditional"
        case .hypertrophy: return "figure.mind.and.body"
        case .calisthenics: return "figure.climbing"
        case .weightlifting: return "figure.mixed.cardio"
        case .beginner: return "star.fill"
        case .custom: return "folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .strength: return .red
        case .hypertrophy: return .blue
        case .calisthenics: return .green
        case .weightlifting: return .orange
        case .beginner: return .yellow
        case .custom: return .purple
        }
    }
}
```

---

## 🗂 Repository Layer

### Protocol: WorkoutTemplateRepositoryProtocol

```swift
@MainActor
protocol WorkoutTemplateRepositoryProtocol: Actor {
    // CRUD
    func createTemplate(_ template: WorkoutTemplate) async throws
    func fetchAllTemplates() async throws -> [WorkoutTemplate]
    func fetchTemplate(by id: UUID) async throws -> WorkoutTemplate?
    func fetchTemplatesByCategory(_ category: TemplateCategory) async throws -> [WorkoutTemplate]
    func updateTemplate(_ template: WorkoutTemplate) async throws
    func deleteTemplate(_ template: WorkoutTemplate) async throws

    // Preset Management
    func seedPresetTemplates() async throws
    func fetchPresetTemplates() async throws -> [WorkoutTemplate]

    // Duplication
    func duplicateTemplate(_ template: WorkoutTemplate, newName: String) async throws -> WorkoutTemplate

    // Usage Tracking
    func markTemplateUsed(_ template: WorkoutTemplate) async throws
}
```

### Implementation: WorkoutTemplateRepository

```swift
@ModelActor
actor WorkoutTemplateRepository: WorkoutTemplateRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    // Implementation details...
    // - Uses SwiftData ModelContext for persistence
    // - Handles preset seeding on first launch
    // - Manages template-exercise relationships
}
```

---

## 🎨 UI/UX Layer

### View Hierarchy

```
TemplatesView (Main List)
├── TemplateListView
│   ├── TemplateCategoryFilterView (horizontal scroll)
│   ├── TemplateCard (for each template)
│   └── EmptyState (no templates)
│
├── CreateTemplateFlow (Multi-step wizard)
│   ├── Step 1: TemplateInfoView (name, category)
│   ├── Step 2: TemplateExerciseSelectionView (add exercises)
│   └── Step 3: TemplateSetConfigView (configure sets/reps)
│
├── TemplateDetailView
│   ├── Template info display
│   ├── Exercise list with set/rep configuration
│   ├── Actions: Edit, Duplicate, Delete, Start Workout
│   └── Metadata: Created date, last used
│
└── EditTemplateView
    └── Same as CreateTemplateFlow but pre-filled
```

### HomeView Integration

```swift
// HomeView.swift - Add quick action
struct QuickActionButtons: View {
    // Existing actions...

    Button {
        showTemplateSelector = true
    } label: {
        QuickActionButton(
            icon: "doc.text.fill",
            title: "My Templates",
            color: .purple
        )
    }
}

.sheet(isPresented: $showTemplateSelector) {
    TemplateQuickSelectorView(
        onTemplateSelected: { template in
            // Start lifting session with template
            startWorkoutFromTemplate(template)
        }
    )
}
```

### LiftingSessionView Integration

```swift
// LiftingSessionView.swift - Add template selection
@State private var selectedTemplate: WorkoutTemplate?

var body: some View {
    VStack {
        if exercises.isEmpty && selectedTemplate == nil {
            Button("Start from Template") {
                showTemplateSelector = true
            }
        }

        // Existing UI...
    }
    .sheet(isPresented: $showTemplateSelector) {
        TemplateQuickSelectorView(
            onTemplateSelected: { template in
                loadExercisesFromTemplate(template)
            }
        )
    }
}

private func loadExercisesFromTemplate(_ template: WorkoutTemplate) {
    // Pre-populate exercises with template configuration
    for templateExercise in template.exercises.sorted(by: { $0.order < $1.order }) {
        addExerciseFromTemplate(templateExercise)
    }
}
```

### Workout Completion Flow

```swift
// WorkoutSummaryView.swift - Add "Save as Template"
Button {
    showSaveTemplateSheet = true
} label: {
    Label("Save as Template", systemImage: "doc.badge.plus")
}
.sheet(isPresented: $showSaveTemplateSheet) {
    SaveWorkoutAsTemplateView(workout: workout)
}
```

---

## 📚 Preset Template Library

### Categories & Templates

#### Category: Strength (Focus: Heavy compounds, low reps)

**1. Powerlifting Focused (3 day)**
- Day 1: Squat Focus (Squat, Front Squat, Leg Press, Bulgarian Split Squat)
- Day 2: Bench Focus (Bench Press, Incline Bench, Close Grip Bench, Dips)
- Day 3: Deadlift Focus (Deadlift, Romanian Deadlift, Bent Over Row, Pull-ups)

**2. Starting Strength (3 day)**
- Workout A: Squat 3x5, Bench 3x5, Deadlift 1x5
- Workout B: Squat 3x5, Press 3x5, Power Clean 5x3

#### Category: Hypertrophy (Focus: Muscle growth, 8-12 reps)

**3. PPL (Push/Pull/Legs) - 3 day**
- Push: Bench, Incline DB Press, Shoulder Press, Lateral Raises, Tricep Pushdown
- Pull: Deadlift, Pull-ups, Barbell Row, Face Pulls, Bicep Curls
- Legs: Squat, Leg Press, Leg Curl, Calf Raises

**4. Bro Split (5 day)**
- Monday (Chest): Bench, Incline Bench, Dumbbell Flyes, Cable Crossover
- Tuesday (Back): Deadlift, Pull-ups, Barbell Row, Cable Row, Lat Pulldown
- Wednesday (Shoulders): Shoulder Press, Lateral Raises, Front Raises, Rear Delt Flyes
- Thursday (Arms): Barbell Curl, Hammer Curl, Tricep Pushdown, Skull Crushers
- Friday (Legs): Squat, Leg Press, Leg Curl, Leg Extension, Calf Raises

**5. Upper/Lower Split (2 day)**
- Upper: Bench, Row, Shoulder Press, Pull-ups, Bicep Curls, Triceps
- Lower: Squat, Romanian Deadlift, Leg Press, Leg Curl, Calf Raises

#### Category: Calisthenics (Focus: Bodyweight)

**6. Full Body Calisthenics**
- Push-ups (4 sets x 12-15)
- Pull-ups (4 sets x 8-12)
- Dips (3 sets x 10-15)
- Pistol Squats (3 sets x 8 each leg)
- L-sits (3 sets x 20-30s)

**7. Skill-Based Calisthenics**
- Handstand Practice
- Muscle-up Progressions
- Front Lever Progressions
- Planche Progressions

#### Category: Weightlifting (Focus: Olympic lifts)

**8. Olympic Lifting Program**
- Snatch (5 sets x 2-3 reps)
- Clean & Jerk (5 sets x 2-3 reps)
- Front Squat (4 sets x 3-5 reps)
- Overhead Squat (3 sets x 5 reps)

#### Category: Beginner

**9. Full Body Beginner (3 day)**
- Workout A: Squat 3x8, Bench 3x8, Row 3x8, Plank 3x30s
- Workout B: Deadlift 3x8, Press 3x8, Pull-ups 3x8, Hanging Leg Raise 3x10

---

## 🔄 User Flows

### Flow 1: Create Template from Scratch

```
1. User taps "+" in TemplatesView
2. Step 1: Enter name & select category
   - Validates name is unique
   - Shows category icons with colors
3. Step 2: Add exercises
   - Opens ExerciseSelectionView
   - Can add multiple exercises
   - Shows exercise count badge
4. Step 3: Configure each exercise
   - For each exercise: Set count, rep range, notes
   - Can skip to use defaults (3 sets, 8-12 reps)
5. Tap "Create Template"
   - Saves to repository
   - Shows success message
   - Navigates to TemplateDetailView
```

### Flow 2: Start Workout from Template (HomeView)

```
1. User taps "My Templates" in HomeView
2. Sheet shows TemplateQuickSelectorView
   - List of user templates
   - Category filter chips
   - Search bar
3. User selects template
4. Sheet dismisses
5. Navigates to LiftingSessionView
6. Exercises pre-loaded with template config
7. User completes workout normally
8. Template NOT modified (one-off workout)
```

### Flow 3: Start Workout from Template (LiftingSessionView)

```
1. User taps "Start Workout" in HomeView
2. LiftingSessionView opens (empty)
3. User taps "Start from Template" button
4. Sheet shows TemplateQuickSelectorView
5. User selects template
6. Exercises loaded into session
7. User can modify (add/remove exercises) for this workout
8. Changes don't affect original template
```

### Flow 4: Save Workout as Template

```
1. User completes workout
2. WorkoutSummaryView shows
3. User taps "Save as Template"
4. Sheet shows SaveWorkoutAsTemplateView
   - Pre-filled name (e.g., "Workout on Nov 3")
   - Category selector
   - Exercise list preview
5. User edits name & selects category
6. Taps "Save"
7. Template created with:
   - Exercises from workout
   - Set counts (from completed sets)
   - Rep ranges (min/max from completed reps)
8. Success toast shown
9. Template accessible in TemplatesView
```

### Flow 5: Duplicate Template

```
1. User in TemplatesView
2. Swipes left on template card
3. "Duplicate" action appears
4. Taps "Duplicate"
5. System creates copy:
   - Name: "[Original Name] (Copy)"
   - Same category
   - All exercises & configs copied
   - isPreset = false
6. Success toast shown
7. New template appears in list
```

### Flow 6: Use Preset Template

```
1. User opens TemplatesView
2. Filters by preset categories
3. Taps on preset template card
4. TemplateDetailView shows with "Use This Template" button
5. User taps "Use This Template"
6. System creates copy:
   - Prompt: "This will create a copy you can modify"
   - Name: [Preset Name]
   - Category: preserved
   - isPreset = false
7. Copy created and added to "My Templates"
8. Navigates to new template detail
9. User can now edit or start workout
```

---

## 🛠 Implementation Plan

### Phase 1: Domain & Data Layer (Sprint 1 - 2 days)

**Tasks:**
- [ ] Create WorkoutTemplate model
- [ ] Create TemplateExercise model
- [ ] Create TemplateCategory enum
- [ ] Create WorkoutTemplateRepositoryProtocol
- [ ] Implement WorkoutTemplateRepository (@ModelActor)
- [ ] Add repository to AppDependencies
- [ ] Create PresetTemplateSeeder utility
- [ ] Seed 9 preset templates on first launch

**Files to Create:**
```
Core/Domain/Models/Template/
├── WorkoutTemplate.swift
├── TemplateExercise.swift
└── TemplateCategory.swift

Core/Domain/Protocols/Repositories/
└── WorkoutTemplateRepositoryProtocol.swift

Core/Data/Repositories/
└── WorkoutTemplateRepository.swift

Core/Data/Seeders/
└── PresetTemplateSeeder.swift
```

### Phase 2: Core Views (Sprint 2 - 3 days)

**Tasks:**
- [ ] Create TemplatesView (main list)
- [ ] Create TemplateCard component
- [ ] Create TemplateCategoryFilterView
- [ ] Create TemplateDetailView
- [ ] Create TemplateQuickSelectorView (sheet)
- [ ] Add "My Templates" to HomeView
- [ ] Add "Start from Template" to LiftingSessionView

**Files to Create:**
```
Features/Templates/
├── Views/
│   ├── TemplatesView.swift
│   ├── TemplateDetailView.swift
│   ├── TemplateQuickSelectorView.swift
│   └── Components/
│       ├── TemplateCard.swift
│       └── TemplateCategoryFilterView.swift
└── ViewModels/
    ├── TemplatesViewModel.swift
    └── TemplateDetailViewModel.swift
```

### Phase 3: Template Creation (Sprint 3 - 3 days)

**Tasks:**
- [ ] Create CreateTemplateFlow (multi-step wizard)
- [ ] Step 1: TemplateInfoView (name, category)
- [ ] Step 2: TemplateExerciseSelectionView (add exercises)
- [ ] Step 3: TemplateSetConfigView (configure sets/reps)
- [ ] Create EditTemplateView (reuse wizard)
- [ ] Implement form validation
- [ ] Add navigation flow between steps

**Files to Create:**
```
Features/Templates/Views/CreateTemplate/
├── CreateTemplateFlow.swift
├── TemplateInfoView.swift
├── TemplateExerciseSelectionView.swift
└── TemplateSetConfigView.swift

Features/Templates/ViewModels/
└── CreateTemplateViewModel.swift
```

### Phase 4: Workout Integration (Sprint 4 - 2 days)

**Tasks:**
- [ ] Integrate template selection in LiftingSessionView
- [ ] Load exercises from template
- [ ] Implement "Save as Template" in WorkoutSummaryView
- [ ] Create SaveWorkoutAsTemplateView
- [ ] Handle template-based workout tracking (mark lastUsedAt)

**Files to Update:**
```
Features/Workouts/LiftingSession/
├── ViewModels/LiftingSessionViewModel.swift  (add template support)
└── Views/
    ├── LiftingSessionView.swift  (add template button)
    └── WorkoutSummaryView.swift  (add save template)

Features/Templates/Views/
└── SaveWorkoutAsTemplateView.swift  (new)
```

### Phase 5: Advanced Features (Sprint 5 - 2 days)

**Tasks:**
- [ ] Implement template duplication
- [ ] Add swipe actions (duplicate, delete)
- [ ] Implement preset template copy mechanism
- [ ] Add empty states for all views
- [ ] Add loading states
- [ ] Error handling & validation
- [ ] Add success/error toasts

**Design System Components Needed:**
- [ ] Multi-step wizard component (reusable)
- [ ] Category filter chips component
- [ ] Swipe action helpers

### Phase 6: Testing & Polish (Sprint 6 - 2 days)

**Tasks:**
- [ ] Manual testing of all flows
- [ ] Edge case testing (empty states, deletion, etc.)
- [ ] Performance testing (large template lists)
- [ ] UI polish (animations, transitions)
- [ ] Accessibility (VoiceOver, Dynamic Type)
- [ ] Dark mode verification
- [ ] Update documentation (MODELS.md, CHANGELOG.md)

---

## 📊 Success Metrics (Future - v1.2)

**Note:** These are NOT implemented in v1.1, but defined for future tracking.

- **Template Usage Rate**: % of workouts started from templates
- **Template Creation Rate**: Avg templates created per user
- **Preset Adoption**: Most popular preset templates
- **Template Reuse**: Avg times a template is used
- **Completion Rate**: % of template-based workouts completed

---

## 🚀 Future Enhancements (v1.2+)

### v1.2 Scope
- [ ] Template progress tracking (usage count, last used, avg duration)
- [ ] Template favorites/pinning
- [ ] Template search (by name, exercise)
- [ ] Template sharing (export/import JSON)
- [ ] Template tags (flexible tagging system)

### v2.0 Scope
- [ ] Weekly routine scheduler (assign templates to days)
- [ ] Template periodization (progressive overload planning)
- [ ] Template analytics (volume, frequency, muscle groups)
- [ ] Community template library (share with others)
- [ ] Template recommendations (AI-powered suggestions)

---

## ⚠️ Technical Considerations

### Performance

**Large Template Lists:**
- Use SwiftUI's `List` with `ForEach` (lazy loading)
- Limit preset seeding to 10-15 templates initially
- Paginate if user has 50+ custom templates

**Exercise Loading:**
- Exercise library is already in-memory (ExerciseLibrary)
- Template exercises reference by ID (fast lookup)
- No N+1 queries (SwiftData handles relationships)

### Data Migration

**First Launch:**
- PresetTemplateSeeder runs once
- Checks if preset templates already exist
- Seeds only if empty (idempotent)

**Model Changes:**
- WorkoutTemplate and TemplateExercise are new models
- No migration needed from v1.0 → v1.1
- SwiftData auto-migration handles schema changes

### Edge Cases

**Deleted Exercises:**
- Exercise library is read-only (no custom exercises yet)
- Reference approach safe: exercises never deleted
- Future: If custom exercises added, need deletion handling

**Template Duplication:**
- Deep copy: template + all exercises
- New UUIDs generated for template and exercises
- Relationships preserved

**Preset Template Updates:**
- If preset library updated in app update, need versioning
- Option 1: Don't update existing user copies
- Option 2: Add "Update Available" badge (v1.2)

---

## 📝 Open Questions

1. **Template Reordering:**
   - Should users be able to reorder exercises in templates?
   - Decision: YES - drag-and-drop in edit mode (Phase 3)

2. **Template Categories - User Custom:**
   - Can users create custom categories?
   - Decision: NO - predefined categories only (v1.1), custom tags in v1.2

3. **Template Import/Export:**
   - Should we support template sharing between users?
   - Decision: NOT YET - v1.2 feature (JSON export/import)

4. **Workout Notes in Template:**
   - Should templates have workout-level notes (not exercise-level)?
   - Decision: YES - add optional `notes: String?` to WorkoutTemplate

5. **Set Configuration Flexibility:**
   - Should templates support different rep ranges per set?
   - Decision: NO - single rep range for simplicity (8-12 means all sets)
   - Future: Per-set configuration in v1.2

---

## ✅ Approval Checklist

Before starting implementation:

- [x] All user stories defined
- [x] Domain models designed
- [x] Repository architecture specified
- [x] UI/UX flows documented
- [x] Preset template library planned
- [x] Implementation phases outlined
- [x] Technical considerations addressed
- [x] Future scope defined
- [ ] **Personal Trainer Review** (Preset templates accuracy)
- [ ] **UX Review** (Flow usability)
- [ ] **Tech Review** (Architecture feasibility)

---

**Next Steps:**
1. Review this plan with stakeholders
2. Finalize preset template library (exercises, set/rep configs)
3. Begin Phase 1 implementation
4. Create GitHub issue tracking for each phase

**Estimated Total Time:** 12-14 days (6 sprints x 2 days)

**Target Release:** v1.1 - December 2025

---

**Document Version:** 1.0
**Last Updated:** 2025-11-03
**Author:** Burak Küçükhüseyinoğlu (with Claude Code assistance)
