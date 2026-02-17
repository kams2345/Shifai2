import XCTest
@testable import ShifAI

final class PredictionRecordTests: XCTestCase {

    // ─── Defaults ───

    func testDefaultSourceIsRuleBased() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertEqual(p.source, "rule_based")
    }

    func testDefaultConfidenceIsZero() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertEqual(p.confidence, 0)
    }

    func testDefaultUnsyncedAndNoActual() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertFalse(p.isSynced)
        XCTAssertNil(p.actualDate)
    }

    // ─── Confidence Clamping ───

    func testConfidenceClampedToMax1() {
        let p = PredictionRecord(type: "period", predictedDate: Date(), confidence: 1.5)
        XCTAssertEqual(p.confidence, 1.0)
    }

    func testConfidenceClampedToMin0() {
        let p = PredictionRecord(type: "period", predictedDate: Date(), confidence: -0.3)
        XCTAssertEqual(p.confidence, 0.0)
    }

    // ─── Accuracy ───

    func testAccuracyNilWhenNoActual() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertNil(p.accuracyDays)
    }

    func testAccuracyZeroWhenExact() {
        let date = Date()
        let p = PredictionRecord(type: "period", predictedDate: date, actualDate: date)
        XCTAssertEqual(p.accuracyDays, 0)
    }

    func testAccuracyPositiveWhenLate() {
        let predicted = Date()
        let actual = Calendar.current.date(byAdding: .day, value: 2, to: predicted)!
        let p = PredictionRecord(type: "period", predictedDate: predicted, actualDate: actual)
        XCTAssertEqual(p.accuracyDays, 2)
    }

    // ─── Table ───

    func testTableName() {
        XCTAssertEqual(PredictionRecord.databaseTableName, "predictions")
    }

    // ─── Identity ───

    func testUniqueIds() {
        let p1 = PredictionRecord(type: "period", predictedDate: Date())
        let p2 = PredictionRecord(type: "ovulation", predictedDate: Date())
        XCTAssertNotEqual(p1.id, p2.id)
    }
}
