import SwiftUI

/// Data management section component
struct DataManagementSection: View {
    let onExport: () -> Void

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
        } header: {
            Text("Data Management")
        } footer: {
            Text("Export your workout data.")
                .font(DSTypography.caption)
        }
    }
}
