//
//  RootView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .onAppear {
                        // Show splash for 2.5 seconds, then transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else if !authManager.isAuthenticated {
                // Authentication flow
                if !appState.isOnboardingComplete {
                    OnboardingView(isOnboardingComplete: Binding(
                        get: { appState.isOnboardingComplete },
                        set: { newValue in
                            appState.isOnboardingComplete = newValue
                            if newValue {
                                appState.completeOnboarding()
                            }
                        }
                    ))
                    .transition(.opacity)
                } else {
                    LoginView(authManager: authManager)
                        .transition(.opacity)
                }
            } else {
                // Main app
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.5), value: appState.isOnboardingComplete)
        .animation(.easeInOut(duration: 0.5), value: authManager.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environmentObject(AppStateManager())
        .environmentObject(AuthManager())
}
