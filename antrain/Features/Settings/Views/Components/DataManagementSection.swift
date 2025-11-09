import SwiftUI

/// Data management section component
struct DataManagementSection: View {
    let onImport: () -> Void
    let onExport: () -> Void
    let onRecalculatePRs: () -> Void

    var body: some View {
        Section {
            // Import from CSV
            Button(action: onImport) {
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

            // Export to CSV
            Button(action: onExport) {
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

            // Recalculate PRs
            Button(action: onRecalculatePRs) {
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
    }
}
