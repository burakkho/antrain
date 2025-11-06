//
//  NotificationSetupSheet.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import SwiftUI

/// Onboarding sheet for setting up workout notifications
/// Shows when user wants to enable notifications for the first time
struct NotificationSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var notificationService = NotificationService.shared
    @State private var preferredTime = Date()
    @State private var isEnabling = false

    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.xl) {
                Spacer()

                // Icon
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(DSColors.primary)

                // Title
                Text("Stay on Track")
                    .font(DSTypography.title1)
                    .foregroundStyle(DSColors.textPrimary)

                // Description
                Text("Get reminded when it's time for your workout")
                    .font(DSTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DSColors.textSecondary)
                    .padding(.horizontal, DSSpacing.lg)

                // Time Picker
                VStack(spacing: DSSpacing.sm) {
                    Text("Preferred Time")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    DatePicker(
                        "Preferred Time",
                        selection: $preferredTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .padding(.top, DSSpacing.md)

                Spacer()

                // Actions
                VStack(spacing: DSSpacing.md) {
                    Button {
                        enableReminders()
                    } label: {
                        if isEnabling {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Enable Reminders")
                                .font(DSTypography.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(DSColors.primary)
                    .cornerRadius(DSCornerRadius.md)
                    .disabled(isEnabling)

                    Button {
                        dismiss()
                    } label: {
                        Text("Not Now")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .background(DSColors.backgroundSecondary)
                    .cornerRadius(DSCornerRadius.md)
                }
                .padding(.horizontal, DSSpacing.lg)
            }
            .padding(DSSpacing.lg)
            .navigationTitle("Workout Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundStyle(DSColors.textSecondary)
                }
            }
        }
        .onAppear {
            // Set initial time to current notification settings or default
            if let hour = notificationService.settings.preferredTime.hour,
               let minute = notificationService.settings.preferredTime.minute {
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                preferredTime = Calendar.current.date(from: components) ?? Date()
            }
        }
    }

    private func enableReminders() {
        isEnabling = true

        Task {
            do {
                // Request authorization
                try await notificationService.requestAuthorization()

                // Update settings
                var settings = NotificationSettings.defaultSettings
                settings.isEnabled = true
                settings.preferredTime = Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: preferredTime
                )

                await notificationService.updateSettings(settings)
                await notificationService.scheduleNextNotification()

                // Dismiss sheet
                await MainActor.run {
                    dismiss()
                }
            } catch {
                // Permission denied or error
                await MainActor.run {
                    isEnabling = false
                    // Could show error alert here if needed
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationSetupSheet()
}
