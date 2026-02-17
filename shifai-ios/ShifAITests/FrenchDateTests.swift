import XCTest
@testable import ShifAI

final class FrenchDateTests: XCTestCase {

    // ─── Format Outputs ───

    func testShortFormatUsesSlashes() {
        let date = Date()
        let formatted = FrenchDate.short.string(from: date)
        XCTAssertTrue(formatted.contains("/"))
    }

    func testTimeFormatUsesColon() {
        let date = Date()
        let formatted = FrenchDate.time.string(from: date)
        XCTAssertTrue(formatted.contains(":"))
    }

    func testFullFormatContainsYear() {
        let date = Date()
        let formatted = FrenchDate.full.string(from: date)
        XCTAssertTrue(formatted.contains("2026"))
    }

    // ─── Cycle Day ───

    func testCycleDayFormat() {
        let result = FrenchDate.cycleDay(14, phase: "folliculaire")
        XCTAssertEqual(result, "Jour 14 — folliculaire")
    }

    func testCycleDay1() {
        let result = FrenchDate.cycleDay(1, phase: "menstruel")
        XCTAssertTrue(result.hasPrefix("Jour 1"))
    }

    // ─── Days Until ───

    func testDaysUntilToday() {
        let result = FrenchDate.daysUntil(Date())
        XCTAssertEqual(result, "Aujourd'hui")
    }

    func testDaysUntilTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let result = FrenchDate.daysUntil(tomorrow)
        XCTAssertEqual(result, "Demain")
    }

    func testDaysUntilFuture() {
        let future = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let result = FrenchDate.daysUntil(future)
        XCTAssertEqual(result, "Dans 5 jours")
    }

    // ─── Relative ───

    func testRelativeNotEmpty() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = FrenchDate.relative(yesterday)
        XCTAssertFalse(result.isEmpty)
    }

    // ─── Locale ───

    func testMonthYearNotEmpty() {
        let date = Date()
        let formatted = FrenchDate.monthYear.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }
}
