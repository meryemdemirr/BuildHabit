//
//  MainTabView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var notificationManager: NotificationManager
    private let profileAccent = Color(red: 0.97, green: 0.55, blue: 0.62)
    
    @StateObject private var habitManager = HabitManager()
    @State private var selectedTab = 0
    @State private var openedFromHome = false
    @State private var selectedDate = Date()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    selectedTab: $selectedTab,
                    openedFromHome: $openedFromHome,
                    selectedDate: $selectedDate
                )
                    .environmentObject(habitManager)
            }
            .tabItem {
                Label("tab_home", systemImage: "house.fill")
            }
            .tag(0)
            
            StatsView(habits: habitManager.habits, selectedDate: selectedDate)
                .tabItem {
                    Label("tab_statistics", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            
            NavigationStack {
                SettingsView(selectedTab: $selectedTab, openedFromHome: $openedFromHome)
                    .environmentObject(habitManager)
            }
            .tabItem {
                Label("tab_settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .environmentObject(habitManager)
        .environmentObject(notificationManager)
        .accentColor(profileAccent)
        .onChange(of: selectedTab) { _, newValue in
            if newValue != 2 {
                openedFromHome = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitsDidChange)) { _ in
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
        }
        .onChange(of: authManager.user?.uid) { _, newUserId in
            habitManager.setCurrentUser(newUserId)
            if newUserId == nil {
                selectedDate = Date()
            }
        }
        .onAppear {
            habitManager.setCurrentUser(authManager.user?.uid)
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondaryLabel
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
                red: 0.97,
                green: 0.55,
                blue: 0.62,
                alpha: 1.0
            )
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(
                    red: 0.97,
                    green: 0.55,
                    blue: 0.62,
                    alpha: 1.0
                )
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStateManager())
        .environmentObject(AuthManager())
        .environmentObject(ThemeManager())
        .environmentObject(NotificationManager())
}
