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
    
    private let onboardingKey = "hasSeenOnboarding"
    private let legacyOnboardingKey = "hasCompletedOnboarding"
    
    init() {
        migrateLegacyOnboardingKeyIfNeeded()
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
        
        NotificationCenter.default.addObserver(
            forName: .onboardingDidReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resetOnboarding()
        }
        
        NotificationCenter.default.addObserver(
            forName: .onboardingDidComplete,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        UserDefaults.standard.set(true, forKey: legacyOnboardingKey)
    }
    
    func resetOnboarding() {
        isOnboardingComplete = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
        UserDefaults.standard.set(false, forKey: legacyOnboardingKey)
    }
    
    private func migrateLegacyOnboardingKeyIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: onboardingKey) == nil else { return }
        let legacyValue = defaults.bool(forKey: legacyOnboardingKey)
        defaults.set(legacyValue, forKey: onboardingKey)
    }
}
