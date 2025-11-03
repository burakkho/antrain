# Antrain - Comprehensive Fitness Tracking App

## Project Overview

**Antrain** is a comprehensive fitness tracking application designed to compete with Hevy while offering broader functionality. It targets the entire fitness community - from powerlifters to CrossFit athletes to hybrid training enthusiasts.

### Key Features
- **Lifting**: Real-time session tracking with Hevy-style UX
- **Cardio & MetCon**: Post-workout quick logging
- **Nutrition**: Simple macro and calorie tracking
- **History & Progress**: Comprehensive workout and nutrition tracking

### Target Users
- Strength training athletes
- CrossFit and functional fitness enthusiasts
- Hybrid athletes (Hyrox, etc.)
- Anyone seeking comprehensive fitness tracking

---

## Tech Stack

- **Language**: Swift 6 (strict concurrency)
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS**: 17.0+
- **Localization**: String Catalog (English base, Turkish planned for future)
- **Architecture**: Clean Architecture (Simplified) + MVVM
- **Design**: Apple HIG compliant, modern best practices

---

## Architecture

### Three-Layer Clean Architecture

```
┌─────────────────────────────────┐
│   PRESENTATION LAYER            │
│   (SwiftUI Views + ViewModels)  │
│   - User Interface              │
│   - User Interaction            │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   DOMAIN LAYER                  │
│   (Business Logic)              │
│   - Entities (Models)           │
│   - Repository Protocols        │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   DATA LAYER                    │
│   (Data Management)             │
│   - Repositories (concrete)     │
│   - SwiftData Storage           │
│   - Libraries (Exercise/Food)   │
└─────────────────────────────────┘
```

### Key Principles
- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Protocol-Oriented**: All repositories defined as protocols
- **Dependency Injection**: Through AppDependencies container
- **Repository Pattern**: Abstraction over data sources
- **Single Target**: No frameworks, organized by folders

### Dependency Flow
```
Presentation → Domain ← Data
(Views/VMs)   (Protocols) (Repos)
```

---

## Folder Structure

### Micro-Modular Approach
Each file should be **100-200 lines maximum** (300 absolute max) for optimal AI readability and maintainability. Extract components early and often.

```
Antrain/
├── App/
│   ├── AntrainApp.swift
│   └── AppDependencies.swift
│
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Workout/
│   │   │   │   ├── Workout.swift
│   │   │   │   ├── WorkoutType.swift
│   │   │   │   └── WorkoutSet.swift
│   │   │   ├── Exercise/
│   │   │   │   ├── Exercise.swift
│   │   │   │   ├── ExerciseCategory.swift
│   │   │   │   ├── MuscleGroup.swift
│   │   │   │   └── Equipment.swift
│   │   │   ├── Nutrition/
│   │   │   │   ├── NutritionLog.swift
│   │   │   │   ├── Meal.swift
│   │   │   │   ├── FoodItem.swift
│   │   │   │   ├── FoodEntry.swift
│   │   │   │   └── FoodCategory.swift
│   │   │   └── User/
│   │   │       ├── UserProfile.swift
│   │   │       └── BodyweightEntry.swift
│   │   │
│   │   └── Protocols/
│   │       ├── Repositories/
│   │       │   ├── WorkoutRepositoryProtocol.swift
│   │       │   ├── ExerciseRepositoryProtocol.swift
│   │       │   └── NutritionRepositoryProtocol.swift
│   │       └── Libraries/
│   │           ├── ExerciseLibraryProtocol.swift
│   │           └── FoodLibraryProtocol.swift
│   │
│   ├── Data/
│   │   ├── Repositories/
│   │   │   ├── WorkoutRepository.swift
│   │   │   ├── ExerciseRepository.swift
│   │   │   └── NutritionRepository.swift
│   │   │
│   │   └── Libraries/
│   │       ├── ExerciseLibrary/
│   │       │   ├── ExerciseLibrary.swift
│   │       │   ├── ExerciseDTO.swift
│   │       │   ├── BarbellExercises.swift
│   │       │   ├── DumbbellExercises.swift
│   │       │   ├── BodyweightExercises.swift
│   │       │   ├── CardioExercises.swift
│   │       │   └── MetConExercises.swift
│   │       │
│   │       └── FoodLibrary/
│   │           ├── FoodLibrary.swift
│   │           ├── FoodDTO.swift
│   │           ├── ProteinFoods.swift
│   │           ├── CarbFoods.swift
│   │           ├── FatFoods.swift
│   │           └── VegetableFoods.swift
│   │
│   └── Persistence/
│       └── PersistenceController.swift
│
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   └── Components/
│   │   │       ├── TodaySummaryCard.swift
│   │   │       ├── QuickActionButtons.swift
│   │   │       └── RecentWorkoutsList.swift
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift
│   │
│   ├── Workouts/
│   │   ├── LiftingSession/
│   │   │   ├── Views/
│   │   │   │   ├── LiftingSessionView.swift
│   │   │   │   ├── ExerciseSelectionView.swift
│   │   │   │   └── Components/
│   │   │   │       ├── ActiveSetRow.swift
│   │   │   │       ├── CompletedSetRow.swift
│   │   │   │       └── ExerciseCard.swift
│   │   │   └── ViewModels/
│   │   │       ├── LiftingSessionViewModel.swift
│   │   │       └── ExerciseSelectionViewModel.swift
│   │   │
│   │   ├── QuickLog/
│   │   │   ├── Views/
│   │   │   │   ├── QuickLogView.swift
│   │   │   │   ├── CardioLogView.swift
│   │   │   │   └── MetConLogView.swift
│   │   │   └── ViewModels/
│   │   │       └── QuickLogViewModel.swift
│   │   │
│   │   └── History/
│   │       ├── Views/
│   │       │   ├── WorkoutHistoryView.swift
│   │       │   └── WorkoutDetailView.swift
│   │       └── ViewModels/
│   │           └── WorkoutHistoryViewModel.swift
│   │
│   ├── Nutrition/
│   │   ├── LogMeal/
│   │   │   ├── Views/
│   │   │   │   ├── LogMealView.swift
│   │   │   │   └── Components/
│   │   │   │       ├── MealTypeSelector.swift
│   │   │   │       └── FoodItemRow.swift
│   │   │   └── ViewModels/
│   │   │       └── LogMealViewModel.swift
│   │   │
│   │   ├── FoodSearch/
│   │   │   ├── Views/
│   │   │   │   ├── FoodSearchView.swift
│   │   │   │   └── AddCustomFoodView.swift
│   │   │   └── ViewModels/
│   │   │       └── FoodSearchViewModel.swift
│   │   │
│   │   └── DailyLog/
│   │       ├── Views/
│   │       │   ├── DailyNutritionView.swift
│   │       │   └── Components/
│   │       │       ├── MacroProgressRing.swift
│   │       │       └── MealCard.swift
│   │       └── ViewModels/
│   │           └── DailyNutritionViewModel.swift
│   │
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift
│       │   ├── ProfileView.swift
│       │   └── GoalsView.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
│
├── Shared/
│   ├── DesignSystem/
│   │   ├── Tokens/
│   │   │   ├── DSColors.swift
│   │   │   ├── DSTypography.swift
│   │   │   ├── DSSpacing.swift
│   │   │   └── DSCornerRadius.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── Buttons/
│   │   │   │   ├── DSPrimaryButton.swift
│   │   │   │   ├── DSSecondaryButton.swift
│   │   │   │   └── DSIconButton.swift
│   │   │   ├── Cards/
│   │   │   │   ├── DSCard.swift
│   │   │   │   └── DSListCard.swift
│   │   │   ├── TextFields/
│   │   │   │   ├── DSTextField.swift
│   │   │   │   └── DSNumberField.swift
│   │   │   └── Other/
│   │   │       ├── DSLoadingView.swift
│   │   │       ├── DSEmptyState.swift
│   │   │       └── DSErrorView.swift
│   │   │
│   │   └── Modifiers/
│   │       ├── CardModifier.swift
│   │       ├── ShadowModifier.swift
│   │       └── ShimmerModifier.swift
│   │
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Double+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   ├── Protocols/
│   │   └── Identifiable+Extensions.swift
│   │
│   └── Utilities/
│       ├── Constants.swift
│       ├── Logger.swift
│       └── Formatters.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.xcstrings
│
└── docs/
    ├── README.md (this file)
    ├── ARCHITECTURE.md
    ├── SPRINT_LOG.md
    ├── MODELS.md
    └── DESIGN_SYSTEM.md
```

---

## Core Models

### Workout Domain

```
Workout
├── id: UUID
├── date: Date
├── type: WorkoutType (lifting, cardio, metcon)
├── duration: TimeInterval
├── notes: String?
├── exercises: [Exercise]? (lifting only)
└── quickLogData: QuickLogData? (cardio/metcon)

WorkoutType
├── lifting (real-time tracking)
├── cardio (quick log)
└── metcon (quick log)

Exercise (from ExerciseLibrary)
├── id: UUID
├── name: String
├── category: ExerciseCategory
├── muscleGroups: [MuscleGroup]
├── equipment: Equipment
├── isCustom: Bool
└── version: Int

WorkoutSet
├── id: UUID
├── reps: Int
├── weight: Double
├── isCompleted: Bool
├── notes: String?
└── exercise: Exercise (relationship)

QuickLogData (for cardio/metcon)
├── cardioType: CardioType? (run, bike, row, etc.)
├── distance: Double?
├── pace: Double?
├── metconType: MetConType? (amrap, emom, forTime)
├── rounds: Int?
└── result: String?
```

### Nutrition Domain

```
NutritionLog (daily log)
├── id: UUID
├── date: Date
└── meals: [Meal]

Computed Properties:
├── totalCalories: Double
├── totalProtein: Double
├── totalCarbs: Double
└── totalFats: Double

Meal
├── id: UUID
├── name: String (Breakfast, Lunch, Dinner, Snack)
├── timestamp: Date
└── foodItems: [FoodEntry]

FoodItem (from FoodLibrary)
├── id: UUID
├── name: String
├── brand: String?
├── calories: Double (per 100g)
├── protein: Double (per 100g)
├── carbs: Double (per 100g)
├── fats: Double (per 100g)
├── servingSize: Double (grams)
├── category: FoodCategory
├── isCustom: Bool
├── isFavorite: Bool
└── version: Int

FoodEntry
├── id: UUID
├── food: FoodItem (relationship)
├── servingAmount: Double (e.g., 150g)
└── meal: Meal (relationship)

Computed Properties:
├── calories: Double
├── protein: Double
├── carbs: Double
└── fats: Double
```

### User Domain

```
UserProfile
├── id: UUID
├── name: String?
├── dailyCalorieGoal: Double
├── dailyProteinGoal: Double
├── dailyCarbsGoal: Double
├── dailyFatsGoal: Double
└── bodyweightHistory: [BodyweightEntry]

BodyweightEntry
├── id: UUID
├── date: Date
└── weight: Double
```

### SwiftData Relationships

```
Workout 1:N WorkoutSet (cascade delete)
Workout 1:N Exercise (no cascade)
NutritionLog 1:N Meal (cascade delete)
Meal 1:N FoodEntry (cascade delete)
FoodEntry N:1 FoodItem (no cascade)
UserProfile 1:N BodyweightEntry (cascade delete)
```

---

## Design System

### Principles
- **Reusable**: All components are reusable across features
- **Apple HIG Compliant**: Follows modern iOS design guidelines
- **Accessible**: Dynamic Type support, VoiceOver ready
- **Dark Mode Native**: Designed for both light and dark modes
- **Consistent**: Design tokens ensure visual consistency

### Design Tokens

**Colors** (`DSColors.swift`)
- Primary, Secondary, Tertiary
- Success, Warning, Error
- Background (primary, secondary, tertiary)
- Text (primary, secondary, tertiary)

**Typography** (`DSTypography.swift`)
- Large Title, Title 1-3
- Headline, Body, Callout
- Subheadline, Footnote, Caption

**Spacing** (`DSSpacing.swift`)
- xxxs (2pt), xxs (4pt), xs (8pt)
- sm (12pt), md (16pt), lg (24pt)
- xl (32pt), xxl (48pt), xxxl (64pt)

**Corner Radius** (`DSCornerRadius.swift`)
- sm (4pt), md (8pt), lg (12pt), xl (16pt)

### Component Library

**Buttons**
- `DSPrimaryButton`: Main action button
- `DSSecondaryButton`: Secondary actions
- `DSIconButton`: Icon-only actions

**Cards**
- `DSCard`: Generic container
- `DSListCard`: List item container

**Text Fields**
- `DSTextField`: Text input
- `DSNumberField`: Numeric input

**Other**
- `DSLoadingView`: Loading states
- `DSEmptyState`: Empty state screens
- `DSErrorView`: Error states

---

## Development Workflow

### Sprint-Based Development

Development is organized into **focused sprints** of 2-5 days each. This approach is optimized for working with Claude Code, allowing for clean session management and clear progress tracking.

#### Sprint Structure

Each sprint should:
1. Have a clear, achievable goal
2. Be documented in `SPRINT_LOG.md`
3. Result in working, testable features
4. Include documentation updates

#### Workflow

1. **Start Sprint**: Open new Claude Code session
2. **Read Context**: Review `SPRINT_LOG.md` and `CHANGELOG.md`
3. **Define Goal**: Set clear sprint objective
4. **Execute**: Build features following architecture
5. **Document**: Update `SPRINT_LOG.md` with progress
6. **Commit**: Push changes with meaningful commits
7. **Close Sprint**: Mark sprint as complete

#### Sprint Log Format

See `SPRINT_LOG.md` for current sprint status and history. Claude Code maintains this file.

### Git Workflow

**Branch Strategy** (Simple, solo developer)
```
main (production ready)
└── develop (active development)
    └── feature/* (individual features)
```

**Commit Convention**
```
feat: Add new feature
fix: Bug fix
refactor: Code refactoring
docs: Documentation updates
style: Formatting changes
chore: Maintenance tasks
```

**Workflow Steps**
1. Create feature branch from `develop`
2. Make changes and commit regularly
3. Merge to `develop` when feature complete
4. Merge `develop` to `main` for releases

---

## Coding Standards

### General Guidelines
- **File Size**: 100-200 lines ideal, 300 lines absolute maximum
- **Single Responsibility**: One clear purpose per file/class
- **Extract Early**: Create components when code exceeds 150 lines
- **Meaningful Names**: Use descriptive, self-documenting names
- **Comments**: Only for complex logic; code should be self-explanatory

### Swift 6 & Concurrency
- Use `async/await` for asynchronous operations
- Use `actor` for thread-safe state management
- Repositories should be `actor` types
- ViewModels use `@Observable` macro

### SwiftUI Best Practices
- Prefer composition over inheritance
- Extract subviews at ~50 lines
- Use `@State` for view-local state
- Use `@Environment` for dependency injection
- Keep Views focused on presentation only

### SOLID Application
- **S**: Each file has one clear responsibility
- **O**: Use protocols for extensibility
- **L**: Subtypes must be substitutable
- **I**: Small, focused protocols
- **D**: Depend on protocols, not concrete types

### Naming Conventions
- **Views**: `[Feature][Type]View` (e.g., `LiftingSessionView`)
- **ViewModels**: `[Feature]ViewModel` (e.g., `LiftingSessionViewModel`)
- **Components**: `DS[Type]` for design system (e.g., `DSPrimaryButton`)
- **Repositories**: `[Entity]Repository` (e.g., `WorkoutRepository`)
- **Protocols**: `[Entity]RepositoryProtocol` (e.g., `WorkoutRepositoryProtocol`)

---

## MVP Scope

### In Scope ✅

**Workout Tracking**
- Real-time lifting session tracking (Hevy-style UX)
- Set, rep, weight logging
- Exercise selection from library
- Custom exercise creation
- Workout history view

**Quick Logging**
- Cardio: type, duration, distance, pace
- MetCon: type (AMRAP/EMOM/For Time), duration, rounds/result
- Post-workout entry (not real-time)

**Nutrition Tracking**
- Daily macro goals (calories, protein, carbs, fats)
- Meal logging (breakfast, lunch, dinner, snacks)
- Food search from library
- Custom food creation
- Daily nutrition summary

**User Profile**
- Basic profile information
- Daily nutrition goals
- Bodyweight tracking (manual entry)

**Libraries**
- Preset exercise library (150+ exercises)
- Preset food library (100+ common foods)
- User can add custom exercises
- User can add custom foods

### Out of Scope ❌ (Future Phases)

**Phase 2**
- Routine/workout templates
- Advanced analytics and progress charts
- Personal records (PR) tracking
- Workout notes and tags
- Food favorites and recent items

**Phase 3**
- HealthKit integration
- Cloud sync across devices
- Data export (CSV, PDF)
- Social features
- Turkish localization

**Phase 4**
- Rest timer with notifications
- Plate calculator
- Exercise instruction videos/GIFs
- Nutrition recommendations
- Apple Watch app

---

## Development Setup

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ Simulator or Device

### Getting Started

1. **Clone Repository**
   ```bash
   git clone [repository-url]
   cd Antrain
   ```

2. **Open Project**
   ```bash
   open Antrain.xcodeproj
   ```

3. **Build and Run**
   - Select target device/simulator
   - Press `Cmd + R` to build and run
   - No external dependencies required

### Project Configuration
- **Bundle Identifier**: `com.yourname.Antrain` (update as needed)
- **Team**: Set your development team in project settings
- **Deployment Target**: iOS 17.0

---

## Roadmap

### Sprint 1: Foundation ✅
- [x] Project structure setup
- [x] Core domain models
- [x] SwiftData persistence layer
- [x] Basic navigation structure

### Sprint 2: Nutrition Complete ✅
- [x] Food models and protocols
- [x] Food library implementation (103 foods)
- [x] NutritionRepository with CRUD operations
- [x] DailyNutritionView
- [x] FoodSearchView
- [x] Macro progress visualization

### Sprint 3: Quick Log Features ✅
- [x] CardioLogView implementation
- [x] MetConLogView implementation
- [x] Save quick log workouts
- [x] HomeView integration

### Sprint 4: Weight Unit System & UI ✅
- [x] Comprehensive unit conversion (kg/lbs, g/oz, km/mi)
- [x] Dual-value pattern implementation
- [x] UI improvements (pull-to-refresh, auto-refresh, navigation)
- [x] Theme switching support

### Sprint 5: Settings & UserProfile ✅
- [x] UserProfile model
- [x] BodyweightEntry model
- [x] SettingsView with all features
- [x] Nutrition goals editing
- [x] Bodyweight tracking with history

### Sprint 6: Exercise Library Expansion ⚠️ CRITICAL
- [ ] DumbbellExercises.swift (~40 exercises)
- [ ] BodyweightExercises.swift (~30 exercises)
- [ ] CardioExercises.swift (~20 exercises)
- [ ] MetConExercises.swift (~15 exercises)
- [ ] MachineExercises.swift (~45 exercises)
- **Current:** 10/150+ exercises (93% shortage)

### Sprint 7: Custom Creation UIs 🔜
- [ ] AddCustomExerciseView
- [ ] Exercise creation form
- [ ] AddCustomFoodView
- [ ] Food creation form
- [ ] Integration with search views

### Sprint 8: Lifting Session (COMPLETED) ✅
- [x] LiftingSessionView UI
- [x] ExerciseSelectionView
- [x] Real-time set tracking
- [x] Workout save/cancel flow
- [x] WorkoutHistoryView list
- [x] WorkoutDetailView

### Sprint 9: Home Screen (COMPLETED) ✅
- [x] HomeView implementation
- [x] Today's summary
- [x] Quick action buttons (4 actions)
- [x] Recent workouts list

### Sprint 10: Design System (COMPLETED) ✅
- [x] Design tokens (colors, typography, spacing)
- [x] Component library (buttons, cards, text fields)
- [x] Apply design system across all views
- [x] Dark mode fully functional

### Sprint 11: Polish & Testing (IN PROGRESS) ⏳
- [x] Empty states
- [x] Loading states
- [x] Error handling
- [ ] Performance optimization
- [x] Bug fixes (0 critical bugs)

### Sprint 12: App Store Prep 🔜
- [ ] App icon and launch screen
- [ ] Screenshots
- [ ] App Store description
- [ ] Privacy policy
- [ ] TestFlight beta

**Progress:** 90% MVP Complete (8/12 sprints done, 2 in progress, 2 pending)

---

## Contributing

This is currently a solo project. External contributions are not accepted at this time.

---

## License

Proprietary - All rights reserved

---

## Contact

For questions or support, contact [your-email]

---

**Last Updated**: 2025-02-11
**Current Sprint**: Sprint 6 - Exercise Library Expansion (CRITICAL)
**Version**: 0.9.0 (90% MVP Complete - Exercise library expansion required)
**Status**: BUILD SUCCEEDED ✅ | 0 Critical Bugs ✅ | Highly Functional 🚀# antrain
