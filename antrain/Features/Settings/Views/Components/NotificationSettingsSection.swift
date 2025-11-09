import SwiftUI

/// Notification settings section component
struct NotificationSettingsSection: View {
    @ObservedObject var notificationService: NotificationService
    @Binding var showPermissionAlert: Bool
    let onToast: (LocalizedStringKey, DSToast.ToastType) -> Void

    var body: some View {
        Section {
            // Main notification toggle
            Toggle(isOn: Binding(
                get: { notificationService.settings.isEnabled },
                set: { newValue in
                    handleNotificationToggle(newValue)
                }
            )) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(DSColors.primary)
                    Text("Workout Reminders")
                }
            }

            // Show additional settings when enabled
            if notificationService.settings.isEnabled {
                // Notification Time
                DatePicker(
                    "Notification Time",
                    selection: Binding(
                        get: {
                            Calendar.current.date(from: notificationService.settings.preferredTime) ?? Date()
                        },
                        set: { newDate in
                            var updatedSettings = notificationService.settings
                            updatedSettings.preferredTime = Calendar.current.dateComponents(
                                [.hour, .minute],
                                from: newDate
                            )
                            Task {
                                await notificationService.updateSettings(updatedSettings)
                            }
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)

                // Active Days
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Active Days")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    DaySelectionChips(selectedDays: Binding(
                        get: { notificationService.settings.enabledDays },
                        set: { newDays in
                            var updatedSettings = notificationService.settings
                            updatedSettings.enabledDays = newDays
                            Task {
                                await notificationService.updateSettings(updatedSettings)
                            }
                        }
                    ))
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                // Rest Day Reminders
                Toggle("Rest Day Reminders", isOn: Binding(
                    get: { notificationService.settings.sendOnRestDays },
                    set: { newValue in
                        var updatedSettings = notificationService.settings
                        updatedSettings.sendOnRestDays = newValue
                        Task {
                            await notificationService.updateSettings(updatedSettings)
                        }
                    }
                ))
            }
        } header: {
            Text("Notifications")
        } footer: {
            if notificationService.settings.isEnabled {
                Text("Get reminded when it's time for your scheduled workout")
            } else if notificationService.authorizationStatus == .denied {
                Text("Notification permissions are required. Please enable in iOS Settings.")
            }
        }

        // iOS Settings Link (if permission denied)
        if notificationService.settings.isEnabled && notificationService.authorizationStatus != .authorized {
            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Open iOS Settings")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.caption)
                    }
                }
            }
        }
    }

    // MARK: - Notification Toggle Handler

    private func handleNotificationToggle(_ isEnabled: Bool) {
        if isEnabled {
            // Check if permission is already granted
            if notificationService.authorizationStatus == .notDetermined {
                showPermissionAlert = true
            } else if notificationService.authorizationStatus == .denied {
                onToast("Please enable notifications in iOS Settings", .error)
            } else {
                // Permission already granted
                var updatedSettings = notificationService.settings
                updatedSettings.isEnabled = true
                Task {
                    await notificationService.updateSettings(updatedSettings)
                }
                onToast("Notifications enabled", .success)
            }
        } else {
            var updatedSettings = notificationService.settings
            updatedSettings.isEnabled = false
            Task {
                await notificationService.updateSettings(updatedSettings)
            }
            onToast("Notifications disabled", .info)
        }
    }
}
