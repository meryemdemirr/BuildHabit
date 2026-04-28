
//
//  NotificationsView.swift
//  HabitTracker
//

// NotificationsView.swift
// f49632d1e052debed37595ee644f310e3586b471

import SwiftUI

struct NotificationsView: View {
    private let habitsDidChangeNotification = Notification.Name("com.habittracker.habitsDidChange")

    @EnvironmentObject private var habitManager: HabitManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var notifications: [String] = []
    @State private var newNotification: String = ""
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: Binding(
                    get: { notificationManager.remindersEnabled },
                    set: { newValue in
                        notificationManager.setRemindersEnabled(newValue, habitManager: habitManager)
                    }
                )) {
                    Text("notif_enable_toggle")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                
                Text("notif_description")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("reminder_title")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Text("reminder_body")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
                .foregroundStyle(Color(.secondaryLabel))
                
                if let summary = notificationManager.nextReminderSummary {
                    Text(summary)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.label))
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .navigationTitle("notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
            notificationManager.refreshAuthorizationAndSummary()
        }
        .onReceive(NotificationCenter.default.publisher(for: habitsDidChangeNotification)) { _ in
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
        }
        .alert("notif_permission_title", isPresented: $notificationManager.showPermissionDeniedAlert) {
            Button("ok", role: .cancel) { }
        } message: {
            Text("notif_permission_message")
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(HabitManager())
            .environmentObject(NotificationManager())
    }
}



// f49632d1e052debed37595ee644f310e3586b471
