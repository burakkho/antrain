import SwiftUI

/// Profile view with user information and bodyweight tracking
struct ProfileView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .kg
    @State private var viewModel: ProfileViewModel?
    @State private var showNameEditor = false
    @State private var showHeightEditor = false
    @State private var showGenderEditor = false
    @State private var showDateOfBirthEditor = false
    @State private var showActivityLevelEditor = false
    @State private var showBodyweightEntry = false
    @State private var showBodyweightHistory = false
    @State private var showSettings = false

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

    var body: some View {
        NavigationStack {
            if let viewModel {
                Form {
                    // Profile Section
                    Section("Profile") {
                        Button(action: { showNameEditor = true }) {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(viewModel.userProfile?.name.isEmpty == false ? viewModel.userProfile!.name : String(localized: "Not set"))
                                    .foregroundStyle(DSColors.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)

                        Button(action: { showHeightEditor = true }) {
                            HStack {
                                Text("Height")
                                Spacer()
                                if let height = viewModel.userProfile?.height {
                                    Text(height.formattedHeight(unit: weightUnit.rawValue))
                                        .foregroundStyle(DSColors.textSecondary)
                                } else {
                                    Text(String(localized: "Not set"))
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)

                        Button(action: { showGenderEditor = true }) {
                            HStack {
                                Text("Gender")
                                Spacer()
                                Text(viewModel.userProfile?.gender?.rawValue ?? String(localized: "Not set"))
                                    .foregroundStyle(DSColors.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)

                        Button(action: { showDateOfBirthEditor = true }) {
                            HStack {
                                Text("Date of Birth")
                                Spacer()
                                if let age = viewModel.userProfile?.age {
                                    Text("\(age) \(String(localized: "years old"))")
                                        .foregroundStyle(DSColors.textSecondary)
                                } else {
                                    Text(String(localized: "Not set"))
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)

                        Button(action: { showActivityLevelEditor = true }) {
                            HStack {
                                Text("Activity Level")
                                Spacer()
                                Text(viewModel.userProfile?.activityLevel?.rawValue ?? String(localized: "Not set"))
                                    .foregroundStyle(DSColors.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }
                        .foregroundStyle(DSColors.textPrimary)
                    }

                    // Bodyweight Tracking Section
                    Section("Bodyweight Tracking") {
                        // Current Weight
                        if let currentWeight = viewModel.userProfile?.currentBodyweight {
                            HStack {
                                Text("Current Weight")
                                Spacer()
                                Text(currentWeight.weight.formattedWeight(unit: weightUnit.rawValue))
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .font(DSTypography.body)
                        } else {
                            Text("No bodyweight entries yet")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }

                        Button("Add Weight Entry") {
                            showBodyweightEntry = true
                        }

                        if viewModel.userProfile?.bodyweightEntries.isEmpty == false {
                            Button("View Weight History") {
                                showBodyweightHistory = true
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
                .sheet(isPresented: $showNameEditor) {
                    ProfileNameEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showHeightEditor) {
                    ProfileHeightEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showGenderEditor) {
                    ProfileGenderEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showDateOfBirthEditor) {
                    ProfileDateOfBirthEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showActivityLevelEditor) {
                    ProfileActivityLevelEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightEntry) {
                    ProfileBodyweightEntrySheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightHistory) {
                    ProfileBodyweightHistorySheet(viewModel: viewModel)
                }
                .fullScreenCover(isPresented: $showSettings) {
                    SettingsView()
                        .environmentObject(appDependencies)
                }
            } else {
                DSLoadingView(message: "Loading profile...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ProfileViewModel(userProfileRepository: appDependencies.userProfileRepository)
                Task {
                    await viewModel?.loadProfile()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppDependencies.preview)
}
