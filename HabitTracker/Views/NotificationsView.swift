//
//  NotificationsView.swift
//  HabitTracker
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var habitManager: HabitManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
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
                    Text("Bildirimleri Aç")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                
                Text("Açıkken, bugün için tamamlanmamış alışkanıkların varsa her gün akşam 18:00–22:00 arasında rastgele bir saatte hatırlatma alırsın.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
                
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
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
            notificationManager.refreshAuthorizationAndSummary()
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitsDidChange)) { _ in
            notificationManager.rescheduleEveningReminderIfNeeded(habitManager: habitManager)
        }
        .alert("Bildirim izni gerekli", isPresented: $notificationManager.showPermissionDeniedAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Ayarlar > HabitTracker > Bildirimler bölümünden izin verebilirsin.")
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
