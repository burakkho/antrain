# Workout Templates - Sprint Tracking

**Feature:** Workout Templates v1.1
**Start Date:** 2025-11-03
**Target Completion:** December 2025
**Estimated Duration:** 12-14 days (6 sprints)

---

## Sprint Overview

| Sprint | Focus | Duration | Status |
|--------|-------|----------|--------|
| Sprint 1 | Domain & Data Layer | 2 days | 🔜 Not Started |
| Sprint 2 | Core Views & Navigation | 3 days | ⏸️ Pending |
| Sprint 3 | Template Creation Flow | 3 days | ⏸️ Pending |
| Sprint 4 | Workout Integration | 2 days | ⏸️ Pending |
| Sprint 5 | Advanced Features | 2 days | ⏸️ Pending |
| Sprint 6 | Testing & Polish | 2 days | ⏸️ Pending |

---

## Sprint 1: Domain & Data Layer
**Duration:** 2 days
**Status:** 🔜 Not Started
**Goal:** Build solid foundation with models and repository

### Tasks

#### Domain Models
- [ ] Create `WorkoutTemplate` model
  - Properties: id, name, category, isPreset, createdAt, lastUsedAt
  - Relationship: exercises (1:N)
  - Computed: exerciseCount, estimatedDuration
- [ ] Create `TemplateExercise` model
  - Properties: id, order, exerciseId, exerciseName, setCount, repRangeMin, repRangeMax, notes
  - Relationship: template
- [ ] Create `TemplateCategory` enum
  - Cases: strength, hypertrophy, calisthenics, weightlifting, beginner, custom
  - Methods: icon, color

#### Repository Layer
- [ ] Create `WorkoutTemplateRepositoryProtocol`
  - CRUD methods
  - Preset management methods
  - Duplication method
  - Usage tracking
- [ ] Implement `WorkoutTemplateRepository` (@ModelActor)
  - SwiftData ModelContext integration
  - All protocol methods
  - Error handling

#### Preset Seeder
- [ ] Create `PresetTemplateSeeder` utility
  - Idempotent seeding (check if already seeded)
  - 9 preset templates with standard format:
    - **Strength:** Powerlifting (3 day), Starting Strength (2 workouts)
    - **Hypertrophy:** PPL (3 day), Bro Split (5 day), Upper/Lower (2 day)
    - **Calisthenics:** Full Body, Skill-Based
    - **Weightlifting:** Olympic Lifting
    - **Beginner:** Full Body (2 workouts)
  - Standard set/rep configs:
    - Strength: 3-4 sets x 3-5 reps
    - Hypertrophy: 3-4 sets x 8-12 reps
    - Calisthenics: 3-4 sets x 8-15 reps
    - Weightlifting: 4-5 sets x 2-3 reps
    - Beginner: 3 sets x 8-10 reps

#### Integration
- [ ] Add repository to `AppDependencies`
- [ ] Update `PersistenceController` schema
- [ ] Call seeder on first launch

### Files Created
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

App/
└── AppDependencies.swift (updated)
```

### Definition of Done
- [ ] All models compile and pass SwiftData validation
- [ ] Repository protocol fully defined
- [ ] Repository implementation complete with error handling
- [ ] Preset seeder creates 9 templates on first launch
- [ ] Repository injected in AppDependencies
- [ ] No compiler warnings
- [ ] Code follows 100-200 line guideline

---

## Sprint 2: Core Views & Navigation
**Duration:** 3 days
**Status:** ⏸️ Pending
**Goal:** Build main template listing and viewing

### Tasks

#### Main Templates View
- [ ] Create `TemplatesViewModel`
  - Fetch all templates
  - Filter by category
  - Delete template
  - State management (@Observable)
- [ ] Create `TemplatesView`
  - Navigation structure
  - Category filter chips (horizontal scroll)
  - Template list (grouped: My Templates, Presets)
  - FAB for create template
  - Empty state

#### Components
- [ ] Create `TemplateCard` component
  - Template name, category, exercise count
  - Category color accent
  - Swipe actions (duplicate, delete)
  - Tap to view detail
- [ ] Create `TemplateCategoryFilterView`
  - Horizontal scrolling chips
  - Category icons with colors
  - Active state highlighting
  - "All" option

#### Template Detail View
- [ ] Create `TemplateDetailViewModel`
  - Fetch template with exercises
  - Delete template
  - Duplicate template
  - Start workout from template
- [ ] Create `TemplateDetailView`
  - Template info header
  - Exercise list with set/rep display
  - Action buttons: Edit, Duplicate, Delete, Start Workout
  - Metadata: Created date, last used

#### Quick Selector Sheet
- [ ] Create `TemplateQuickSelectorView`
  - Sheet presentation
  - Search bar
  - Category filter
  - Template list (simplified cards)
  - onTemplateSelected callback

#### Navigation Integration
- [ ] Add Templates tab to `MainTabView`
- [ ] Add "My Templates" to HomeView quick actions
- [ ] Navigation flow: List → Detail → Edit

### Files Created
```
Features/Templates/
├── ViewModels/
│   ├── TemplatesViewModel.swift
│   └── TemplateDetailViewModel.swift
├── Views/
│   ├── TemplatesView.swift
│   ├── TemplateDetailView.swift
│   ├── TemplateQuickSelectorView.swift
│   └── Components/
│       ├── TemplateCard.swift
│       └── TemplateCategoryFilterView.swift

App/
└── MainTabView.swift (updated)

Features/Home/Views/
└── HomeView.swift (updated)
```

### Definition of Done
- [ ] Can view all templates (My Templates + Presets)
- [ ] Can filter by category
- [ ] Can view template detail
- [ ] Can delete user templates (not presets)
- [ ] Can duplicate templates
- [ ] Empty state shows when no templates
- [ ] Quick selector sheet works
- [ ] Dark mode fully supported
- [ ] No performance issues with 50+ templates

---

## Sprint 3: Template Creation Flow
**Duration:** 3 days
**Status:** ⏸️ Pending
**Goal:** Multi-step wizard for creating templates

### Tasks

#### Create Template ViewModel
- [ ] Create `CreateTemplateViewModel`
  - Step management (current step, navigation)
  - Form state (name, category, exercises, configs)
  - Validation logic
  - Save template
  - Edit mode support

#### Step 1: Template Info
- [ ] Create `TemplateInfoView`
  - Name text field (validation: unique, non-empty)
  - Category picker (grid layout with icons)
  - Continue button (disabled until valid)

#### Step 2: Exercise Selection
- [ ] Create `TemplateExerciseSelectionView`
  - Reuse `ExerciseSelectionView` logic
  - Multi-select mode
  - Exercise count badge
  - Order preview (drag to reorder)
  - Continue button (disabled if no exercises)

#### Step 3: Set Configuration
- [ ] Create `TemplateSetConfigView`
  - List of selected exercises
  - For each exercise:
    - Set count picker (1-10)
    - Rep range (min/max)
    - Optional notes field
  - "Use defaults" option per exercise
  - Create button

#### Wizard Flow
- [ ] Create `CreateTemplateFlow`
  - Step indicator (1/3, 2/3, 3/3)
  - Navigation: Back, Continue, Cancel
  - State preservation between steps
  - Validation on each step
  - Sheet presentation

#### Edit Template
- [ ] Create `EditTemplateView`
  - Reuse CreateTemplateFlow
  - Pre-fill all fields
  - Show "Update" instead of "Create"
  - Handle preset templates (create copy, not edit)

### Files Created
```
Features/Templates/
├── ViewModels/
│   └── CreateTemplateViewModel.swift
└── Views/CreateTemplate/
    ├── CreateTemplateFlow.swift
    ├── TemplateInfoView.swift
    ├── TemplateExerciseSelectionView.swift
    ├── TemplateSetConfigView.swift
    └── EditTemplateView.swift
```

### Definition of Done
- [ ] Can create template with all 3 steps
- [ ] Form validation works correctly
- [ ] Can navigate back/forward between steps
- [ ] Can cancel at any step
- [ ] Can save template successfully
- [ ] Can edit existing template
- [ ] Preset templates create copy when edited
- [ ] All error states handled
- [ ] Smooth animations between steps

---

## Sprint 4: Workout Integration
**Duration:** 2 days
**Status:** ⏸️ Pending
**Goal:** Connect templates to workout flow

### Tasks

#### LiftingSession Integration
- [ ] Update `LiftingSessionViewModel`
  - Add `loadFromTemplate()` method
  - Convert TemplateExercise → WorkoutExercise
  - Pre-populate sets based on template config
  - Track template usage (mark lastUsedAt)
- [ ] Update `LiftingSessionView`
  - Add "Start from Template" button (when empty)
  - Show template selector sheet
  - Load exercises when template selected
  - Allow modifications (don't save to template)

#### HomeView Integration
- [ ] Update `HomeViewModel`
  - Add template quick access
- [ ] Update `HomeView`
  - Add "My Templates" quick action button
  - Navigate to TemplateQuickSelectorView
  - On template select → start lifting session

#### Save Workout as Template
- [ ] Create `SaveWorkoutAsTemplateViewModel`
  - Convert Workout → WorkoutTemplate
  - Extract exercise configs (set count, rep ranges)
  - Save template
- [ ] Create `SaveWorkoutAsTemplateView`
  - Sheet presentation
  - Pre-filled name (e.g., "Workout on Nov 3")
  - Category selector
  - Exercise preview list
  - Save button
- [ ] Update `WorkoutSummaryView`
  - Add "Save as Template" button
  - Show save template sheet

### Files Created
```
Features/Workouts/LiftingSession/
├── ViewModels/
│   └── LiftingSessionViewModel.swift (updated)
└── Views/
    └── LiftingSessionView.swift (updated)

Features/Templates/
├── ViewModels/
│   └── SaveWorkoutAsTemplateViewModel.swift
└── Views/
    └── SaveWorkoutAsTemplateView.swift

Features/Workouts/LiftingSession/Views/
└── WorkoutSummaryView.swift (updated)

Features/Home/
├── ViewModels/
│   └── HomeViewModel.swift (updated)
└── Views/
    └── HomeView.swift (updated)
```

### Definition of Done
- [ ] Can start workout from template (HomeView)
- [ ] Can start workout from template (LiftingSessionView)
- [ ] Template exercises loaded correctly
- [ ] Can modify exercises during workout (one-off)
- [ ] Template lastUsedAt updated
- [ ] Can save completed workout as template
- [ ] Template created with correct configs
- [ ] All flows integrated smoothly

---

## Sprint 5: Advanced Features
**Duration:** 2 days
**Status:** ⏸️ Pending
**Goal:** Polish and additional features

### Tasks

#### Swipe Actions
- [ ] Add swipe actions to TemplateCard
  - Duplicate (creates copy)
  - Delete (confirmation alert)
  - Edit (navigate to EditTemplateView)
- [ ] Disable delete for preset templates
- [ ] Smooth animations

#### Template Duplication
- [ ] Implement duplicate in repository
  - Deep copy template + exercises
  - Generate new UUIDs
  - Add "(Copy)" suffix to name
- [ ] Update TemplatesViewModel
  - Call duplicate method
  - Show success toast
  - Refresh list

#### Preset Template Handling
- [ ] Implement "Use Preset" flow
  - Show info sheet: "This will create your own copy"
  - Create copy with same name
  - Navigate to new template
- [ ] Add "Preset" badge to preset template cards
- [ ] Prevent editing/deleting presets

#### Empty States
- [ ] EmptyState for no templates (with CTA)
- [ ] EmptyState for filtered categories
- [ ] EmptyState for search with no results

#### Loading States
- [ ] Loading spinner when fetching templates
- [ ] Skeleton loading for template cards
- [ ] Loading state in quick selector

#### Error Handling
- [ ] Error alerts for failed operations
- [ ] Validation errors in forms
- [ ] Network/persistence errors

#### Toast Notifications
- [ ] Success: Template created
- [ ] Success: Template deleted
- [ ] Success: Template duplicated
- [ ] Success: Workout saved as template
- [ ] Error: Failed to save

### Files Created
```
Features/Templates/Views/Components/
├── TemplateEmptyState.swift
├── TemplateLoadingView.swift
└── PresetInfoSheet.swift

Shared/DesignSystem/Components/
└── DSToast.swift (if not exists)
```

### Definition of Done
- [ ] All swipe actions work correctly
- [ ] Template duplication creates proper copy
- [ ] Preset templates handled correctly
- [ ] All empty states implemented
- [ ] All loading states smooth
- [ ] All errors handled gracefully
- [ ] Toast notifications for all actions
- [ ] No crashes on edge cases

---

## Sprint 6: Testing & Polish
**Duration:** 2 days
**Status:** ⏸️ Pending
**Goal:** Final testing and polish

### Tasks

#### Manual Testing
- [ ] Test all user flows end-to-end
  - Create template from scratch
  - Start workout from template
  - Save workout as template
  - Duplicate template
  - Edit template
  - Delete template
  - Browse presets
  - Use preset (create copy)
- [ ] Test edge cases
  - Empty states
  - Single template
  - 50+ templates
  - Long template names
  - Many exercises in template
  - Template with 1 exercise
- [ ] Test error scenarios
  - Network/persistence failures
  - Invalid form inputs
  - Concurrent modifications

#### Performance Testing
- [ ] Test with large dataset (100+ templates)
- [ ] Verify smooth scrolling
- [ ] Check memory usage
- [ ] Profile SwiftData queries

#### UI Polish
- [ ] Add smooth animations/transitions
- [ ] Refine spacing and layout
- [ ] Improve color consistency
- [ ] Add haptic feedback where appropriate

#### Accessibility
- [ ] VoiceOver support for all views
- [ ] Dynamic Type support
- [ ] Sufficient color contrast
- [ ] Accessible labels for all interactive elements

#### Dark Mode
- [ ] Verify all views in dark mode
- [ ] Check color readability
- [ ] Test category colors

#### Documentation
- [ ] Update MODELS.md with new models
- [ ] Update CHANGELOG.md with v1.1 features
- [ ] Add templates feature to README.md
- [ ] Update SPRINT_LOG.md

#### Code Quality
- [ ] Remove debug print statements
- [ ] Remove unused code
- [ ] Add documentation comments
- [ ] Verify file sizes (100-300 lines)
- [ ] Run SwiftLint (if configured)

### Definition of Done
- [ ] All manual tests pass
- [ ] No crashes or bugs found
- [ ] Performance is acceptable
- [ ] UI is polished and consistent
- [ ] Accessibility requirements met
- [ ] Dark mode fully supported
- [ ] Documentation updated
- [ ] Code is clean and well-documented
- [ ] Ready for v1.1 release

---

## Session Continuity Notes

### Current Sprint: Sprint 1
**Status:** 🔜 Ready to Start
**Next Task:** Create WorkoutTemplate model

### Session Handoff Template
When starting a new session, provide:
```
Current Sprint: [Sprint Number]
Completed Tasks: [List]
Current Task: [Task name]
Blockers: [Any issues]
Next Steps: [What to do next]
```

### Progress Tracking
- Use TodoWrite tool for task-level tracking
- Update this document after each sprint
- Mark completed tasks with ✅
- Update sprint status:
  - 🔜 Not Started
  - 🏃 In Progress
  - ✅ Completed
  - ⏸️ Pending

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-03 | Initial sprint plan created |

---

**Next Action:** Begin Sprint 1 - Create domain models
