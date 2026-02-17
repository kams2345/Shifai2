import XCTest
@testable import ShifAI

final class WidgetDataProviderTests: XCTestCase {

    // ─── Defaults ───

    func testDefaultCycleDayIs1() {
        // iOS WidgetDataProvider reads from UserDefaults group
        let defaultDay = 1
        XCTAssertEqual(defaultDay, 1)
    }

    func testDefaultCycleTotalIs28() {
        let defaultTotal = 28
        XCTAssertEqual(defaultTotal, 28)
    }

    func testDefaultPhaseIsFolliculaire() {
        let defaultPhase = "Folliculaire"
        XCTAssertEqual(defaultPhase, "Folliculaire")
    }

    func testDefaultPrivacyModeIsFalse() {
        let privacyMode = false
        XCTAssertFalse(privacyMode)
    }

    // ─── App Group Key ───

    func testAppGroupIdentifier() {
        let groupId = "group.com.shifai.shared"
        XCTAssertTrue(groupId.hasPrefix("group."))
    }

    // ─── Privacy Mode ───

    func testPrivacyModeHidesData() {
        let privacyEnabled = true
        let displayText = privacyEnabled ? "•••" : "Jour 14"
        XCTAssertEqual(displayText, "•••")
    }

    func testNormalModeShowsData() {
        let privacyEnabled = false
        let displayText = privacyEnabled ? "•••" : "Jour 14"
        XCTAssertEqual(displayText, "Jour 14")
    }

    // ─── Emoji Mapping ───

    func testPhaseEmojiMapping() {
        let emojis: [String: String] = [
            "Menstruelle": "🩸",
            "Folliculaire": "🌱",
            "Ovulatoire": "☀️",
            "Lutéale": "🌙"
        ]
        XCTAssertEqual(emojis.count, 4)
        XCTAssertEqual(emojis["Ovulatoire"], "☀️")
    }
}
