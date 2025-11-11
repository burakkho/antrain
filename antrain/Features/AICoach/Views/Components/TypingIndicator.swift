//
//  TypingIndicator.swift
//  antrain
//
//  Created by AI Coach Feature
//

import SwiftUI

struct TypingIndicator: View {
    @State private var animationOffset: [CGFloat] = [0, 0, 0]

    var body: some View {
        HStack(alignment: .bottom, spacing: DSSpacing.xs) {
            // Gemini logo
            Image("gemini-logo")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())

            // Typing bubble
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset[index])
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                LinearGradient(
                    colors: [
                        DSColors.primary.opacity(0.8),
                        DSColors.primary.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
            )
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Animation

    private func startAnimation() {
        for index in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever()
                .delay(Double(index) * 0.2)
            ) {
                animationOffset[index] = -8
            }
        }
    }
}

#Preview {
    VStack {
        TypingIndicator()
        Spacer()
    }
    .padding()
}
