//
//  HabitManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let habitsStoragePrefix = "saved_habits_user_"
    private var currentUserId: String?
    
    init(initialUserId: String? = nil) {
        setCurrentUser(initialUserId)
    }

    func setCurrentUser(_ userId: String?) {
        let normalizedId = userId?.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeId = (normalizedId?.isEmpty == false) ? normalizedId : nil
        guard safeId != currentUserId else { return }
        currentUserId = safeId
        loadHabits()
    }
    
    // Habit ekle
    func addHabit(_ habit: Habit) {
        guard let currentUserId else { return }
        var habitForUser = habit
        habitForUser.userId = currentUserId
        habits.append(habitForUser)
        saveHabits()
    }
    
    // Habit güncelle
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    /// Tek bir alışkanlığı kaldırır (yerel depolama).
    func deleteHabit(_ habit: Habit) {
        let deletedHabitId = habit.id.uuidString
        let deletedUserId = currentUserId
        habits.removeAll { $0.id == habit.id }
        saveHabits()
        syncDeleteHabitFromFirestore(habitId: deletedHabitId, userId: deletedUserId)
    }
    
    /// Aktif kullanıcının tüm alışkanlıklarını kaldırır.
    func deleteAllHabits() {
        let deletedHabitIds = habits.map { $0.id.uuidString }
        let deletedUserId = currentUserId
        habits.removeAll()
        saveHabits()
        syncDeleteAllHabitsFromFirestore(habitIds: deletedHabitIds, userId: deletedUserId)
    }
    
    /// Tamamlama geçmişi ve serileri sıfırlanır; alışkanlık tanımları (sıklık, planlı günler vb.) kalır.
    func resetAllCompletionProgress() {
        habits = habits.map { habit in
            var h = habit
            h.completionDates = []
            h.streak = 0
            return h
        }
        saveHabits()
    }
    
    // Tarih bazlı tamamlama kontrolü
    func toggleCompletion(for habit: Habit, on date: Date) -> Habit? {
        guard var updatedHabit = habits.first(where: { $0.id == habit.id }) else {
            return nil
        }
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // O gün için tamamlanmış mı kontrol et
        let isCompleted = updatedHabit.completionDates.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: normalizedDate)
        }
        
        if isCompleted {
            // Tamamlamayı geri al
            updatedHabit.completionDates.removeAll { completionDate in
                calendar.isDate(completionDate, inSameDayAs: normalizedDate)
            }
            // Streak'i yeniden hesapla
            updatedHabit.streak = calculateStreak(for: updatedHabit)
        } else {
            // Tamamla - sadece o gün için
            updatedHabit.completionDates.append(normalizedDate)
            // Streak'i yeniden hesapla
            updatedHabit.streak = calculateStreak(for: updatedHabit)
        }
        
        updateHabit(updatedHabit)
        return updatedHabit
    }
    
    // Streak hesapla (ardışık tamamlanan günler)
    private func calculateStreak(for habit: Habit) -> Int {
        guard !habit.completionDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Bugünden geriye doğru say
        while true {
            let hasCompletion = habit.completionDates.contains { completionDate in
                calendar.isDate(completionDate, inSameDayAs: currentDate)
            }
            
            if hasCompletion {
                streak += 1
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDate
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Belirli bir tarihte tamamlanmış mı?
    func isCompleted(_ habit: Habit, on date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return habit.completionDates.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: normalizedDate)
        }
    }
    
    // Belirli bir tarihte var olan alışkanlıklar
    func habitsForDate(_ date: Date) -> [Habit] {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return habits.filter { habit in
            let habitDate = calendar.startOfDay(for: habit.createdAt ?? Date())
            
            // Alışkanlık oluşturulma tarihinden önce olamaz
            guard habitDate <= normalizedDate else { return false }
            
            // Daily: Sadece oluşturulma tarihinde
            if habit.frequency == .daily {
                return calendar.isDate(habitDate, inSameDayAs: normalizedDate)
            }
            
            // Weekly veya Monthly: Scheduled dates içinde mi kontrol et
            return habit.scheduledDates.contains { scheduledDate in
                calendar.isDate(scheduledDate, inSameDayAs: normalizedDate)
            }
        }
    }
    
    // Kaydet
    private func saveHabits() {
        guard let currentUserId else {
            habits.removeAll()
            NotificationCenter.default.post(name: .habitsDidChange, object: nil)
            return
        }
        let key = habitsStoragePrefix + currentUserId
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        NotificationCenter.default.post(name: .habitsDidChange, object: nil)
    }
    
    // Yükle
    private func loadHabits() {
        guard let currentUserId else {
            habits = []
            NotificationCenter.default.post(name: .habitsDidChange, object: nil)
            return
        }
        let key = habitsStoragePrefix + currentUserId
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded.filter { $0.userId.isEmpty || $0.userId == currentUserId }
            habits = habits.map { habit in
                var updated = habit
                if updated.userId.isEmpty {
                    updated.userId = currentUserId
                }
                return updated
            }
            saveHabits()
            return
        }
        habits = []
        NotificationCenter.default.post(name: .habitsDidChange, object: nil)
    }

    private func syncDeleteHabitFromFirestore(habitId: String, userId: String?) {
        guard let userId else { return }
        Task {
            do {
                let db = Firestore.firestore()
                try await db.collection("users")
                    .document(userId)
                    .collection("habits")
                    .document(habitId)
                    .delete()

                try await db.collection("habits").document(habitId).delete()

                let snapshot = try await db.collection("habits")
                    .whereField("userId", isEqualTo: userId)
                    .whereField("id", isEqualTo: habitId)
                    .getDocuments()
                if !snapshot.documents.isEmpty {
                    let batch = db.batch()
                    snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                    try await batch.commit()
                }
            } catch {
                print("Failed to sync habit deletion to Firestore: \(error.localizedDescription)")
            }
        }
    }

    private func syncDeleteAllHabitsFromFirestore(habitIds: [String], userId: String?) {
        guard let userId else { return }
        Task {
            do {
                let db = Firestore.firestore()
                let rootHabitsSnapshot = try await db.collection("habits")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                if !rootHabitsSnapshot.documents.isEmpty {
                    let batch = db.batch()
                    rootHabitsSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                    try await batch.commit()
                }

                if !habitIds.isEmpty {
                    let batch = db.batch()
                    for habitId in habitIds {
                        let scopedRef = db.collection("users")
                            .document(userId)
                            .collection("habits")
                            .document(habitId)
                        batch.deleteDocument(scopedRef)

                        let rootRef = db.collection("habits").document(habitId)
                        batch.deleteDocument(rootRef)
                    }
                    try await batch.commit()
                }
            } catch {
                print("Failed to sync delete-all to Firestore: \(error.localizedDescription)")
            }
        }
    }
}
