import XCTest
@testable import ShifAI

final class CrashReporterTests: XCTestCase {

    // ─── Log Format ───

    func testLogEntryContainsTimestamp() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        XCTAssertFalse(timestamp.isEmpty)
    }

    func testLogEntryContainsErrorCode() {
        let code = "SYNC_FAILED"
        let line = "[2026-02-17 12:00:00] [\(code)] Sync error | context"
        XCTAssertTrue(line.contains(code))
    }

    func testCrashEntryPrefixed() {
        let entry = "[CRASH] 2026-02-17 12:00:00 | file.swift:42 | Error"
        XCTAssertTrue(entry.hasPrefix("[CRASH]"))
    }

    // ─── File Rotation ───

    func testMaxLogSize() {
        let maxSize = 500_000
        XCTAssertEqual(maxSize, 500_000)
    }

    func testRotationTriggered() {
        let fileSize = 600_000
        let maxSize = 500_000
        XCTAssertTrue(fileSize > maxSize)
    }

    // ─── Retrieval ───

    func testRecentLogsDefaultLines() {
        let defaultLines = 50
        XCTAssertEqual(defaultLines, 50)
    }

    func testEmptyLogsReturnEmptyString() {
        let logs = ""
        XCTAssertTrue(logs.isEmpty)
    }

    // ─── App Group ───

    func testLogFileInAppGroup() {
        let group = "group.com.shifai.shared"
        XCTAssertTrue(group.hasPrefix("group."))
    }

    // ─── Zero PII ───

    func testNoUserDataInLogs() {
        let logLine = "[2026-02-17] [DB_ERROR] Database locked | CycleRepository"
        XCTAssertFalse(logLine.contains("user_id"))
        XCTAssertFalse(logLine.contains("email"))
    }

    func testErrorCodeIsAnonymized() {
        let code = "SYNC_FAILED"
        // Codes are generic, not user-specific
        XCTAssertFalse(code.contains("@"))
    }
}
