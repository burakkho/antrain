import SwiftUI

/// Time input field using wheel pickers for minutes and seconds
struct DSTimeField: View {
    let title: String
    @Binding var duration: TimeInterval

    @State private var minutes: Int
    @State private var seconds: Int

    private let minuteRange = 0...60
    private let secondRange = 0...59

    init(title: String, duration: Binding<TimeInterval>) {
        self.title = title
        self._duration = duration

        // Initialize state from duration
        let totalSeconds = Int(duration.wrappedValue)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60

        self._minutes = State(initialValue: mins)
        self._seconds = State(initialValue: secs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textSecondary)
            }

            HStack(spacing: 0) {
                // Minutes Picker
                Picker("Minutes", selection: $minutes) {
                    ForEach(minuteRange, id: \.self) { minute in
                        Text("\(minute)")
                            .font(DSTypography.body)
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Text(":")
                    .font(DSTypography.title2)
                    .foregroundStyle(DSColors.textPrimary)
                    .padding(.horizontal, DSSpacing.xs)

                // Seconds Picker
                Picker("Seconds", selection: $seconds) {
                    ForEach(secondRange, id: \.self) { second in
                        Text(String(format: "%02d", second))
                            .font(DSTypography.body)
                            .tag(second)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)
            .onChange(of: minutes) { _, _ in
                updateDuration()
            }
            .onChange(of: seconds) { _, _ in
                updateDuration()
            }

            HStack {
                Text("\(minutes) min")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)

                Spacer()

                Text("\(seconds) sec")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    private func updateDuration() {
        duration = TimeInterval((minutes * 60) + seconds)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var duration: TimeInterval = 1200 // 20 minutes

        var body: some View {
            Form {
                Section {
                    DSTimeField(title: "Duration", duration: $duration)
                }

                Section {
                    Text("Total: \(Int(duration)) seconds")
                    Text("Time: \(Int(duration) / 60):\(String(format: "%02d", Int(duration) % 60))")
                }
            }
        }
    }

    return PreviewWrapper()
}
