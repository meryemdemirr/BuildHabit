import XCTest
@testable import HabitTracker

final class HabitAddDraftTests: XCTestCase {
    func testPresetLibraryHasStableUniqueIDs() {
        let ids = PresetHabitTemplate.library.map(\.id)
        let unique = Set(ids)

        XCTAssertEqual(ids.count, unique.count, "Preset id'leri benzersiz olmalı.")
        XCTAssertFalse(ids.isEmpty, "Preset kütüphanesi boş olmamalı.")
    }

    func testPresetLibraryCoversExpectedCoreHabits() {
        let ids = Set(PresetHabitTemplate.library.map(\.id))

        XCTAssertTrue(ids.contains("water"))
        XCTAssertTrue(ids.contains("run"))
        XCTAssertTrue(ids.contains("read"))
        XCTAssertTrue(ids.contains("sleep"))
    }
}
