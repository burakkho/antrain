import SwiftUI

/// Data management section component
struct DataManagementSection: View {
    let onExport: () -> Void
    let onRecalculatePRs: () -> Void

    var body: some View {
        Section {
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
            Text("Export your data or recalculate personal records.")
                .font(DSTypography.caption)
        }
    }
}
