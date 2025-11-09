# Changelog

All notable changes to Antrain will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.2.0] - 2025-11-09

### Added

#### Personal Records Analysis
- **Advanced PR Filtering System**
  - Filter by date range (Last 7 days, Last 30 days, Last 3 months, Last year, All time)
  - Filter by muscle group (Push, Pull, Legs, Core, Full Body)
  - Search by exercise name with instant filtering
  - Combined filters for precise PR discovery

- **PR Statistics Dashboard**
  - Total PRs count across all exercises
  - Last 30 days PR count with percentage of total
  - Last 7 days PR count with recent progress indicator
  - Average PRs per week calculation
  - Color-coded stat cards with SF Symbols

- **Interactive PR Cards**
  - Expandable exercise cards with smooth animations
  - PR details: date, set info (reps × weight), volume
  - PR history chart (Swift Charts) showing progress over time
  - Empty state with helpful message when no PRs found
  - Relative date formatting (e.g., "2 days ago", "Last week")

#### CSV Export
- **CSV Export**: Backup workout data to CSV format
  - Compatible with popular fitness apps (Hevy, Strong, Fitbod)
  - Exports all workout history with exercise details
  - Share via Files app, email, or cloud storage
  - One-tap export from Settings

#### Set Type System
- **Set Type Differentiation**
  - Support for multiple set types: Normal, Warmup, Dropset, Failure
  - `SetType` enum with icon and color coding
  - Foundation for advanced workout tracking
  - Prepares for future features (auto-warmup suggestions, advanced analytics)

#### Enhanced Live Activity & Widget Services
- **LiveActivityManager**: Duration-based timer management
  - Tracks workout duration with pause/resume support
  - Updates Live Activity dynamically
  - Efficient timer management with background support

- **WidgetUpdateService**: Widget data synchronization
  - Automatically updates Home Screen widgets
  - Syncs workout summary data
  - Ensures widgets show latest workout information

#### Food Library Expansion
- **New Food Categories** (400+ new foods)
  - Fruits: 50+ fruits with accurate macros
  - Turkish Foods: Traditional Turkish cuisine items
  - International Foods: Global cuisine staples
  - Packaged Foods: Common branded/packaged items
  - Better serving size options
  - More accurate nutritional data

### Changed

#### Settings & Profile Separation
- **Profile Tab**: Replaced Settings tab in main navigation
  - User profile data (name, height, gender, date of birth, activity level)
  - Bodyweight tracking with add/view history functionality
  - Direct access to personal metrics from tab bar
  - Icon: `person.fill` (SF Symbol)

- **Settings Moved**: Now accessed via fullScreenCover from Home and Profile
  - App preferences only (notifications, theme, language, version)
  - Cleaner separation of concerns (user data vs app preferences)
  - Toolbar gear icon (⚙️) in Home and Profile for quick access
  - Presented as modal fullscreen overlay
  - Close button (X) in navigation bar

- **Modular Component Architecture**: 7 sheet-based edit components
  - `ProfileNameEditorSheet.swift` - Name editor
  - `ProfileHeightEditorSheet.swift` - Height editor (cm/inches)
  - `ProfileGenderEditorSheet.swift` - Gender picker
  - `ProfileDateOfBirthEditorSheet.swift` - DOB calendar picker
  - `ProfileActivityLevelEditorSheet.swift` - Activity level picker
  - `ProfileBodyweightEntrySheet.swift` - Add weight entry
  - `ProfileBodyweightHistorySheet.swift` - View/delete weight history

### Improved

#### Navigation & UX
- Better information architecture following iOS HIG
- Profile data more accessible (1 tap from any screen)
- Settings less cluttered (app preferences only)
- Consistent navigation pattern (toolbar gear icon → Settings)

#### Code Architecture
- Feature separation: `Features/Profile/` directory structure
- Reusable, testable sheet components
- `ProfileViewModel` manages user profile state
- `SettingsView` simplified (no user data logic)

---

## [Unreleased]

### Added

#### Nutrition Goals Editor - Modern UI
- **MacroSliderField Component**: Interactive macro input with slider, stepper buttons (+/-), and manual text input
  - Real-time validation with visual feedback (red border for invalid input)
  - Supports both quick adjustments (slider) and precise input (text field)
  - Range indicators showing min/max values
- **MacroDistributionChart Component**: Visual pie chart showing macro distribution
  - Real-time calorie calculation display
  - Breakdown by grams, calories, and percentage for each macro
  - Color-coded legend (Protein: red, Carbs: orange, Fats: yellow)

### Improved

#### Nutrition Goals Editor - UX/UI Enhancements
- **Simplified State Management**: Removed complex onChange handlers with flags
  - Eliminated `isUpdating` and `lastEditedField` complexity
  - Direct Double type usage instead of String ↔ Double conversions
  - Cleaner, more maintainable code (-27% lines in ViewModel)
- **One-Way Calculation**: Macros → Calories (simplified from bidirectional)
  - More intuitive user experience
  - Automatic calorie calculation as computed property
  - Consistent behavior across all macro inputs

#### Error Handling - Toast Notifications
- **Silent Failures Fixed**: Food add/remove errors now visible to users
  - Toast notifications for operation failures (addFood, removeFood)
  - 3-second auto-dismiss with slide-in animation
  - Top-aligned toast using existing DSToast component
- **Better User Feedback**: Clear error messages for failed operations
  - "Failed to add food" and "Failed to remove food" notifications
  - Screen-level errors still use DSErrorView for critical failures
  - Separation of concerns: toast for operations, error view for loading

### Technical

#### Code Quality Improvements
- Removed duplicate DSToast implementation
- Standardized error handling patterns across nutrition ViewModels
- Better separation between loading errors and operation errors
- Improved code readability and maintainability

---

## [1.2.1] - 2025-11-08

### Added

#### Food Library Expansion
- **35 new food items** added to nutrition library (105 → 140 total items)
- **Enhanced variety** across all categories for better tracking flexibility

**Protein Foods (11 new)**
- Seafood: Trout, Sea Bass, Mackerel, Anchovy
- Meat: Beef Tenderloin, Meatballs
- Processed Meats: Turkey Salami, Turkish Sausage (Sucuk)
- Dairy: Lor Cheese, Kashar Cheese (Turkish cheeses)
- Supplements: Protein Bar

**Carbohydrate Foods (10 new)**
- Breads: Rye Bread, Bran Bread
- Breakfast: Waffle, Pancake, Crepe
- Snacks: Granola Bar, Popcorn, Rice Cake, French Fries
- Rice: Sushi Rice (Cooked)

**Vegetables & Fruits (13 new)**
- Vegetables: Okra, Peas (Fresh), Corn (Fresh), Onion, Garlic, Leek
- Fruits: Kiwi, Grapefruit, Melon, Cherry, Apricot, Plum, Fig

**Fat Foods (6 new)**
- Nuts: Hazelnuts
- Dairy Fats: Butter, Margarine, Labneh, Cream Cheese
- Oils: Soybean Oil

### Improved

#### Food Library Organization
- Better categorization of international foods
- Added Turkish cuisine items (Sucuk, Lor, Kashar, Labneh)
- Enhanced variety for common cooking ingredients (Onion, Garlic, Leek)
- More breakfast options (Waffle, Pancake, Crepe)
- Additional fruits for seasonal variety

#### Documentation
- Created comprehensive FOOD_LIBRARY.md documentation
- Updated README.md to reflect 140+ food items
- Detailed breakdown of all food categories
- Technical implementation details
- Version history and future enhancements

### Technical

#### Code Metrics (v1.2.1)
- **Files Modified:** 4 food library files
  - ProteinFoods.swift: +11 items (30 → 41)
  - CarbFoods.swift: +10 items (28 → 38)
  - VegetableFoods.swift: +13 items (31 → 44)
  - FatFoods.swift: +6 items (16 → 22)
- **Total Lines Added:** ~600 lines (food definitions + serving units)
- **Documentation:** +1 new file (FOOD_LIBRARY.md, 400+ lines)

#### Quality Assurance
- All new foods include accurate nutritional data
- Multiple serving units per food (3-4 units average)
- Fully localized names (EN, TR, ES support)
- Proper categorization and metadata
- Build: ✅ Successful
- No breaking changes

---

## [1.2.0] - 2025-11-08

### Added

#### iOS 18+ Integration Features

**Home Screen Widgets**
- 3 widget sizes (Small 2×2, Medium 4×2, Large 4×4)
- Real-time workout count from current week
- Smart display logic: "Let's start!" (0 workouts) vs "X workouts" (1+ workouts)
- Beautiful gradient design (blue → purple)
- Deep link integration (`antrain://start-workout`)
- Auto-refresh on workout save and app launch
- Timeline refresh: Every hour
- UserDefaults-based data sharing (no App Group needed)
- Liquid Glass style with `.regularMaterial` backgrounds
- Full light/dark mode support

**Files Created:**
- `AntrainWidget/AntrainWidget.swift` (327 lines)
- `AntrainWidget/WidgetDataHelper.swift` (81 lines)
- `AntrainWidget/AntrainWidgetBundle.swift`
- `AntrainWidget/AntrainWidgetControl.swift` (template for iOS 18+)

**Files Modified:**
- `MainTabView.swift` - Widget data update integration
- `LiftingSessionViewModel.swift` - Auto-refresh widget on save

---

**Siri Shortcuts & App Intents**
- StartWorkoutIntent with tri-lingual support
- Siri voice commands:
  - 🇬🇧 "Hey Siri, start workout in Antrain"
  - 🇹🇷 "Hey Siri, Antrain antrenmana başla"
  - 🇪🇸 "Hey Siri, comenzar entrenamiento en Antrain"
- Shortcuts app integration
- Deep linking to home tab with quick actions
- Custom app icon: dumbbell.fill SF Symbol
- Siri entitlements enabled

**Files Created:**
- `antrain/AppIntents/StartWorkoutIntent.swift` (64 lines)
- `antrain/Resources/en.lproj/AppIntents.strings`
- `antrain/Resources/tr.lproj/AppIntents.strings`
- `antrain/Resources/es.lproj/AppIntents.strings`
- `antrain/antrain.entitlements` (Siri capability)

---

**Live Activities with Dynamic Island** (Complete)
- Real-time workout tracking on Lock Screen and Dynamic Island
- `WorkoutActivityAttributes` domain model for workout state
- `LiveActivityServiceProtocol` for abstraction and testability
- `LiveActivityService` implementation with ActivityKit integration
- Full Dynamic Island UI with Compact, Expanded, and Minimal states
- Lock Screen UI with comprehensive workout stats
- Automatic updates on set completion and every second (duration)
- Integration with `ActiveWorkoutManager` for lifecycle management
- State persistence and restoration on app restart

**Dynamic Island Features:**
- Expanded view: Current exercise, set progress, weight/reps, duration, volume, completed sets
- Compact view: Workout icon + set progress
- Minimal view: Workout icon only
- Orange keyline tint for visual consistency

**Lock Screen Features:**
- Current exercise name and set details
- Real-time duration with monospaced digits
- Workout stats: exercises, sets, volume
- Professional iOS-native styling

**Files Created:**
- `antrain/Core/Domain/State/LiveActivityService.swift` (132 lines)
- `antrain/Core/Domain/State/LiveActivityServiceProtocol.swift`
- `antrain/Core/Domain/State/WorkoutActivityAttributes.swift` (42 lines)
- `AntrainWidget/AntrainWidgetLiveActivity.swift` (296 lines)

**Files Modified:**
- `ActiveWorkoutManager.swift` - Live Activity lifecycle integration
- `LiftingSessionViewModel.swift` - Real-time state updates with Timer
- `MainTabView.swift` - Dependency injection

**Status:** ✅ Complete and functional (Rest Timer: Future enhancement)

---

**Design System Enhancements**

**Liquid Glass Transformation:**
- 17 components transformed with modern glassmorphism
- `.regularMaterial` backgrounds throughout
- Subtle shadow effects for depth (radius: 8, y: 4, opacity: 0.08)
- Premium iOS aesthetic
- Full light/dark mode adaptive

**Components Updated:**
- DSCard (base component)
- ActiveWorkoutBar
- CompactNutritionSummary & DailyNutritionSummary
- FoodSearchView
- TemplateQuickSelectorView
- ProgramCard & TemplateCard
- TemplateDetailView
- WorkoutProgramsView
- WorkoutsOverviewView
- RecentWorkoutRow
- And more...

**Haptic Feedback System:**
- Premium tactile feedback across all major interactions
- Set completion → Success haptic
- Quick action buttons → Medium impact
- Add set → Light impact
- Exercise delete → Warning notification
- PR achievement → Celebration haptic (existing, maintained)

**Files Modified:**
- `QuickActionButton.swift`
- `SetRow.swift`
- `LiftingSessionView.swift`
- `ExerciseCard.swift`
- All 17 Liquid Glass components

---

### Improved

#### Deep Link System
- URL scheme registration: `antrain://start-workout`
- Navigation handler in MainTabView
- Widget and Siri integration ready

#### iOS Version Support
- Deployment target: iOS 17+ (for `.containerBackground` API)
- iOS 18+ features prepared (Control Widgets template)

### Technical

#### Code Metrics (v1.2.0)
- **Widget Extension:**
  - 5 new files (AntrainWidget.swift, WidgetDataHelper.swift, etc.)
  - ~600 lines of widget code
- **App Intents:**
  - StartWorkoutIntent.swift (64 lines)
  - 3 localization files (EN, TR, ES)
  - Entitlements configuration
- **Live Activities Infrastructure:**
  - 4 new files (~500 lines)
  - Protocol-based architecture
  - Ready for Phase 2 implementation
- **Design System:**
  - 17 components updated with Liquid Glass
  - 4 components with haptic feedback
  - Consistent `.regularMaterial` usage

#### Files Created (v1.2.0)
- **Widget Extension:** 5 files
- **App Intents:** 4 files (1 Swift + 3 localization)
- **Live Activities:** 4 files
- **Total:** ~13 new files, ~1,200 lines

#### Files Modified (v1.2.0)
- Design system components: 17 files
- Haptic feedback: 4 files
- Deep linking: 2 files (MainTabView, AntrainApp)
- **Total:** ~23 files modified

#### Documentation (v1.2.0)
- Created `docs/v1.2/README.md` (comprehensive feature guide)
- Created `docs/v1.2/WIDGET_README.md` (widget implementation)
- Created `docs/v1.2/APPINTENTS_README.md` (Siri integration)
- Created `docs/v1.2/ROADMAP.md` (development roadmap)
- Moved future planning to `docs/v3/` (iOS 26, Swift 6.2, AI Coach)

---

## [Unreleased]

### Planned for v1.3

#### To Be Added
- Rest Timer for Live Activities
- Custom exercise creation UI
- Custom food creation UI
- Food favorites and recent items
- Exercise notes and attachments

#### To Be Improved
- Performance optimizations
- Enhanced analytics and progress charts with Swift Charts
- Accessibility improvements (VoiceOver support, Dynamic Type)

---

## [1.1.0] - 2025-11-05

### Added

#### Training Programs System (Complete)
**Backend & Core (Complete):**
- Complete training program management system with 3-tier hierarchy (Program → Week → Day)
- Domain models: `TrainingProgram`, `ProgramWeek`, `ProgramDay` with SwiftData persistence
- Supporting enums: `ProgramCategory`, `DifficultyLevel`, `TrainingPhase`, `WeekProgressionPattern`
- `TrainingProgramRepository` with full CRUD operations and @ModelActor pattern
- `ProgressiveOverloadService` with RPE-based weight suggestions (RPE 1-6: +5%, RPE 7-8: +2.5%, RPE 9-10: -2.5%)
- Template deletion safety system (prevents deletion of templates used in programs)
- Program library with DTO pattern for preset programs
- Automatic seeding system for preset programs

**Preset Programs (4 Available):**
- Starting Strength (Beginner, 12 weeks, 3 days/week)
- StrongLifts 5x5 (Beginner, 12 weeks, 3 days/week)
- Push Pull Legs 6-Day (Hypertrophy, 8 weeks, 6 days/week)
- 5/3/1 Boring But Big (Powerlifting, 4 weeks, 4 days/week)

**User Interface (Complete):**
- 23 UI components including ViewModels, Views, and Components
- `ProgramsListView` with search and category filtering
- `ProgramDetailView` with week/day navigation
- `CreateProgramFlow` - 4-step wizard for custom program creation (Basic Info, Progression, Schedule, Preview)
- Template selector with search and filtering
- Progression pattern visualizer with Swift Charts
- `ActiveProgramCard` component for home screen
- Program activation/deactivation flow
- Navigation integration from Workouts tab

**User Profile Integration:**
- `activeProgram: TrainingProgram?` relationship
- `activeProgramStartDate: Date?` and `currentWeekNumber: Int?` tracking
- `activateProgram()` / `deactivateProgram()` methods
- `getTodaysWorkout()` - calculates current week and day
- `progressToNextWeek()` for weekly advancement
- Progress computation helpers

**Modified Models:**
- `Workout` model: Added `rpe: Int?` field (1-10 Rate of Perceived Exertion)
- `UserProfile` model: Added active program tracking fields

#### Enhanced Workout Summary
- **PR Detection & Celebration**
  - Automatic detection of new personal records during workout
  - Trophy icon with highlighted PR display in summary
  - Shows weight, reps, and estimated 1RM for each PR
  - PRs automatically saved to PR repository
- **Comprehensive Volume & Statistics**
  - Total volume (tonnage) calculation and display
  - Total sets and exercises count
  - Duration tracking with formatted display
  - Enhanced stat boxes with SF Symbol icons
- **Muscle Group Breakdown**
  - Volume distribution by muscle group
  - Set count per muscle group
  - Exercise count per muscle group
  - Sorted by volume (top 5 displayed)
- **Previous Workout Comparison**
  - Automatic comparison with last similar workout
  - Volume change (absolute and percentage)
  - Set count change
  - Duration change
  - Visual indicators (arrows) for improvements/declines
- **Enhanced Exercise Details**
  - Set-by-set breakdown for each exercise
  - Completion status indicators (checkmark icons)
  - Total volume per exercise
  - Weight and rep display for each set
- **Workout Rating System**
  - 1-5 star rating for workouts
  - Proper database field storage (not notes)
  - Haptic feedback on star selection
  - Enables future filtering and analytics
- **Delete Workout Option**
  - Delete workout from summary screen
  - Confirmation dialog for safety
  - Async deletion with error handling

#### iOS Native UI Redesign
- Complete WorkoutSummaryView rewrite with iOS native styling
  - List with .insetGrouped style (Settings-app aesthetic)
  - Section-based organization
  - System semantic colors (.primary, .secondary, .tertiary, .blue, .green)
  - SF Pro system fonts (.body, .callout, .caption)
  - Native components (ProgressView, Label, Image)
  - Automatic dark mode support
  - No custom animations or excessive styling
- Native stat boxes with rounded corners and system gray background
- Clean comparison rows with arrow indicators
- Simple, minimal design philosophy

### Improved

#### Backend Architecture
- **Workout Model Extensions**
  - `volumeByMuscleGroup` computed property for muscle group analysis
  - `muscleGroupStats` for detailed muscle group statistics
  - `topMuscleGroups` for quick top-3 access
  - `compare(with:)` method for workout comparison
  - `getPRs(from:)` and `getPRCount(from:)` for PR retrieval
  - Added `rating: Int?` field for star ratings
- **WorkoutSummaryViewModel**
  - Parallel data loading with TaskGroup for performance
  - Loads PRs, comparison, and stats simultaneously
  - Async/await patterns throughout
  - @Observable macro for modern state management
  - @MainActor for thread safety
  - Proper error handling and loading states
- **New Domain Models**
  - `WorkoutComparison` struct for detailed comparison metrics
  - `ExerciseImprovement` struct for per-exercise analysis
  - `MuscleGroupStats` struct for muscle group data
- **AppDependencies**
  - Added convenience alias for prRepository

#### Localization
- Fixed WorkoutsView template strings for String Catalog auto-detection
- Removed `String(localized:)` wrappers (modern Swift localization)
- Plain strings work with both LocalizedStringKey and String parameters
- Xcode automatically detects and extracts strings

### Technical

#### Performance
- Parallel async operations with TaskGroup
  - PR detection runs concurrently with comparison loading
  - All data loading completes faster
  - Better user experience with minimal wait time

#### Code Quality
- Created 2 new files (WorkoutComparison.swift, WorkoutSummaryViewModel.swift)
- Modified 3 files (Workout.swift, WorkoutSummaryView.swift, WorkoutsView.swift)
- Added comprehensive computed properties for stats
- Clean separation of concerns (View, ViewModel, Domain)
- Proper dependency injection pattern

---

## [1.0.0] - 2025-11-03

### Initial Release

**First public release of Antrain - A comprehensive fitness tracking app for iOS.**

#### Added

##### Workout Tracking
- Real-time lifting session tracking
- Set, rep, and weight logging for strength training
- Exercise selection from preset library
- Quick logging for cardio workouts (time, distance, pace)
- Quick logging for MetCon workouts (AMRAP, EMOM, For Time)
- Comprehensive workout history view
- Detailed workout view with all exercises and sets
- Automatic Personal Record (PR) detection and tracking
- 1RM calculations using Brzycki formula
- PR history for all exercises

##### Nutrition Tracking
- Daily macro tracking (calories, protein, carbs, fats)
- Meal logging (breakfast, lunch, dinner, snacks)
- Food search from preset library (100+ items)
- Visual macro progress rings
- Daily nutrition summary
- Food serving size tracking and calculation

##### User Profile & Settings
- Basic profile information
- Daily nutrition goals management
- Manual bodyweight tracking with history
- Unit preferences (kg/lbs, g/oz, km/mi conversion)
- Theme switching support (light/dark mode)

##### Libraries
- 180+ preset exercises (barbell, dumbbell, bodyweight, machine, cable, weightlifting)
- 103 preset food items across all categories
- Category-based organization (protein, carbs, fats, vegetables)

##### Design & UX
- Modern design system with design tokens
- Component library (buttons, cards, text fields)
- Dark mode support
- Empty states for all screens
- Loading states with smooth transitions
- Pull-to-refresh on main screens
- Responsive layout for all iOS devices

##### Technical Features
- 100% local storage using SwiftData
- Clean Architecture (3-layer: Presentation, Domain, Data)
- MVVM + Protocol-Oriented Design
- Swift 6 with strict concurrency
- iOS 18.0+ support
- No external dependencies
- Complete privacy (no analytics, no tracking, no cloud)

#### Architecture
- Micro-modular file organization (100-200 lines per file)
- Repository pattern for data abstraction
- Dependency injection via AppDependencies
- SOLID principles throughout codebase

---

## [1.1.0] - 2025-11-05

### Added

#### Workout Templates System
- Complete workout template management system
- 12 preset workout templates across 5 categories (Strength, Hypertrophy, Calisthenics, Weightlifting, Beginner)
- Create custom workout templates with 3-step wizard
- Save completed workouts as templates
- Start workouts from templates with one tap
- Template browsing with search and category filtering
- Template editing and duplication
- Usage tracking (last used timestamp)
- Swipe actions for quick template management

#### Comprehensive Localization
- Full Turkish (Türkçe) language support
- Full Spanish (Español) language support
- 500+ strings localized across all features
- Automatic string extraction enabled for future updates
- Localized date formatting (calendar weekdays)
- Localized units and measurements
- Device language detection

#### Smart Nutrition Onboarding
- 5-step onboarding wizard for new users
- TDEE (Total Daily Energy Expenditure) calculator
- Smart macro recommendations based on user profile
- 5 macro presets (Balanced, High Protein, Keto, Low Carb, Endurance)
- Activity level tracking (sedentary to very active)
- Goal-based calorie recommendations (weight loss/gain/maintain)
- Initial bodyweight entry integration

### Improved

#### Architecture & Code Quality
- Clean Architecture refactoring for Nutrition module
  - DailyNutritionView reduced from 814 to 246 lines (70% reduction)
  - Extracted ViewModels from Views
  - Created pure domain functions (MacroCalculator)
  - Moved MacroPreset to Domain layer
- View component extraction (micro-modular architecture)
  - NutritionSettingsView reduced from 445 to 156 lines (65% reduction)
  - Extracted 4 reusable components with independent previews
- Architecture health score improved from 67.5 to 71-72/100
- Better separation of concerns
- Improved testability

#### Localization Infrastructure
- SwipeableNumberField now uses LocalizedStringKey for placeholders
- DSCalendarView uses DateFormatter for automatic weekday localization
- Fixed 49 localization patterns for auto-extraction
- All loading states properly localized
- Unit displays consistently localized (kg, lbs, kcal, g, min, sec, km, mi)

### Changed

#### Nutrition Serving Unit System Overhaul
- **Breaking Change:** Removed deprecated `servingAmount` field from `FoodEntry` model
- **Type Safety:** Made `selectedUnit` non-nullable in `FoodEntry` (always requires a unit)
- **Automatic Fallback:** All `FoodItem` instances now automatically ensure a gram unit exists
- **Improved UX:** Unit picker always visible in `FoodSearchView` (no more conditional rendering)
- **Consistency:** Removed duplicate `servingAmount` property (migration compatibility)
- **Better API:** Updated `NutritionRepository` to always require `ServingUnit` parameter
- **Helper Method:** Enhanced `FoodItem.getDefaultUnit()` with guaranteed non-null return

#### Workouts UI Refactoring
- Removed nested TabView anti-pattern, replaced with iOS native segmented control
- Renamed `WorkoutsHistoryTabView` → `WorkoutsOverviewView` (more accurate naming)
- Renamed `WorkoutTemplatesTabView` → `WorkoutTemplatesView`
- Renamed `WorkoutProgramsTabView` → `WorkoutProgramsView`
- Moved `ActiveProgramCard` from `Features/Home/` to `Features/Workouts/Programs/`
- Improved program activation flow with success alert and automatic navigation
- Fixed duplicate workout save bug in `WorkoutSummaryView`

#### Platform Requirements
- Minimum iOS version updated from 17.0 to 18.0
- Leverages latest SwiftUI features
- Better performance on iOS 18+

#### User Experience
- Templates accessible from Workouts tab (user feedback-driven decision)
- Improved navigation patterns
- Better empty states throughout
- Enhanced loading states with skeleton cards
- Smoother animations and transitions

### Fixed

#### Critical Bugs
- UUID mismatch in template seeding (templates now correctly reference SwiftData exercises)
- Exercise name mismatches (23 exercise names corrected)
- MainActor isolation warnings resolved
- Sendable conformance issues fixed
- Circular update prevention in ViewModels
- Workout save persistence bug
- Multiple white screen bugs across views

#### Localization
- Fixed nil coalescing patterns for proper localization
- Fixed string interpolation with units
- Fixed string concatenation patterns
- Removed 2 stale format string keys
- All DSLoadingView messages now properly localized

### Technical

#### Code Metrics
- 28+ new files created
- ~3,500 lines of new code
- ~688 lines of complex code refactored
- 23+ critical bugs fixed
- 0 critical bugs remaining
- Build: Successful
- Architecture compliance: Achieved

#### Files Modified
- 27 files changed
- 14,859 insertions
- 4,744 deletions
- Net improvement: +10,115 lines (includes localizations and new features)

---

## Version History

- **1.2.0** (2025-11-08) - iOS 18+ features (Widgets, Siri, Liquid Glass, Live Activities with Dynamic Island)
- **1.1.0** (2025-11-05) - Templates, Programs, Enhanced Workout Summary, Localization
- **1.0.0** (2025-11-03) - Initial App Store release
- **0.9.0** (2025-02-11) - Pre-release beta (90% MVP complete)
- **0.1.0** (2025-01-15) - First development sprint

---

## Notes

### Build Status
- **v1.2.0**: ✅ Build Succeeded | 0 Critical Bugs | Fully Functional | iOS 18+ Features
- **v1.1.0**: ✅ Build Succeeded | 0 Critical Bugs | Fully Functional
- **v1.0.0**: ✅ Build Succeeded | 0 Critical Bugs | Fully Functional

### Development
This project was developed using sprint-based methodology optimized for AI-assisted development with Claude Code. See `docs/SPRINT_LOG.md` for detailed development history.

### Privacy & Data
All versions maintain our core principle: **100% local storage, zero data transmission, complete privacy.**

---

For questions or bug reports, please visit: https://github.com/burakkho/antrain/issues
