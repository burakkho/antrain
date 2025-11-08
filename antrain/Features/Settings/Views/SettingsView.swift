import SwiftUI

/// Settings view with app preferences and configuration
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .kg
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    // Notification Settings
    @ObservedObject private var notificationService = NotificationService.shared
    @State private var showNotificationSetup = false
    @State private var showToast = false
    @State private var toastMessage: LocalizedStringKey = ""
    @State private var toastType: DSToast.ToastType = .info
    @State private var showPermissionAlert = false

    enum WeightUnit: String, CaseIterable {
        case kg = "Kilograms"
        case lbs = "Pounds"

        var localizedName: LocalizedStringKey {
            switch self {
            case .kg:
                return "Kilograms"
            case .lbs:
                return "Pounds"
            }
        }
    }

    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"

        var localizedName: LocalizedStringKey {
            switch self {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .system:
                return "System"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {

                // Notifications Section
                Section {
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

                // Preferences Section
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }

                    Picker("Language", selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("Spanish").tag("es")
                        Text("Turkish").tag("tr")
                    }

                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
                .sheet(isPresented: $showNotificationSetup) {
                    NotificationSetupSheet()
                }
                .toast(
                    isPresented: $showToast,
                    message: toastMessage,
                    type: toastType,
                    duration: 3.0
                )
                .alert("Enable Notifications", isPresented: $showPermissionAlert) {
                    Button("Allow") {
                        Task {
                            await requestNotificationPermission()
                        }
                    }
                    Button("Not Now", role: .cancel) {
                        // User declined, nothing to do (toggle already off)
                    }
                } message: {
                    Text("Antrain needs permission to send you workout reminders")
                }
        }
    }

    // MARK: - Notification Helpers

    private func handleNotificationToggle(_ isEnabled: Bool) {
        if isEnabled {
            // Check if permission is already granted
            if notificationService.authorizationStatus == .notDetermined {
                showPermissionAlert = true
            } else if notificationService.authorizationStatus == .denied {
                showToast(message: "Please enable notifications in iOS Settings", type: .error)
            } else {
                // Permission already granted
                var updatedSettings = notificationService.settings
                updatedSettings.isEnabled = true
                Task {
                    await notificationService.updateSettings(updatedSettings)
                }
                showToast(message: "Notifications enabled", type: .success)
            }
        } else {
            var updatedSettings = notificationService.settings
            updatedSettings.isEnabled = false
            Task {
                await notificationService.updateSettings(updatedSettings)
            }
            showToast(message: "Notifications disabled", type: .info)
        }
    }

    private func requestNotificationPermission() async {
        do {
            try await notificationService.requestAuthorization()
            var updatedSettings = notificationService.settings
            updatedSettings.isEnabled = true
            await notificationService.updateSettings(updatedSettings)
            showToast(message: "Notifications enabled successfully", type: .success)
        } catch {
            showToast(message: "Permission denied", type: .error)
        }
    }

    private func showToast(message: LocalizedStringKey, type: DSToast.ToastType) {
        toastMessage = message
        toastType = type
        withAnimation {
            showToast = true
        }
    }
}

#Preview {
    SettingsView()
}
