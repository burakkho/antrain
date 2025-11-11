//
//  GeminiAPIService.swift
//  antrain
//
//  Created by AI Coach Feature
//

import Foundation
import NaturalLanguage

/// Service for interacting with Google Gemini 2.5 Flash-Lite API
@MainActor
final class GeminiAPIService: GeminiAPIServiceProtocol {
    // MARK: - Constants

    private let maxMessageLength = 1000

    // MARK: - URLSession

    private let session: URLSession

    // MARK: - Initialization

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = GeminiConfig.timeoutInterval
        configuration.timeoutIntervalForResource = GeminiConfig.timeoutInterval
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Send Message

    func sendMessage(
        _ message: String,
        context: WorkoutContext,
        chatHistory: [ChatHistoryItem],
        isNewUser: Bool
    ) async throws -> String {
        // Validate message
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiAPIError.messageEmpty
        }

        guard message.count <= maxMessageLength else {
            throw GeminiAPIError.messageTooLong(limit: maxMessageLength)
        }

        // Detect language from user message
        let language = detectLanguage(from: message)

        // Build request
        let request = try buildRequest(
            message: message,
            context: context,
            chatHistory: chatHistory,
            language: language,
            isNewUser: isNewUser
        )

        // Log request for debugging
        print("🚀 [GeminiAPI] Sending request to: \(request.url?.absoluteString ?? "unknown")")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 [GeminiAPI] Request body: \(bodyString)")
        }

        // Execute request
        do {
            let (data, response) = try await session.data(for: request)

            // Log response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 [GeminiAPI] Response status: \(httpResponse.statusCode)")
            }

            // Log response body
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 [GeminiAPI] Response body: \(responseString)")
            }

            // Validate HTTP response
            try validateResponse(response)

            // Parse response
            let aiResponse = try parseResponse(data)

            print("✅ [GeminiAPI] Successfully received response")
            return aiResponse

        } catch let error as GeminiAPIError {
            print("❌ [GeminiAPI] GeminiAPIError: \(error)")
            throw error
        } catch let urlError as URLError {
            print("❌ [GeminiAPI] URLError: \(urlError.localizedDescription)")
            throw handleURLError(urlError)
        } catch {
            print("❌ [GeminiAPI] Unknown error: \(error)")
            throw GeminiAPIError.unknown(error)
        }
    }

    // MARK: - Language Detection

    private func detectLanguage(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)

        guard let languageCode = recognizer.dominantLanguage?.rawValue else {
            return "English" // Default fallback
        }

        switch languageCode {
        case "tr":
            return "Turkish"
        case "en":
            return "English"
        case "es":
            return "Spanish"
        default:
            return "English"
        }
    }

    // MARK: - Build Request

    private func buildRequest(
        message: String,
        context: WorkoutContext,
        chatHistory: [ChatHistoryItem],
        language: String,
        isNewUser: Bool
    ) throws -> URLRequest {
        var request = URLRequest(url: GeminiConfig.generateContentURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add API key as header (Google's recommended method)
        request.setValue(GeminiConfig.apiKey, forHTTPHeaderField: "x-goog-api-key")

        // Build request body
        let requestBody = buildRequestBody(
            message: message,
            context: context,
            chatHistory: chatHistory,
            language: language,
            isNewUser: isNewUser
        )

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }

    private func buildRequestBody(
        message: String,
        context: WorkoutContext,
        chatHistory: [ChatHistoryItem],
        language: String,
        isNewUser: Bool
    ) -> [String: Any] {
        // Build system prompt with context
        let contextString = context.toPromptString(language: language)
        let systemPrompt = GeminiConfig.systemPrompt(language: language, userContext: contextString, isNewUser: isNewUser)

        // Build contents array with chat history
        var contents: [[String: Any]] = []

        // Add chat history (last 10 messages max to save tokens)
        let recentHistory = Array(chatHistory.suffix(10))

        for historyItem in recentHistory {
            let role = historyItem.isFromUser ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": historyItem.content]]
            ])
        }

        // Add current user message
        contents.append([
            "role": "user",
            "parts": [["text": message]]
        ])

        return [
            "systemInstruction": [
                "parts": [["text": systemPrompt]]
            ],
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048
            ]
        ]
    }

    // MARK: - Response Handling

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401, 403:
            throw GeminiAPIError.invalidAPIKey
        case 429:
            // Rate limit exceeded - try to extract retry-after header
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
            let seconds = Int(retryAfter ?? "60") ?? 60
            throw GeminiAPIError.rateLimitExceeded(retryAfter: seconds)
        case 500...599:
            throw GeminiAPIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw GeminiAPIError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GeminiAPIError.invalidResponse
        }

        // Navigate JSON structure:
        // response.candidates[0].content.parts[0].text

        guard let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiAPIError.invalidResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func handleURLError(_ error: URLError) -> GeminiAPIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}
