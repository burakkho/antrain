# Training Programs Feature (v2.0)

> **Status:** 🚧 Phase 5 Complete - Integration In Progress
> **Target Release:** v2.0
> **Progress:** 5/6 Phases Complete (90%)

## Overview

Training Programs is a major feature addition that enables users to follow structured, multi-week workout plans with built-in periodization, progressive overload, and auto-regulation capabilities. This brings Antrain to professional-grade training management.

---

## Documentation Index

### Core Documents

1. **[TRAINING_PROGRAMS.md](./TRAINING_PROGRAMS.md)** - Architecture & Design Decisions
   - Complete system architecture
   - Design decisions and rationale
   - Domain model specifications
   - Data integrity patterns

2. **[IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)** - Step-by-Step Implementation
   - 6 implementation phases
   - Detailed task breakdowns
   - Testing strategy
   - Success metrics

3. **[API_DESIGN.md](./API_DESIGN.md)** - Complete API Reference
   - Full model specifications
   - Repository protocols
   - Service layer APIs
   - ViewModel interfaces

4. **[NOTIFICATIONS.md](./NOTIFICATIONS.md)** - Workout Notifications System
   - Notification architecture
   - UNUserNotificationCenter integration
   - Scheduling logic
   - Permission handling
   - Actions & deep linking

---

## Quick Start

### For Developers

**Starting Implementation:**
```bash
# 1. Review architecture
open docs/v2/TRAINING_PROGRAMS.md

# 2. Check implementation plan
open docs/v2/IMPLEMENTATION_PLAN.md

# 3. Start Phase 1
# Follow IMPLEMENTATION_PLAN.md Phase 1 checklist
```

**Key Files to Create (Phase 1):**
- `Core/Domain/Models/Program/TrainingProgram.swift`
- `Core/Domain/Models/Program/ProgramWeek.swift`
- `Core/Domain/Models/Program/ProgramDay.swift`
- Supporting enums

### For Reviewers

**Review Checklist:**
- [ ] Architecture aligns with existing patterns
- [ ] SwiftData models properly defined
- [ ] Repository pattern followed
- [ ] MVVM architecture maintained
- [ ] Privacy principles preserved (100% local)
- [ ] Testing strategy comprehensive

---

## Feature Highlights

### User-Facing Features

✅ **Structured Programs**
- Pre-built professional programs (PPL, 5x5, Starting Strength, etc.)
- Custom program creation with multi-step wizard
- 12+ weeks of planned training

✅ **Progressive Overload**
- Auto-suggest weights based on RPE
- Week-to-week progression patterns
- Deload week management

✅ **Active Program Tracking**
- "Today's workout" suggestions
- Progress visualization
- Week completion tracking

✅ **Flexibility**
- Override any suggestion
- Modify programs on the fly
- Duplicate and customize presets

🔔 **Workout Notifications** (NEW)
- Daily workout reminders
- Smart scheduling based on active program
- Interactive actions (Start Workout, Snooze)
- Rest day reminders (optional)
- Full user control over timing and days

### Technical Features

🏗️ **Architecture**
- Clean 3-layer architecture
- SwiftData persistence
- `@ModelActor` repositories
- `@Observable` ViewModels

🔒 **Privacy**
- 100% local storage
- Zero cloud sync
- No HealthKit dependency

⚡ **Performance**
- Background thread data operations
- Efficient relationship fetching
- Pagination support

🧪 **Testing**
- Unit tests for algorithms
- Integration tests for repositories
- UI tests for critical flows

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **HealthKit** | Zero integration | Preserves privacy, full control |
| **Periodization** | Simple weekly (no Mesocycle) | Faster MVP, 90% coverage |
| **Overload** | Hybrid (auto-suggest + override) | Balance automation & control |
| **Templates** | Reference (single source) | Storage efficient, updates propagate |
| **Progression** | Pattern-based | Flexible, various methodologies |
| **Active Program** | UserProfile field | Apple's recommended pattern |
| **RPE** | Workout-level | Simple MVP, expandable later |
| **Delete Safety** | Multi-layer constraints | Data integrity + UX |

---

## Architecture Overview

### Hierarchy

```
TrainingProgram (MacroCycle)
  └── ProgramWeek (MicroCycle)
      └── ProgramDay
          └── WorkoutTemplate (Reference)
              └── Exercise (Single Source of Truth)
```

### Example

```
12-Week PPL Split
├── Week 1 [Hypertrophy Phase] @ 1.0x intensity
│   ├── Mon: Push Day
│   ├── Tue: Pull Day
│   ├── Wed: Leg Day
│   └── (repeat Thu-Sat)
├── Week 2 [Hypertrophy Phase] @ 1.025x intensity
│   └── ...
├── ...
└── Week 12 [Deload Week] @ 0.6x intensity
```

### File Structure

```
antrain/
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Program/              ← NEW
│   │   │   │   ├── TrainingProgram.swift
│   │   │   │   ├── ProgramWeek.swift
│   │   │   │   └── ProgramDay.swift
│   │   │   ├── Workout/              ← MODIFIED
│   │   │   └── User/                 ← MODIFIED
│   │   └── Protocols/Repositories/
│   │       └── TrainingProgramRepositoryProtocol.swift
│   └── Data/
│       ├── Repositories/
│       │   └── TrainingProgramRepository.swift
│       ├── Services/
│       │   └── ProgressiveOverloadService.swift
│       └── Libraries/
│           └── ProgramLibrary/
└── Features/
    └── Programs/                     ← NEW FEATURE
        ├── ViewModels/
        └── Views/
```

---

## Implementation Timeline

| Phase | Duration | Focus | Status |
|-------|----------|-------|--------|
| Phase 1 | 2-3 days | Domain Models & Enums | ✅ Complete |
| Phase 2 | 2-3 days | Repository & Services | ✅ Complete |
| Phase 3 | 3 days | Basic UI | ✅ Complete |
| Phase 4 | 3-4 days | Program Creation Wizard | ✅ Complete |
| Phase 5 | 2 days | Preset Programs | ✅ Complete |
| Phase 6 | 2-3 days | Active Program Tracking | ⚠️ Partial (50%) |
| **Total** | **14-18 days** | **2-3 weeks** | **90% Complete** |

---

## Progressive Overload Algorithm

**RPE-Based Auto-Suggestion:**

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

finalWeight = suggestedWeight * weekModifier
```

---

## Testing Strategy

### Unit Tests
- Progressive overload algorithm
- Week progression patterns
- RPE calculations
- Domain model validation

### Integration Tests
- Repository CRUD operations
- Template-Program relationships
- Active program state management

### UI Tests
- Program creation flow
- Template selection
- Activation flow
- Delete safety warnings

---

## Success Metrics

### Technical
- ✅ All unit tests passing (>95% coverage)
- ✅ Build time < 30 seconds
- ✅ SwiftData fetch times < 100ms
- ✅ Zero memory leaks

### Feature
- ✅ Program creation < 2 minutes
- ✅ Program activation < 10 seconds
- ✅ Suggestions accurate 90% of time
- ✅ Zero template deletion bugs

---

## Future Enhancements (v2.1+)

### Planned Features

**Mesocycle Support**
- Explicit training blocks
- Phase-based periodization
- Auto-progression between phases

**1RM Tracking**
- Track estimated 1RM per exercise
- Percentage-based programming
- 1RM calculator integration

**Advanced Auto-Regulation**
- Fatigue management algorithms
- Automatic deload recommendations
- Velocity-based training (future)

**Community Features**
- Share/import programs
- Program marketplace
- Ratings and reviews

**Apple Watch Integration**
- Sync program schedule
- Workout reminders
- Quick start from watch

**Analytics**
- Program adherence tracking
- Volume/intensity trends
- PR frequency analysis

---

## Dependencies

### Internal
- SwiftData (persistence)
- WorkoutTemplate (existing)
- Exercise (existing)
- UserProfile (existing)

### External
- None (100% native Swift)

---

## Migration Notes

### Database Changes

**New Tables:**
- `TrainingProgram`
- `ProgramWeek`
- `ProgramDay`

**Modified Tables:**
- `Workout` - Add `rpe: Int?` field
- `UserProfile` - Add `activeProgram`, `activeProgramStartDate`, `currentWeekNumber`

**Migration Strategy:**
- SwiftData auto-migration
- No breaking changes to existing data
- Backward compatible

---

## FAQ

**Q: Will this replace templates?**
A: No, templates remain as building blocks. Programs organize templates into multi-week plans.

**Q: Can I use programs without HealthKit?**
A: Yes! Programs are 100% local, no HealthKit required.

**Q: Can I modify preset programs?**
A: You can duplicate and modify them. Original presets remain unchanged.

**Q: What happens if I delete a template used in programs?**
A: The app prevents deletion and shows which programs use it.

**Q: Can I have multiple active programs?**
A: MVP supports one active program. Multi-program support planned for v2.1.

**Q: How does RPE tracking work?**
A: After each workout, optionally rate difficulty 1-10. This improves future suggestions.

---

## Contributing

See main [CONTRIBUTING.md](../../CONTRIBUTING.md) for general guidelines.

**For This Feature:**
1. Follow implementation plan phases
2. Write tests for all new code
3. Update documentation as you go
4. Create focused PRs per phase

---

## Questions?

- **Architecture:** See [TRAINING_PROGRAMS.md](./TRAINING_PROGRAMS.md)
- **Implementation:** See [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)
- **API Reference:** See [API_DESIGN.md](./API_DESIGN.md)
- **Issues:** Create GitHub issue with `v2.0` label

---

## Completed Phases Summary

### ✅ Phase 1: Domain Models & Enums
- Created all domain models (TrainingProgram, ProgramWeek, ProgramDay)
- Implemented all supporting enums (ProgramCategory, DifficultyLevel, TrainingPhase, WeekProgressionPattern)
- Modified existing models (Workout, UserProfile)
- Swift 6 concurrency compliance achieved

### ✅ Phase 2: Repository & Services
- Implemented TrainingProgramRepository with @ModelActor
- Created ProgressiveOverloadService with RPE-based algorithm
- Added template deletion safety checks
- Updated AppDependencies

### ✅ Phase 3: Basic UI
- Created 3 ViewModels (ProgramsList, ProgramDetail, WeekDetail)
- Built 4 UI Components (ProgramCard, WeekCard, DayCard, PhaseIndicator)
- Implemented 3 main views (List, Detail, Week views)
- Integrated into Workouts navigation

### ✅ Phase 4: Program Creation Wizard
- Built CreateProgramViewModel with multi-step state management
- Created 4-step wizard flow (BasicInfo, Progression, Schedule, Preview)
- Implemented TemplateSelectorSheet for template selection
- Added progression chart with Swift Charts
- Wired up creation flow in WorkoutsView and ProgramsListView

### ✅ Phase 5: Preset Programs
- Created ProgramLibrary structure with DTO pattern
- Implemented 4 preset programs (Starting Strength, StrongLifts 5x5, PPL 6-Day, 5/3/1 BBB)
- Built seeding system in PersistenceController
- Automatic preset program loading on first launch
- Template reference resolution working correctly

### ⚠️ Phase 6: Active Program Tracking (Partial - 50%)
**Completed:**
- ✅ Active program state management in UserProfile
- ✅ Activation/deactivation methods
- ✅ getTodaysWorkout() logic
- ✅ ActiveProgramCard component created
- ✅ Navigation integration in WorkoutsView

**Remaining:**
- ❌ ActiveProgramCard not visible in HomeView (needs integration)
- ❌ Template deletion safety UI (backend ready, UI missing)
- ❌ Program-based workout flow with suggestions
- ❌ RPE prompt after workout completion

---

**Last Updated:** 2025-11-06
**Status:** 🚧 Phase 5 Complete - Phase 6 Integration In Progress (90% Overall)
