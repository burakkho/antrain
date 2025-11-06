# HIG Compliance Improvements - Sprint Tracking

**Feature:** Apple Human Interface Guidelines Compliance
**Current Score:** 82% → **Target:** 95%+
**Start Date:** TBD (Post v2.0 major features)
**Estimated Duration:** 7-9 days (3 sprints)
**Priority:** Low (v2.x roadmap - integrated with new features)

---

## 📊 Sprint Overview

| Sprint | Focus | Duration | Priority | Status |
|--------|-------|----------|----------|--------|
| Sprint 1 | Critical Accessibility | 3 days | High | 🔜 Not Started |
| Sprint 2 | UX Polish & Enhancements | 2-3 days | Medium | ⏸️ Pending |
| Sprint 3 | Visual Polish & Documentation | 2-3 days | Low | ⏸️ Pending |

---

## 🎯 Overall Objectives

### Current State (v1.0 - 82% HIG Compliant)
**Strengths:**
- ✅ Native SwiftUI components
- ✅ Proper navigation patterns
- ✅ Dynamic Type support (semantic fonts)
- ✅ Dark mode support
- ✅ Platform-specific gestures

**Critical Gaps:**
- ❌ No accessibility support (VoiceOver, labels, hints)
- ⚠️ Some touch targets below 44x44pt minimum
- ⚠️ Custom fonts don't scale with Dynamic Type

### Target State (v2.x - 95%+ HIG Compliant)
- ✅ Full VoiceOver support
- ✅ All touch targets meet minimum size
- ✅ Haptic feedback on key actions
- ✅ Comprehensive accessibility documentation
- ✅ HIG-ready new features (HealthKit, Watch, Cloud)

---

## Sprint 1: Critical Accessibility
**Duration:** 3 days
**Status:** 🔜 Not Started
**Priority:** High
**Goal:** Add VoiceOver support and fix touch targets

### 📋 Tasks

#### A. Design System Components Accessibility
**Priority:** Critical (affects entire app)

- [ ] **DSPrimaryButton** (`Shared/DesignSystem/Components/Buttons/DSPrimaryButton.swift`)
  - Add `.accessibilityLabel()` if custom icon
  - Verify loading state accessibility

- [ ] **DSSecondaryButton** (`Shared/DesignSystem/Components/Buttons/DSSecondaryButton.swift`)
  - Add accessibility labels

- [ ] **DSTextField** (`Shared/DesignSystem/Components/Inputs/DSTextField.swift`)
  - Verify error state accessibility
  - Add hint for validation rules

- [ ] **DSNumberField** (`Shared/DesignSystem/Components/Inputs/DSNumberField.swift`)
  - Add accessibility value for current number
  - Hint for increment/decrement

#### B. Home Feature Accessibility
- [ ] **QuickActionButton** (`Features/Home/Views/Components/QuickActionButton.swift:10-26`)
  - Add `.accessibilityLabel(title)`
  - Add `.accessibilityHint("Double tap to \(title.lowercased())")`
  - Add `.accessibilityAddTraits(.isButton)`

- [ ] **TodayStatsCard** (Home components)
  - Add accessibility labels for stat values
  - Add `.accessibilityElement(children: .combine)`

#### C. Workout Feature Accessibility
**High-impact components:**

- [ ] **SetRow** (`Features/Workouts/LiftingSession/Views/Components/SetRow.swift:43-114`)
  - Add `.accessibilityElement(children: .combine)`
  - Add `.accessibilityLabel("Set \(setNumber)")`
  - Add `.accessibilityValue("\(Int(reps)) reps at \(weight) \(unit), \(set.isCompleted ? "completed" : "not completed")")`
  - Add `.accessibilityHint("Swipe to mark complete or delete")`

- [ ] **ExerciseCard** (`Features/Workouts/LiftingSession/Views/Components/ExerciseCard.swift:23-27`)
  - Delete button: `.accessibilityLabel("Delete \(workoutExercise.exercise?.name ?? "exercise")")`
  - Delete button: `.accessibilityHint("Double tap to remove from workout")`

- [ ] **WorkoutCard** (Workouts list)
  - Add accessibility summary
  - Add accessibility value for workout details

#### D. Nutrition Feature Accessibility
- [ ] **MealCard** (`Features/Nutrition/DailyNutrition/Views/Components/MealCard.swift:98-101`)
  - Remove button: `.accessibilityLabel("Remove food item")`
  - Add button: `.accessibilityLabel("Add food to \(mealType)")`

- [ ] **MacroRing** (Nutrition components)
  - Add accessibility label for macro values
  - Add percentage information

#### E. Settings Feature Accessibility
- [ ] **SettingsRow** components
  - Add accessibility hints for navigation
  - Add accessibility values for current settings

#### F. Touch Target Fixes
**Minimum 44x44pt requirement:**

- [ ] **SetRow delete button** (trash icon)
  - Add `.frame(minWidth: 44, minHeight: 44)`

- [ ] **MealCard remove button** (minus circle)
  - Add `.frame(minWidth: 44, minHeight: 44)`

- [ ] **ExerciseCard delete button**
  - Verify padding/tap area

- [ ] **QuickActionButton** tap area
  - Verify entire card is tappable (should be OK with Button wrapper)

- [ ] **Tab bar items**
  - Verify (should be automatic with native TabView)

- [ ] **Toolbar items**
  - Verify all toolbar buttons meet minimum size

### 📁 Files Updated
```
Shared/DesignSystem/Components/
├── Buttons/
│   ├── DSPrimaryButton.swift (updated)
│   └── DSSecondaryButton.swift (updated)
└── Inputs/
    ├── DSTextField.swift (updated)
    └── DSNumberField.swift (updated)

Features/Home/Views/Components/
└── QuickActionButton.swift (updated)

Features/Workouts/LiftingSession/Views/Components/
├── SetRow.swift (updated)
└── ExerciseCard.swift (updated)

Features/Nutrition/DailyNutrition/Views/Components/
└── MealCard.swift (updated)

Features/Settings/Views/Components/
└── SettingsRow.swift (updated)
```

### ✅ Definition of Done
- [ ] All critical components have accessibility labels
- [ ] All icon-only buttons have descriptive labels
- [ ] Complex components use `.accessibilityElement(children: .combine)`
- [ ] All touch targets verified ≥ 44x44pt
- [ ] Manual VoiceOver test passed:
  - [ ] Can navigate Home screen
  - [ ] Can complete a workout session
  - [ ] Can add food to nutrition log
  - [ ] Can navigate Settings
- [ ] No VoiceOver announces "Button" without description
- [ ] All interactive elements discoverable with VoiceOver

---

## Sprint 2: UX Polish & Enhancements
**Duration:** 2-3 days
**Status:** ⏸️ Pending
**Priority:** Medium
**Goal:** Add haptic feedback, fix UX issues, improve Dynamic Type

### 📋 Tasks

#### A. Haptic Feedback
**Add UINotificationFeedbackGenerator for key actions:**

- [ ] **Set completion** (`SetRow.swift` - onComplete)
  ```swift
  let generator = UINotificationFeedbackGenerator()
  generator.notificationOccurred(.success)
  ```

- [ ] **Exercise deletion** (`ExerciseCard.swift` - onDeleteExercise)
  ```swift
  let generator = UINotificationFeedbackGenerator()
  generator.notificationOccurred(.warning)
  ```

- [ ] **Workout save** (`LiftingSessionView.swift` - onSave)
  ```swift
  let generator = UINotificationFeedbackGenerator()
  generator.notificationOccurred(.success)
  ```

- [ ] **Food item added** (`FoodSearchView.swift` - onAdd)
  ```swift
  let generator = UIImpactFeedbackGenerator(style: .light)
  generator.impactOccurred()
  ```

- [ ] **Personal record** (when PR is achieved)
  ```swift
  let generator = UINotificationFeedbackGenerator()
  generator.notificationOccurred(.success)
  ```

#### B. Swipe Actions Refinement
- [ ] **Fix SetRow swipe edges** (`SetRow.swift:97-105`)
  - Current: Complete on trailing, Delete on leading (reversed)
  - Fix: Complete on leading (swipe right), Delete on trailing (swipe left)
  - Update accessibility hints accordingly

- [ ] Verify swipe action consistency across app
  - Delete actions should be on trailing edge
  - Non-destructive actions on leading edge

#### C. Loading States
**Add loading indicators to Settings sheets:**

- [ ] **HeightEditorSheet** - Show loading on save
- [ ] **WeightGoalEditorSheet** - Show loading on save
- [ ] **GenderEditorSheet** - Show loading on save
- [ ] **NameEditorSheet** - Show loading on save
- [ ] Use `DSPrimaryButton`'s `isLoading` parameter

#### D. Dynamic Type Improvements
**Fix custom fonts to scale with accessibility text sizes:**

- [ ] **DSTypography.swift:45-52** - Custom font styles
  ```swift
  // Before: Fixed sizes
  static let numberDisplay = Font.system(size: 48, weight: .bold, design: .rounded)

  // After: Scaled sizes
  @ScaledMetric(relativeTo: .largeTitle)
  private static var numberDisplaySize: CGFloat = 48
  static let numberDisplay = Font.system(size: numberDisplaySize, weight: .bold, design: .rounded)
  ```

- [ ] Apply to: `numberDisplay`, `statValue`, `button` (if critical)
- [ ] Test with Settings → Accessibility → Larger Text

#### E. TextField Placeholder Improvements
- [ ] **DailyNutritionView.swift:275, 292, 309, 326**
  - Replace empty `""` placeholders with "0" or "Enter value"

- [ ] Verify all TextFields have descriptive placeholders
- [ ] Use consistent placeholder style across app

#### F. Error State Improvements
- [ ] Add error alerts for critical failures
  - Workout save failures
  - Data persistence errors
- [ ] Improve validation error messages
- [ ] Add retry options for failed operations

### 📁 Files Updated
```
Features/Workouts/LiftingSession/Views/Components/
├── SetRow.swift (haptic + swipe fix)
└── ExerciseCard.swift (haptic)

Features/Nutrition/
└── FoodSearchView.swift (haptic)

Features/Settings/Views/Editors/
├── HeightEditorSheet.swift (loading state)
├── WeightGoalEditorSheet.swift (loading state)
├── GenderEditorSheet.swift (loading state)
└── NameEditorSheet.swift (loading state)

Shared/DesignSystem/Tokens/
└── DSTypography.swift (Dynamic Type)

Features/Nutrition/DailyNutrition/Views/
└── DailyNutritionView.swift (placeholders)
```

### ✅ Definition of Done
- [ ] Haptic feedback added to 5+ key actions
- [ ] Swipe actions follow HIG convention (right = non-destructive, left = destructive)
- [ ] All Settings sheets show loading state on save
- [ ] Custom fonts scale with Dynamic Type (test with Larger Text)
- [ ] All TextFields have descriptive placeholders
- [ ] Error states provide clear feedback and recovery options
- [ ] Manual testing: Haptics feel natural and not excessive
- [ ] Manual testing: Large text sizes don't break layouts

---

## Sprint 3: Visual Polish & Documentation
**Duration:** 2-3 days
**Status:** ⏸️ Pending
**Priority:** Low
**Goal:** Final polish, documentation, comprehensive testing

### 📋 Tasks

#### A. Color Contrast Audit
- [ ] **Verify WCAG AA compliance** (4.5:1 for normal text, 3:1 for large)
  - [ ] Text on backgrounds
  - [ ] Button states (default, pressed, disabled)
  - [ ] Category colors in templates
  - [ ] Macro ring colors

- [ ] Use Xcode Accessibility Inspector for contrast check
- [ ] Test in both light and dark mode

#### B. Dark Mode Verification
- [ ] **Full app walkthrough in dark mode**
  - [ ] Home screen
  - [ ] Workout session
  - [ ] Nutrition tracking
  - [ ] Settings
  - [ ] Templates (if in v2)

- [ ] Verify semantic colors used everywhere
- [ ] Check for any hardcoded colors
- [ ] Verify SF Symbols render correctly

#### C. Accessibility Documentation
- [ ] **Create HIG_COMPLIANCE.md** in `/docs`
  - Current compliance score
  - Component-level checklist
  - VoiceOver testing guide
  - Accessibility best practices for antrain

- [ ] **Update CONTRIBUTING.md** with accessibility requirements
  - Add "Accessibility Checklist" section
  - Require accessibility labels for new components
  - VoiceOver testing guidelines

- [ ] **Add inline documentation** to DS components
  - Document accessibility implementation
  - Provide usage examples

#### D. Component Accessibility Reference
**Create quick reference for common patterns:**

- [ ] Document in code comments or separate guide:
  - Button accessibility pattern
  - Icon-only button pattern
  - Complex row pattern (combine children)
  - Form field pattern
  - Swipe action pattern

#### E. VoiceOver Testing Guide
- [ ] **Create step-by-step testing scenarios:**
  - Scenario 1: Complete a workout
  - Scenario 2: Log daily nutrition
  - Scenario 3: Update user settings
  - Scenario 4: Browse workouts

- [ ] Document expected VoiceOver announcements
- [ ] Create checklist for testing new features

#### F. Final Polish
- [ ] Remove any debug print statements
- [ ] Verify no accessibility warnings in Xcode
- [ ] Run Accessibility Inspector audit
- [ ] Test on physical device (if available)

#### G. Update Project Documentation
- [ ] **CHANGELOG.md** - Add HIG improvements to v2.x notes
- [ ] **README.md** - Add accessibility badge/statement
- [ ] **MODELS.md** - No changes needed (data layer unchanged)

### 📁 Files Created/Updated
```
docs/
├── HIG_COMPLIANCE.md (new)
├── CONTRIBUTING.md (updated - add accessibility section)
├── CHANGELOG.md (updated)
└── README.md (updated)

docs/v2/
└── HIG_IMPROVEMENTS_SPRINTS.md (this file - mark completed)

Shared/DesignSystem/Components/
└── [All components] (add documentation comments)
```

### ✅ Definition of Done
- [ ] Color contrast verified (WCAG AA)
- [ ] Dark mode fully tested
- [ ] HIG_COMPLIANCE.md created with 95%+ score
- [ ] CONTRIBUTING.md updated with accessibility guidelines
- [ ] VoiceOver testing guide documented
- [ ] Component documentation complete
- [ ] Xcode Accessibility Inspector shows no critical issues
- [ ] Manual testing on device passed
- [ ] Project documentation updated
- [ ] **Ready for v2.x release with HIG compliance**

---

## 🔗 v2 Feature Integration Checklist

### When Adding New Features (HealthKit, Watch, Cloud)
Use this checklist to ensure HIG compliance from the start:

#### Accessibility Checklist
- [ ] All buttons have `.accessibilityLabel()`
- [ ] Icon-only buttons have descriptive labels
- [ ] Complex views use `.accessibilityElement(children: .combine)`
- [ ] Dynamic content has `.accessibilityValue()`
- [ ] All interactive elements have `.accessibilityHint()` (if non-obvious)
- [ ] Touch targets ≥ 44x44pt
- [ ] VoiceOver tested

#### UX Checklist
- [ ] Haptic feedback on key actions
- [ ] Loading states for async operations
- [ ] Error states with clear messaging
- [ ] Swipe actions follow convention (if applicable)
- [ ] TextField placeholders descriptive

#### Visual Checklist
- [ ] Dark mode supported
- [ ] Semantic colors used (no hardcoded)
- [ ] Color contrast ≥ 4.5:1
- [ ] SF Symbols used (consistent style)
- [ ] Dynamic Type supported

#### Testing Checklist
- [ ] VoiceOver walkthrough
- [ ] Large text size tested
- [ ] Dark mode verified
- [ ] Accessibility Inspector audit passed

---

## 📊 Progress Tracking

### Current Status
**Overall Progress:** 0% (Not Started)

| Sprint | Progress | Completed | Total | Status |
|--------|----------|-----------|-------|--------|
| Sprint 1 | 0% | 0 | 25+ tasks | 🔜 Not Started |
| Sprint 2 | 0% | 0 | 15+ tasks | ⏸️ Pending |
| Sprint 3 | 0% | 0 | 12+ tasks | ⏸️ Pending |

### Session Continuity Notes

#### Current Sprint: None
**Status:** 🔜 Ready to Start (after v2.0 major features)
**Next Task:** Begin Sprint 1 - Add accessibility to DSPrimaryButton

#### Session Handoff Template
When starting a new HIG improvement session:
```
Current Sprint: [Sprint 1/2/3]
Completed Tasks: [List of completed items]
Current Task: [What you're working on]
Blockers: [Any issues preventing progress]
Next Steps: [1-3 immediate next actions]
Files Changed: [List of modified files]
Testing Done: [VoiceOver/manual tests completed]
```

### Sprint Status Indicators
- 🔜 Not Started - Ready to begin when scheduled
- 🏃 In Progress - Currently working on tasks
- ✅ Completed - All tasks done, Definition of Done met
- ⏸️ Pending - Waiting for previous sprint or other dependencies
- ⚠️ Blocked - Cannot proceed due to external blocker

---

## 🎯 Success Metrics

### Quantitative
- **HIG Compliance Score:** 82% → 95%+
- **Accessibility Coverage:** 0% → 100% (all interactive components)
- **Touch Target Compliance:** ~90% → 100%
- **Color Contrast Compliance:** Unknown → 100% (WCAG AA)

### Qualitative
- **VoiceOver Usability:** Not usable → Fully navigable
- **Haptic Feedback:** None → Natural and helpful
- **User Feedback:** TBD (collect post-implementation)
- **App Store Review:** No accessibility rejections

### Testing Benchmarks
- [ ] Complete workout session with VoiceOver only
- [ ] Log nutrition with VoiceOver only
- [ ] Navigate entire app with VoiceOver
- [ ] Use app with Largest text size
- [ ] Use app in dark mode exclusively

---

## 🚀 Future Enhancements (Post v2.x)

### Potential v3.0 Accessibility Features
- [ ] Voice Control optimization
- [ ] Switch Control support
- [ ] Reduce Motion support (custom animations)
- [ ] Guided Access optimization
- [ ] Accessibility shortcuts configuration

### Advanced HIG Compliance
- [ ] Custom accessibility actions (`.accessibilityAction()`)
- [ ] Accessibility custom content (`.accessibilityCustomContent()`)
- [ ] Accessibility rotor support
- [ ] Accessibility notifications for state changes

### Internationalization HIG
- [ ] RTL (Right-to-Left) layout support
- [ ] Localized accessibility strings
- [ ] Cultural accessibility considerations

---

## ⚠️ Important Notes

### Why Low Priority?
HIG improvements are marked as low priority because:
1. **v1.0 already has 82% compliance** (app is functional and approved)
2. **v2.0 major features first** (HealthKit, Watch, Cloud are higher user value)
3. **No critical accessibility bugs reported** (no user complaints yet)
4. **Better done incrementally** (integrate with v2 features as built)

### Why Still Important?
Despite low priority, HIG compliance matters because:
1. **Legal/ethical obligation** (accessibility is a right, not a feature)
2. **10-15% user base** (vision/motor impaired users)
3. **App Store reputation** (Apple values accessibility highly)
4. **Future-proofing** (easier to maintain than retrofit)

### Integration Strategy
**Recommended approach:**
- Sprint 1 (Critical Accessibility) → Do between v2.0 and v2.1
- Sprint 2 (UX Polish) → Do during v2.1 development
- Sprint 3 (Documentation) → Do before v2.2 release

**OR** (Preferred):
- Build new v2 features HIG-ready from start
- Retrofit v1 components during polish sprints
- Document as you go

---

## 📝 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-03 | Initial HIG sprint plan created | Burak (with Claude Code) |

---

**Next Action:** Wait for v2.0 major features completion, then begin Sprint 1

**Estimated Start Date:** Post v2.0 release (HealthKit, Watch, Cloud complete)

**Target Completion:** v2.2 release
