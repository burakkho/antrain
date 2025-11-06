//
//  DSToast.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import SwiftUI

/// Toast notification component for temporary feedback messages
/// Usage: Success/error feedback, confirmation messages
struct DSToast: View {
    let message: LocalizedStringKey
    let type: ToastType
    let duration: TimeInterval

    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return DSColors.success
            case .error: return DSColors.error
            case .info: return DSColors.primary
            }
        }
    }

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundStyle(type.color)

            Text(message)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.textPrimary)

            Spacer()
        }
        .padding(DSSpacing.md)
        .background(DSColors.backgroundSecondary)
        .cornerRadius(DSCornerRadius.md)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal, DSSpacing.md)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: LocalizedStringKey
    let type: DSToast.ToastType
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if isPresented {
                DSToast(message: message, type: type, duration: duration)
                    .padding(.top, DSSpacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
                    .onAppear {
                        // Auto-dismiss after duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.3), value: isPresented)
    }
}

extension View {
    /// Show a toast notification
    /// - Parameters:
    ///   - isPresented: Binding to control visibility
    ///   - message: Message to display
    ///   - type: Toast type (success, error, info)
    ///   - duration: Auto-dismiss duration (default: 3 seconds)
    func toast(
        isPresented: Binding<Bool>,
        message: LocalizedStringKey,
        type: DSToast.ToastType = .info,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                message: message,
                type: type,
                duration: duration
            )
        )
    }
}

// MARK: - Preview

#Preview("Success Toast") {
    VStack {
        Text("Main Content")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toast(
        isPresented: .constant(true),
        message: "Notifications enabled successfully",
        type: .success
    )
}

#Preview("Error Toast") {
    VStack {
        Text("Main Content")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toast(
        isPresented: .constant(true),
        message: "Failed to schedule notification",
        type: .error
    )
}

#Preview("Info Toast") {
    VStack {
        Text("Main Content")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toast(
        isPresented: .constant(true),
        message: "Settings saved",
        type: .info
    )
}
