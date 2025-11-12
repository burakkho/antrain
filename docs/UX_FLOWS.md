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

## Profile Flow (v1.2)

### Navigation Structure

```
┌─────────────────────────────────────────┐
│ Profile                    [⚙️ Settings] │
├─────────────────────────────────────────┤
│ Profile                                  │
│ • Name                         [Edit >] │
│ • Height                       [Edit >] │
│ • Gender                       [Edit >] │
│ • Date of Birth                [Edit >] │
│ • Activity Level               [Edit >] │
├─────────────────────────────────────────┤
│ Bodyweight Tracking                      │
│ • Current Weight: 75 kg                 │
│ • [Add Weight Entry]                     │
│ • [View Weight History >]                │
└─────────────────────────────────────────┘
```

### Profile Tab (4th Tab in TabBar)

**Icon:** `person.fill` (SF Symbol)

**Sections:**
1. **Profile Information**
   - Name → ProfileNameEditorSheet
   - Height → ProfileHeightEditorSheet (cm/inches based on weight unit)
   - Gender → ProfileGenderEditorSheet (picker)
   - Date of Birth → ProfileDateOfBirthEditorSheet (calendar picker)
   - Activity Level → ProfileActivityLevelEditorSheet (picker with descriptions)

2. **Bodyweight Tracking**
   - Current Weight display
   - Add Weight Entry → ProfileBodyweightEntrySheet (weight, date, notes)
   - View Weight History → ProfileBodyweightHistorySheet (list with delete)

**Toolbar:**
- Settings icon (⚙️) → Opens SettingsView as fullScreenCover

---

## Settings Flow (v1.2)

### Access Points

Settings is now accessed via **fullScreenCover** from:
- Home Tab → Toolbar gear icon (⚙️)
- Profile Tab → Toolbar gear icon (⚙️)

### Navigation Structure

```
┌─────────────────────────────────────────┐
│ [X] Settings                             │
├─────────────────────────────────────────┤
│ Notifications                            │
│ • Workout Reminders      [Toggle]       │
│ • Time                   [09:00]         │
│ • Active Days            [M T W T F]    │
├─────────────────────────────────────────┤
│ Preferences                              │
│ • Weight Unit        [Kilograms ▼]      │
│ • Language          [English ▼]         │
│ • Theme             [System ▼]          │
├─────────────────────────────────────────┤
│ About                                    │
│ • Version           1.2.0               │
└─────────────────────────────────────────┘
```

**Presentation:** fullScreenCover (modal)
**Dismissal:** X button (top-left toolbar)

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

### Tab Bar Structure (v1.3)

```
┌─────────────────────────────────────────────────┐
│          [Tab Bar - 5 Tabs]                     │
├─────────────────────────────────────────────────┤
│  Home  │  Workouts  │  Nutrition  │  AI Coach  │  Profile  │
└─────────────────────────────────────────────────┘
```

**1. Home Tab** (Icon: house.fill)
- Root: HomeView
- Quick actions lead to other tabs
- Toolbar: Settings icon (⚙️) → fullScreenCover SettingsView

**2. Workouts Tab** (Icon: dumbbell.fill)
- Root: WorkoutsView (segmented control for History/Templates/Programs)
- Tap workout → WorkoutDetailView (push)
- "Start Workout" button → LiftingSessionView (full screen modal)

**3. Nutrition Tab** (Icon: fork.knife)
- Root: DailyNutritionView
- Date picker to change day
- Add food → FoodSearchView (sheet modal)
- Settings icon → NutritionSettingsView (sheet)

**4. AI Coach Tab** (Icon: brain / sparkles) - NEW in v1.3
- Root: AICoachView
- Chat interface with AI fitness coach
- Context-aware coaching (workout data, nutrition, programs)
- Quick action chips for common questions
- Persistent chat history
- Toolbar: Clear chat button (trash icon)

**5. Profile Tab** (Icon: person.fill) - NEW in v1.2
- Root: ProfileView
- Shows: Personal info (name, height, gender, DOB, activity level)
- Shows: Bodyweight tracking with history
- Edit fields → Sheet modals (ProfileNameEditorSheet, etc.)
- Toolbar: Settings icon (⚙️) → fullScreenCover SettingsView

**Settings (fullScreenCover)** - Changed in v1.2
- Not in tab bar anymore
- Accessed from Home and Profile toolbar
- Contains: App preferences only (notifications, theme, language, version)
- Dismissal: X button (top-left)

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

## Workout Templates Flow

### Overview

Templates sistemi kullanıcıların favori workout'larını kaydetmesini ve hızlıca yeniden kullanmasını sağlar.

### Entry Points

1. **WorkoutsView → "My Templates" Section**
   - Quick access cards: Browse, Start from Template, Create
2. **Templates Tab**
   - Full template list with search and filtering
3. **LiftingSessionView**
   - "Start from Template" button when no exercises
4. **WorkoutSummaryView**
   - "Save as Template" button after completing workout

---

### Flow 1: Browse Templates

```
┌─────────────────────────────────────────┐
│ Templates                        [+]     │  ← Create button (top-right)
├─────────────────────────────────────────┤
│ [Search bar]                             │
├─────────────────────────────────────────┤
│ Categories (horizontal scroll)           │
│ [All] [Strength] [Hypertrophy] ...      │  ← Filter chips
├─────────────────────────────────────────┤
│ My Templates                             │
│ ┌─────────────────────────────────────┐│
│ │ 💪 My Upper Body                    ││
│ │ Strength • 5 exercises              ││
│ │ Last used: 2 days ago              ││  ← User template
│ └─────────────────────────────────────┘│
│                                          │
│ Presets                                  │
│ ┌─────────────────────────────────────┐│
│ │ 🏋️ Powerlifting - Squat Day        ││
│ │ Strength • 5 exercises              ││
│ │ [Preset badge]                      ││  ← Preset template
│ └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

**User Actions:**

**Search:**
- Type in search bar → Real-time filter by template name
- Works with category filter (combined filtering)

**Category Filter:**
- Tap chip → Show only templates in that category
- "All" chip resets filter
- Active chip highlighted

**Tap Template Card:**
- Navigate to TemplateDetailView
- Shows full exercise list, metadata, actions

**Swipe Actions on User Templates:**
- Swipe left → Duplicate, Edit, Delete
- Preset templates: only Duplicate available

**Empty States:**
- No templates: "Create your first template" CTA
- No results from search: "No templates found" message
- Filtered category empty: "No {category} templates" message

---

### Flow 2: Create Template (3-Step Wizard)

```
Step 1: Template Info
┌─────────────────────────────────────────┐
│ < Back    Create Template    Cancel     │
├─────────────────────────────────────────┤
│ Step 1 of 3                              │
├─────────────────────────────────────────┤
│ Template Name                            │
│ ┌─────────────────────────────────────┐│
│ │ [Text field]                        ││
│ └─────────────────────────────────────┘│
│                                          │
│ Category                                 │
│ ┌───────┐ ┌───────┐ ┌───────┐         │
│ │ 💪    │ │ 🏋️   │ │ 🤸    │         │
│ │Strength│ │Hyper │ │Calis │         │  ← Grid picker
│ └───────┘ └───────┘ └───────┘         │
│                                          │
│           [Continue →]                   │  ← Disabled until valid
└─────────────────────────────────────────┘

Step 2: Select Exercises
┌─────────────────────────────────────────┐
│ < Back    Create Template    Cancel     │
├─────────────────────────────────────────┤
│ Step 2 of 3                              │
├─────────────────────────────────────────┤
│ Selected: 3 exercises                    │
│                                          │
│ [Search exercises...]                    │
│                                          │
│ Barbell                                  │
│ ☑ Barbell Bench Press                   │
│ ☑ Barbell Back Squat                    │
│ ☐ Barbell Deadlift                      │  ← Multi-select
│                                          │
│ Dumbbell                                 │
│ ☑ Dumbbell Shoulder Press               │
│                                          │
│           [Continue →]                   │  ← Disabled if empty
└─────────────────────────────────────────┘

Step 3: Configure Sets & Reps
┌─────────────────────────────────────────┐
│ < Back    Create Template    Cancel     │
├─────────────────────────────────────────┤
│ Step 3 of 3                              │
├─────────────────────────────────────────┤
│ 1. Barbell Bench Press                   │
│    Sets: [4 ▼]  Reps: [8] - [12]       │
│    Notes: [Optional...]                  │
│ ─────────────────────────────────────   │
│ 2. Barbell Back Squat                    │
│    Sets: [4 ▼]  Reps: [6] - [10]       │
│    Notes: [Optional...]                  │
│ ─────────────────────────────────────   │
│ 3. Dumbbell Shoulder Press              │
│    Sets: [3 ▼]  Reps: [10] - [12]      │
│    Notes: [Optional...]                  │
│                                          │
│           [Create Template]              │
└─────────────────────────────────────────┘
```

**State Transitions:**

```
[Step 1: Info]
    ↓ name valid & category selected
[Step 2: Exercises]
    ↓ at least 1 exercise selected
[Step 3: Configure]
    ↓ all configs valid
[Save] → TemplatesView (toast: "Template created")
```

**Validation:**
- Step 1: Name required, must be unique (case-insensitive)
- Step 2: Minimum 1 exercise
- Step 3: repMin <= repMax for all exercises

**Cancel Behavior:**
- Tap Cancel → Confirmation alert: "Discard template?"
- Tap Back from Step 1 → Same as Cancel

**Edit Template:**
- Same flow, pre-filled with existing data
- Button text: "Update Template" instead of "Create"
- If preset template → Create copy, don't edit original

---

### Flow 3: Start Workout from Template

```
Entry: WorkoutsView → "Start from Template" card
       OR LiftingSessionView → "Start from Template" button

┌─────────────────────────────────────────┐
│ Select Template              [×]         │  ← Sheet presentation
├─────────────────────────────────────────┤
│ [Search...]                              │
├─────────────────────────────────────────┤
│ Recent                                   │
│ ┌─────────────────────────────────────┐│
│ │ 💪 My Upper Body                    ││
│ │ Used 2 days ago                     ││  ← Recently used
│ └─────────────────────────────────────┘│
│                                          │
│ All Templates                            │
│ [Category filter chips...]               │
│                                          │
│ ┌─────────────────────────────────────┐│
│ │ 🏋️ Powerlifting - Squat Day        ││  ← Tap to select
│ └─────────────────────────────────────┘│
│ ┌─────────────────────────────────────┐│
│ │ 💪 PPL - Push Day                   ││
│ └─────────────────────────────────────┘│
└─────────────────────────────────────────┘

↓ Tap template

┌─────────────────────────────────────────┐
│ Active Workout          [Finish] [...]   │
├─────────────────────────────────────────┤
│ Powerlifting - Squat Day                 │  ← Loaded from template
├─────────────────────────────────────────┤
│ 1. Barbell Back Squat                    │
│    Set 1: [ ] reps  [  ] kg             │  ← Pre-populated structure
│    Set 2: [ ] reps  [  ] kg             │
│    Set 3: [ ] reps  [  ] kg             │
│    Set 4: [ ] reps  [  ] kg             │
│                                          │
│ 2. Barbell Front Squat                   │
│    Set 1: [ ] reps  [  ] kg             │
│    ...                                   │
└─────────────────────────────────────────┘
```

**Loading Logic:**

1. User selects template
2. Sheet dismisses
3. LiftingSessionViewModel.loadFromTemplate():
   - Clear existing exercises
   - For each TemplateExercise:
     - Fetch Exercise from library by UUID
     - Create WorkoutExercise
     - Create WorkoutSets (setCount times, pre-fill repRangeMin)
   - Add to workout
4. Mark template.lastUsedAt = now
5. User can modify as needed (changes not saved to template)

**Error Handling:**
- Exercise not found by UUID → Skip exercise, log warning
- Template exercises empty → Show error, don't load

---

### Flow 4: Save Workout as Template

```
Entry: WorkoutSummaryView (after finishing workout)

┌─────────────────────────────────────────┐
│ Workout Summary                          │
├─────────────────────────────────────────┤
│ Duration: 1h 23m                         │
│ Exercises: 5                             │
│ Total Volume: 4,250 kg                   │
├─────────────────────────────────────────┤
│ 1. Barbell Bench Press                   │
│    4 sets completed                      │
│ ...                                      │
├─────────────────────────────────────────┤
│ [Save as Template]                       │  ← New button
│ [Done]                                   │
└─────────────────────────────────────────┘

↓ Tap "Save as Template"

┌─────────────────────────────────────────┐
│ Save as Template            [×]          │  ← Sheet
├─────────────────────────────────────────┤
│ Template Name                            │
│ ┌─────────────────────────────────────┐│
│ │ Workout on Nov 3                    ││  ← Auto-generated name
│ └─────────────────────────────────────┘│
│                                          │
│ Category                                 │
│ [Strength ▼]                             │
│                                          │
│ Exercises (5)                            │
│ ✓ Barbell Bench Press (4 sets, 8-10 reps)│
│ ✓ Barbell Back Squat (4 sets, 6-8 reps) │  ← Extracted from workout
│ ✓ Dumbbell Shoulder Press (3×10-12)     │
│ ...                                      │
│                                          │
│ [Save Template]                          │
└─────────────────────────────────────────┘
```

**Extraction Logic:**

1. For each WorkoutExercise:
   - exerciseId = exercise.id
   - exerciseName = exercise.name
   - setCount = number of completed sets
   - repRangeMin = min(reps across all sets)
   - repRangeMax = max(reps across all sets)
2. Create WorkoutTemplate with these TemplateExercises
3. Save to repository
4. Show toast: "Template created"

**Edge Cases:**
- Incomplete sets → Only count completed sets
- Single set completed → repRangeMin = repRangeMax = reps
- Name collision → Append "(2)" to name

---

### Flow 5: Template Detail View

```
┌─────────────────────────────────────────┐
│ < Back    Powerlifting - Squat Day  [...] │
├─────────────────────────────────────────┤
│ [Preset] Strength • 5 exercises          │  ← Metadata
│ Created: Nov 1, 2025                     │
│ Last used: 2 days ago                    │
├─────────────────────────────────────────┤
│ Exercises                                │
│                                          │
│ 1. Barbell Back Squat                    │
│    4 sets × 3-5 reps                     │
│                                          │
│ 2. Barbell Front Squat                   │
│    3 sets × 5-8 reps                     │
│                                          │
│ 3. Leg Press                             │
│    3 sets × 8-12 reps                    │
│                                          │
│ 4. Barbell Bulgarian Split Squat         │
│    3 sets × 6-8 reps                     │
│                                          │
│ 5. Leg Curl (Lying)                      │
│    3 sets × 10-12 reps                   │
├─────────────────────────────────────────┤
│ [Start Workout]                          │  ← Primary action
│                                          │
│ [Edit]  [Duplicate]  [Delete]            │  ← Secondary actions
└─────────────────────────────────────────┘
```

**Actions:**

**Start Workout:**
- Same as Flow 3: Load template into LiftingSessionView
- Dismiss detail view, navigate to active workout

**Edit (User Templates Only):**
- Navigate to EditTemplateView (same as CreateTemplateFlow)
- Pre-fill all fields
- Save updates template

**Edit (Preset Templates):**
- Show alert: "Preset templates can't be edited. Create a copy?"
- If yes → Duplicate with same name (add "(Copy)")

**Duplicate:**
- Create copy with "(Copy)" suffix
- Navigate to duplicated template detail
- Show toast: "Template duplicated"

**Delete (User Templates Only):**
- Confirmation alert: "Delete template? This can't be undone."
- If confirmed → Delete, navigate back
- Show toast: "Template deleted"

**Delete (Preset Templates):**
- Button disabled, show tooltip: "Preset templates can't be deleted"

**Menu (...):**
- Share template (future)
- View statistics (future)

---

### Template Navigation Architecture

```
WorkoutsView
    ├─→ TemplatesView (tab/navigation)
    │       ├─→ TemplateDetailView
    │       │       ├─→ EditTemplateView (sheet)
    │       │       └─→ LiftingSessionView (load template)
    │       └─→ CreateTemplateFlow (sheet)
    │
    └─→ TemplateQuickSelectorView (sheet)
            └─→ LiftingSessionView (load template)

LiftingSessionView
    └─→ TemplateQuickSelectorView (sheet)
            └─→ Load template into current session

WorkoutSummaryView
    └─→ SaveWorkoutAsTemplateView (sheet)
            └─→ Create template, dismiss
```

---

### State Management

**TemplatesViewModel (@Observable):**
- templates: [WorkoutTemplate]
- searchQuery: String
- selectedCategory: TemplateCategory?
- isLoading: Bool
- error: Error?

**Operations:**
- loadTemplates() async
- filterTemplates(category:) async
- searchTemplates(query:)
- deleteTemplate(id:) async
- duplicateTemplate(id:) async

**CreateTemplateViewModel (@Observable):**
- currentStep: Int (1-3)
- templateName: String
- selectedCategory: TemplateCategory?
- selectedExercises: [Exercise]
- exerciseConfigs: [UUID: ExerciseConfig]
- isValid: Bool

**SaveWorkoutAsTemplateViewModel (@Observable):**
- workout: Workout
- templateName: String
- selectedCategory: TemplateCategory
- extractedExercises: [TemplateExerciseData]

---

### Loading & Error States

**TemplatesView:**
- Loading: Skeleton cards (3-4 placeholders)
- Empty: "No templates yet. Create your first template!" CTA
- Error: Alert with retry button

**Template Quick Selector:**
- Loading: Spinner in center
- Empty recent: Hide "Recent" section
- Error: Show error message, retry button

**Template Detail:**
- Loading exercises: Spinner
- Exercise not found: "Exercise deleted" placeholder
- Error loading: Alert with dismiss

---

### Accessibility

**VoiceOver Labels:**
- Template cards: "{template name}, {category}, {exercise count} exercises, {last used}"
- Category chips: "{category name}, filter button"
- Actions: "Start workout from template", "Edit template", etc.

**Dynamic Type:**
- All text respects user font size
- Cards expand vertically to accommodate larger text

**Haptic Feedback:**
- Template selected: Light impact
- Template created/deleted: Success notification
- Error: Error notification

---

## AI Coach Flow (v1.3)

### Overview

AI Coach tab provides real-time chat with an AI fitness coach powered by Google Gemini 2.5 Flash-Lite. The AI has full context of user's workout history, nutrition data, active training programs, and personal records.

### Layout Structure

```
┌─────────────────────────────────────────┐
│ AI Coach                  [🗑️ Clear]   │  ← Toolbar
├─────────────────────────────────────────┤
│                                          │
│ [Scroll Area - Chat Messages]           │
│                                          │
│  AI: Hi! How can I help you today?      │  ← AI message (gray, left)
│                                          │
│          User: How's my progress?       │  ← User message (blue, right)
│                                          │
│  AI: You've made great progress!...     │  ← AI response with typewriter
│                                          │
│  [Quick Action Chips]                    │  ← Suggestion chips
│  • How's my progress?                   │
│  • Suggest a workout                    │
│  • Nutrition advice                     │
│                                          │
├─────────────────────────────────────────┤
│ [Text Input Field]            [Send]    │  ← Input bar (bottom)
└─────────────────────────────────────────┘
```

### High-Level Flow

```
[AI Coach Tab]
    │
    ├─ Empty State (No messages)
    │   • Welcome message from AI
    │   • Quick action chips visible
    │
    ├─ User types message
    │   ▼
    │  [Message input field active]
    │   ▼
    │  User taps "Send"
    │   ▼
    │  [User message appears]
    │   ▼
    │  [API call in progress]
    │   • "AI is typing..." indicator
    │   • User message saved to SwiftData
    │   ▼
    │  [AI response received]
    │   • Typewriter animation shows response
    │   • AI message saved to SwiftData
    │   ▼
    │  [Chat updated, scroll to bottom]
    │
    └─ User taps "Clear Chat"
        ▼
       [Confirmation alert]
        ▼
       All messages cleared from SwiftData
```

### State Diagram

```
┌─────────────────────────────────────────────────┐
│              AI COACH CHAT STATES                │
└─────────────────────────────────────────────────┘

[Initial Load]
  │
  │ Load chat history from SwiftData
  │
  ▼
[Empty State]
  │
  │ No messages → Show welcome message
  │
  ▼
[Chat Idle]
  │
  │ User types message
  │
  ▼
[Message Input - Has Text]
  │
  │ User taps "Send"
  │
  ▼
[Sending Message]
  │
  ├─ User message added to UI
  ├─ User message saved to SwiftData
  ├─ Build WorkoutContext (async)
  ├─ Send API request to Gemini
  │
  ▼
[Waiting for Response]
  │
  │ Show "AI is typing..." indicator
  │
  ├─ Success → [Displaying AI Response]
  │    │
  │    ├─ Typewriter animation starts
  │    ├─ User can tap to skip animation
  │    ├─ AI message saved to SwiftData
  │    │
  │    ▼
  │   [Chat Idle] (ready for next message)
  │
  └─ Error → [Error State]
       │
       ├─ Show error banner
       ├─ User can retry
       │
       ▼
      [Chat Idle]
```

### Detailed User Actions

**1. Open AI Coach Tab**
- **Entry:** Tap AI Coach tab in TabBar
- **Action:** Load chat history from SwiftData
- **UI:**
  - If no messages: Show welcome message + quick action chips
  - If has messages: Show full chat history, scroll to bottom
- **Loading:** Skeleton view while loading (< 1s typically)

**2. Send Message**
- **Trigger:** User types message and taps "Send" or presses Return
- **Validation:**
  - Message not empty (trimmed)
  - Message ≤ 1000 characters
- **Flow:**
  1. Disable input field
  2. Add user message to chat (timestamp: "Just now")
  3. Save user message to SwiftData
  4. Show "AI is typing..." indicator
  5. Build WorkoutContext (30-day workouts, PRs, nutrition, program)
  6. Send API request with:
     - User message
     - WorkoutContext
     - Last 10 messages (chat history)
     - isNewUser flag
  7. Wait for API response (typically < 3s)
  8. Receive AI response
  9. Start typewriter animation (0.02s per character)
  10. Save AI message to SwiftData
  11. Scroll to bottom
  12. Re-enable input field

**3. Tap Quick Action Chip**
- **Trigger:** User taps a suggestion chip
- **Action:** Populate input field with chip text
- **Behavior:**
  - Input field gains focus
  - User can edit before sending
  - Keyboard appears

**Quick Action Examples:**
- "How's my progress this month?"
- "Suggest a workout for today"
- "What should I eat for muscle gain?"
- "Analyze my last workout"
- "Should I take a deload week?"

**4. Skip Typewriter Animation**
- **Trigger:** User taps anywhere on AI message during animation
- **Action:** Complete animation instantly, show full message
- **Rationale:** User control, faster reading for long responses

**5. Clear Chat**
- **Trigger:** Tap trash icon in toolbar
- **Confirmation:** Alert "Clear all chat history? This cannot be undone."
- **If confirmed:**
  - Delete all ChatMessage records from SwiftData
  - Delete ChatConversation record
  - Reset chat to empty state
  - Show welcome message

**6. View Message Timestamp**
- **Hover/Long Press:** Show full timestamp
- **Display:** Relative time ("2h ago", "Yesterday", "Nov 3")

### Edge Cases & Handling

| Scenario | Behavior | Rationale |
|----------|----------|-----------|
| API request fails | Show error banner, keep user message, allow retry | Preserve user input |
| Network offline | Error: "No internet connection" | Clear messaging |
| Rate limit exceeded | Error: "Too many requests, wait X seconds" | Show retry timer |
| Message too long (>1000 chars) | Validation error, disable send | Prevent API rejection |
| App backgrounded during API call | Continue request, show response on return | Background URLSession |
| Empty user message | Send button disabled | Prevent empty messages |
| AI response empty | Error: "Invalid response from AI" | Fallback message |
| WorkoutContext build fails | Send message with empty context | Graceful degradation |

### Error States

**Error Banner Display:**
```
┌─────────────────────────────────────────┐
│ ⚠️ Error: No internet connection       │  ← Red banner
│                                   [Retry]│
└─────────────────────────────────────────┘
```

**Error Types:**
- **Network Errors:**
  - "No internet connection"
  - "Request timed out, try again"
- **API Errors:**
  - "API rate limit exceeded, wait X seconds"
  - "Invalid API key, contact support"
  - "Server error, try again later"
- **Validation Errors:**
  - "Message too long (max 1000 characters)"
  - "Message cannot be empty"

**Retry Behavior:**
- Network errors: Retry button re-sends last message
- Rate limits: Show countdown timer
- Server errors: Retry with exponential backoff

### Loading States

**1. Chat History Loading:**
- Skeleton placeholders for messages
- Duration: < 1s (SwiftData query)

**2. API Request Loading:**
- "AI is typing..." with animated dots
- Duration: 2-5s typically
- User can scroll, read previous messages

**3. Context Building:**
- Happens in background (async)
- No loading indicator (seamless)
- Duration: < 1s

### Empty State

**No Messages:**
```
┌─────────────────────────────────────────┐
│                                          │
│         🤖                               │
│                                          │
│  Hi! I'm your AI fitness coach.         │
│  Ask me about your workouts,            │
│  nutrition, or training advice.         │
│                                          │
│  [Quick Action Chips]                   │
│  • How's my progress?                   │
│  • Suggest a workout                    │
│  • Nutrition advice                     │
│                                          │
└─────────────────────────────────────────┘
```

### Typewriter Animation

**Behavior:**
- Characters appear one-by-one
- Speed: 0.02s per character
- Smooth, natural reading pace
- Can be skipped by tapping

**Why Typewriter?**
- Feels more conversational
- Gives impression of "thinking"
- Better UX for long responses
- Industry standard (ChatGPT, Claude)

### Context Awareness

AI Coach has access to:

**Workout Data (30 days):**
- Workout count, frequency, duration
- Volume trends (total kg lifted)
- Exercise breakdown by muscle group
- Detailed last 5 workouts (sets, reps, weights)

**Active Training Program:**
- Program name, difficulty, progress (Week X/Y)
- Current week workouts (exercises, sets, reps)
- Next week preview
- Deload indicators, intensity/volume modifiers

**Personal Records:**
- All PRs with 1RM calculations
- Recent PRs (last 30 days)
- Progress trends

**Nutrition (7 days):**
- Daily calorie/macro goals
- Adherence percentage
- Average intake vs goals
- Bodyweight trend correlation

**User Profile:**
- Name, age, gender
- Height, weight, BMI
- Activity level
- Fitness goals (muscle gain, fat loss, etc.)

**Example Context-Aware Response:**
> "Burak, you've trained 4 times this week—great consistency! Your volume is up 12% from last month. However, I noticed you're in a deload week (Week 8 of PPL program) with 70% volume modifier. Focus on recovery, don't push for PRs this week."

### Accessibility

**VoiceOver Labels:**
- Messages: "User message: [content], sent [timestamp]"
- Input field: "Type your message to AI coach"
- Send button: "Send message to AI coach"
- Quick chips: "[Chip text], suggestion button"

**Dynamic Type:**
- All text respects user font size
- Chat bubbles expand to fit text
- Minimum touch target: 44x44pt

**Haptic Feedback:**
- Message sent: Light impact
- AI response received: Success notification
- Error: Error notification

### Performance

**Optimizations:**
- Only last 10 messages sent to API (token limit)
- Chat history lazy loaded (pagination if >100 messages)
- SwiftData background context for saves
- Cancel API request if user leaves tab

**Metrics:**
- Chat history load: < 1s
- API response time: 2-5s (average)
- Typewriter animation: 0.02s/char (skippable)

### Future Enhancements (Post-v1.3)

**Planned Features:**
- Voice input (speech-to-text)
- Voice output (text-to-speech)
- Message search
- Export chat history
- Conversation branching
- Image upload (form check)
- Workout plan generation
- Meal photo analysis

---

**Son Güncelleme:** 2025-11-10
**Eklenen:** Template flows (v1.1 feature), AI Coach flows (v1.3 feature)
**Dosya Boyutu:** ~350 satır
**Token Efficiency:** ASCII diagrams, comprehensive UX documentation
