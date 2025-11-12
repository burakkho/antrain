import SwiftUI

/// Sheet displaying bodyweight history with delete functionality
struct ProfileBodyweightHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weightUnit") private var weightUnit: ProfileView.WeightUnit = .kg
    let viewModel: ProfileViewModel
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
                        ForEach(entries, id: \.id) { entry in
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
                    Button(String(localized: "Done")) {
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
