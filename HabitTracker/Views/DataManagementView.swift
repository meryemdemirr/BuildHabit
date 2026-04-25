//
//  DataManagementView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 18.04.2026.
//

import SwiftUI

/// Alışkanlık ve yerel uygulama verisi yönetimi (UserDefaults; Firebase’de habit senkronu yoktur).
struct DataManagementView: View {
    @EnvironmentObject private var habitManager: HabitManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var confirmResetProgress = false
    @State private var confirmResetAllData = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            List {
                Section {
                    Text("data_footer_note")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.vertical, 4)
                }
                
                Section {
                    destructiveActionRow(
                        icon: "arrow.counterclockwise.circle.fill",
                        title: NSLocalizedString("data_reset_progress_title", comment: ""),
                        subtitle: NSLocalizedString("data_reset_progress_subtitle", comment: "")
                    ) {
                        confirmResetProgress = true
                    }
                }
                
                Section {
                    destructiveActionRow(
                        icon: "exclamationmark.triangle.fill",
                        title: NSLocalizedString("data_reset_all_title", comment: ""),
                        subtitle: NSLocalizedString("data_reset_all_subtitle", comment: "")
                    ) {
                        confirmResetAllData = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("settings_data")
        .navigationBarTitleDisplayMode(.inline)
        .alert("warning", isPresented: $confirmResetProgress) {
            Button("cancel", role: .cancel) {}
            Button("reset", role: .destructive) {
                habitManager.resetAllCompletionProgress()
            }
        } message: {
            Text("data_reset_confirm")
        }
        .alert("warning", isPresented: $confirmResetAllData) {
            Button("cancel", role: .cancel) {}
            Button("reset", role: .destructive) {
                habitManager.deleteAllHabits()
                notificationManager.resetEveningReminderPreferences()
                themeManager.selectedTheme = .light
            }
        } message: {
            Text("data_reset_confirm")
        }
    }
    
    private func destructiveActionRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: .destructive, action: action) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 28, alignment: .center)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        DataManagementView()
            .environmentObject(HabitManager())
            .environmentObject(NotificationManager())
            .environmentObject(ThemeManager())
    }
}
