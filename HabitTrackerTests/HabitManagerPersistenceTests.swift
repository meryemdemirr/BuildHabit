import XCTest
import SwiftUI
@testable import HabitTracker

final class HabitManagerPersistenceTests: XCTestCase {
    private let userA = "persist-user-a"
    private let userB = "persist-user-b"
    private let keyA = "saved_habits_user_persist-user-a"
    private let keyB = "saved_habits_user_persist-user-b"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: keyA)
        UserDefaults.standard.removeObject(forKey: keyB)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: keyA)
        UserDefaults.standard.removeObject(forKey: keyB)
        super.tearDown()
    }

    private func makeHabit(title: String = "Test Habit", frequency: HabitFrequency = .daily) -> Habit {
        Habit(
            title: title,
            icon: "star.fill",
            color: .blue,
            createdAt: Date(),
            frequency: frequency
        )
    }

    func testAddHabitAssignsCurrentUserId() {
        let manager = HabitManager(initialUserId: userA)
        manager.deleteAllHabits()

        manager.addHabit(makeHabit())

        XCTAssertEqual(manager.habits.count, 1)
        XCTAssertEqual(manager.habits.first?.userId, userA)
    }

    func testHabitsPersistAndLoadForSameUser() {
        let managerA = HabitManager(initialUserId: userA)
        managerA.deleteAllHabits()
        managerA.addHabit(makeHabit(title: "Persisted"))

        let reloadedManager = HabitManager(initialUserId: userA)

        XCTAssertEqual(reloadedManager.habits.count, 1)
        XCTAssertEqual(reloadedManager.habits.first?.title, "Persisted")
    }

    func testSwitchingUserLoadsDifferentHabitList() {
        let manager = HabitManager(initialUserId: userA)
        manager.deleteAllHabits()
        manager.addHabit(makeHabit(title: "User A Habit"))

        manager.setCurrentUser(userB)
        manager.deleteAllHabits()
        manager.addHabit(makeHabit(title: "User B Habit"))

        XCTAssertEqual(manager.habits.count, 1)
        XCTAssertEqual(manager.habits.first?.title, "User B Habit")

        manager.setCurrentUser(userA)
        XCTAssertEqual(manager.habits.count, 1)
        XCTAssertEqual(manager.habits.first?.title, "User A Habit")
    }

    func testResetAllCompletionProgressClearsDatesAndStreak() {
        let manager = HabitManager(initialUserId: userA)
        manager.deleteAllHabits()

        var habit = makeHabit()
        let today = Calendar.current.startOfDay(for: Date())
        habit.completionDates = [today]
        habit.streak = 4
        manager.addHabit(habit)

        manager.resetAllCompletionProgress()

        XCTAssertEqual(manager.habits.first?.streak, 0)
        XCTAssertEqual(manager.habits.first?.completionDates.count, 0)
    }

    func testHabitsForDateFiltersBasedOnFrequencyRules() {
        let manager = HabitManager(initialUserId: userA)
        manager.deleteAllHabits()
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: Date())
        let nextDay = calendar.date(byAdding: .day, value: 1, to: targetDate)!

        var weekly = makeHabit(title: "Weekly", frequency: .weekly)
        weekly.createdAt = targetDate
        weekly.scheduledDates = [targetDate]

        manager.addHabit(makeHabit(title: "Daily", frequency: .daily))
        manager.addHabit(weekly)

        let todayHabits = manager.habitsForDate(targetDate).map(\.title)
        let nextDayHabits = manager.habitsForDate(nextDay).map(\.title)

        XCTAssertTrue(todayHabits.contains("Daily"))
        XCTAssertTrue(todayHabits.contains("Weekly"))
        XCTAssertFalse(nextDayHabits.contains("Daily"))
        XCTAssertFalse(nextDayHabits.contains("Weekly"))
    }
}
