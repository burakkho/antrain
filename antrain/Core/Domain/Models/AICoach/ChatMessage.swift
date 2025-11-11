//
//  ChatMessage.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation
import SwiftData

@Model
final class ChatMessage: @unchecked Sendable {
    // MARK: - Properties

    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date

    // MARK: - UI State (Not Persisted)

    @Transient var isSending: Bool = false

    // MARK: - Relationships

    var conversation: ChatConversation?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }

    // MARK: - Computed Properties

    var isFromAI: Bool {
        !isFromUser
    }

    var relativeTimestamp: String {
        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: timestamp,
            to: now
        )

        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }

        if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }

        if let days = components.day, days > 0 {
            if days == 1 {
                return "Yesterday"
            } else if days < 7 {
                return "\(days) days ago"
            } else {
                let weeks = days / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            }
        }

        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1h ago" : "\(hours)h ago"
        }

        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1m ago" : "\(minutes)m ago"
        }

        return "Just now"
    }
}
