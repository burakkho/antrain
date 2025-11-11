import SwiftUI

/// Settings view with app preferences and configuration
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: SettingsViewModel?

    // App Storage
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .kg
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true

    // Notification Settings
    @ObservedObject private var notificationService = NotificationService.shared
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
                NotificationSettingsSection(
                    notificationService: notificationService,
                    showPermissionAlert: $showPermissionAlert,
                    onToast: { message, type in
                        viewModel?.showToastMessage(message, type: type)
                    }
                )

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

                // Feedback Section
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                        .onChange(of: hapticsEnabled) { _, newValue in
                            // Haptic feedback for both enable/disable
                            if newValue {
                                HapticManager.shared.light()
                            }
                        }
                }

                // Data Management Section
                DataManagementSection(
                    onExport: {
                        Task {
                            await viewModel?.exportWorkouts()
                        }
                    }
                )

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.3.0")
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
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
            .toast(
                isPresented: Binding(
                    get: { viewModel?.showToast ?? false },
                    set: { viewModel?.showToast = $0 }
                ),
                message: viewModel?.toastMessage ?? "",
                type: viewModel?.toastType ?? .info,
                duration: 3.0
            )
            .alert("Enable Notifications", isPresented: $showPermissionAlert) {
                Button("Allow") {
                    Task {
                        await requestNotificationPermission()
                    }
                }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text("Antrain needs permission to send you workout reminders")
            }
            .sheet(item: Binding(
                get: { viewModel?.exportFileURL },
                set: { viewModel?.exportFileURL = $0 }
            )) { url in
                ShareSheet(items: [url])
            }
            .overlay {
                if viewModel?.isLoading == true {
                    loadingOverlay
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = SettingsViewModel(
                        userProfileRepository: appDependencies.userProfileRepository,
                        workoutRepository: appDependencies.workoutRepository,
                        exerciseRepository: appDependencies.exerciseRepository
                    )
                }
            }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text(viewModel?.loadingMessage ?? "Loading...")
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

    // MARK: - Notification Permission

    private func requestNotificationPermission() async {
        do {
            try await notificationService.requestAuthorization()
            var updatedSettings = notificationService.settings
            updatedSettings.isEnabled = true
            await notificationService.updateSettings(updatedSettings)
            viewModel?.showToastMessage("Notifications enabled successfully", type: .success)
        } catch {
            viewModel?.showToastMessage("Permission denied", type: .error)
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
