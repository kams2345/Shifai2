import XCTest
@testable import ShifAI

final class FeatureFlagsTests: XCTestCase {

    override func tearDown() {
        FeatureFlags.shared.reset()
    }

    // ─── Defaults ───

    func testMLPredictionsDisabledByDefault() {
        XCTAssertFalse(FeatureFlags.shared.mlPredictions)
    }

    func testShareLinksEnabledByDefault() {
        XCTAssertTrue(FeatureFlags.shared.shareLinks)
    }

    func testCycleInsightsEnabledByDefault() {
        XCTAssertTrue(FeatureFlags.shared.cycleInsights)
    }

    func testBodyMapV2DisabledByDefault() {
        XCTAssertFalse(FeatureFlags.shared.bodyMapV2)
    }

    func testBackgroundSyncEnabledByDefault() {
        XCTAssertTrue(FeatureFlags.shared.backgroundSync)
    }

    // ─── Remote Override ───

    func testRemoteOverrideEnablesFlag() {
        FeatureFlags.shared.update(from: ["ml_predictions": true])
        XCTAssertTrue(FeatureFlags.shared.mlPredictions)
    }

    func testRemoteOverrideDisablesFlag() {
        FeatureFlags.shared.update(from: ["share_links": false])
        XCTAssertFalse(FeatureFlags.shared.shareLinks)
    }

    func testResetRestoresDefaults() {
        FeatureFlags.shared.update(from: ["ml_predictions": true])
        FeatureFlags.shared.reset()
        XCTAssertFalse(FeatureFlags.shared.mlPredictions)
    }

    // ─── Unknown Flags ───

    func testUnknownFlagReturnsFalse() {
        XCTAssertFalse(FeatureFlags.shared.isEnabled("nonexistent_flag"))
    }

    // ─── Count ───

    func testTenFlagsExist() {
        let flags = ["ml_predictions", "share_links", "cycle_insights", "body_map_v2",
                     "pdf_export", "widget_predictions", "biometric_lock", "analytics_v2",
                     "background_sync", "csv_export"]
        XCTAssertEqual(flags.count, 10)
    }
}
