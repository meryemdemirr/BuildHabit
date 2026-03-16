//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import FirebaseCore

@main
struct HabitTrackerApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Firebase yapılandırmasını başlat
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
