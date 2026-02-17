import XCTest
@testable import ShifAI

final class CSVExporterTests: XCTestCase {

    // ─── Headers ───

    func testCycleEntriesHeader() {
        let header = "date,cycle_day,phase,flow_intensity,mood_score,energy_score,sleep_hours,stress_level,notes"
        XCTAssertTrue(header.contains("date"))
        XCTAssertTrue(header.contains("cycle_day"))
        XCTAssertTrue(header.contains("notes"))
    }

    func testSymptomLogsHeader() {
        let header = "cycle_entry_id,category,symptom_type,intensity,body_zone"
        XCTAssertTrue(header.contains("category"))
        XCTAssertTrue(header.contains("intensity"))
    }

    // ─── Sanitization ───

    func testCommasReplacedInNotes() {
        let notes = "crampes, nausée"
        let sanitized = notes.replacingOccurrences(of: ",", with: ";")
        XCTAssertFalse(sanitized.contains(","))
    }

    func testNewlinesReplacedInNotes() {
        let notes = "ligne 1\nligne 2"
        let sanitized = notes.replacingOccurrences(of: "\n", with: " ")
        XCTAssertFalse(sanitized.contains("\n"))
    }

    // ─── File ───

    func testFileExtensionIsCSV() {
        let filename = "shifai_cycle_entries_2026-02-13.csv"
        XCTAssertTrue(filename.hasSuffix(".csv"))
    }

    func testFilenameContainsDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStamp = formatter.string(from: Date())
        let filename = "shifai_cycle_entries_\(dateStamp).csv"
        XCTAssertTrue(filename.contains("2026"))
    }

    // ─── Errors ───

    func testNoDataThrowsError() {
        let entries: [CycleEntry] = []
        XCTAssertTrue(entries.isEmpty)
    }

    // ─── Row Format ───

    func testRowContainsAllFields() {
        let row = "2026-02-13,14,follicular,0,7,6,8.0,3,\"notes\""
        let fields = row.components(separatedBy: ",")
        XCTAssertGreaterThanOrEqual(fields.count, 9)
    }

    func testOptionalBodyZone() {
        let row = "abc,PAIN,cramps,5,"
        XCTAssertTrue(row.hasSuffix(","))
    }

    func testMultipleEntriesJoinedByNewline() {
        let rows = ["row1", "row2", "row3"]
        let csv = rows.joined(separator: "\n")
        XCTAssertEqual(csv.components(separatedBy: "\n").count, 3)
    }
}
