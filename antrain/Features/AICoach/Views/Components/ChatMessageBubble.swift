//
//  ChatMessageBubble.swift
//  antrain
//
//  Created by AI Coach Feature
//

import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessage
    let isNew: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var opacity: Double = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromAI {
                // AI message: Gemini logo + bubble on left
                geminiLogo
                messageBubble
                Spacer(minLength: 40)
            } else {
                // User message: bubble on right
                Spacer(minLength: 40)
                messageBubble
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .opacity(isNew && message.isFromAI ? opacity : 1)
        .onAppear {
            if isNew && message.isFromAI {
                withAnimation(.easeIn(duration: 0.25)) {
                    opacity = 1
                }
            } else {
                opacity = 1
            }
        }
    }

    // MARK: - Gemini Logo

    private var geminiLogo: some View {
        Image("gemini-logo")
            .resizable()
            .frame(width: 24, height: 24)
            .clipShape(Circle())
    }

    // MARK: - Message Bubble

    private var messageBubble: some View {
        VStack(alignment: message.isFromAI ? .leading : .trailing, spacing: 4) {
            // Message content with Markdown support
            Text(markdownText)
                .font(DSTypography.body)
                .foregroundColor(textColor)
                .textSelection(.enabled)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(bubbleBackground)
            .clipShape(bubbleShape)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .contextMenu {
                // Copy option on long press
                Button(action: copyMessage) {
                    Label(String(localized: "Copy"), systemImage: "doc.on.doc")
                }
            }

            // Timestamp or sending indicator
            HStack(spacing: 4) {
                if message.isSending {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Sending...")
                        .font(DSTypography.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(message.relativeTimestamp)
                        .font(DSTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, DSSpacing.sm)
        }
    }

    // MARK: - Bubble Background

    private var bubbleBackground: some View {
        Group {
            if message.isFromAI {
                // AI: Blue gradient with liquid glass effect
                LinearGradient(
                    colors: [
                        DSColors.primary.opacity(0.8),
                        DSColors.primary.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    // Liquid glass effect
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
            } else {
                // User: Gray
                Color.secondary.opacity(colorScheme == .dark ? 0.3 : 0.15)
            }
        }
    }

    // MARK: - Bubble Shape

    private var bubbleShape: some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: message.isFromAI ? 4 : 18,
            bottomLeadingRadius: 18,
            bottomTrailingRadius: 18,
            topTrailingRadius: message.isFromAI ? 18 : 4
        )
    }

    // MARK: - Text Color

    private var textColor: Color {
        message.isFromAI ? .white : .primary
    }

    // MARK: - Markdown Text

    private var markdownText: AttributedString {
        // Parse Markdown from message content
        do {
            var attributedString = try AttributedString(
                markdown: message.content,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )

            // Apply font to the entire string
            attributedString.font = DSTypography.body

            return attributedString
        } catch {
            // Fallback to plain text if Markdown parsing fails
            return AttributedString(message.content)
        }
    }

    // MARK: - Actions

    private func copyMessage() {
        #if os(iOS)
        UIPasteboard.general.string = message.content
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
        #endif
    }
}

#Preview {
    VStack(spacing: 16) {
        // AI message
        ChatMessageBubble(
            message: ChatMessage(
                content: "Merhaba! Son **30 günde** 15 antrenman görüyorum. Size nasıl yardımcı olabilirim?\n\n- Volume trend: +8.2%\n- Training frequency: 5.2 days/week",
                isFromUser: false
            ),
            isNew: false
        )

        // User message
        ChatMessageBubble(
            message: ChatMessage(
                content: "Bu haftaki programım ne?",
                isFromUser: true
            ),
            isNew: false
        )
    }
    .padding()
}
