import XCTest
import SwiftUI
@testable import HabitTracker

final class HabitModelTests: XCTestCase {
    private let calendar = Calendar.current

    func testIsCompletedReturnsTrueForSameDay() {
        let completion = calendar.date(from: DateComponents(year: 2026, month: 4, day: 20, hour: 9))!
        let checkDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 20, hour: 20))!

        var habit = Habit(
            title: "Su İç",
            icon: "drop.fill",
            color: .blue,
            createdAt: completion,
            frequency: .daily
        )
        habit.completionDates = [completion]

        XCTAssertTrue(habit.isCompleted(on: checkDate))
    }

    func testIsTrackedForDailyOnlyOnCreatedDay() {
        let createdAt = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        let anotherDay = calendar.date(from: DateComponents(year: 2026, month: 4, day: 19))!

        let habit = Habit(
            title: "Meditasyon",
            icon: "brain.head.profile",
            color: .purple,
            createdAt: createdAt,
            frequency: .daily
        )

        XCTAssertTrue(habit.isTracked(on: createdAt))
        XCTAssertFalse(habit.isTracked(on: anotherDay))
    }

    func testIsTrackedForWeeklyUsesScheduledDates() {
        let createdAt = calendar.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let scheduledOne = calendar.date(from: DateComponents(year: 2026, month: 4, day: 3))!
        let scheduledTwo = calendar.date(from: DateComponents(year: 2026, month: 4, day: 5))!
        let unscheduled = calendar.date(from: DateComponents(year: 2026, month: 4, day: 6))!

        var habit = Habit(
            title: "Koşu",
            icon: "figure.run",
            color: .orange,
            createdAt: createdAt,
            frequency: .weekly
        )
        habit.scheduledDates = [scheduledOne, scheduledTwo]

        XCTAssertTrue(habit.isTracked(on: scheduledOne))
        XCTAssertTrue(habit.isTracked(on: scheduledTwo))
        XCTAssertFalse(habit.isTracked(on: unscheduled))
    }

    func testDecodingLegacyHabitDefaultsMissingFields() throws {
        let legacyJSON = """
        {
          "id": "\(UUID().uuidString)",
          "title": "Legacy Habit",
          "icon": "star.fill",
          "color": { "red": 1, "green": 0.8, "blue": 0.5, "alpha": 1 },
          "streak": 3
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Habit.self, from: legacyJSON)

        XCTAssertEqual(decoded.userId, "")
        XCTAssertEqual(decoded.frequency, .daily)
        XCTAssertTrue(decoded.completionDates.isEmpty)
        XCTAssertTrue(decoded.scheduledDates.isEmpty)
    }
}
