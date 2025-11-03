# UX Flows - Antrain

**Amaç:** Kullanıcı yolculukları, state transitions, navigation patterns, edge case handling

**Format:** ASCII flow diagrams + user action scenarios

**Son Güncelleme:** 2025-02-11

---

## Home Screen

### Layout Structure

```
┌─────────────────────────────────────────┐
│ Home                                     │
├─────────────────────────────────────────┤
│ Merhaba, Burak                          │  ← Welcome message (time-based)
├─────────────────────────────────────────┤
│ Quick Actions                            │
│ [Start Workout] [Log Cardio] [Log MetCon]│ ← 3 buttons
├─────────────────────────────────────────┤
│ Today's Nutrition                       │  ← Macro summary (tappable)
│ • Calories: 1450 / 2000 kcal           │
│ • Protein: 85 / 150g                   │
│ • Carbs: 150 / 200g                    │
│ • Fats: 45 / 65g                       │
├─────────────────────────────────────────┤
│ Personal Records                        │  ← Top 5 PRs
│ • Barbell Bench Press: 100kg (2d ago)  │
│ • Barbell Squat: 120kg (1w ago)        │
├─────────────────────────────────────────┤
│ Recent Workouts                         │  ← Last 5 workouts
│ • Lifting - Today 10:00 AM             │
│ • Cardio - Yesterday                   │
└─────────────────────────────────────────┘
```

### Components

**1. Welcome Message**
- Format: `{Greeting}, {Name}`
- Greeting based on time:
  - 05:00-12:00: "Günaydın"
  - 12:00-18:00: "Merhaba"
  - 18:00-22:00: "İyi akşamlar"
  - 22:00-05:00: "Merhaba"
- Name from UserProfile (falls back to "Hoşgeldin" if empty)

**2. Quick Actions**
- `DailyWorkoutSummary` (reusable component from Workouts feature)
- `DailyNutritionSummary` (reusable component from Nutrition feature)
- Both components update automatically on data changes

**3. Personal Records**
- Shows top 5 PRs by weight
- Auto-updates when workout saved
- Trophy icon + exercise name + weight + relative date

**4. Recent Workouts**
- Shows last 5 workouts
- Tappable → WorkoutDetailView
- Loading/Error/Empty states

### User Actions

**Tap "Today's Nutrition"**
- Action: Switch to Nutrition tab
- Mechanism: NotificationCenter post "SwitchToNutritionTab"

**Tap Quick Action Button**
- "Start Workout" → Full screen LiftingSessionView
- "Log Cardio" → Sheet CardioLogView
- "Log MetCon" → Sheet MetConLogView

**Pull to Refresh**
- Refreshes both workout data and nutrition data
- Uses `HomeViewModel.loadData()`

---

## Settings Flow

### Navigation Structure

```
┌─────────────────────────────────────────┐
│ Settings                                 │
├─────────────────────────────────────────┤
│ Profile                                  │
│ • Name                         [Edit >] │
│ • Height                       [Edit >] │
│ • Gender                       [Edit >] │
├─────────────────────────────────────────┤
│ Preferences                              │
│ • Weight Unit        [Kilograms ▼]     │
│ • Language          [English ▼]        │
│ • Theme             [System ▼]         │
├─────────────────────────────────────────┤
│ About                                    │
│ • Version           1.0.0              │
└─────────────────────────────────────────┘
```

### Features Moved to Nutrition Tab

**Previous Location:** Settings
**New Location:** Nutrition Tab → Settings Button

**Rationale:**
- Better feature separation
- Nutrition goals belong with nutrition data
- Body metrics (weight, BMI) related to nutrition/diet
- Settings tab now cleaner, general-purpose only

---

## Nutrition Settings Flow

### Navigation

```
[Nutrition Tab]
    │
    ├─ Tap Settings Icon (gear, top-left)
    │
    ▼
[Nutrition Settings Screen]
    │
    ├─ Daily Nutrition Goals
    │   ├─ Calories: 2000 kcal
    │   ├─ Protein: 150g
    │   ├─ Carbs: 200g
    │   └─ Fats: 65g
    │   └─ [Tap to Edit >]
    │
    ├─ Body Metrics
    │   ├─ Current Weight: 75kg
    │   ├─ BMI: 22.5 (Normal) ← Auto-calculated
    │   ├─ BMI Category: Normal (green)
    │   ├─ [Add Weight Entry]
    │   └─ [View Weight History >]
    │
    └─ [Done]
```

### State Diagram

```
[Nutrition Tab - Daily View]
  │
  │ Tap Settings Icon
  │
  ▼
[Nutrition Settings]
  │
  ├─ Tap "Edit Goals"
  │  ▼
  │ [Goals Editor Sheet]
  │   │
  │   ├─ Edit Calories/Protein/Carbs/Fats
  │   ├─ Tap "Save"
  │   │  ▼
  │   │ [Validate > Save > Dismiss]
  │   │
  │   └─ Tap "Cancel"
  │      ▼
  │     [Dismiss without saving]
  │
  ├─ Tap "Add Weight Entry"
  │  ▼
  │ [Bodyweight Entry Sheet]
  │   │
  │   ├─ Select Date
  │   ├─ Enter Weight (kg/lbs auto-converted)
  │   ├─ Add Notes (optional)
  │   ├─ Tap "Save"
  │   │  ▼
  │   │ [Convert to kg > Save > Recalc BMI > Dismiss]
  │   │
  │   └─ Tap "Cancel"
  │      ▼
  │     [Dismiss without saving]
  │
  └─ Tap "View Weight History"
     ▼
    [Weight History List]
      │
      ├─ Shows all entries (newest first)
      ├─ Swipe to delete
      └─ Tap "Done" → Dismiss
```

### BMI Calculation

**Formula:** BMI = weight (kg) / (height (m))²

**Requirements:**
- Height must be set in Profile
- Current weight must exist

**Categories & Colors:**
- < 18.5: "Underweight" (orange)
- 18.5-25: "Normal" (green)
- 25-30: "Overweight" (orange)
- \>= 30: "Obese" (red)

**Display:**
- BMI value: 1 decimal (e.g., "22.5")
- Category with color coding
- Auto-updates when weight or height changes

### User Actions

**Edit Nutrition Goals**
- Tap row → Sheet opens
- Edit 4 fields (Calories, Protein, Carbs, Fats)
- Save → Updates UserProfile
- HomeView auto-refreshes macro targets

**Add Weight Entry**
- Tap "Add Weight Entry"
- Enter weight (auto-converts lbs→kg if needed)
- Optional date + notes
- Save → Updates currentBodyweight
- BMI recalculates automatically

**View History**
- Shows all bodyweight entries
- Sorted by date (newest first)
- Swipe to delete
- Updates BMI when deleting current weight

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Height not set | BMI shows "Set height in Profile to see BMI" |
| No weight entries | BMI section hidden |
| Delete current weight | BMI uses next most recent entry |
| Weight unit changed | All displays auto-convert (storage always in kg) |

---

## Lifting Session Flow (Primary Feature)

### High-Level Flow

```
[Home Screen]
    │
    ├─ Tap "Start Workout" (lifting)
    │
    ▼
[Lifting Session - Empty State]
    │
    ├─ Tap "Add Exercise"
    │
    ▼
[Exercise Selection Modal]
    │
    ├─ Search/Browse exercises
    ├─ Tap exercise
    │
    ▼
[Lifting Session - Exercise Added]
    │
    ├─ Tap "Add Set" → Enter reps/weight
    ├─ Tap checkmark → Mark set complete
    ├─ Repeat for multiple sets
    ├─ Tap "Add Exercise" → Add more exercises
    │
    ├─ Tap "Finish Workout"
    │
    ▼
[Workout Summary Preview]
    │
    ├─ Tap "Save"
    │
    ▼
[Home Screen - Workout Saved]
```

### State Diagram

```
┌─────────────────────────────────────────────────┐
│              LIFTING SESSION STATES              │
└─────────────────────────────────────────────────┘

[Idle]
  │
  │ User taps "Start Workout"
  │
  ▼
[Active - Empty]
  │
  │ User adds exercise
  │
  ▼
[Active - Has Exercises]
  │
  │ User adds/completes sets
  │
  ├──────┐ (ongoing)
  │      │
  │      ▼
  │   [Active - Has Completed Sets]
  │
  │ User taps "Finish"
  │
  ▼
[Summary Preview]
  │
  ├─ User taps "Save"
  │  ▼
  │ [Saved - Navigate to Home]
  │
  ├─ User taps "Cancel"
  │  ▼
  │ [Discard Confirmation]
  │   │
  │   ├─ Confirm → [Discarded - Navigate to Home]
  │   └─ Cancel → [Summary Preview]
  │
  └─ [Edge: App Backgrounded]
      └─> Save as draft, restore on return
```

### Detailed User Actions

**1. Start Workout**
- **Entry:** HomeView → Tap "Start Lifting Workout" button
- **Action:** Create new Workout(type: .lifting, date: Date())
- **State:** LiftingSessionViewModel initialized
- **UI:** Navigate to LiftingSessionView (empty state)
- **Empty State Message:** "Egzersiz ekleyerek başlayın"

**2. Add Exercise**
- **Trigger:** Tap "Add Exercise" button
- **Action:** Present ExerciseSelectionView (modal sheet)
- **Search:** TextField with live search filtering
- **Categories:** Segmented picker (All, Barbell, Dumbbell, Bodyweight)
- **Selection:** Tap exercise → Add to workout.exercises → Dismiss modal
- **UI Update:** Exercise card appears in session view

**3. Add Set**
- **Trigger:** Tap "Add Set" on exercise card
- **UI:** New row appears with weight/reps TextFields
- **Focus:** Auto-focus on weight field (keyboard opens)
- **Input:**
  - Weight: NumberField (decimal, kg)
  - Reps: NumberField (integer)
- **Validation:**
  - Weight >= 0 (0 = bodyweight)
  - Reps > 0
- **Save:** Tap checkmark or "Done" on keyboard

**4. Complete Set**
- **Trigger:** Tap checkmark icon
- **Action:** WorkoutSet.isCompleted = true
- **UI:** Row turns green, checkmark filled
- **Behavior:** Duplicate set values to next set (convenience)

**5. Finish Workout**
- **Trigger:** Tap "Finish Workout" button
- **Validation:**
  - At least 1 exercise required
  - At least 1 completed set per exercise
- **If invalid:** Alert "En az 1 egzersiz ve 1 set gerekli"
- **If valid:** Navigate to Summary Preview

**6. Save Workout**
- **Trigger:** Tap "Save" on summary
- **Action:**
  - Calculate workout.duration
  - repository.save(workout)
  - Navigate to Home
- **Success:** Toast "Workout kaydedildi"
- **Error:** Alert with error message

### Edge Cases & Handling

| Scenario | Behavior | Rationale |
|----------|----------|-----------|
| User taps back button mid-workout | Confirmation dialog: "Workout kaydedilmemiş. Devam et?" | Prevent accidental data loss |
| App backgrounded during session | Auto-save as draft to UserDefaults | Recovery on return |
| App killed during session | Draft recovery on next launch | Data safety |
| No completed sets when finishing | Validation error + alert | Ensure data quality |
| Exercise deleted from library | Show "Deleted Exercise" placeholder | Handle library changes |
| Empty exercise name | Prevent add, show validation | Data integrity |

---

## Quick Log Flow (Cardio/MetCon)

### High-Level Flow

```
[Home Screen]
    │
    ├─ Tap "Log Cardio" or "Log MetCon"
    │
    ▼
[Quick Log Form]
    │
    ├─ Select type (run/bike for cardio, AMRAP/EMOM for metcon)
    ├─ Enter duration
    ├─ Enter distance/pace (cardio) or rounds/result (metcon)
    ├─ Add notes (optional)
    │
    ├─ Tap "Save"
    │
    ▼
[Home Screen - Workout Saved]
```

### State Diagram

```
[Idle]
  │
  │ User taps "Log Cardio/MetCon"
  │
  ▼
[Form - Empty]
  │
  │ User fills fields
  │
  ▼
[Form - Has Data]
  │
  │ User taps "Save"
  │
  ├─ Validation OK → [Saved]
  └─ Validation Error → Show error, stay in form
```

**Validation Rules:**
- Duration > 0
- Cardio: cardioType required
- MetCon: metconType required
- Distance/pace/rounds optional but validated if entered

---

## Nutrition Logging Flow

### High-Level Flow

```
[Home Screen]
    │
    ├─ Tap "Log Meal"
    │
    ▼
[Daily Nutrition View]
    │
    ├─ Tap "+ Add Food" on meal (Breakfast/Lunch/Dinner/Snack)
    │
    ▼
[Food Search View]
    │
    ├─ Search food library
    ├─ Tap food item
    │
    ▼
[Serving Amount Modal]
    │
    ├─ Enter serving amount (grams)
    ├─ Preview macros
    │
    ├─ Tap "Add"
    │
    ▼
[Daily Nutrition View - Food Added]
    │
    └─ Macros auto-calculated, progress rings update
```

### State Diagram

```
[Daily Nutrition - Current Day]
  │
  │ User taps meal "+ Add Food"
  │
  ▼
[Food Search]
  │
  │ User searches
  │
  ▼
[Search Results]
  │
  │ User taps food
  │
  ▼
[Serving Amount Modal]
  │
  ├─ User enters amount
  │
  ├─ Tap "Add"
  │  ▼
  │ [Food Added - Back to Daily View]
  │
  └─ Tap "Cancel"
     ▼
    [Back to Food Search]
```

**Auto-calculations:**
- Meal macros update (sum of food entries)
- Daily macros update (sum of all meals)
- Progress rings animate to new values

---

## Navigation Patterns

### Tab Bar Structure

```
┌────────────────────────────────────────┐
│          [Tab Bar - 4 Tabs]            │
├────────────────────────────────────────┤
│  Home  │  Workouts  │  Nutrition  │  Settings  │
└────────────────────────────────────────┘
```

**1. Home Tab**
- Root: HomeView
- Quick actions lead to other tabs

**2. Workouts Tab**
- Root: WorkoutHistoryView
- Tap workout → WorkoutDetailView (push)
- "Start Workout" button → LiftingSessionView (full screen modal)

**3. Nutrition Tab**
- Root: DailyNutritionView
- Date picker to change day
- Add food → FoodSearchView (sheet modal)

**4. Settings Tab**
- Root: SettingsView
- Profile → ProfileView (push)
- Goals → GoalsView (push)

### Modal Presentations

| Modal Type | Presentation | Dismiss Behavior |
|------------|--------------|------------------|
| Exercise Selection | Sheet (.medium) | Tap exercise → auto-dismiss |
| Food Search | Sheet (.large) | Add food → auto-dismiss |
| Lifting Session | Full Screen Cover | "Save" or "Cancel" button |
| Serving Amount | Sheet (.medium) | "Add" or "Cancel" button |

---

## Loading States

### Pattern: Skeleton Screens

**When to use:**
- Initial data load (workout history, nutrition log)
- Long operations (save with validation)

**Implementation:**
```swift
if viewModel.isLoading {
    SkeletonView() // Shimmer placeholder
} else if let data = viewModel.data {
    ContentView(data: data)
} else {
    EmptyStateView()
}
```

### Pattern: Inline Spinners

**When to use:**
- Button actions (save, delete)
- Quick operations

**Implementation:**
```swift
Button("Save") {
    await viewModel.save()
}
.disabled(viewModel.isLoading)
.overlay {
    if viewModel.isLoading {
        ProgressView()
    }
}
```

---

## Empty States

| Screen | Empty State Message | CTA |
|--------|---------------------|-----|
| Workout History | "Henüz antrenman kaydı yok\nİlk antrenmanını başlat!" | "Start Workout" button |
| Daily Nutrition | "Bugün henüz yemek kaydı yok\nİlk öğünü ekle!" | "+ Add Food" button |
| Lifting Session | "Egzersiz ekleyerek başlayın" | "Add Exercise" button |
| Exercise Library Search | "'\(query)' için sonuç bulunamadı" | "Clear Search" button |

---

## Error States

### Error Display Strategy

**User-Facing Errors:**
- **Alert Dialog:** Critical errors (save failed, validation error)
- **Toast:** Non-critical info (workout saved, food added)
- **Inline Error:** Form validation (red text under field)

**Error Message Format:**
```
[Clear Problem]
[User-Friendly Solution]

❌ Bad: "RepositoryError.saveFailed"
✅ Good: "Workout kaydedilemedi\nLütfen tekrar deneyin"
```

### Retry Strategy

**Failed Save:**
1. Show error alert
2. "Retry" button → repeat operation
3. "Cancel" button → return to form (data preserved)

**Failed Load:**
1. Show error view
2. "Retry" button → repeat fetch
3. Data preserved in ViewModel

---

## Confirmation Dialogs

| Action | Confirmation Required? | Message |
|--------|------------------------|---------|
| Cancel workout mid-session | YES | "Workout kaydedilmedi. Çıkmak istediğine emin misin?" |
| Delete workout | YES | "Bu workout silinecek. Emin misin?" |
| Delete food entry | NO | Just delete (can undo if needed) |
| Discard nutrition log | YES | "Bugünkü kayıtlar silinecek. Emin misin?" |
| Save workout | NO | Direct save |

---

## Keyboard Behavior

**Number Input Fields:**
- **Weight:** Decimal pad, auto-focus, "Done" button dismisses
- **Reps:** Number pad, "Done" button dismisses
- **Distance:** Decimal pad
- **Serving Amount:** Decimal pad

**Text Input Fields:**
- **Notes:** Default keyboard, return key = "Done"
- **Exercise Search:** Default keyboard, return key = "Search"

**Auto-Focus:**
- First empty field when adding set
- Search field when opening exercise selection

---

## Accessibility

**VoiceOver Labels:**
- Buttons: Describe action ("Add exercise", "Complete set")
- Text fields: Label + current value ("Weight, 80 kilograms")
- Exercise cards: "Exercise name, X sets completed"

**Dynamic Type:**
- All text respects user's font size preference
- Layout adapts to larger text sizes

**Haptic Feedback:**
- Set completed: Light impact
- Workout saved: Success notification
- Error: Error notification

---

**Son Güncelleme:** 2025-02-11
**Dosya Boyutu:** ~180 satır
**Token Efficiency:** ASCII diagrams, table-heavy
