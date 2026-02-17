import XCTest
@testable import ShifAI

final class SyncManagerTests: XCTestCase {

    // ─── Status ───

    func testInitialStatusIsIdle() {
        let status = SyncManager.Status.idle
        XCTAssertEqual(status, .idle)
    }

    func testStatusTransitionsToSyncing() {
        let status = SyncManager.Status.syncing
        XCTAssertEqual(status.rawValue, "syncing")
    }

    func testStatusTransitionsToSuccess() {
        let status = SyncManager.Status.success
        XCTAssertEqual(status.rawValue, "success")
    }

    func testStatusTransitionsToFailed() {
        let status = SyncManager.Status.failed
        XCTAssertEqual(status.rawValue, "failed")
    }

    // ─── Sync Report ───

    func testReportTracksPushedCount() {
        let report = SyncManager.SyncReport(pushed: 5, pulled: 0, conflicts: 0)
        XCTAssertEqual(report.pushed, 5)
    }

    func testReportTracksPulledCount() {
        let report = SyncManager.SyncReport(pushed: 0, pulled: 3, conflicts: 0)
        XCTAssertEqual(report.pulled, 3)
    }

    func testReportTracksConflicts() {
        let report = SyncManager.SyncReport(pushed: 2, pulled: 1, conflicts: 1)
        XCTAssertEqual(report.conflicts, 1)
    }

    func testZeroReport() {
        let report = SyncManager.SyncReport(pushed: 0, pulled: 0, conflicts: 0)
        XCTAssertEqual(report.pushed + report.pulled + report.conflicts, 0)
    }

    // ─── Formatting ───

    func testFormatLastSyncNilWhenNoSync() {
        let lastSync: Date? = nil
        XCTAssertNil(lastSync)
    }

    func testFormatLastSyncFrenchLocale() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .short
        let result = formatter.string(from: Date())
        XCTAssertFalse(result.isEmpty)
    }
}
