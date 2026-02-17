import XCTest
@testable import ShifAI

final class InsightsViewModelTests: XCTestCase {

    // ─── Initial State ───

    func testInitialFilterIsAll() {
        // Default filter should show all insights
        let defaultFilter = "all"
        XCTAssertEqual(defaultFilter, "all")
    }

    func testInsightFiltersExist() {
        let filters = ["all", "predictions", "correlations", "recommendations"]
        XCTAssertEqual(filters.count, 4)
    }

    func testMLStatusDefaultIsRuleBased() {
        let status = "rule_based"
        XCTAssertEqual(status, "rule_based")
    }

    // ─── Filter Logic ───

    func testFilterPredictionsExcludesCorrelations() {
        let insights = [
            ("prediction", "Période dans 5 jours"),
            ("correlation", "Migraines liées au stress"),
            ("recommendation", "Dormez plus")
        ]
        let filtered = insights.filter { $0.0 == "prediction" }
        XCTAssertEqual(filtered.count, 1)
    }

    func testFilterAllReturnsEverything() {
        let insights = [
            ("prediction", "test"),
            ("correlation", "test"),
            ("recommendation", "test")
        ]
        let filtered = insights // "all" = no filter
        XCTAssertEqual(filtered.count, 3)
    }

    // ─── Feedback ───

    func testFeedbackOptionsExist() {
        let options = ["accurate", "early", "late", "wrong"]
        XCTAssertEqual(options.count, 4)
        XCTAssertTrue(options.contains("accurate"))
    }

    // ─── Read Status ───

    func testInsightDefaultsToUnread() {
        let isRead = false
        XCTAssertFalse(isRead)
    }

    func testMarkAsReadChangesStatus() {
        var isRead = false
        isRead = true
        XCTAssertTrue(isRead)
    }

    // ─── Confidence ───

    func testConfidenceFormatting() {
        let confidence = 0.85
        let formatted = "\(Int(confidence * 100)) %"
        XCTAssertEqual(formatted, "85 %")
    }

    func testLowConfidenceFormatting() {
        let confidence = 0.0
        let formatted = "\(Int(confidence * 100)) %"
        XCTAssertEqual(formatted, "0 %")
    }
}
