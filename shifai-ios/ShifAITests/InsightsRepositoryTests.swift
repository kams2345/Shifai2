import XCTest
@testable import ShifAI

final class InsightsRepositoryTests: XCTestCase {

    // ─── Offline-First ───

    func testSavedInsightMarkedUnsynced() {
        let insight = InsightRecord(type: "prediction", title: "Test", body: "Body")
        XCTAssertFalse(insight.isSynced)
    }

    func testDefaultSourceIsRuleBased() {
        let insight = InsightRecord(type: "correlation", title: "Test", body: "Body")
        XCTAssertEqual(insight.source, "rule_based")
    }

    // ─── Confidence ───

    func testConfidenceClampedToMax1() {
        let insight = InsightRecord(type: "prediction", title: "T", body: "B", confidence: 1.5)
        XCTAssertEqual(insight.confidence, 1.0)
    }

    func testConfidenceClampedToMin0() {
        let insight = InsightRecord(type: "prediction", title: "T", body: "B", confidence: -0.5)
        XCTAssertEqual(insight.confidence, 0.0)
    }

    func testValidConfidencePassesThrough() {
        let insight = InsightRecord(type: "prediction", title: "T", body: "B", confidence: 0.85)
        XCTAssertEqual(insight.confidence, 0.85, accuracy: 0.001)
    }

    // ─── Read Status ───

    func testDefaultUnread() {
        let insight = InsightRecord(type: "recommendation", title: "T", body: "B")
        XCTAssertFalse(insight.isRead)
    }

    func testFeedbackDefaultNil() {
        let insight = InsightRecord(type: "recommendation", title: "T", body: "B")
        XCTAssertNil(insight.feedback)
    }

    // ─── Identifiable ───

    func testUniqueIds() {
        let i1 = InsightRecord(type: "a", title: "T", body: "B")
        let i2 = InsightRecord(type: "b", title: "T", body: "B")
        XCTAssertNotEqual(i1.id, i2.id)
    }

    // ─── Table Name ───

    func testDatabaseTableName() {
        XCTAssertEqual(InsightRecord.databaseTableName, "insights")
    }

    // ─── Types ───

    func testInsightTypes() {
        let types = ["prediction", "correlation", "recommendation"]
        XCTAssertEqual(types.count, 3)
    }
}
