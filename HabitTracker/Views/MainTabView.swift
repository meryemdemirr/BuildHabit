//
//  MainTabView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var habitManager = HabitManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Ana Sayfa
            HomeView()
                .environmentObject(habitManager)
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
                .tag(0)
            
            // İstatistikler
            StatsView(habits: habitManager.habits)
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            
            // Ayarlar
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(Color(red: 0.95, green: 0.7, blue: 0.5))
        .onAppear {
            // TabBar arka planını blur efekti ile özelleştir
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
            
            // Seçili olmayan ikonlar için gri renk
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondaryLabel
            ]
            
            // Seçili ikonlar için ana renk
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
}
