//
//  NotificationManager.swift
//  HabitTracker
//

import Foundation
import SwiftUI
import UserNotifications

extension Notification.Name {
    static let habitsDidChange = Notification.Name("com.habittracker.habitsDidChange")
}

/// Akşam hatırlatıcıları: UNUserNotificationCenter, 18:00–22:00 arası rastgele günlük tetikleyici.
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let eveningReminderIdentifier = "habit.evening.reminder"
    
    private let defaultsEnabledKey = "habitEveningRemindersEnabled"
    private let defaultsHourKey = "habitEveningReminderHour"
    private let defaultsMinuteKey = "habitEveningReminderMinute"
    
    @Published private(set) var remindersEnabled: Bool
    @Published private(set) var nextReminderSummary: String?
    @Published var showPermissionDeniedAlert = false
    
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
    
    override init() {
        remindersEnabled = UserDefaults.standard.bool(forKey: defaultsEnabledKey)
        super.init()
        UNUserNotificationCenter.current().delegate = self
        refreshAuthorizationAndSummary()
    }
    
    /// Toggle: açılınca izin iste ve planla; kapanınca iptal et.
    func setRemindersEnabled(_ enabled: Bool, habitManager: HabitManager) {
        if !enabled {
            cancelEveningReminder()
            remindersEnabled = false
            UserDefaults.standard.set(false, forKey: defaultsEnabledKey)
            nextReminderSummary = nil
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    self.remindersEnabled = true
                    UserDefaults.standard.set(true, forKey: self.defaultsEnabledKey)
                    self.scheduleEveningReminderIfNeeded(habitManager: habitManager)
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionDeniedAlert = true
                    self.remindersEnabled = false
                    UserDefaults.standard.set(false, forKey: self.defaultsEnabledKey)
                    self.nextReminderSummary = nil
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        if granted {
                            self.remindersEnabled = true
                            UserDefaults.standard.set(true, forKey: self.defaultsEnabledKey)
                            self.scheduleEveningReminderIfNeeded(habitManager: habitManager)
                        } else {
                            self.showPermissionDeniedAlert = true
                            self.remindersEnabled = false
                            UserDefaults.standard.set(false, forKey: self.defaultsEnabledKey)
                            self.nextReminderSummary = nil
                        }
                    }
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.remindersEnabled = false
                    UserDefaults.standard.set(false, forKey: self.defaultsEnabledKey)
                }
            }
        }
    }
    
    /// Alışkanlıklar değişince veya uygulama açılınca yeniden planla.
    func rescheduleEveningReminderIfNeeded(habitManager: HabitManager) {
        guard remindersEnabled else { return }
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral else {
                DispatchQueue.main.async {
                    self.nextReminderSummary = nil
                }
                return
            }
            DispatchQueue.main.async {
                self.scheduleEveningReminderIfNeeded(habitManager: habitManager)
            }
        }
    }
    
    func refreshAuthorizationAndSummary() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let pending = requests.contains { $0.identifier == Self.eveningReminderIdentifier }
            DispatchQueue.main.async {
                if self.remindersEnabled, pending {
                    self.updateSummaryFromPendingList()
                } else if self.remindersEnabled {
                    self.nextReminderSummary = nil
                }
            }
        }
    }
    
    private func cancelEveningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.eveningReminderIdentifier])
    }
    
    private func scheduleEveningReminderIfNeeded(habitManager: HabitManager) {
        cancelEveningReminder()
        
        let today = Date()
        let incomplete = habitManager.habitsForDate(today).filter { !habitManager.isCompleted($0, on: today) }
        
        guard !incomplete.isEmpty else {
            nextReminderSummary = "Bugün tamamlanmayan alışkanlığın yok; akşam bildirimi gönderilmeyecek."
            return
        }
        
        let totalMinutes = Int.random(in: (18 * 60)...(22 * 60))
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        
        UserDefaults.standard.set(hour, forKey: defaultsHourKey)
        UserDefaults.standard.set(minute, forKey: defaultsMinuteKey)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Habit'ini unutma!"
        content.body = "Bugün henüz tamamlamadığın alışkanlıklar var"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: Self.eveningReminderIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.nextReminderSummary = "Bildirim planlanamadı: \(error.localizedDescription)"
                    return
                }
                if let next = trigger.nextTriggerDate() {
                    let timeStr = self.timeFormatter.string(from: next)
                    self.nextReminderSummary = "Sonraki hatırlatma: \(timeStr)"
                } else {
                    self.nextReminderSummary = "Her gün saat \(String(format: "%02d:%02d", hour, minute)) civarında hatırlatma."
                }
            }
        }
    }
    
    private func updateSummaryFromPendingList() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            guard let req = requests.first(where: { $0.identifier == Self.eveningReminderIdentifier }),
                  let trigger = req.trigger as? UNCalendarNotificationTrigger,
                  let next = trigger.nextTriggerDate() else {
                DispatchQueue.main.async { self.nextReminderSummary = nil }
                return
            }
            let timeStr = self.timeFormatter.string(from: next)
            DispatchQueue.main.async {
                self.nextReminderSummary = "Sonraki hatırlatma: \(timeStr)"
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
