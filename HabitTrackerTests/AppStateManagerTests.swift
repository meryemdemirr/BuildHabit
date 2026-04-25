import XCTest
@testable import HabitTracker

final class AppStateManagerTests: XCTestCase {
    private let onboardingKey = "hasSeenOnboarding"
    private let legacyOnboardingKey = "hasCompletedOnboarding"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: legacyOnboardingKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: legacyOnboardingKey)
        super.tearDown()
    }

    func testLegacyValueMigratesWhenNewKeyMissing() {
        UserDefaults.standard.set(true, forKey: legacyOnboardingKey)

        let manager = AppStateManager()

        XCTAssertTrue(manager.isOnboardingComplete)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: onboardingKey))
    }

    func testCompleteOnboardingWritesBothKeys() {
        let manager = AppStateManager()

        manager.completeOnboarding()

        XCTAssertTrue(manager.isOnboardingComplete)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: onboardingKey))
        XCTAssertTrue(UserDefaults.standard.bool(forKey: legacyOnboardingKey))
    }

    func testResetOnboardingClearsBothKeys() {
        let manager = AppStateManager()
        manager.completeOnboarding()

        manager.resetOnboarding()

        XCTAssertFalse(manager.isOnboardingComplete)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: onboardingKey))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: legacyOnboardingKey))
    }
}
