import SwiftUI

/// Personal records section for workout summary
struct PRSectionView: View {
    let detectedPRs: [PersonalRecord]

    var body: some View {
        Section {
            ForEach(detectedPRs, id: \.id) { pr in
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(pr.exerciseName)
                            .font(.body)

                        Text("\(Int(pr.actualWeight)) kg × \(pr.reps)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("New PR")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.yellow)

                        Text("\(Int(pr.estimated1RM)) kg 1RM")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Personal Records")
        }
    }
}
