import SwiftUI
import UniformTypeIdentifiers

/// Settings view with app preferences and configuration
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies
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

    // Data Management
    @State private var showImportPicker = false
    @State private var showExportShare = false
    @State private var exportFileURL: URL?
    @State private var isImporting = false
    @State private var importProgress: String = ""

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

                // Data Management Section
                Section {
                    Button {
                        showImportPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundStyle(DSColors.primary)
                            VStack(alignment: .leading) {
                                Text("Import from CSV")
                                    .foregroundStyle(DSColors.textPrimary)
                                Text("Import from Hevy, Strong, Fitbod, etc.")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            Spacer()
                        }
                    }

                    Button {
                        Task { await exportWorkouts() }
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(DSColors.primary)
                            VStack(alignment: .leading) {
                                Text("Export to CSV")
                                    .foregroundStyle(DSColors.textPrimary)
                                Text("Backup your workout data")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            Spacer()
                        }
                    }

                    Button {
                        Task { await recalculatePRs() }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(DSColors.primary)
                            VStack(alignment: .leading) {
                                Text("Recalculate PRs")
                                    .foregroundStyle(DSColors.textPrimary)
                                Text("Fix personal record calculations")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Import workouts from other apps, export your data, or recalculate personal records.")
                        .font(DSTypography.caption)
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.2.0")
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
                .fileImporter(
                    isPresented: $showImportPicker,
                    allowedContentTypes: [.commaSeparatedText, .plainText],
                    allowsMultipleSelection: false
                ) { result in
                    Task { await handleImport(result) }
                }
                .sheet(item: $exportFileURL) { url in
                    ShareSheet(items: [url])
                }
                .overlay {
                    if isImporting {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()

                            VStack(spacing: DSSpacing.lg) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)

                                Text(importProgress)
                                    .font(DSTypography.body)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(DSSpacing.xl)
                            .background(.ultraThinMaterial)
                            .cornerRadius(DSCornerRadius.lg)
                            .shadow(radius: 20)
                        }
                    }
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

    // MARK: - Data Management Helpers

    private func handleImport(_ result: Result<[URL], Error>) async {
        do {
            let fileURL = try result.get().first
            guard let fileURL else { return }

            // Show loading
            isImporting = true
            importProgress = "Reading CSV file..."

            // Initialize services
            let exerciseRepo = appDependencies.exerciseRepository as! ExerciseRepository
            let exerciseNameMapper = ExerciseNameMapper(
                exerciseRepository: exerciseRepo
            )
            let importService = CSVImportService(
                exerciseNameMapper: exerciseNameMapper,
                exerciseRepository: exerciseRepo
            )

            // Import workouts
            importProgress = "Parsing workouts..."
            let (workouts, fixedOutliers) = try await importService.importWorkouts(from: fileURL)

            // Save to repository and detect PRs
            importProgress = "Saving \(workouts.count) workouts..."
            var totalPRs = 0

            for (index, workout) in workouts.enumerated() {
                // Update progress
                importProgress = "Saving workout \(index + 1)/\(workouts.count)..."

                try await appDependencies.workoutRepository.save(workout)

                // Detect PRs for this workout (only for lifting workouts)
                if workout.type == .lifting {
                    let prs = try await appDependencies.prDetectionService.detectAndSavePRs(from: workout)
                    totalPRs += prs.count
                }
            }

            // Hide loading
            isImporting = false

            // Build success message
            var message = "Imported \(workouts.count) workouts"
            if totalPRs > 0 {
                message += " with \(totalPRs) PRs"
            }
            if fixedOutliers > 0 {
                message += " (fixed \(fixedOutliers) typos)"
            }
            message += "!"

            showToast(
                message: LocalizedStringKey(stringLiteral: message),
                type: .success
            )
        } catch {
            isImporting = false
            showToast(
                message: "Import failed: \(error.localizedDescription)",
                type: .error
            )
        }
    }

    private func exportWorkouts() async {
        do {
            // Fetch all workouts
            let workouts = try await appDependencies.workoutRepository.fetchAll()

            guard !workouts.isEmpty else {
                showToast(message: "No workouts to export", type: .info)
                return
            }

            // Export to CSV
            let exportService = CSVExportService()
            let csvContent = exportService.exportWorkouts(workouts)
            let fileURL = try exportService.saveToFile(csvContent)

            // Show share sheet
            exportFileURL = fileURL
            showToast(
                message: "Exported \(workouts.count) workouts",
                type: .success
            )
        } catch {
            showToast(
                message: "Export failed: \(error.localizedDescription)",
                type: .error
            )
        }
    }

    private func recalculatePRs() async {
        do {
            // Show loading
            isImporting = true
            importProgress = "Fetching workouts..."

            // Fetch all workouts
            let workouts = try await appDependencies.workoutRepository.fetchAll()

            guard !workouts.isEmpty else {
                isImporting = false
                showToast(message: "No workouts found", type: .info)
                return
            }

            // Recalculate PRs
            importProgress = "Recalculating PRs from \(workouts.count) workouts..."
            try await appDependencies.prDetectionService.recalculateAllPRs(workouts: workouts)

            // Hide loading
            isImporting = false

            showToast(
                message: "PRs recalculated successfully!",
                type: .success
            )
        } catch {
            isImporting = false
            showToast(
                message: "Failed to recalculate PRs: \(error.localizedDescription)",
                type: .error
            )
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - URL Identifiable

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    SettingsView()
        .environmentObject(AppDependencies.preview)
}
