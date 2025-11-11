//
//  AICoachViewModel.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation
import Network
import Observation

/// Sendable DTO for passing chat history across actor boundaries
struct ChatHistoryItem: Sendable {
    let content: String
    let isFromUser: Bool

    init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
    }

    init(from message: ChatMessage) {
        self.content = message.content
        self.isFromUser = message.isFromUser
    }
}

@Observable @MainActor
final class AICoachViewModel {
    // MARK: - Dependencies

    private let chatRepository: ChatRepositoryProtocol
    private let geminiAPIService: GeminiAPIServiceProtocol
    private let workoutContextBuilder: WorkoutContextBuilder

    // MARK: - State

    var messages: [ChatMessage] = []
    var isLoading = false
    var errorMessage: String?
    var errorType: ErrorType?
    var workoutContext: WorkoutContext?
    var isOffline = false

    // Lazy loading & cache
    private var cachedContext: WorkoutContext?
    private var contextLoadedAt: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes

    // MARK: - Network Monitor

    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    // MARK: - Initialization

    init(
        chatRepository: ChatRepositoryProtocol,
        geminiAPIService: GeminiAPIServiceProtocol,
        workoutContextBuilder: WorkoutContextBuilder
    ) {
        self.chatRepository = chatRepository
        self.geminiAPIService = geminiAPIService
        self.workoutContextBuilder = workoutContextBuilder

        startNetworkMonitoring()
    }

    deinit {
        networkMonitor.cancel()
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOffline = path.status != .satisfied
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }

    // MARK: - Computed Properties

    /// Check if user needs onboarding (new user without complete profile)
    var isNewUser: Bool {
        guard let context = workoutContext else { return false }
        // User is "new" if they have no fitness level and no goals set
        return context.fitnessLevel == nil && context.fitnessGoals.isEmpty
    }

    /// Check if cache is still valid
    private var isCacheValid: Bool {
        guard let loadedAt = contextLoadedAt else { return false }
        return Date().timeIntervalSince(loadedAt) < cacheValidityDuration
    }

    // MARK: - Load Data

    func loadMessages() async {
        do {
            messages = try await chatRepository.fetchAllMessages()
        } catch {
            print("Error loading messages: \(error)")
        }
    }

    /// Load workout context with caching
    /// Context is cached for 5 minutes to avoid unnecessary database queries
    func loadContext(forceRefresh: Bool = false) async {
        // Return cached context if valid and not forcing refresh
        if !forceRefresh, isCacheValid, let cached = cachedContext {
            workoutContext = cached
            return
        }

        // Build fresh context
        let freshContext = await workoutContextBuilder.buildContext()
        workoutContext = freshContext
        cachedContext = freshContext
        contextLoadedAt = Date()
    }

    /// Invalidate cache (call this when user adds workout/nutrition)
    func invalidateCache() {
        cachedContext = nil
        contextLoadedAt = nil
    }

    // MARK: - Send Message

    func sendMessage(_ text: String) async {
        guard !isOffline else {
            errorType = .offline
            return
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Clear previous errors
        errorMessage = nil
        errorType = nil

        // Create and show user message immediately with sending state
        let tempMessage = ChatMessage(
            content: text,
            isFromUser: true,
            timestamp: Date()
        )
        tempMessage.isSending = true
        messages.append(tempMessage)

        // Save to database (wait for completion but user sees message immediately)
        do {
            _ = try await chatRepository.saveMessage(content: text, isFromUser: true)
            tempMessage.isSending = false
        } catch {
            errorMessage = String(localized: "Failed to save message")
            // Remove failed message from UI
            if let index = messages.firstIndex(where: { $0.id == tempMessage.id }) {
                messages.remove(at: index)
            }
            return
        }

        // Show loading state
        isLoading = true

        // Ensure context is loaded
        if workoutContext == nil {
            await loadContext()
        }

        // Send to Gemini API
        do {
            // Convert ChatMessage to Sendable DTO to avoid actor isolation issues
            let chatHistory = messages.suffix(10).map { ChatHistoryItem(from: $0) }

            let response = try await geminiAPIService.sendMessage(
                text,
                context: workoutContext ?? WorkoutContext.empty(),
                chatHistory: chatHistory,
                isNewUser: isNewUser
            )

            // Save AI response
            let aiMessage = try await chatRepository.saveMessage(content: response, isFromUser: false)
            messages.append(aiMessage)

            // Haptic feedback on success
            HapticManager.shared.success()

        } catch let error as GeminiAPIError {
            handleGeminiError(error)
        } catch {
            let format = String(localized: "Unexpected error: %@")
            errorMessage = String(format: format, error.localizedDescription)
            errorType = .apiError
        }

        isLoading = false
    }

    // MARK: - Quick Actions

    func selectQuickAction(_ message: String) {
        Task {
            await sendMessage(message)
        }
    }

    // MARK: - Clear Chat

    func clearChat() async {
        do {
            try await chatRepository.clearHistory()
            messages = []
            errorMessage = nil
            errorType = nil
        } catch {
            errorMessage = String(localized: "Failed to clear chat")
        }
    }

    // MARK: - Delete Message

    func deleteMessage(_ message: ChatMessage) async {
        do {
            try await chatRepository.deleteMessage(message)
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages.remove(at: index)
            }
        } catch {
            errorMessage = String(localized: "Failed to delete message")
            errorType = .apiError
        }
    }

    // MARK: - Retry

    func retryLastMessage() async {
        // Get last user message
        guard let lastUserMessage = messages.last(where: { $0.isFromUser }) else {
            return
        }

        // Remove failed AI response if exists
        if let lastMessage = messages.last, lastMessage.isFromAI {
            let messageToDelete = lastMessage
            messages.removeLast()
            try? await chatRepository.deleteMessage(messageToDelete)
        }

        // Retry
        await sendMessage(lastUserMessage.content)
    }

    // MARK: - Error Handling

    private func handleGeminiError(_ error: GeminiAPIError) {
        errorMessage = error.localizedDescription

        switch error {
        case .noInternetConnection:
            errorType = .offline

        case .rateLimitExceeded(let seconds):
            errorType = .rateLimitExceeded(seconds: seconds)

        case .timeout:
            errorType = .timeout

        case .invalidAPIKey, .serverError, .invalidResponse, .messageEmpty, .messageTooLong, .unknown:
            errorType = .apiError
        }
    }

    // MARK: - Dismiss Error

    func dismissError() {
        errorMessage = nil
        errorType = nil
    }
}
