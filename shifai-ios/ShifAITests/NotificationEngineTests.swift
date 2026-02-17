import XCTest
@testable import ShifAI

final class NotificationEngineTests: XCTestCase {

    var engine: NotificationEngine!

    override func setUp() {
        engine = NotificationEngine.shared
        // Reset state
        UserDefaults.standard.removeObject(forKey: "last_notification_date")
        UserDefaults.standard.removeObject(forKey: "notification_ignore_counts")
    }

    // MARK: - Anti-Spam: Max 1/Day

    func testCanSendToday_FirstTime_ReturnsTrue() {
        XCTAssertTrue(engine.canSendToday(), "First notification of day should be allowed")
    }

    func testCanSendToday_AfterSending_ReturnsFalse() {
        UserDefaults.standard.set(Date(), forKey: "last_notification_date")
        XCTAssertFalse(engine.canSendToday(), "Second notification same day should be blocked")
    }

    func testCanSendToday_NextDay_ReturnsTrue() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: "last_notification_date")
        XCTAssertTrue(engine.canSendToday(), "Next day should allow notifications again")
    }

    // MARK: - Category Toggles

    func testCategoryEnabled_Default_IsTrue() {
        for category in NotificationEngine.NotificationCategory.allCases {
            XCTAssertTrue(engine.isCategoryEnabled(category),
                "Category \(category.rawValue) should be enabled by default")
        }
    }

    func testCategoryDisabled_AfterToggle_ReturnsFalse() {
        let category = NotificationEngine.NotificationCategory.cyclePrediction
        engine.setCategoryEnabled(category, enabled: false)
        XCTAssertFalse(engine.isCategoryEnabled(category))
    }

    // MARK: - Auto-Stop

    func testAutoStop_Under3Ignores_NotStopped() {
        let category = NotificationEngine.NotificationCategory.recommendation
        engine.recordIgnore(category: category)
        engine.recordIgnore(category: category)
        XCTAssertFalse(engine.isAutoStopped(category), "2 ignores should not trigger auto-stop")
    }

    func testAutoStop_3Ignores_IsStopped() {
        let category = NotificationEngine.NotificationCategory.recommendation
        engine.recordIgnore(category: category)
        engine.recordIgnore(category: category)
        engine.recordIgnore(category: category)
        XCTAssertTrue(engine.isAutoStopped(category), "3 consecutive ignores should auto-stop")
    }

    // MARK: - Quiet Hours

    func testQuietHours_At3AM_IsQuiet() {
        // Simulate 3AM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 3
        let date = Calendar.current.date(from: components)!
        XCTAssertTrue(engine.isQuietHours(at: date), "3AM should be quiet hours")
    }

    func testQuietHours_At10AM_IsNotQuiet() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 10
        let date = Calendar.current.date(from: components)!
        XCTAssertFalse(engine.isQuietHours(at: date), "10AM should not be quiet hours")
    }

    func testQuietHours_At23PM_IsQuiet() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        let date = Calendar.current.date(from: components)!
        XCTAssertTrue(engine.isQuietHours(at: date), "11PM should be quiet hours")
    }
}
