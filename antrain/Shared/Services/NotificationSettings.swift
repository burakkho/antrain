//
//  NotificationSettings.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import Foundation

/// User preferences for workout notifications
struct NotificationSettings: Codable {
    // MARK: - Properties

    /// Master switch for all workout notifications
    var isEnabled: Bool

    /// Preferred notification time (hour and minute)
    var preferredTime: DateComponents

    /// Which days to send notifications (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    var enabledDays: Set<Int>

    /// Whether to send notifications on rest days
    var sendOnRestDays: Bool

    /// Last time we successfully scheduled a notification
    var lastScheduledDate: Date?

    // MARK: - Defaults

    /// Default notification settings
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
    /// - Parameter dayOfWeek: Day of week (1 = Sunday, 7 = Saturday)
    /// - Returns: Whether notifications should be sent
    func shouldNotify(for dayOfWeek: Int) -> Bool {
        isEnabled && enabledDays.contains(dayOfWeek)
    }
}
