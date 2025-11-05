# Changelog

All notable changes to Antrain will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [Unreleased]

### Added

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

### Planned for v1.2

#### To Be Added
- Custom exercise creation UI
- Custom food creation UI
- Food favorites and recent items
- Exercise notes and attachments

#### To Be Improved
- Performance optimizations
- Enhanced analytics and progress charts
- Accessibility improvements (VoiceOver support, Dynamic Type)

### Planned for v2.0

#### Major Features
- HealthKit integration
- Cloud sync across devices (optional)
- Data export (CSV, PDF)
- Rest timer with notifications
- Plate calculator
- Exercise instruction videos/GIFs
- Apple Watch companion app

---

## Version History

- **1.0.0** (2025-11-03) - Initial App Store release
- **0.9.0** (2025-02-11) - Pre-release beta (90% MVP complete)
- **0.1.0** (2025-01-15) - First development sprint

---

## Notes

### Build Status
- **v1.0.0**: ✅ Build Succeeded | 0 Critical Bugs | Fully Functional

### Development
This project was developed using sprint-based methodology optimized for AI-assisted development with Claude Code. See `docs/SPRINT_LOG.md` for detailed development history.

### Privacy & Data
All versions maintain our core principle: **100% local storage, zero data transmission, complete privacy.**

---

For questions or bug reports, please visit: https://github.com/burakkho/antrain/issues
