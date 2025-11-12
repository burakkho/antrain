//
//  ErrorBanner.swift
//  antrain
//
//  Created by AI Coach Feature
//

import SwiftUI
import Combine

struct ErrorBanner: View {
    let type: ErrorType
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    @State private var countdown: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(type.color)

            // Message
            VStack(alignment: .leading, spacing: 2) {
                Text(type.title)
                    .font(DSTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(type.color)

                if let subtitle = type.subtitle(countdown: countdown) {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                // Retry button (if applicable)
                if let retry = onRetry, type.showRetry {
                    Button(action: retry) {
                        Text("Retry")
                            .font(DSTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(type.color)
                    }
                }

                // Dismiss button
                if let dismiss = onDismiss, type.canDismiss {
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                .fill(type.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: DSCornerRadius.lg)
                        .strokeBorder(type.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .padding(.horizontal, DSSpacing.md)
        .onAppear {
            // Trigger haptic on error
            HapticManager.shared.warning()

            // Start countdown for rate limit
            if case .rateLimitExceeded(let seconds) = type {
                countdown = seconds
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            // SwiftUI native timer - no memory leak, automatically cleaned up
            if countdown > 0 {
                countdown -= 1
            }
        }
    }
}

// MARK: - Error Type

enum ErrorType {
    case offline
    case rateLimitExceeded(seconds: Int)
    case apiError
    case timeout

    var icon: String {
        switch self {
        case .offline:
            return "wifi.slash"
        case .rateLimitExceeded:
            return "clock.fill"
        case .apiError, .timeout:
            return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .offline:
            return .blue
        case .rateLimitExceeded:
            return .orange
        case .apiError, .timeout:
            return .red
        }
    }

    var backgroundColor: Color {
        color.opacity(0.1)
    }

    var title: String {
        switch self {
        case .offline:
            return "Internet connection required"
        case .rateLimitExceeded:
            return "Too many requests"
        case .apiError:
            return "A temporary error occurred"
        case .timeout:
            return "Request timed out"
        }
    }

    func subtitle(countdown: Int) -> String? {
        switch self {
        case .offline:
            return nil
        case .rateLimitExceeded:
            if countdown > 0 {
                let format = String(localized: "%lld seconds remaining")
                return String(format: format, countdown)
            } else {
                return String(localized: "You can try again")
            }
        case .apiError:
            return String(localized: "Please try again")
        case .timeout:
            return String(localized: "Please try again")
        }
    }

    var showRetry: Bool {
        switch self {
        case .offline:
            return false // Can't retry without internet
        case .rateLimitExceeded:
            return false // Must wait for countdown
        case .apiError, .timeout:
            return true
        }
    }

    var canDismiss: Bool {
        switch self {
        case .offline:
            return false // Can't dismiss offline warning
        case .rateLimitExceeded, .apiError, .timeout:
            return true
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ErrorBanner(
            type: .offline,
            onRetry: {},
            onDismiss: {}
        )

        ErrorBanner(
            type: .rateLimitExceeded(seconds: 45),
            onRetry: {},
            onDismiss: {}
        )

        ErrorBanner(
            type: .apiError,
            onRetry: {},
            onDismiss: {}
        )
    }
    .padding()
}
