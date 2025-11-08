# Antrain v1.2 - iOS 18+ Features

> Modern iOS capabilities for enhanced user experience

**Released:** November 8, 2025

---

## 🎯 What's New in v1.2

Antrain v1.2 brings modern iOS features that enhance the workout tracking experience:

### 🏠 Home Screen Widgets
Three widget sizes with beautiful gradient design and real workout data:
- **Small (2×2)**: Quick "Start Workout" button with app branding
- **Medium (4×2)**: Weekly workout count + large start button
- **Large (4×4)**: Comprehensive stats display with time and workout summary

**Features:**
- Real-time workout count from current week
- Smart display logic ("Let's start!" vs "X workouts")
- Deep link integration (`antrain://start-workout`)
- Auto-refresh on workout save and app launch
- Liquid Glass design with blue → purple gradient

**Documentation:** [WIDGET_README.md](./WIDGET_README.md)

---

### 🎤 Siri Shortcuts & App Intents
Voice control and Shortcuts app integration:

**Supported Commands:**
- 🇬🇧 "Hey Siri, start workout in Antrain"
- 🇹🇷 "Hey Siri, Antrain antrenmana başla"
- 🇪🇸 "Hey Siri, comenzar entrenamiento en Antrain"

**Features:**
- StartWorkoutIntent with tri-lingual support (EN, TR, ES)
- Shortcuts app integration
- Deep linking to home tab
- Siri entitlements enabled
- Custom app icon (dumbbell.fill)

**Documentation:** [APPINTENTS_README.md](./APPINTENTS_README.md)

---

### ✨ Enhanced Design & UX

#### Liquid Glass Design
17 components transformed with modern glassmorphism:
- `.regularMaterial` backgrounds
- Subtle shadows for depth
- Light/dark mode adaptive
- Premium feel throughout

**Components:**
- DSCard (base component)
- ActiveWorkoutBar
- Nutrition summaries (Compact & Daily)
- Program & Template cards
- Workout overview cards
- And more...

#### Haptic Feedback
Premium tactile feedback across all major interactions:
- ✅ Set completion → Success haptic
- ✅ Quick actions → Medium impact
- ✅ Add set → Light impact
- ✅ Exercise delete → Warning notification
- ✅ PR achievement → Celebration haptic

---

## 🏗️ Architecture

### Settings & Profile Separation (v1.2.0)

**Background:**
Following iOS Human Interface Guidelines for better information architecture and improved UX.

**Changes:**
1. **Profile Tab** (new 4th tab in TabBar):
   - Replaced Settings in main navigation
   - Icon: `person.fill`
   - Contains: Personal info (name, height, gender, DOB, activity level)
   - Contains: Bodyweight tracking with history
   - Direct access from tab bar for frequent use

2. **Settings** (now fullScreenCover):
   - App-level preferences only
   - Access: Toolbar gear icon (⚙️) from Home or Profile
   - Contains: Notifications, Theme, Language, Version
   - Less frequently accessed, cleaner separation

3. **Modular Components**:
   - 7 sheet-based edit components in Profile/Views/Components/
   - Reusable, testable, maintainable
   - Follow DSCard design system patterns

**Files Created:**
- `Features/Profile/ViewModels/ProfileViewModel.swift`
- `Features/Profile/Views/ProfileView.swift`
- `Features/Profile/Views/Components/` (7 sheet components)

**Files Modified:**
- `MainTabView.swift` - Profile tab replaces Settings tab
- `SettingsView.swift` - Simplified to app preferences only
- `HomeView.swift` - Added toolbar Settings button

**Navigation Flow:**
```
MainTabView
  ├─> HomeView [⚙️] → SettingsView (fullScreenCover)
  ├─> WorkoutsView
  ├─> NutritionView
  └─> ProfileView [⚙️] → SettingsView (fullScreenCover)
```

---

### Widget Architecture
```
AntrainWidget (Widget Extension)
  ↓
WidgetDataHelper (Data Sharing)
  ↓
UserDefaults (Simple & Effective)
  ↑
MainTabView / LiftingSessionViewModel
(Auto-refresh on workout save)
```

**Key Decisions:**
- UserDefaults for data sharing (no App Group needed)
- Link-based deep linking (not widgetURL)
- Timeline refresh: Every hour
- Manual refresh via WidgetCenter on workout save

### App Intents Architecture
```
StartWorkoutIntent (AppIntent)
  ↓
Opens App (openAppWhenRun = true)
  ↓
MainTabView handles navigation
  ↓
Home tab with quick actions
```

**Localization:**
- EN: `en.lproj/AppIntents.strings`
- TR: `tr.lproj/AppIntents.strings`
- ES: `es.lproj/AppIntents.strings`

---

## 📋 Implementation Details

### Files Created

**Widget Extension:**
- `AntrainWidget/AntrainWidget.swift` (327 lines)
- `AntrainWidget/WidgetDataHelper.swift` (81 lines)
- `AntrainWidget/AntrainWidgetBundle.swift`
- `AntrainWidget/AntrainWidgetControl.swift` (template for future Control Widgets)
- `AntrainWidget/AntrainWidgetLiveActivity.swift` (296 lines - Complete with Dynamic Island UI)
- `AntrainWidget/AppIntent.swift` (template)

**App Intents:**
- `antrain/AppIntents/StartWorkoutIntent.swift` (64 lines)
- `antrain/Resources/en.lproj/AppIntents.strings`
- `antrain/Resources/tr.lproj/AppIntents.strings`
- `antrain/Resources/es.lproj/AppIntents.strings`

**Live Activities with Dynamic Island (Complete):**
- `antrain/Core/Domain/State/LiveActivityService.swift` (132 lines)
- `antrain/Core/Domain/State/LiveActivityServiceProtocol.swift`
- `antrain/Core/Domain/State/WorkoutActivityAttributes.swift` (42 lines)
- `AntrainWidget/AntrainWidgetLiveActivity.swift` (296 lines with full UI)

**Entitlements:**
- `antrain/antrain.entitlements` (Siri capability)

### Files Modified

**Widget Integration:**
- `AntrainApp.swift` - URL scheme handling
- `MainTabView.swift` - Navigation + widget data update
- `LiftingSessionViewModel.swift` - Auto-refresh widget on save

**Haptic Feedback:**
- `QuickActionButton.swift`
- `SetRow.swift`
- `LiftingSessionView.swift`
- `ExerciseCard.swift`

---

## 📊 Technical Specifications

### iOS Version Support
- **Widgets:** iOS 17+ (`.containerBackground` API)
- **App Intents:** iOS 16+
- **Control Widgets:** iOS 18+ (template prepared for future implementation)
- **Live Activities:** iOS 16.1+ (✅ Complete with Dynamic Island and Lock Screen UI)

### Deep Linking
- **URL Scheme:** `antrain://start-workout`
- **Handled in:** `MainTabView.swift:177-192`
- **Behavior:** Switches to home tab, shows quick actions

### Data Sharing
- **Method:** UserDefaults
- **Keys:**
  - `widget_workout_count` (Int)
  - `widget_last_workout_date` (Date)
  - `widget_active_program` (String?)
- **Update Frequency:** On workout save + app launch

---

## 🎨 Design System

### Widget Visual Style
```swift
// Gradient Background
LinearGradient(
    colors: [.blue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Material Container (iOS 17+)
.containerBackground(for: .widget) {
    LinearGradient(...)
}

// Shadows
.shadow(color: .black.opacity(0.2), radius: 10, y: 5)
```

### Liquid Glass Components
```swift
// Base Card Style
.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.08), radius: 8, y: 4)
```

---

## 🧪 Testing

### Widget Testing
- [x] Small widget displays correctly
- [x] Medium widget shows workout count
- [x] Large widget shows full stats
- [x] Deep link opens app
- [x] Deep link navigates to home tab
- [x] Widget refreshes on workout save
- [x] Light/dark mode tested
- [x] Simulator tested

### App Intents Testing
- [x] "Hey Siri, start workout" works
- [x] Shortcuts app integration works
- [x] Tri-lingual support (EN, TR, ES)
- [x] Deep linking to home tab
- [x] App opens from Siri command

### Haptic Testing
- [x] All major interactions have haptic
- [x] Appropriate haptic types used
- [x] No excessive/annoying haptics

---

## 🚀 Deployment

### Requirements
- Xcode 15.0+
- iOS 17.0+ deployment target
- Siri entitlements enabled

### Build Configuration
1. Widget extension properly configured in project
2. App Groups: Not required (UserDefaults sufficient)
3. URL schemes registered: `antrain`
4. Siri capability enabled in entitlements

---

## 📈 Future Enhancements (Phase 2)

### Rest Timer for Live Activities
**Status:** Planned for v1.3

**Planned Features:**
- Rest timer with countdown in Dynamic Island
- Background timer handling
- Notification when rest is complete
- Configurable rest durations

**Dependencies:**
- Background timer implementation
- Notification permissions
- Performance optimization

**Estimated Effort:** 2-3 days

### Control Widgets (iOS 18+)
**Status:** Template prepared, implementation pending

**Planned Features:**
- Lock Screen quick actions
- Control Center integration
- One-tap workout start from Control Center

**Estimated Effort:** 1-2 days

---

## 🎯 Success Metrics

### Completed (v1.2)
- ✅ 3 widget sizes with beautiful design
- ✅ Deep linking system working
- ✅ Siri voice commands (3 languages)
- ✅ Haptic feedback across all interactions
- ✅ Liquid Glass design (17 components)
- ✅ Auto-refresh widget data
- ✅ Live Activities with Dynamic Island (real-time workout tracking)
- ✅ Lock Screen workout display with stats
- ✅ Automatic state updates every second

### Planned (v1.3)
- [ ] Rest timer with countdown in Live Activities
- [ ] Control widgets (interactive, iOS 18+)
- [ ] Nutrition widget
- [ ] PR widget

---

## 📖 Documentation

### Implementation Guides
- **[WIDGET_README.md](./WIDGET_README.md)** - Complete widget implementation guide
- **[APPINTENTS_README.md](./APPINTENTS_README.md)** - App Intents & Siri setup
- **[ROADMAP.md](./ROADMAP.md)** - Development roadmap and session log

### Architecture Documentation
- **[../ARCHITECTURE.md](../ARCHITECTURE.md)** - Core app architecture
- **[../DESIGN_SYSTEM.md](../DESIGN_SYSTEM.md)** - Design tokens & components
- **[../LOCALIZATION.md](../LOCALIZATION.md)** - Localization strategy

### Future Plans
- **[../v3/](../v3/)** - v3.0 planning (iOS 26, Swift 6.2, AI Coach)

---

## 💡 Lessons Learned

### What Worked Well
1. **UserDefaults for widget data** - Simple and effective, no App Group needed
2. **Link-based deep linking** - More flexible than widgetURL for complex layouts
3. **Protocol-based Live Activity design** - Ready for Phase 2 implementation
4. **Tri-lingual App Intents** - Good foundation for international users

### Technical Decisions
1. **No App Groups** - UserDefaults sufficient for current needs
2. **Link over widgetURL** - Better for multiple interactive elements
3. **Timeline refresh hourly** - Balanced between freshness and battery
4. **Manual refresh on save** - Ensures data is always current

### Development Strategy
1. **Focus on high ROI features** - Widgets & Siri have high user impact
2. **Iterate fast** - Widget built in 1.5 hours
3. **Test in simulator** - Preview sometimes unstable, simulator reliable
4. **Use AI for boilerplate** - Claude helped with widget templates

---

## 🔄 Version History

### v1.2.0 (Nov 8, 2025)
- ✅ Home Screen Widgets (3 sizes)
- ✅ Siri Shortcuts & App Intents
- ✅ Liquid Glass design transformation
- ✅ Haptic feedback system
- ✅ Live Activities infrastructure
- ✅ Deep linking system

### v1.1.0 (Nov 5, 2025)
- Workout Templates
- Training Programs (4 presets)
- Localization (EN, TR, ES)
- Nutrition serving units overhaul

### v1.0.0 (Nov 3, 2025)
- Initial release
- Lifting sessions with PR detection
- Nutrition tracking
- SwiftData persistence

---

## 🤝 Contributing

When adding new iOS features:
1. Follow existing architecture patterns
2. Update relevant documentation
3. Add localization for all languages
4. Test in simulator and device
5. Update ROADMAP.md with progress

---

**Last Updated:** November 8, 2025
**Document Version:** 1.0
**Status:** v1.2 Released ✅

---

Happy Coding! 🚀
