import SwiftUI

/// Settings view with profile, preferences, and goals
struct SettingsView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .kg
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var viewModel: SettingsViewModel?
    @State private var showNameEditor = false
    @State private var showHeightEditor = false
    @State private var showGenderEditor = false
    @State private var showDateOfBirthEditor = false
    @State private var showActivityLevelEditor = false
    @State private var showBodyweightEntry = false
    @State private var showBodyweightHistory = false

    enum WeightUnit: String, CaseIterable {
        case kg = "Kilograms"
        case lbs = "Pounds"
    }

    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }

    var body: some View {
        NavigationStack {
            if let viewModel {
                @Bindable var viewModel = viewModel
                Form {
                    // Profile Section
                    Section("Profile") {
                        Button(action: { showNameEditor = true }) {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(viewModel.userProfile?.name.isEmpty == false ? viewModel.userProfile!.name : "Not set")
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
                                    Text("Not set")
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
                                Text(viewModel.userProfile?.gender?.rawValue ?? "Not set")
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
                                    Text("\(age) years old")
                                        .foregroundStyle(DSColors.textSecondary)
                                } else {
                                    Text("Not set")
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
                                Text(viewModel.userProfile?.activityLevel?.rawValue ?? "Not set")
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
                .sheet(isPresented: $showNameEditor) {
                    NameEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showHeightEditor) {
                    HeightEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showGenderEditor) {
                    GenderEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showDateOfBirthEditor) {
                    DateOfBirthEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showActivityLevelEditor) {
                    ActivityLevelEditorSheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightEntry) {
                    SettingsBodyweightEntrySheet(viewModel: viewModel)
                }
                .sheet(isPresented: $showBodyweightHistory) {
                    SettingsBodyweightHistorySheet(viewModel: viewModel)
                }
            } else {
                DSLoadingView(message: "Loading settings...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(userProfileRepository: appDependencies.userProfileRepository)
                Task {
                    await viewModel?.loadProfile()
                }
            }
        }
    }
}

// MARK: - Height Editor Sheet

struct HeightEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: SettingsView.WeightUnit = .kg
    @Bindable var viewModel: SettingsViewModel
    @State private var height: Double = 170.0
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Height") {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $height, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(weightUnit == .kg ? "cm" : "in")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveHeight()
                        }
                    }
                    .disabled(isSaving || height <= 0)
                }
            }
        }
        .onAppear {
            if let currentHeight = viewModel.userProfile?.height {
                // Convert from cm if user uses imperial
                height = weightUnit == .lbs ? currentHeight.cmToInches() : currentHeight
            }
        }
    }

    private func saveHeight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Convert to cm if user entered inches (database always stores in cm)
            let heightInCm = weightUnit == .lbs ? height.inchesToCm() : height
            try await viewModel.updateHeight(heightInCm)
            dismiss()
        } catch {
            errorMessage = "Failed to save height: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Gender Editor Sheet

struct GenderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    @State private var selectedGender: UserProfile.Gender = .preferNotToSay
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Gender") {
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Gender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveGender()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedGender = viewModel.userProfile?.gender ?? .preferNotToSay
        }
    }

    private func saveGender() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateGender(selectedGender)
            dismiss()
        } catch {
            errorMessage = "Failed to save gender: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Date of Birth Editor Sheet

struct DateOfBirthEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Date of Birth",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)

                    if let age = calculateAge(from: selectedDate) {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(age) years old")
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                } header: {
                    Text("Your Date of Birth")
                } footer: {
                    Text("Your age is used to calculate your TDEE (Total Daily Energy Expenditure) for personalized calorie recommendations.")
                        .font(DSTypography.caption)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Date of Birth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveDateOfBirth()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            if let dateOfBirth = viewModel.userProfile?.dateOfBirth {
                selectedDate = dateOfBirth
            }
        }
    }

    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }

    private func saveDateOfBirth() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateDateOfBirth(selectedDate)
            dismiss()
        } catch {
            errorMessage = "Failed to save date of birth: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Activity Level Editor Sheet

struct ActivityLevelEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    @State private var selectedActivityLevel: UserProfile.ActivityLevel = .moderatelyActive
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Activity Level", selection: $selectedActivityLevel) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                    .font(DSTypography.body)
                                Text(activityLevelDescription(level))
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Your Activity Level")
                } footer: {
                    Text("Your activity level is used to calculate your TDEE (Total Daily Energy Expenditure) for personalized calorie recommendations.")
                        .font(DSTypography.caption)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Activity Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveActivityLevel()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            selectedActivityLevel = viewModel.userProfile?.activityLevel ?? .moderatelyActive
        }
    }

    private func activityLevelDescription(_ level: UserProfile.ActivityLevel) -> String {
        // Map to TDEECalculator.ActivityLevel to get description
        if let tdeeLevel = TDEECalculator.ActivityLevel(rawValue: level.rawValue) {
            return tdeeLevel.description
        }
        return ""
    }

    private func saveActivityLevel() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateActivityLevel(selectedActivityLevel)
            dismiss()
        } catch {
            errorMessage = "Failed to save activity level: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Name Editor Sheet

struct NameEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    @State private var name: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Name") {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveName()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            name = viewModel.userProfile?.name ?? ""
        }
    }

    private func saveName() async {
        isSaving = true
        errorMessage = nil

        do {
            try await viewModel.updateName(name)
            dismiss()
        } catch {
            errorMessage = "Failed to save name: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Settings Bodyweight Entry Sheet

struct SettingsBodyweightEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: SettingsView.WeightUnit = .kg
    @Bindable var viewModel: SettingsViewModel
    @State private var weight: Double = 70.0
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Enter Bodyweight") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(weightUnit == .kg ? "kg" : "lbs")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("How are you feeling?", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.error)
                    }
                }
            }
            .navigationTitle("Add Bodyweight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveBodyweight()
                        }
                    }
                    .disabled(isSaving || weight <= 0)
                }
            }
        }
    }

    private func saveBodyweight() async {
        isSaving = true
        errorMessage = nil

        do {
            // Convert to kg if user entered lbs (database always stores in kg)
            let weightInKg = weightUnit == .lbs ? weight.lbsToKg() : weight
            try await viewModel.addBodyweightEntry(
                weight: weightInKg,
                date: date,
                notes: notes.isEmpty ? nil : notes
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save bodyweight: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

// MARK: - Settings Bodyweight History Sheet

struct SettingsBodyweightHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: SettingsView.WeightUnit = .kg
    @Bindable var viewModel: SettingsViewModel
    @State private var entries: [BodyweightEntry] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    DSLoadingView(message: "Loading history...")
                } else if entries.isEmpty {
                    DSEmptyState(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "No History Yet",
                        message: "Add your first bodyweight entry to start tracking"
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                HStack {
                                    Text(entry.date, style: .date)
                                        .font(DSTypography.body)
                                    Spacer()
                                    Text(entry.weight.formattedWeight(unit: weightUnit.rawValue))
                                        .font(DSTypography.headline)
                                        .foregroundStyle(DSColors.primary)
                                }

                                if let notes = entry.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                            }
                            .padding(.vertical, DSSpacing.xxs)
                        }
                        .onDelete { indexSet in
                            Task {
                                await deleteEntries(at: indexSet)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Weight History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadHistory()
            }
        }
    }

    private func loadHistory() async {
        isLoading = true
        do {
            entries = try await viewModel.getBodyweightHistory()
            isLoading = false
        } catch {
            print("Failed to load bodyweight history: \(error)")
            isLoading = false
        }
    }

    private func deleteEntries(at indexSet: IndexSet) async {
        for index in indexSet {
            let entry = entries[index]
            do {
                try await viewModel.deleteBodyweightEntry(entry)
            } catch {
                print("Failed to delete entry: \(error)")
            }
        }
        await loadHistory()
    }
}


#Preview {
    SettingsView()
        .environmentObject(AppDependencies.preview)
}
