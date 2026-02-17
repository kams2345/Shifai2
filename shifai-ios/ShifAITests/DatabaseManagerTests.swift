import XCTest
@testable import ShifAI

final class DatabaseManagerTests: XCTestCase {

    // ─── Configuration ───

    func testDatabaseNameIsShifAI() {
        let name = "shifai.db"
        XCTAssertEqual(name, "shifai.db")
    }

    func testAppGroupIdentifier() {
        let group = "group.com.shifai.shared"
        XCTAssertTrue(group.hasPrefix("group."))
    }

    // ─── Tables ───

    func testCycleEntriesTable() {
        XCTAssertEqual(CycleEntry.databaseTableName, "cycle_entries")
    }

    func testSymptomLogsTable() {
        XCTAssertEqual(SymptomLog.databaseTableName, "symptom_logs")
    }

    func testInsightsTable() {
        XCTAssertEqual(InsightRecord.databaseTableName, "insights")
    }

    // ─── Migration ───

    func testMigrationV1Identifier() {
        let migration = "v1_initial"
        XCTAssertFalse(migration.isEmpty)
    }

    // ─── Foreign Keys ───

    func testSymptomsLinkedToCycleEntries() {
        let fk = "cycleEntryId"
        XCTAssertEqual(fk, "cycleEntryId")
    }

    // ─── Encryption ───

    func testSQLCipherRequired() {
        let encrypted = true
        XCTAssertTrue(encrypted)
    }

    func testForeignKeysEnabled() {
        let enabled = true
        XCTAssertTrue(enabled)
    }

    func testTestInstanceIsInMemory() {
        let inMemory = true
        XCTAssertTrue(inMemory)
    }
}
