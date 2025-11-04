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

## [Unreleased]

### Planned for v1.1

#### To Be Added
- Custom exercise creation UI
- Custom food creation UI
- Food favorites and recent items
- Exercise notes and attachments

#### To Be Improved
- Performance optimizations
- Enhanced analytics and progress charts
- Workout templates and routines

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
