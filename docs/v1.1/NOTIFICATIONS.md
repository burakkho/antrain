# Workout Notifications System (v2.0)

> **Status:** Planning Phase
> **Target Release:** v2.0 (with Training Programs)
> **Last Updated:** 2025-11-05

## Overview

Workout Notifications system enables users to receive timely reminders for their scheduled training days. This is the first notification feature in Antrain, built alongside Training Programs to maximize user adherence and engagement.

---

## Core Decisions

### 1. Native UNUserNotificationCenter
- **Decision:** Use Apple's native notification framework
- **Rationale:** Reliable, system-integrated, supports all iOS features
- **Benefits:** Scheduling, actions, categories, badge management built-in

### 2. Program-Based Scheduling
- **Decision:** Auto-schedule based on active program
- **Rationale:** Intelligent, requires minimal user configuration
- **UX:** User only sets preferred time, system handles rest

### 3. Simple Content (MVP)
- **Decision:** Basic title/body format
- **Content:** "Workout Time! • Today: Push Day"
- **Rationale:** Clear, actionable, quick to implement

### 4. Basic Actions
- **Decision:** Two interactive actions
- **Actions:** "Start Workout" and "Snooze 1 hour"
- **Rationale:** Cover primary use cases without overwhelming

### 5. Daily Re-Scheduling
- **Decision:** Schedule next day's notification each day
- **Rationale:** Adapts quickly to program changes, flexible
- **Trade-off:** Slight overhead vs. batch scheduling

### 6. Contextual Permission Request
- **Decision:** Ask when user activates first program
- **Rationale:** User has clear context and intent
- **UX:** Non-intrusive, opt-in approach

---

## Architecture

### Service Location

```
antrain/
└── Shared/
    └── Services/
        ├── NotificationService.swift
        └── NotificationScheduler.swift
```

**Rationale:** App-wide service, reusable across features (future: nutrition reminders, PR celebrations, etc.)

---

## Domain Models

### NotificationSettings

```swift
import Foundation

/// User preferences for workout notifications
struct NotificationSettings: Codable {
    /// Master switch for all workout notifications
    var isEnabled: Bool

    /// Preferred notification time (hour and minute)
    var preferredTime: DateComponents

    /// Which days to send notifications (1 = Monday, 7 = Sunday)
    var enabledDays: Set<Int>

    /// Whether to send notifications on rest days
    var sendOnRestDays: Bool

    /// Last time we successfully scheduled a notification
    var lastScheduledDate: Date?

    // MARK: - Defaults

    static var defaultSettings: NotificationSettings {
        NotificationSettings(
            isEnabled: false,
            preferredTime: DateComponents(hour: 9, minute: 0),  // 9:00 AM
            enabledDays: Set(1...7),  // All days
            sendOnRestDays: false,
            lastScheduledDate: nil
        )
    }

    // MARK: - Helpers

    /// Check if notifications should be sent for a specific day
    func shouldNotify(for dayOfWeek: Int) -> Bool {
        isEnabled && enabledDays.contains(dayOfWeek)
    }
}
```

**Storage:** Stored in `UserDefaults` (lightweight, doesn't need SwiftData)

---

## Service Layer

### NotificationService

```swift
import Foundation
import UserNotifications

/// Main service for managing workout notifications
@MainActor
final class NotificationService: NSObject, ObservableObject {
    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Published State

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var settings: NotificationSettings

    // MARK: - Dependencies

    private let center = UNUserNotificationCenter.current()
    private let scheduler: NotificationScheduler

    // MARK: - Initialization

    private override init() {
        // Load settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "notificationSettings"),
           let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .defaultSettings
        }

        self.scheduler = NotificationScheduler()

        super.init()

        center.delegate = self
        Task { await updateAuthorizationStatus() }
    }

    // MARK: - Authorization

    /// Request notification permissions
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await center.requestAuthorization(options: options)

        await updateAuthorizationStatus()

        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    /// Check current authorization status
    func updateAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Settings Management

    /// Update notification settings
    func updateSettings(_ newSettings: NotificationSettings) async {
        settings = newSettings

        // Persist to UserDefaults
        if let encoded = try? JSONEncoder().encode(newSettings) {
            UserDefaults.standard.set(encoded, forKey: "notificationSettings")
        }

        // Re-schedule if enabled
        if newSettings.isEnabled {
            await scheduleNextNotification()
        } else {
            await cancelAllNotifications()
        }
    }

    // MARK: - Scheduling

    /// Schedule notification for next workout day
    func scheduleNextNotification() async {
        guard settings.isEnabled else { return }
        guard authorizationStatus == .authorized else { return }

        // Cancel existing notifications
        await cancelAllNotifications()

        // Get active program
        guard let activeProgram = await getActiveProgram(),
              let todaysWorkout = getTodaysWorkout(from: activeProgram) else {
            return
        }

        // Schedule tomorrow if there's a workout
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowDayOfWeek = Calendar.current.component(.weekday, from: tomorrow)

        // Check if should notify tomorrow
        guard settings.shouldNotify(for: tomorrowDayOfWeek) else { return }

        // Get tomorrow's workout
        guard let tomorrowsWorkout = getTomorrowsWorkout(from: activeProgram) else {
            // No workout tomorrow, maybe it's rest day
            if settings.sendOnRestDays {
                try? await scheduleRestDayNotification(for: tomorrow)
            }
            return
        }

        // Schedule workout notification
        try? await scheduleWorkoutNotification(
            for: tomorrow,
            workout: tomorrowsWorkout
        )

        // Update last scheduled date
        var updatedSettings = settings
        updatedSettings.lastScheduledDate = Date()
        await updateSettings(updatedSettings)
    }

    /// Schedule a workout notification
    private func scheduleWorkoutNotification(
        for date: Date,
        workout: ProgramDay
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Workout Time!"
        content.body = "Today: \(workout.displayName)"
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"

        // Add custom data
        content.userInfo = [
            "type": "workout",
            "workoutId": workout.id.uuidString,
            "dayOfWeek": workout.dayOfWeek
        ]

        // Create trigger (specific date and time)
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
        dateComponents.hour = settings.preferredTime.hour
        dateComponents.minute = settings.preferredTime.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        // Create request
        let request = UNNotificationRequest(
            identifier: "workout_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedule rest day notification
    private func scheduleRestDayNotification(for date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Rest Day"
        content.body = "Recovery is progress. Take it easy today!"
        content.sound = .default
        content.categoryIdentifier = "REST_DAY"

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
        dateComponents.hour = settings.preferredTime.hour
        dateComponents.minute = settings.preferredTime.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "rest_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Helpers

    private func getActiveProgram() async -> TrainingProgram? {
        // Fetch from UserProfile via repository
        // Implementation depends on repository access
        nil  // Placeholder
    }

    private func getTodaysWorkout(from program: TrainingProgram) -> ProgramDay? {
        // Implementation from UserProfile extension
        nil  // Placeholder
    }

    private func getTomorrowsWorkout(from program: TrainingProgram) -> ProgramDay? {
        // Similar to getTodaysWorkout but for tomorrow
        nil  // Placeholder
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner even when app is active
        completionHandler([.banner, .sound])
    }

    /// Handle user's response to notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        switch actionIdentifier {
        case "START_WORKOUT":
            // Navigate to lifting session
            handleStartWorkoutAction(userInfo: userInfo)

        case "SNOOZE":
            // Re-schedule for 1 hour later
            Task {
                await handleSnoozeAction()
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped notification (not an action button)
            handleTapNotification(userInfo: userInfo)

        default:
            break
        }

        completionHandler()
    }

    private func handleStartWorkoutAction(userInfo: [AnyHashable: Any]) {
        // Post notification to open workout screen
        NotificationCenter.default.post(
            name: NSNotification.Name("StartWorkoutFromNotification"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleSnoozeAction() async {
        // Schedule notification for 1 hour from now
        let content = UNMutableNotificationContent()
        content.title = "Workout Reminder"
        content.body = "Ready to start your workout now?"
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3600,  // 1 hour
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "snooze_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    private func handleTapNotification(userInfo: [AnyHashable: Any]) {
        // Same as start workout
        handleStartWorkoutAction(userInfo: userInfo)
    }
}

// MARK: - Notification Categories

extension NotificationService {
    /// Register notification categories and actions
    func registerCategories() {
        // Workout reminder category
        let startAction = UNNotificationAction(
            identifier: "START_WORKOUT",
            title: "Start Workout",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 1 hour",
            options: []
        )

        let workoutCategory = UNNotificationCategory(
            identifier: "WORKOUT_REMINDER",
            actions: [startAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Rest day category (no actions needed)
        let restCategory = UNNotificationCategory(
            identifier: "REST_DAY",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([workoutCategory, restCategory])
    }
}

// MARK: - Errors

enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission denied. Please enable in Settings."
        case .schedulingFailed:
            return "Failed to schedule notification. Please try again."
        }
    }
}
```

---

## UI Integration

### Settings View

**Location:** `Features/Settings/Views/NotificationSettingsView.swift`

```swift
import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var notificationService = NotificationService.shared
    @State private var settings: NotificationSettings
    @State private var showPermissionAlert = false

    init() {
        _settings = State(initialValue: notificationService.settings)
    }

    var body: some View {
        Form {
            // Master Toggle
            Section {
                Toggle("Workout Reminders", isOn: $settings.isEnabled)
                    .onChange(of: settings.isEnabled) { _, newValue in
                        if newValue && notificationService.authorizationStatus != .authorized {
                            showPermissionAlert = true
                        } else {
                            Task {
                                await notificationService.updateSettings(settings)
                            }
                        }
                    }
            } footer: {
                Text("Get reminded when it's time for your scheduled workout")
            }

            if settings.isEnabled {
                // Preferred Time
                Section {
                    DatePicker(
                        "Notification Time",
                        selection: Binding(
                            get: {
                                Calendar.current.date(from: settings.preferredTime) ?? Date()
                            },
                            set: { newDate in
                                settings.preferredTime = Calendar.current.dateComponents(
                                    [.hour, .minute],
                                    from: newDate
                                )
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                } header: {
                    Text("Timing")
                }

                // Days Selection
                Section {
                    ForEach(1...7, id: \.self) { day in
                        Toggle(
                            dayName(for: day),
                            isOn: Binding(
                                get: { settings.enabledDays.contains(day) },
                                set: { enabled in
                                    if enabled {
                                        settings.enabledDays.insert(day)
                                    } else {
                                        settings.enabledDays.remove(day)
                                    }
                                }
                            )
                        )
                    }
                } header: {
                    Text("Active Days")
                }

                // Rest Day Toggle
                Section {
                    Toggle("Rest Day Reminders", isOn: $settings.sendOnRestDays)
                } footer: {
                    Text("Receive gentle reminders on rest days about the importance of recovery")
                }

                // Save Button
                Section {
                    Button("Save Settings") {
                        Task {
                            await notificationService.updateSettings(settings)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Authorization Status
            if notificationService.authorizationStatus != .authorized {
                Section {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } footer: {
                    Text("Notification permissions are required. Please enable in iOS Settings.")
                }
            }
        }
        .navigationTitle("Workout Reminders")
        .alert("Enable Notifications", isPresented: $showPermissionAlert) {
            Button("Allow") {
                Task {
                    try? await notificationService.requestAuthorization()
                    await notificationService.updateSettings(settings)
                }
            }
            Button("Not Now", role: .cancel) {
                settings.isEnabled = false
            }
        } message: {
            Text("Antrain needs permission to send you workout reminders")
        }
    }

    private func dayName(for day: Int) -> String {
        Calendar.current.weekdaySymbols[day - 1]
    }
}
```

---

### Program Activation Flow

**Location:** `Features/Programs/Views/ProgramDetailView.swift`

```swift
// When user activates a program
Button("Start This Program") {
    Task {
        await viewModel.activateProgram()

        // Check notification permissions
        if NotificationService.shared.authorizationStatus == .notDetermined {
            showNotificationSetup = true
        } else if NotificationService.shared.settings.isEnabled {
            // Schedule notifications
            await NotificationService.shared.scheduleNextNotification()
        }
    }
}
.sheet(isPresented: $showNotificationSetup) {
    NotificationSetupSheet()
}
```

**NotificationSetupSheet:**
```swift
struct NotificationSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferredTime = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Stay on Track")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Get reminded when it's time for your workout")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                DatePicker(
                    "Preferred Time",
                    selection: $preferredTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)

                Spacer()

                VStack(spacing: 12) {
                    Button("Enable Reminders") {
                        Task {
                            var settings = NotificationSettings.defaultSettings
                            settings.isEnabled = true
                            settings.preferredTime = Calendar.current.dateComponents(
                                [.hour, .minute],
                                from: preferredTime
                            )

                            try? await NotificationService.shared.requestAuthorization()
                            await NotificationService.shared.updateSettings(settings)
                            await NotificationService.shared.scheduleNextNotification()

                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Not Now") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Workout Reminders")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

---

## App Lifecycle Integration

### App Initialization

**Location:** `AntrainApp.swift`

```swift
@main
struct AntrainApp: App {
    init() {
        // Register notification categories
        NotificationService.shared.registerCategories()

        // Handle background notification scheduling
        Task {
            await NotificationService.shared.updateAuthorizationStatus()
            await NotificationService.shared.scheduleNextNotification()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onReceive(NotificationCenter.default.publisher(
                    for: NSNotification.Name("StartWorkoutFromNotification")
                )) { notification in
                    // Handle deep link to workout
                    handleWorkoutDeepLink(notification.userInfo)
                }
        }
    }

    private func handleWorkoutDeepLink(_ userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
              let workoutIdString = userInfo["workoutId"] as? String,
              let workoutId = UUID(uuidString: workoutIdString) else {
            return
        }

        // Post to app-wide notification for navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToWorkout"),
            object: workoutId
        )
    }
}
```

### Daily Scheduling

**Background Task or Scene Phase:**

```swift
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        // App became active, check if we need to schedule
        Task {
            await NotificationService.shared.scheduleNextNotification()
        }
    }
}
```

---

## Testing Strategy

### Unit Tests

```swift
final class NotificationServiceTests: XCTestCase {
    func testDefaultSettings() {
        let settings = NotificationSettings.defaultSettings

        XCTAssertFalse(settings.isEnabled)
        XCTAssertEqual(settings.preferredTime.hour, 9)
        XCTAssertEqual(settings.preferredTime.minute, 0)
        XCTAssertEqual(settings.enabledDays.count, 7)
    }

    func testShouldNotify() {
        var settings = NotificationSettings.defaultSettings
        settings.isEnabled = true
        settings.enabledDays = [1, 3, 5]  // Mon, Wed, Fri

        XCTAssertTrue(settings.shouldNotify(for: 1))
        XCTAssertFalse(settings.shouldNotify(for: 2))
        XCTAssertTrue(settings.shouldNotify(for: 3))
    }
}
```

### Integration Tests

- Test notification scheduling
- Test permission flow
- Test action handling
- Test deep linking

### Manual Testing

- [ ] Request permission flow
- [ ] Schedule notification
- [ ] Receive notification (wait or use simulator time)
- [ ] Tap "Start Workout" action
- [ ] Tap "Snooze" action
- [ ] Tap notification body
- [ ] Change settings and verify re-scheduling
- [ ] Disable notifications and verify cancellation

---

## Localization

All notification content must be localized:

```swift
// Notification strings
"notification.workout.title" = "Workout Time!"
"notification.workout.body" = "Today: %@"
"notification.rest.title" = "Rest Day"
"notification.rest.body" = "Recovery is progress. Take it easy today!"
"notification.action.start" = "Start Workout"
"notification.action.snooze" = "Snooze 1 hour"

// Settings strings
"settings.notifications.title" = "Workout Reminders"
"settings.notifications.enabled" = "Enable Reminders"
"settings.notifications.time" = "Notification Time"
"settings.notifications.days" = "Active Days"
"settings.notifications.restDays" = "Rest Day Reminders"
```

---

## Future Enhancements (v2.1+)

### Advanced Features

**Smart Timing**
- Learn from user's workout history
- Suggest optimal notification times
- Adjust based on adherence patterns

**Rich Notifications**
- Show workout preview (exercises, duration)
- Display progress (week X of Y)
- Include motivational messages

**Streak Tracking**
- Show current streak in notifications
- Celebrate milestones (7-day, 30-day streaks)
- Warning when streak is at risk

**Multiple Programs**
- Support notifications for multiple active programs
- Prioritize based on schedule

**Nutrition Reminders**
- Meal logging reminders
- Hydration reminders
- Macro target warnings

**PR Celebrations**
- Notify when user sets a new PR
- Weekly PR summary notifications

**Integration with Calendar**
- Sync workouts to iOS Calendar
- Create calendar events automatically

---

## Privacy Considerations

### Data Collected
- Notification preferences (local only)
- Schedule times (local only)
- Authorization status (system)

### Data Shared
- **None** - All data stays on device
- No analytics on notification interactions
- No remote notification servers

### User Control
- Full control over when/if to enable
- Granular day selection
- Easy disable in Settings
- iOS Settings integration

---

## Performance

### Optimization
- Minimal battery impact (system handles scheduling)
- No background refresh needed
- No network calls
- Efficient UserDefaults storage

### Monitoring
- Track permission grant rate
- Monitor notification delivery rate
- Track action usage (Start vs Snooze)

---

## Implementation Phases

### Phase 1: Core Service (1 day)
- [ ] Create NotificationService
- [ ] Implement permission handling
- [ ] Create NotificationSettings model
- [ ] UserDefaults persistence

### Phase 2: Scheduling Logic (1 day)
- [ ] Implement daily scheduling
- [ ] Program integration
- [ ] Rest day handling
- [ ] Cancel/update logic

### Phase 3: UI (1 day)
- [ ] Settings view
- [ ] Program activation sheet
- [ ] Permission request flow
- [ ] Settings link from main Settings

### Phase 4: Actions & Deep Linking (0.5 day)
- [ ] Register categories
- [ ] Implement action handlers
- [ ] Deep link to workout
- [ ] Snooze functionality

### Phase 5: Testing & Polish (0.5 day)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] Localization

**Total: 3-4 days** (can be done in parallel with Programs Phase 3-4)

---

## References

- [Apple UNUserNotificationCenter Documentation](https://developer.apple.com/documentation/usernotifications)
- [Training Programs Architecture](./TRAINING_PROGRAMS.md)
- [Implementation Plan](./IMPLEMENTATION_PLAN.md)

---

**Document Version:** 1.0
**Status:** Ready for Implementation
**Dependencies:** Training Programs (active program required)
