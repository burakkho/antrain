import SwiftUI

struct TypewriterTextView: View {
    let fullText: String
    let textColor: Color

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var isCompleted: Bool = false

    private let typingSpeed: TimeInterval = 0.015 // 15ms per character

    var body: some View {
        Text(markdownText)
            .font(DSTypography.body)
            .foregroundColor(textColor)
            .textSelection(.enabled)
            .onTapGesture {
                if isAnimating {
                    skipAnimation()
                }
            }
            .onAppear {
                if !isAnimating && displayedText.isEmpty {
                    startTyping()
                }
            }
    }

    private var markdownText: AttributedString {
        do {
            var attributedString = try AttributedString(
                markdown: displayedText,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )
            attributedString.font = DSTypography.body
            return attributedString
        } catch {
            return AttributedString(displayedText)
        }
    }

    private func startTyping() {
        isAnimating = true
        displayedText = ""
        currentIndex = 0
        typeNextCharacter()
    }

    private func typeNextCharacter() {
        guard currentIndex < fullText.count, !isCompleted else {
            isAnimating = false
            return
        }

        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        displayedText.append(fullText[index])
        currentIndex += 1

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(typingSpeed * 1_000_000_000))
            typeNextCharacter()
        }
    }

    private func skipAnimation() {
        isCompleted = true
        isAnimating = false
        displayedText = fullText
    }
}
