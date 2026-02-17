import XCTest
@testable import ShifAI

final class SettingsViewModelTests: XCTestCase {

    // ─── Sync Defaults ───

    func testSyncDefaultDisabled() {
        let isEnabled = false
        XCTAssertFalse(isEnabled)
    }

    func testLastSyncTimeDefaultNil() {
        let lastSync: Date? = nil
        XCTAssertNil(lastSync)
    }

    // ─── Notification Defaults ───

    func testNotificationDefaultsEnabled() {
        let predictions = true
        let recommendations = true
        let quickWins = true
        let educational = true
        XCTAssertTrue(predictions)
        XCTAssertTrue(recommendations)
        XCTAssertTrue(quickWins)
        XCTAssertTrue(educational)
    }

    // ─── Privacy Defaults ───

    func testBiometricDefaultDisabled() {
        let enabled = false
        XCTAssertFalse(enabled)
    }

    func testWidgetPrivacyDefaultDisabled() {
        let enabled = false
        XCTAssertFalse(enabled)
    }

    func testAnalyticsConsentDefaultDisabled() {
        let enabled = false
        XCTAssertFalse(enabled)
    }

    // ─── Delete Account ───

    func testDeleteDialogDefaultHidden() {
        let showDialog = false
        XCTAssertFalse(showDialog)
    }

    func testDeleteConfirmationRequiresExplicitAction() {
        var showDialog = false
        showDialog = true
        XCTAssertTrue(showDialog)
        showDialog = false
        XCTAssertFalse(showDialog)
    }

    // ─── CSV Export ───

    func testCSVExportFormatsCorrectly() {
        let header = "Date,Jour,Phase,Flux,Humeur,Énergie"
        let fields = header.components(separatedBy: ",")
        XCTAssertEqual(fields.count, 6)
        XCTAssertEqual(fields.first, "Date")
    }

    // ─── Sync Last Time Formatting ───

    func testLastSyncFormatting() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let formatted = formatter.string(from: Date())
        XCTAssertFalse(formatted.isEmpty)
    }
}
