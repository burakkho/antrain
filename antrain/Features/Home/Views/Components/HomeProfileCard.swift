import SwiftUI
import SwiftData
import Foundation

struct HomeProfileCard: View {
    let profile: UserProfile
    let onTap: () -> Void

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    Text("Welcome, \(profile.name)")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(DSColors.textSecondary)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Height")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text(profile.height != nil ? "\(profile.height!, specifier: "%.0f") cm" : "N/A")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Weight")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text(profile.currentBodyweight?.weight != nil ? "\(profile.currentBodyweight!.weight, specifier: "%.1f") kg" : "N/A")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Fitness Level")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text(profile.fitnessLevel?.displayName ?? "N/A")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textPrimary)
                    }
                }
            }
            .padding(DSSpacing.md)
        }
    }
}
