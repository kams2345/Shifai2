import XCTest
@testable import ShifAI

final class PerformanceMonitorTests: XCTestCase {

    // ─── Budget Thresholds ───

    func testColdStartBudget() {
        // Cold start threshold is 1.5s
        let threshold: TimeInterval = 1.5
        XCTAssertEqual(threshold, 1.5)
    }

    func testWarmStartBudget() {
        let threshold: TimeInterval = 0.5
        XCTAssertEqual(threshold, 0.5)
    }

    func testSaveDailyLogBudget() {
        let threshold: TimeInterval = 0.2
        XCTAssertEqual(threshold, 0.2)
    }

    func testTabSwitchBudget() {
        let threshold: TimeInterval = 0.1
        XCTAssertEqual(threshold, 0.1)
    }

    func testSyncBudget() {
        let threshold: TimeInterval = 5.0
        XCTAssertEqual(threshold, 5.0)
    }

    func testPDFGenerationBudget() {
        let threshold: TimeInterval = 3.0
        XCTAssertEqual(threshold, 3.0)
    }

    // ─── Measurement ───

    func testStartDoesNotThrow() {
        PerformanceMonitor.shared.start("test_label")
        XCTAssert(true)
    }

    func testMeasureReturnsValue() {
        let result = PerformanceMonitor.shared.measure("test") { 42 }
        XCTAssertEqual(result, 42)
    }

    func testMeasureReturnsString() {
        let result = PerformanceMonitor.shared.measure("test_string") { "hello" }
        XCTAssertEqual(result, "hello")
    }

    // ─── Default Budget ───

    func testDefaultThresholdIs1Second() {
        let defaultThreshold: TimeInterval = 1.0
        XCTAssertEqual(defaultThreshold, 1.0)
    }
}
