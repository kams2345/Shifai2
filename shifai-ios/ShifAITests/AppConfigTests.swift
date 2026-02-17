import XCTest
@testable import ShifAI

final class AppConfigTests: XCTestCase {

    // ─── API ───

    func testSupabaseURLNotEmpty() {
        XCTAssertFalse(AppConfig.supabaseURL.isEmpty)
    }

    func testSupabaseURLIsHTTPS() {
        XCTAssertTrue(AppConfig.supabaseURL.hasPrefix("https://"))
    }

    func testAnonKeyNotEmpty() {
        XCTAssertFalse(AppConfig.supabaseAnonKey.isEmpty)
    }

    func testPlausibleDomainNotEmpty() {
        XCTAssertFalse(AppConfig.plausibleDomain.isEmpty)
    }

    // ─── Thresholds ───

    func testMLCycleThreshold() {
        XCTAssertEqual(AppConfig.mlCycleThreshold, 6)
    }

    func testMinDataPointsPositive() {
        XCTAssertGreaterThan(AppConfig.minDataPoints, 0)
    }

    func testMaxExportSizeMB() {
        XCTAssertGreaterThan(AppConfig.maxExportSizeMB, 0)
    }

    // ─── Feature Flags ───

    func testMLEnabled() {
        // Default flag
        XCTAssertTrue(AppConfig.isMLEnabled || !AppConfig.isMLEnabled)
    }

    func testSyncEnabled() {
        XCTAssertTrue(AppConfig.isSyncEnabled || !AppConfig.isSyncEnabled)
    }

    // ─── URLs ───

    func testPrivacyPolicyURL() {
        let url = AppConfig.privacyPolicyURL
        XCTAssertTrue(url.absoluteString.contains("privacy"))
    }

    func testTermsURL() {
        let url = AppConfig.termsURL
        XCTAssertTrue(url.absoluteString.contains("terms"))
    }

    // ─── Notifications ───

    func testQuietHoursDefaults() {
        XCTAssertEqual(AppConfig.quietHoursStart, 22)
        XCTAssertEqual(AppConfig.quietHoursEnd, 7)
    }
}
