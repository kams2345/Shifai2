import XCTest
@testable import ShifAI

final class ShifAIErrorTests: XCTestCase {

    // ─── Network ───

    func testNetworkUnavailableDescription() {
        let error = ShifAIError.networkUnavailable
        XCTAssertTrue(error.errorDescription!.contains("connexion"))
    }

    func testServerErrorIncludesCode() {
        let error = ShifAIError.serverError(statusCode: 502)
        XCTAssertTrue(error.errorDescription!.contains("502"))
    }

    func testUnauthorizedDescription() {
        let error = ShifAIError.unauthorized
        XCTAssertTrue(error.errorDescription!.contains("Session"))
    }

    // ─── Database ───

    func testMigrationFailedIncludesVersion() {
        let error = ShifAIError.migrationFailed(version: 3)
        XCTAssertTrue(error.errorDescription!.contains("v3"))
    }

    func testRecordNotFoundIncludesDetails() {
        let error = ShifAIError.recordNotFound(table: "cycle_entries", id: "abc")
        XCTAssertTrue(error.errorDescription!.contains("cycle_entries"))
        XCTAssertTrue(error.errorDescription!.contains("abc"))
    }

    // ─── Domain ───

    func testInsufficientDataShowsCounts() {
        let error = ShifAIError.insufficientData(required: 3, actual: 1)
        XCTAssertTrue(error.errorDescription!.contains("1/3"))
    }

    func testInvalidInputShowsField() {
        let error = ShifAIError.invalidInput(field: "flow", reason: "trop haut")
        XCTAssertTrue(error.errorDescription!.contains("flow"))
    }

    // ─── Sync ───

    func testSyncConflictDescription() {
        let error = ShifAIError.syncConflict(localDate: Date(), remoteDate: Date())
        XCTAssertTrue(error.errorDescription!.contains("synchronisation"))
    }

    // ─── Export ───

    func testExportTooLargeShowsSizes() {
        let error = ShifAIError.exportTooLarge(sizeMB: 15, maxMB: 10)
        XCTAssertTrue(error.errorDescription!.contains("15"))
        XCTAssertTrue(error.errorDescription!.contains("10"))
    }

    // ─── Auth ───

    func testBiometricRecoverySuggestion() {
        let error = ShifAIError.biometricNotAvailable
        XCTAssertTrue(error.recoverySuggestion!.contains("réglages"))
    }

    // ─── Recovery ───

    func testTimeoutRecoverySuggestion() {
        let error = ShifAIError.timeout
        XCTAssertTrue(error.recoverySuggestion!.contains("Réessaie"))
    }

    // ─── Equatable ───

    func testErrorsAreEquatable() {
        XCTAssertEqual(ShifAIError.networkUnavailable, ShifAIError.networkUnavailable)
        XCTAssertNotEqual(ShifAIError.networkUnavailable, ShifAIError.timeout)
    }
}
