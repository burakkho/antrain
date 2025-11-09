//
//  ThemeColorScheme.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// ViewModifier that applies theme-based color scheme (Light, Dark, System)
/// Extracted from MainTabView for reusability and single responsibility
struct ThemeColorScheme: ViewModifier {
    @AppStorage("appTheme") private var appTheme: String = "system"

    func body(content: Content) -> some View {
        content.preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil  // System default
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies app theme color scheme based on user preference
    /// - Returns: View with preferred color scheme applied
    func themedColorScheme() -> some View {
        modifier(ThemeColorScheme())
    }
}
