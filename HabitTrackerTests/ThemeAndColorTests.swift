import XCTest
import SwiftUI
@testable import HabitTracker

final class ThemeAndColorTests: XCTestCase {
    func testAppThemeColorSchemeMapping() {
        XCTAssertEqual(AppTheme.light.colorScheme, .light)
        XCTAssertEqual(AppTheme.dark.colorScheme, .dark)
        XCTAssertNil(AppTheme.system.colorScheme)
    }

    func testColorExtensionBackgroundOpacities() {
        let source = Color.red
        let paleRGBA = UIColor(source.paleBackground)
        let lightRGBA = UIColor(source.lightBackground)

        var paleAlpha: CGFloat = 0
        var lightAlpha: CGFloat = 0
        paleRGBA.getRed(nil, green: nil, blue: nil, alpha: &paleAlpha)
        lightRGBA.getRed(nil, green: nil, blue: nil, alpha: &lightAlpha)

        XCTAssertEqual(paleAlpha, 0.2, accuracy: 0.01)
        XCTAssertEqual(lightAlpha, 0.15, accuracy: 0.01)
    }

    func testPastelColorPaletteHasExpectedCount() {
        XCTAssertEqual(PastelColor.allCases.count, 6)
    }
}
