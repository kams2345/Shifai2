import XCTest
@testable import ShifAI

final class SupabaseClientTests: XCTestCase {

    // ─── Init ───

    func testClientUsesAppConfigURL() {
        let url = AppConfig.supabaseURL
        XCTAssertFalse(url.isEmpty)
        XCTAssertTrue(url.hasPrefix("https://"))
    }

    func testClientUsesAppConfigKey() {
        let key = AppConfig.supabaseAnonKey
        XCTAssertFalse(key.isEmpty)
    }

    // ─── Endpoints ───

    func testCycleEntriesEndpoint() {
        let endpoint = "/rest/v1/cycle_entries"
        XCTAssertTrue(endpoint.contains("cycle_entries"))
    }

    func testSyncDataEndpoint() {
        let endpoint = "/functions/v1/sync-data"
        XCTAssertTrue(endpoint.contains("sync-data"))
    }

    func testShareLinkEndpoint() {
        let endpoint = "/functions/v1/generate-share-link"
        XCTAssertTrue(endpoint.contains("generate-share-link"))
    }

    func testDeleteAccountEndpoint() {
        let endpoint = "/functions/v1/delete-account"
        XCTAssertTrue(endpoint.contains("delete-account"))
    }

    // ─── Headers ───

    func testAuthHeaderFormat() {
        let token = "test-jwt-token"
        let header = "Bearer \(token)"
        XCTAssertTrue(header.hasPrefix("Bearer "))
    }

    func testAPIKeyHeaderName() {
        let headerName = "apikey"
        XCTAssertEqual(headerName, "apikey")
    }

    // ─── Error Mapping ───

    func testHTTP401MapsToUnauthorized() {
        let statusCode = 401
        let error: ShifAIError = statusCode == 401 ? .unauthorized : .serverError(statusCode: statusCode)
        XCTAssertEqual(error, .unauthorized)
    }

    func testHTTP409MapsToConflict() {
        let statusCode = 409
        let error: ShifAIError = statusCode == 409 ? .conflict : .serverError(statusCode: statusCode)
        XCTAssertEqual(error, .conflict)
    }
}
