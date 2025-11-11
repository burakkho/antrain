//
//  ChatConversation.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation
import SwiftData

@Model
final class ChatConversation: @unchecked Sendable {
    // MARK: - Properties

    var id: UUID
    var createdAt: Date
    var lastMessageAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.conversation)
    var messages: [ChatMessage]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        lastMessageAt: Date = Date(),
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
        self.messages = messages
    }

    // MARK: - Computed Properties

    var messageCount: Int {
        messages.count
    }

    var isEmpty: Bool {
        messages.isEmpty
    }

    var sortedMessages: [ChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }

    var lastMessage: ChatMessage? {
        messages.max { $0.timestamp < $1.timestamp }
    }

    // MARK: - Methods

    func addMessage(_ message: ChatMessage) {
        messages.append(message)
        message.conversation = self
        lastMessageAt = message.timestamp
    }

    func getRecentMessages(limit: Int) -> [ChatMessage] {
        Array(sortedMessages.suffix(limit))
    }

    func clearMessages() {
        messages.removeAll()
    }
}
