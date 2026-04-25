import XCTest

final class LocalizationTests: XCTestCase {
    private enum TestError: Error {
        case missingFile(String)
        case unreadableStrings(String)
    }

    private var repoRootURL: URL {
        // .../BuildHabit/HabitTrackerTests/LocalizationTests.swift -> .../BuildHabit
        let fileURL = URL(fileURLWithPath: #filePath)
        return fileURL.deletingLastPathComponent().deletingLastPathComponent()
    }

    private func localizedStringsPath(language: String) -> String {
        repoRootURL
            .appendingPathComponent("HabitTracker")
            .appendingPathComponent("\(language).lproj")
            .appendingPathComponent("Localizable.strings")
            .path
    }

    private func loadStrings(language: String) throws -> [String: String] {
        let path = localizedStringsPath(language: language)
        guard FileManager.default.fileExists(atPath: path) else {
            throw TestError.missingFile(path)
        }

        guard let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            throw TestError.unreadableStrings(path)
        }
        return dict
    }

    func testLocalizableFilesExistForEnglishAndTurkish() {
        let enPath = localizedStringsPath(language: "en")
        let trPath = localizedStringsPath(language: "tr")

        XCTAssertTrue(FileManager.default.fileExists(atPath: enPath), "Missing file: \(enPath)")
        XCTAssertTrue(FileManager.default.fileExists(atPath: trPath), "Missing file: \(trPath)")
    }

    func testReminderStringsMatchExpectedValues() throws {
        let en = try loadStrings(language: "en")
        let tr = try loadStrings(language: "tr")

        XCTAssertEqual(en["reminder_title"], "Reminder")
        XCTAssertEqual(en["reminder_body"], "Don't forget to complete your habits today!")

        XCTAssertEqual(tr["reminder_title"], "Hatırlatma")
        XCTAssertEqual(tr["reminder_body"], "Bugün alışkanlıklarını tamamlamayı unutma!")
    }

    func testAppNameIsHabitStepsInBothLanguages() throws {
        let en = try loadStrings(language: "en")
        let tr = try loadStrings(language: "tr")

        XCTAssertEqual(en["auth_app_name"], "Habit Steps")
        XCTAssertEqual(tr["auth_app_name"], "Habit Steps")
    }

    func testCriticalKeysExistInBothLanguages() throws {
        let en = try loadStrings(language: "en")
        let tr = try loadStrings(language: "tr")

        let criticalKeys = [
            // Home
            "home_my_habits", "home_hello", "home_how_today",
            // Settings
            "settings", "settings_theme", "settings_sign_out",
            // Statistics
            "tab_statistics", "stats_daily_average", "stats_empty_title",
            // Onboarding
            "onboarding_page1_title", "onboarding_page2_title", "onboarding_page3_title"
        ]

        for key in criticalKeys {
            XCTAssertNotNil(en[key], "Missing EN key: \(key)")
            XCTAssertNotNil(tr[key], "Missing TR key: \(key)")
        }
    }

    func testProjectSetsDisplayNameToHabitSteps() throws {
        let pbxprojPath = repoRootURL
            .appendingPathComponent("HabitTracker.xcodeproj")
            .appendingPathComponent("project.pbxproj")
            .path

        guard FileManager.default.fileExists(atPath: pbxprojPath) else {
            throw TestError.missingFile(pbxprojPath)
        }

        let content = try String(contentsOfFile: pbxprojPath, encoding: .utf8)
        let expectedLine = "INFOPLIST_KEY_CFBundleDisplayName = \"Habit Steps\";"
        let occurrences = content.components(separatedBy: expectedLine).count - 1

        XCTAssertGreaterThanOrEqual(occurrences, 2, "Display name should be set for Debug and Release.")
    }
}
