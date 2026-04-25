//
//  ThemeManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Aydınlık"
    case dark = "Karanlık"
    case system = "Sistem"

    var localizedTitle: String {
        switch self {
        case .light: return NSLocalizedString("theme_light", comment: "")
        case .dark: return NSLocalizedString("theme_dark", comment: "")
        case .system: return NSLocalizedString("theme_system", comment: "")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("appTheme") var selectedTheme: AppTheme = .light
    
    var colorScheme: ColorScheme? {
        selectedTheme.colorScheme
    }
}
