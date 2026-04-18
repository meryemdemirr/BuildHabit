//
//  MainTabView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @StateObject private var habitManager = HabitManager()
    @State private var selectedTab = 0
    @State private var openedFromHome = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab, openedFromHome: $openedFromHome)
                    .environmentObject(habitManager)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            StatsView(habits: habitManager.habits)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            
            NavigationStack {
                SettingsView(selectedTab: $selectedTab, openedFromHome: $openedFromHome)
                    .environmentObject(habitManager)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .environmentObject(habitManager)
        .environmentObject(notificationManager)
        .accentColor(Color(red: 0.95, green: 0.7, blue: 0.5))
        .onChange(of: selectedTab) { _, newValue in
            if newValue != 2 {
                openedFromHome = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitsDidChange)) { _ in
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
        }
        .onAppear {
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
                red: 0.95,
                green: 0.7,
                blue: 0.5,
                alpha: 1.0
            )
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(
                    red: 0.95,
                    green: 0.7,
                    blue: 0.5,
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
