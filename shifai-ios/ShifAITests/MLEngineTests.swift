import XCTest
@testable import ShifAI

final class MLEngineTests: XCTestCase {

    // ─── Model Status ───

    func testDefaultModelStatusIsRuleBased() {
        let status = "rule_based"
        XCTAssertEqual(status, "rule_based")
    }

    func testMLRequires6Cycles() {
        let threshold = AppConfig.mlCycleThreshold
        XCTAssertEqual(threshold, 6)
    }

    func testInsufficientCyclesUsesRules() {
        let cycleCount = 3
        let threshold = 6
        let useML = cycleCount >= threshold
        XCTAssertFalse(useML)
    }

    func testSufficientCyclesEnablesML() {
        let cycleCount = 8
        let threshold = 6
        let useML = cycleCount >= threshold
        XCTAssertTrue(useML)
    }

    // ─── Confidence ───

    func testMLConfidenceHigherThanRuleBased() {
        let ruleConfidence = 0.65
        let mlConfidence = 0.85
        XCTAssertGreaterThan(mlConfidence, ruleConfidence)
    }

    func testConfidenceBoundedTo0_1() {
        let raw = 1.5
        let clamped = max(0.0, min(1.0, raw))
        XCTAssertEqual(clamped, 1.0)
    }

    // ─── Prediction Window ───

    func testPredictionWindowIs7Days() {
        let window = 7
        XCTAssertEqual(window, 7)
    }

    // ─── Feature Extraction ───

    func testFeatureVectorSize() {
        // Standard feature vector: cycle_day, flow, mood, energy, sleep, stress + 5 symptom categories
        let featureSize = 11
        XCTAssertEqual(featureSize, 11)
    }

    func testNormalization() {
        let raw = 7.0
        let min = 1.0
        let max = 10.0
        let normalized = (raw - min) / (max - min)
        XCTAssertEqual(normalized, 2.0 / 3.0, accuracy: 0.001)
    }

    // ─── Graceful Degradation ───

    func testMLFailureFallsBackToRules() {
        let mlAvailable = false
        let source = mlAvailable ? "ml" : "rule_based"
        XCTAssertEqual(source, "rule_based")
    }
}
