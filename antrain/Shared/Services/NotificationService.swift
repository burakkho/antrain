//
//  NotificationService.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation
import UserNotifications
import SwiftData
import Combine

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
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "notificationSettings"

    // MARK: - Initialization

    private override init() {
        // Load settings from UserDefaults
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .defaultSettings
        }

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
        print("[NotificationService] 💾 Updating settings...")
        settings = newSettings

        // Persist to UserDefaults
        if let encoded = try? JSONEncoder().encode(newSettings) {
            userDefaults.set(encoded, forKey: settingsKey)
            print("[NotificationService] ✅ Settings saved to UserDefaults")
        } else {
            print("[NotificationService] ❌ Failed to encode settings")
        }

        // Re-schedule if enabled
        if newSettings.isEnabled {
            print("[NotificationService] 📅 Scheduling next notification...")
            await scheduleNextNotification()
        } else {
            print("[NotificationService] 🚫 Cancelling notifications (disabled)")
            await cancelAllNotifications()
        }
    }

    // MARK: - Scheduling

    /// Schedule notification for next workout day
    func scheduleNextNotification() async {
        print("[NotificationService] 🔔 scheduleNextNotification() called")

        guard settings.isEnabled else {
            print("[NotificationService] ⚠️ Settings disabled, skipping")
            return
        }

        guard authorizationStatus == .authorized else {
            print("[NotificationService] ⚠️ Not authorized: \(authorizationStatus.rawValue)")
            return
        }

        print("[NotificationService] ✅ Permission OK, proceeding...")

        // Cancel existing notifications
        await cancelAllNotifications()

        // Get active program and today's workout
        // NOTE: Mock implementation for MVP - real integration in Phase 7
        guard getMockTodaysWorkout() != nil else {
            print("[NotificationService] ⚠️ No today's workout")
            return
        }

        // Calculate tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowDayOfWeek = Calendar.current.component(.weekday, from: tomorrow)

        print("[NotificationService] 📅 Tomorrow is weekday: \(tomorrowDayOfWeek)")

        // Check if should notify tomorrow
        guard settings.shouldNotify(for: tomorrowDayOfWeek) else {
            print("[NotificationService] ⚠️ Tomorrow not in enabled days: \(settings.enabledDays)")
            return
        }

        // Get tomorrow's workout (mock)
        if let tomorrowsWorkout = getMockTomorrowsWorkout() {
            print("[NotificationService] 💪 Scheduling workout: \(tomorrowsWorkout)")
            // Schedule workout notification
            try? await scheduleWorkoutNotification(
                for: tomorrow,
                workoutName: tomorrowsWorkout
            )
        } else if settings.sendOnRestDays {
            print("[NotificationService] 😴 Scheduling rest day notification")
            // Schedule rest day notification
            try? await scheduleRestDayNotification(for: tomorrow)
        } else {
            print("[NotificationService] ⚠️ No workout tomorrow and rest days disabled")
        }

        // Update last scheduled date
        var updatedSettings = settings
        updatedSettings.lastScheduledDate = Date()
        settings = updatedSettings

        // Persist
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }

    /// Schedule a workout notification
    private func scheduleWorkoutNotification(
        for date: Date,
        workoutName: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Workout Time!")
        content.body = String(localized: "Today: \(workoutName)")
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"

        // Add custom data
        content.userInfo = [
            "type": "workout",
            "workoutName": workoutName
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

        print("[NotificationService] 🎯 Scheduling notification for: \(dateComponents)")
        try await center.add(request)
        print("[NotificationService] ✅ Notification scheduled successfully!")
    }

    /// Schedule rest day notification
    private func scheduleRestDayNotification(for date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Rest Day")
        content.body = String(localized: "Recovery is progress. Take it easy today!")
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

    // MARK: - Mock Helpers (Phase 7: Replace with real UserProfile integration)

    private func getMockTodaysWorkout() -> String? {
        // Mock: Return a workout name
        return "Push Day"
    }

    private func getMockTomorrowsWorkout() -> String? {
        // Mock: Return workout name for tomorrow (TESTING: every day has workout)
        let tomorrow = Calendar.current.component(.weekday, from: Date().addingTimeInterval(86400))

        // Mock schedule: All days have workouts for testing
        switch tomorrow {
        case 1: return "Full Body"     // Sunday
        case 2: return "Push Day"      // Monday
        case 3: return "Pull Day"      // Tuesday
        case 4: return "Leg Day"       // Wednesday
        case 5: return "Upper Body"    // Thursday
        case 6: return "Lower Body"    // Friday
        case 7: return "Full Body"     // Saturday
        default: return "Workout Day"
        }
    }

    // MARK: - Category Registration

    /// Register notification categories and actions
    func registerCategories() {
        // Workout reminder category
        let startAction = UNNotificationAction(
            identifier: "START_WORKOUT",
            title: String(localized: "Start Workout"),
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: String(localized: "Snooze 1 hour"),
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

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner even when app is active
        completionHandler([.banner, .sound])
    }

    /// Handle user's response to notification
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        switch actionIdentifier {
        case "START_WORKOUT":
            // Navigate to lifting session
            Self.handleStartWorkoutAction(userInfo: userInfo)

        case "SNOOZE":
            // Re-schedule for 1 hour later
            Task { @MainActor in
                await Self.handleSnoozeAction()
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped notification (not an action button)
            Self.handleTapNotification(userInfo: userInfo)

        default:
            break
        }

        completionHandler()
    }

    private nonisolated static func handleStartWorkoutAction(userInfo: [AnyHashable: Any]) {
        // Post notification to open workout screen
        NotificationCenter.default.post(
            name: NSNotification.Name("StartWorkoutFromNotification"),
            object: nil,
            userInfo: userInfo
        )
    }

    private static func handleSnoozeAction() async {
        // Schedule notification for 1 hour from now
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Workout Reminder")
        content.body = String(localized: "Ready to start your workout now?")
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

        // Use shared center instance (thread-safe)
        try? await UNUserNotificationCenter.current().add(request)
    }

    private nonisolated static func handleTapNotification(userInfo: [AnyHashable: Any]) {
        // Same as start workout
        handleStartWorkoutAction(userInfo: userInfo)
    }
}

// MARK: - Errors

enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return String(localized: "Notification permission denied. Please enable in Settings.")
        case .schedulingFailed:
            return String(localized: "Failed to schedule notification. Please try again.")
        }
    }
}
