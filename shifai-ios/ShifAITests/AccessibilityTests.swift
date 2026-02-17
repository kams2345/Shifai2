import XCTest
@testable import ShifAI

final class AccessibilityTests: XCTestCase {

    // ─── Semantic Labels ───

    func testCycleDayLabel() {
        let label = AccessibilityHelpers.cycleDayLabel(day: 14, total: 28, phase: .ovulatory)
        XCTAssertEqual(label, "Jour 14 sur 28, phase ovulatoire")
    }

    func testSymptomIntensityLabel() {
        let label = AccessibilityHelpers.symptomIntensityLabel(name: "Crampes", intensity: 7)
        XCTAssertEqual(label, "Crampes, intensité 7 sur 10")
    }

    func testFlowIntensityLabel() {
        XCTAssertEqual(AccessibilityHelpers.flowLabel(0), "Flux : aucun")
        XCTAssertEqual(AccessibilityHelpers.flowLabel(1), "Flux : léger")
        XCTAssertEqual(AccessibilityHelpers.flowLabel(2), "Flux : moyen")
        XCTAssertEqual(AccessibilityHelpers.flowLabel(3), "Flux : abondant")
        XCTAssertEqual(AccessibilityHelpers.flowLabel(4), "Flux : très abondant")
    }

    func testConfidenceLabel() {
        XCTAssertEqual(AccessibilityHelpers.confidenceLabel(0.85), "Confiance : 85 %")
        XCTAssertEqual(AccessibilityHelpers.confidenceLabel(0.0), "Confiance : 0 %")
        XCTAssertEqual(AccessibilityHelpers.confidenceLabel(1.0), "Confiance : 100 %")
    }

    func testInsightLabelWithConfidence() {
        let label = AccessibilityHelpers.insightLabel(type: "Prédiction", confidence: 0.9)
        XCTAssertEqual(label, "Prédiction - Confiance 90 %")
    }

    func testInsightLabelWithoutConfidence() {
        let label = AccessibilityHelpers.insightLabel(type: "Recommandation", confidence: nil)
        XCTAssertEqual(label, "Recommandation")
    }

    // ─── Touch Target ───

    func testMinTouchTarget() {
        XCTAssertEqual(AccessibilityHelpers.minTouchTargetPoints, 44)
    }

    // ─── Contrast ───

    func testWhiteOnBlackMeetsAA() {
        XCTAssertTrue(AccessibilityHelpers.meetsContrastAA(
            foreground: .white, background: .black))
    }

    func testSimilarColorsFailAA() {
        let lightGray = UIColor(white: 0.8, alpha: 1)
        XCTAssertFalse(AccessibilityHelpers.meetsContrastAA(
            foreground: lightGray, background: .white))
    }
}
