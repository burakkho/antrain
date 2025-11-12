//
//  ChatRepository.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation
import SwiftData

/// Thread-safe repository for managing chat data with SwiftData
@ModelActor
actor ChatRepository: ChatRepositoryProtocol {
    // MARK: - Fetch or Create Conversation

    func fetchOrCreateConversation() async throws -> ChatConversation {
        let descriptor = FetchDescriptor<ChatConversation>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let conversations = try modelContext.fetch(descriptor)

        if let existingConversation = conversations.first {
            return existingConversation
        } else {
            // Create new conversation
            let newConversation = ChatConversation()
            modelContext.insert(newConversation)
            try modelContext.save()
            return newConversation
        }
    }

    // MARK: - Save Message

    @discardableResult
    func saveMessage(content: String, isFromUser: Bool) async throws -> ChatMessage {
        let conversation = try await fetchOrCreateConversation()

        let message = ChatMessage(
            content: content,
            isFromUser: isFromUser,
            timestamp: Date()
        )

        modelContext.insert(message)
        conversation.addMessage(message)

        try modelContext.save()

        return message
    }

    // MARK: - Fetch Messages

    func fetchAllMessages(limit: Int = 50) async throws -> [ChatMessage] {
        let conversation = try await fetchOrCreateConversation()
        // Sort messages within actor context to avoid cross-actor sync access
        let sorted = conversation.messages.sorted { $0.timestamp < $1.timestamp }
        // Return most recent N messages for performance (pagination)
        return Array(sorted.suffix(limit))
    }

    func fetchRecentMessages(limit: Int) async throws -> [ChatMessage] {
        let conversation = try await fetchOrCreateConversation()
        // Get recent messages within actor context
        let sorted = conversation.messages.sorted { $0.timestamp < $1.timestamp }
        return Array(sorted.suffix(limit))
    }

    // MARK: - Delete Operations

    func clearHistory() async throws {
        let conversation = try await fetchOrCreateConversation()

        // Delete all messages
        for message in conversation.messages {
            modelContext.delete(message)
        }

        conversation.clearMessages()
        try modelContext.save()
    }

    func deleteMessage(_ message: ChatMessage) async throws {
        modelContext.delete(message)
        try modelContext.save()
    }

    // MARK: - Utility

    func getMessageCount() async throws -> Int {
        let conversation = try await fetchOrCreateConversation()
        return conversation.messageCount
    }
}
