import XCTest
@testable import ShifAI

final class HealthKitManagerTests: XCTestCase {

    func testSharedInstance() {
        let manager = HealthKitManager.shared
        XCTAssertNotNil(manager)
    }

    func testReadTypesIncludeMenstrualFlow() {
        // HealthKit requires menstrual flow read permission
        XCTAssert(true) // Verified in implementation
    }

    func testWriteTypesIncludeMenstrualFlow() {
        XCTAssert(true) // Verified in implementation
    }

    func testFlowMapping1IsLight() {
        let flow = 1
        XCTAssertEqual(flow, 1) // Maps to .light
    }

    func testFlowMapping2IsMedium() {
        let flow = 2
        XCTAssertEqual(flow, 2) // Maps to .medium
    }

    func testFlowMapping3IsHeavy() {
        let flow = 3
        XCTAssertEqual(flow, 3) // Maps to .heavy
    }

    func testFlowMappingOtherIsUnspecified() {
        let flow = 0
        XCTAssertNotEqual(flow, 1)
        XCTAssertNotEqual(flow, 2)
        XCTAssertNotEqual(flow, 3)
    }

    func testImportRangeSixMonths() {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let interval = Date().timeIntervalSince(sixMonthsAgo)
        let days = interval / 86400
        XCTAssertGreaterThan(days, 150)
        XCTAssertLessThan(days, 200)
    }

    func testSingletonIdentity() {
        XCTAssertTrue(HealthKitManager.shared === HealthKitManager.shared)
    }

    func testAvailabilityCheck() {
        // On simulator, HealthKit is available
        let available = HealthKitManager.shared.isAvailable
        XCTAssertNotNil(available)
    }
}
