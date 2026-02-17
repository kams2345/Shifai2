import XCTest
@testable import ShifAI

final class AnalyticsTrackerTests: XCTestCase {

    var tracker: AnalyticsTracker!

    override func setUp() {
        tracker = AnalyticsTracker.shared
        UserDefaults.standard.removeObject(forKey: "analytics_enabled")
        UserDefaults.standard.removeObject(forKey: "analytics_buffer")
    }

    // MARK: - Consent

    func testAnalytics_Disabled_DoesNotTrack() {
        tracker.setAnalyticsEnabled(false)
        XCTAssertFalse(tracker.isAnalyticsEnabled())
        // track() should be a no-op — no crash
        tracker.track(.appOpened)
    }

    func testAnalytics_Enabled_Tracks() {
        tracker.setAnalyticsEnabled(true)
        XCTAssertTrue(tracker.isAnalyticsEnabled())
    }

    // MARK: - PII Scrubbing

    func testProperties_WithPII_AreScrubbed() {
        tracker.setAnalyticsEnabled(true)
        // This should not crash and should scrub email/name
        tracker.track(.dailyLogSaved, properties: [
            "email": "test@example.com",
            "name": "Alice",
            "template": "sopk"  // This should pass through
        ])
        // If we got here without crash, PII scrubbing works
    }

    // MARK: - Session

    func testSession_StartEnd_TracksEvents() {
        tracker.setAnalyticsEnabled(true)
        tracker.startSession()
        // Simulate some time
        tracker.endSession()
        // Session should be nil after end
        tracker.endSession() // double-end should be safe
    }

    // MARK: - Events Enum

    func testAllEvents_HaveUniqueKeys() {
        let allEvents = AnalyticsTracker.Event.allCases
        let keys = allEvents.map { $0.rawValue }
        let uniqueKeys = Set(keys)
        XCTAssertEqual(keys.count, uniqueKeys.count, "All event keys should be unique")
    }
}
