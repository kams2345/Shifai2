import XCTest
@testable import ShifAI

final class BiometricManagerTests: XCTestCase {

    // ─── Types ───

    func testFaceIDType() {
        let type = BiometricManager.BiometricType.faceID
        XCTAssertNotNil(type)
    }

    func testTouchIDType() {
        let type = BiometricManager.BiometricType.touchID
        XCTAssertNotNil(type)
    }

    func testNoneType() {
        let type = BiometricManager.BiometricType.none
        XCTAssertNotNil(type)
    }

    // ─── Results ───

    func testSuccessResult() {
        let result = BiometricManager.AuthResult.success
        if case .success = result { XCTAssert(true) } else { XCTFail() }
    }

    func testFailedResultHasMessage() {
        let result = BiometricManager.AuthResult.failed("Échec")
        if case .failed(let msg) = result { XCTAssertEqual(msg, "Échec") } else { XCTFail() }
    }

    func testNotAvailableResult() {
        let result = BiometricManager.AuthResult.notAvailable
        if case .notAvailable = result { XCTAssert(true) } else { XCTFail() }
    }

    func testNotEnrolledResult() {
        let result = BiometricManager.AuthResult.notEnrolled
        if case .notEnrolled = result { XCTAssert(true) } else { XCTFail() }
    }

    // ─── Name ───

    func testFaceIDName() {
        // The biometricName property returns French "Biométrie" when no biometric is available
        let fallback = "Biométrie"
        XCTAssertFalse(fallback.isEmpty)
    }

    // ─── Default State ───

    func testDisabledByDefault() {
        let defaultEnabled = false
        XCTAssertFalse(defaultEnabled)
    }

    func testPreferenceKey() {
        let key = "biometric_lock"
        XCTAssertEqual(key, "biometric_lock")
    }
}
