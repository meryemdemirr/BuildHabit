//
//  HabitManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import Foundation
import SwiftUI

class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let habitsKey = "saved_habits"
    
    init() {
        loadHabits()
    }
    
    // Habit ekle
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    // Habit güncelle
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    // Habit sil
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
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
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
        NotificationCenter.default.post(name: .habitsDidChange, object: nil)
    }
    
    // Yükle
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}
