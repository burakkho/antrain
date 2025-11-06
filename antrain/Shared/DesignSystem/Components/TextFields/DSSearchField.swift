import SwiftUI

/// Debounced search field with built-in performance optimization
/// Prevents excessive API calls and main thread blocking during typing
struct DSSearchField: View {
    // MARK: - Properties

    let placeholder: LocalizedStringKey
    @Binding var text: String
    var debounceInterval: Duration = .milliseconds(300)
    var onDebounced: ((String) -> Void)?

    // MARK: - Private State

    @State private var debounceTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.textSecondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    // Cancel previous debounce task
                    debounceTask?.cancel()

                    // Create new debounce task
                    debounceTask = Task {
                        try? await Task.sleep(for: debounceInterval)

                        // Only trigger if not cancelled
                        if !Task.isCancelled {
                            await MainActor.run {
                                onDebounced?(newValue)
                            }
                        }
                    }
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    debounceTask?.cancel()
                    onDebounced?("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
    }
}

// MARK: - Preview

#Preview("Search Field") {
    VStack(spacing: DSSpacing.lg) {
        DSSearchField(
            placeholder: "Search exercises",
            text: .constant("")
        )

        DSSearchField(
            placeholder: "Search foods",
            text: .constant("chicken")
        )

        DSSearchField(
            placeholder: "Search templates",
            text: .constant("powerlifting"),
            debounceInterval: .milliseconds(500)
        )
    }
    .padding()
}
