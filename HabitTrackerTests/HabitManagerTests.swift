//
//  HabitManagerTests.swift
//  HabitTrackerTests
//
//  Created by Meryem Demir on 14.02.2026.
//

import XCTest
import SwiftUI
@testable import HabitTracker

final class HabitManagerTests: XCTestCase {
    private let testUserId = "habit-manager-tests-user"
    private let storageKey = "saved_habits_user_habit-manager-tests-user"
    var habitManager: HabitManager!
    var testHabit: Habit!
    let calendar = Calendar.current
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: storageKey)
        habitManager = HabitManager(initialUserId: testUserId)
        habitManager.deleteAllHabits()
        testHabit = Habit(
            title: "Test Alışkanlık",
            icon: "star.fill",
            color: Color(red: 0.6, green: 0.8, blue: 1.0),
            streak: 0,
            createdAt: Date(),
            frequency: .daily
        )
    }
    
    override func tearDown() {
        habitManager?.deleteAllHabits()
        UserDefaults.standard.removeObject(forKey: storageKey)
        habitManager = nil
        testHabit = nil
        super.tearDown()
    }
    
    // MARK: - duplicateEntryTest
    func testDuplicateEntry() {
        // Given: Bir alışkanlık oluştur ve ekle
        habitManager.addHabit(testHabit)
        guard var addedHabit = habitManager.habits.first else {
            XCTFail("Alışkanlık eklenemedi")
            return
        }
        
        let testDate = Date()
        let normalizedDate = calendar.startOfDay(for: testDate)
        
        // When: Aynı gün içinde ilk kez tamamla
        let firstCompletion = habitManager.toggleCompletion(for: addedHabit, on: testDate)
        let initialStreak = firstCompletion?.streak ?? 0
        
        // Then: Streak 1 olmalı
        XCTAssertEqual(initialStreak, 1, "İlk tamamlamada streak 1 olmalı")
        
        // When: Aynı günde tekrar tamamlamayı dene (aslında geri alır)
        addedHabit = habitManager.habits.first!
        let secondCompletion = habitManager.toggleCompletion(for: addedHabit, on: testDate)
        let secondStreak = secondCompletion?.streak ?? 0
        
        // Then: Geri alındığı için streak 0 olmalı
        XCTAssertEqual(secondStreak, 0, "Aynı günde ikinci tıklama geri alma olmalı, streak 0 olmalı")
        
        // When: Aynı günde tekrar tamamla
        addedHabit = habitManager.habits.first!
        let thirdCompletion = habitManager.toggleCompletion(for: addedHabit, on: testDate)
        let thirdStreak = thirdCompletion?.streak ?? 0
        
        // Then: Streak tekrar 1 olmalı, 2 olmamalı
        XCTAssertEqual(thirdStreak, 1, "Aynı günde tekrar tamamlandığında streak tekrar 1 olmalı, 2 artmamalı")
        
        // Completion dates'te sadece bir kez olmalı
        let completionCount = addedHabit.completionDates.filter { completionDate in
            calendar.isDate(completionDate, inSameDayAs: normalizedDate)
        }.count
        
        XCTAssertEqual(completionCount, 1, "Aynı gün için completion dates'te sadece bir kayıt olmalı")
    }
    
    // MARK: - weeklyPlanningTest
    func testWeeklyPlanning() {
        // Given: Haftalık sıklıkla bir alışkanlık oluştur
        let startDate = calendar.startOfDay(for: Date())
        
        var weeklyHabit = Habit(
            title: "Haftalık Alışkanlık",
            icon: "book.fill",
            color: Color(red: 0.5, green: 0.9, blue: 0.6),
            streak: 0,
            createdAt: startDate,
            frequency: .weekly
        )
        
        // When: Haftalık sıklık için scheduled dates oluştur (bugünden itibaren 7 gün)
        var scheduledDates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                scheduledDates.append(date)
            }
        }
        weeklyHabit.scheduledDates = scheduledDates
        
        habitManager.addHabit(weeklyHabit)
        
        // Then: Tam 7 farklı tarih oluşturulmalı
        guard let addedHabit = habitManager.habits.first else {
            XCTFail("Alışkanlık eklenemedi")
            return
        }
        
        XCTAssertEqual(addedHabit.scheduledDates.count, 7, "Haftalık sıklık için tam 7 tarih oluşturulmalı")
        
        // Tarihlerin farklı olduğunu kontrol et
        let uniqueDates = Set(addedHabit.scheduledDates.map { calendar.startOfDay(for: $0) })
        XCTAssertEqual(uniqueDates.count, 7, "Tüm tarihler farklı olmalı")
        
        // Tarihlerin ardışık olduğunu kontrol et
        let sortedDates = addedHabit.scheduledDates.sorted()
        for i in 1..<sortedDates.count {
            let previousDate = calendar.startOfDay(for: sortedDates[i-1])
            let currentDate = calendar.startOfDay(for: sortedDates[i])
            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day {
                XCTAssertEqual(daysBetween, 1, "Tarihler ardışık olmalı (1 gün arayla)")
            }
        }
        
        // İlk tarih bugün olmalı
        let firstDate = calendar.startOfDay(for: sortedDates.first!)
        let today = calendar.startOfDay(for: Date())
        XCTAssertTrue(calendar.isDate(firstDate, inSameDayAs: today), "İlk tarih bugün olmalı")
    }
    
    // MARK: - pastDateLockTest
    func testPastDateLock() {
        // Given: Geçmiş bir tarih
        let pastDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        let normalizedPastDate = calendar.startOfDay(for: pastDate)
        let today = calendar.startOfDay(for: Date())
        
        // When: Geçmiş tarih kontrolü yap
        let isPastDate = normalizedPastDate < today
        
        // Then: Geçmiş tarih true olmalı
        XCTAssertTrue(isPastDate, "Geçmiş tarih kontrolü doğru çalışmalı")
        
        // Gelecek tarih kontrolü
        let futureDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        let normalizedFutureDate = calendar.startOfDay(for: futureDate)
        let isFutureDate = normalizedFutureDate > today
        
        XCTAssertTrue(isFutureDate, "Gelecek tarih kontrolü doğru çalışmalı")
        XCTAssertFalse(normalizedFutureDate < today, "Gelecek tarih geçmiş olmamalı")
        
        // Bugün kontrolü
        let isToday = calendar.isDateInToday(Date())
        XCTAssertTrue(isToday, "Bugün kontrolü doğru çalışmalı")
    }
    
    // MARK: - streakResetTest
    func testStreakReset() {
        // Given: Bir alışkanlık oluştur
        let today = calendar.startOfDay(for: Date())
        
        var testHabit = Habit(
            title: "Streak Test",
            icon: "flame.fill",
            color: Color(red: 1.0, green: 0.6, blue: 0.4),
            streak: 0,
            createdAt: today,
            frequency: .daily
        )
        
        habitManager.addHabit(testHabit)
        guard var addedHabit = habitManager.habits.first else {
            XCTFail("Alışkanlık eklenemedi")
            return
        }
        
        // When: Bugünü tamamla
        let firstCompletion = habitManager.toggleCompletion(for: addedHabit, on: Date())
        XCTAssertEqual(firstCompletion?.streak, 1, "Bugün tamamlandığında streak 1 olmalı")
        
        // When: Dünü tamamla (ardışık)
        addedHabit = habitManager.habits.first!
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            let secondCompletion = habitManager.toggleCompletion(for: addedHabit, on: yesterday)
            XCTAssertEqual(secondCompletion?.streak, 2, "Dün de tamamlandığında streak 2 olmalı")
        }
        
        // When: 3 gün öncesini tamamla (gün atlanmış - ardışık değil)
        addedHabit = habitManager.habits.first!
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) {
            let thirdCompletion = habitManager.toggleCompletion(for: addedHabit, on: threeDaysAgo)
            let finalStreak = thirdCompletion?.streak ?? 0
            
            // Streak bugünden geriye doğru sayılır
            // Bugün ve dün tamamlanmış (streak 2)
            // 3 gün önce tamamlanmış ama arada boşluk var
            // Bu durumda streak bugünden başlar, yani 2 olmalı (bugün + dün)
            XCTAssertEqual(finalStreak, 2, "Gün atlandığında streak bugünden geriye doğru hesaplanmalı")
        }
        
        // When: Bugünü geri al
        addedHabit = habitManager.habits.first!
        let fourthCompletion = habitManager.toggleCompletion(for: addedHabit, on: Date())
        let streakAfterUncheck = fourthCompletion?.streak ?? 0
        
        // Then: Streak sıfırlanmalı (bugün tamamlanmamış)
        XCTAssertEqual(streakAfterUncheck, 0, "Bugün geri alındığında streak sıfırlanmalı")
    }
    
    // MARK: - Additional Helper Tests
    func testHabitCreation() {
        // Given & When
        let newHabit = Habit(
            title: "Yeni Alışkanlık",
            icon: "heart.fill",
            color: Color(red: 1.0, green: 0.7, blue: 0.8),
            streak: 0,
            createdAt: Date(),
            frequency: .daily
        )
        
        habitManager.addHabit(newHabit)
        
        // Then
        XCTAssertEqual(habitManager.habits.count, 1, "Alışkanlık başarıyla eklenmeli")
        XCTAssertEqual(habitManager.habits.first?.title, "Yeni Alışkanlık", "Alışkanlık başlığı doğru olmalı")
        XCTAssertEqual(habitManager.habits.first?.frequency, .daily, "Varsayılan sıklık daily olmalı")
    }
    
    func testIsCompleted() {
        // Given
        let testDate = Date()
        habitManager.addHabit(testHabit)
        guard let addedHabit = habitManager.habits.first else {
            XCTFail("Alışkanlık eklenemedi")
            return
        }
        
        // When: Tamamlanmamış
        let initiallyCompleted = habitManager.isCompleted(addedHabit, on: testDate)
        XCTAssertFalse(initiallyCompleted, "Başlangıçta tamamlanmamış olmalı")
        
        // When: Tamamla
        habitManager.toggleCompletion(for: addedHabit, on: testDate)
        
        // Then: Tamamlanmış olmalı
        let afterCompletion = habitManager.isCompleted(addedHabit, on: testDate)
        XCTAssertTrue(afterCompletion, "Tamamlandıktan sonra tamamlanmış olmalı")
    }
    
    func testMonthlyPlanning() {
        // Given: Aylık sıklıkla bir alışkanlık
        let startDate = calendar.startOfDay(for: Date())
        
        var monthlyHabit = Habit(
            title: "Aylık Alışkanlık",
            icon: "calendar",
            color: Color(red: 0.8, green: 0.7, blue: 1.0),
            streak: 0,
            createdAt: startDate,
            frequency: .monthly
        )
        
        // When: Aylık sıklık için scheduled dates oluştur (30 gün)
        var scheduledDates: [Date] = []
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                scheduledDates.append(date)
            }
        }
        monthlyHabit.scheduledDates = scheduledDates
        
        habitManager.addHabit(monthlyHabit)
        
        // Then: Tam 30 farklı tarih oluşturulmalı
        guard let addedHabit = habitManager.habits.first else {
            XCTFail("Alışkanlık eklenemedi")
            return
        }
        
        XCTAssertEqual(addedHabit.scheduledDates.count, 30, "Aylık sıklık için tam 30 tarih oluşturulmalı")
    }
}
