//
//  AppStateManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

class AppStateManager: ObservableObject {
    @Published var showSplash = true
    @Published var showOnboarding = false
    @Published var isOnboardingComplete = false
    
    init() {
        // Check if onboarding has been completed before
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
