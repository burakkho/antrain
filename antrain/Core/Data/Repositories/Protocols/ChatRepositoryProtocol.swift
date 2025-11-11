//
//  ChatRepositoryProtocol.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation

/// Protocol for managing chat conversation and messages with SwiftData
protocol ChatRepositoryProtocol: Actor {
    /// Fetches or creates the main conversation
    /// - Returns: The chat conversation
    func fetchOrCreateConversation() async throws -> ChatConversation

    /// Saves a new message to the conversation
    /// - Parameters:
    ///   - content: Message content
    ///   - isFromUser: Whether the message is from the user (true) or AI (false)
    /// - Returns: The created message
    @discardableResult
    func saveMessage(content: String, isFromUser: Bool) async throws -> ChatMessage

    /// Fetches all messages in chronological order
    /// - Returns: Array of messages sorted by timestamp
    func fetchAllMessages() async throws -> [ChatMessage]

    /// Fetches the last N messages in chronological order
    /// - Parameter limit: Number of messages to fetch
    /// - Returns: Array of recent messages
    func fetchRecentMessages(limit: Int) async throws -> [ChatMessage]

    /// Deletes all messages from the conversation
    func clearHistory() async throws

    /// Deletes a specific message
    /// - Parameter message: The message to delete
    func deleteMessage(_ message: ChatMessage) async throws

    /// Gets the total message count
    /// - Returns: Number of messages in the conversation
    func getMessageCount() async throws -> Int
}
