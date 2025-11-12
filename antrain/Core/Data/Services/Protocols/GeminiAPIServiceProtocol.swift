//
//  GeminiAPIServiceProtocol.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation

/// Protocol for interacting with Google Gemini API
protocol GeminiAPIServiceProtocol {
    /// Sends a message to Gemini AI and returns the response
    /// - Parameters:
    ///   - message: The user's message
    ///   - context: Workout context data
    ///   - chatHistory: Recent chat messages for conversation context
    ///   - isNewUser: Whether user needs onboarding (incomplete profile)
    ///   - useFullContext: Whether to send full context (first message) or minimal context (follow-up)
    /// - Returns: AI response text
    /// - Throws: GeminiAPIError if the request fails
    func sendMessage(
        _ message: String,
        context: WorkoutContext,
        chatHistory: [ChatHistoryItem],
        isNewUser: Bool,
        useFullContext: Bool
    ) async throws -> String
}

/// Errors that can occur when interacting with Gemini API
enum GeminiAPIError: LocalizedError {
    case noInternetConnection
    case invalidAPIKey
    case rateLimitExceeded(retryAfter: Int)
    case serverError(statusCode: Int)
    case invalidResponse
    case timeout
    case messageEmpty
    case messageTooLong(limit: Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return String(localized: "Internet connection required")
        case .invalidAPIKey:
            return String(localized: "Invalid API key")
        case .rateLimitExceeded(let seconds):
            return String(localized: "Too many requests, please wait \(seconds) seconds")
        case .serverError(let code):
            return String(localized: "Server error (\(code))")
        case .invalidResponse:
            return String(localized: "Invalid response received")
        case .timeout:
            return String(localized: "Request timed out")
        case .messageEmpty:
            return String(localized: "Message cannot be empty")
        case .messageTooLong(let limit):
            return String(localized: "Message too long (maximum \(limit) characters)")
        case .unknown(let error):
            return String(localized: "Unexpected error: \(error.localizedDescription)")
        }
    }
}
