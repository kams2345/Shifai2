import XCTest
@testable import ShifAI

final class PatternDetectionEngineTests: XCTestCase {

    var engine: PatternDetectionEngine!

    override func setUp() {
        engine = PatternDetectionEngine()
    }

    // MARK: - Cycle Analysis

    func testCycleLengthCalculation_WithRegularCycle_Returns28() {
        // Given: 3 period start dates, 28 days apart
        let periods = [
            Date(timeIntervalSinceNow: -56 * 86400),
            Date(timeIntervalSinceNow: -28 * 86400),
            Date()
        ]

        // When
        let avgLength = engine.calculateAverageCycleLength(from: periods)

        // Then
        XCTAssertEqual(avgLength, 28, accuracy: 0.5, "Regular cycle should be ~28 days")
    }

    func testCycleLengthCalculation_WithSinglePeriod_ReturnsNil() {
        let periods = [Date()]
        let avgLength = engine.calculateAverageCycleLength(from: periods)
        XCTAssertNil(avgLength, "Need at least 2 periods for cycle length")
    }

    func testCycleRegularity_WithConsistentLengths_IsRegular() {
        let lengths = [28, 27, 29, 28, 28]
        let isRegular = engine.isRegular(cycleLengths: lengths)
        XCTAssertTrue(isRegular, "Cycles within ±2 days should be regular")
    }

    func testCycleRegularity_WithWideLengths_IsIrregular() {
        let lengths = [28, 35, 21, 40, 25]
        let isRegular = engine.isRegular(cycleLengths: lengths)
        XCTAssertFalse(isRegular, "Cycles varying >5 days should be irregular")
    }

    // MARK: - Phase Detection

    func testPhaseDetection_Day1_IsMenstrual() {
        let phase = engine.detectPhase(cycleDay: 1, cycleLength: 28)
        XCTAssertEqual(phase, .menstrual)
    }

    func testPhaseDetection_Day8_IsFollicular() {
        let phase = engine.detectPhase(cycleDay: 8, cycleLength: 28)
        XCTAssertEqual(phase, .follicular)
    }

    func testPhaseDetection_Day14_IsOvulatory() {
        let phase = engine.detectPhase(cycleDay: 14, cycleLength: 28)
        XCTAssertEqual(phase, .ovulatory)
    }

    func testPhaseDetection_Day21_IsLuteal() {
        let phase = engine.detectPhase(cycleDay: 21, cycleLength: 28)
        XCTAssertEqual(phase, .luteal)
    }

    // MARK: - Correlation

    func testPearsonCorrelation_PerfectPositive() {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        let r = engine.pearsonCorrelation(x: x, y: y)
        XCTAssertEqual(r, 1.0, accuracy: 0.001, "Perfect positive should be 1.0")
    }

    func testPearsonCorrelation_PerfectNegative() {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]
        let r = engine.pearsonCorrelation(x: x, y: y)
        XCTAssertEqual(r, -1.0, accuracy: 0.001, "Perfect negative should be -1.0")
    }

    func testPearsonCorrelation_InsufficientData_ReturnsZero() {
        let x = [1.0]
        let y = [2.0]
        let r = engine.pearsonCorrelation(x: x, y: y)
        XCTAssertEqual(r, 0.0, "Single data point should return 0")
    }

    // MARK: - Predictions

    func testNextPeriodPrediction_WithData_ReturnsDate() {
        let lastPeriod = Date(timeIntervalSinceNow: -20 * 86400) // 20 days ago
        let avgCycleLength = 28.0

        let prediction = engine.predictNextPeriod(lastStart: lastPeriod, avgLength: avgCycleLength)
        XCTAssertNotNil(prediction)

        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: prediction!).day!
        XCTAssertEqual(daysUntil, 8, accuracy: 1, "Should predict ~8 days from now")
    }
}
