//
//  ChatInputField.swift
//  antrain
//
//  Rewritten for stability - 2025-11-11
//

import SwiftUI

struct ChatInputField: View {
    @Binding var text: String
    let isLoading: Bool
    let isOffline: Bool
    let onSend: () -> Void

    // MARK: - Constants

    private let maxLength = 1000

    // MARK: - Computed Properties

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !isLoading
        && !isOffline
        && text.count <= maxLength
    }

    var body: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Ask your coach...", text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .disabled(isLoading || isOffline)
                .submitLabel(.send)
                .onSubmit {
                    if canSend {
                        handleSend()
                    }
                }

            // Send button
            Button(action: handleSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        canSend ? Color.accentColor : Color.gray.opacity(0.3)
      
                    )
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - Actions

    private func handleSend() {
        guard canSend else { return }

        // Haptic feedback
        HapticManager.shared.light()

        // Send message
        onSend()
    }
}

#Preview {
    VStack {
        Spacer()

        ChatInputField(
            text: .constant(""),
            isLoading: false,
            isOffline: false,
            onSend: {
                print("Send tapped")
            }
        )
    }
}
