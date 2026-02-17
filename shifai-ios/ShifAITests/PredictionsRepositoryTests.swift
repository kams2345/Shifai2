import XCTest
@testable import ShifAI

final class PredictionsRepositoryTests: XCTestCase {

    // ─── Save ───

    func testSavedPredictionMarkedUnsynced() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertFalse(p.isSynced)
    }

    // ─── Verification ───

    func testUnverifiedPredictionHasNilActual() {
        let p = PredictionRecord(type: "ovulation", predictedDate: Date())
        XCTAssertNil(p.actualDate)
    }

    func testVerifiedPredictionHasActualDate() {
        let date = Date()
        let p = PredictionRecord(type: "period", predictedDate: date, actualDate: date)
        XCTAssertNotNil(p.actualDate)
    }

    // ─── Accuracy ───

    func testAccuracyExact() {
        let date = Date()
        let p = PredictionRecord(type: "period", predictedDate: date, actualDate: date)
        XCTAssertEqual(p.accuracyDays, 0)
    }

    func testAccuracy2DaysLate() {
        let predicted = Date()
        let actual = Calendar.current.date(byAdding: .day, value: 2, to: predicted)!
        let p = PredictionRecord(type: "period", predictedDate: predicted, actualDate: actual)
        XCTAssertEqual(p.accuracyDays, 2)
    }

    func testAccuracy1DayEarly() {
        let predicted = Date()
        let actual = Calendar.current.date(byAdding: .day, value: -1, to: predicted)!
        let p = PredictionRecord(type: "period", predictedDate: predicted, actualDate: actual)
        XCTAssertEqual(p.accuracyDays, -1)
    }

    // ─── Types ───

    func testPredictionTypePeriod() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertEqual(p.type, "period")
    }

    func testPredictionTypeOvulation() {
        let p = PredictionRecord(type: "ovulation", predictedDate: Date())
        XCTAssertEqual(p.type, "ovulation")
    }

    // ─── Source ───

    func testDefaultSourceRuleBased() {
        let p = PredictionRecord(type: "period", predictedDate: Date())
        XCTAssertEqual(p.source, "rule_based")
    }

    func testMLSource() {
        let p = PredictionRecord(type: "period", predictedDate: Date(), source: "ml_model")
        XCTAssertEqual(p.source, "ml_model")
    }
}
