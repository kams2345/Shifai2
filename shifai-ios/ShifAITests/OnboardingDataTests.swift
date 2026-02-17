import XCTest
@testable import ShifAI

final class OnboardingDataTests: XCTestCase {

    // ─── Defaults ───

    func testDefaultCycleLength() {
        let data = OnboardingData()
        XCTAssertEqual(data.cycleLength, 28)
    }

    func testDefaultPeriodLength() {
        let data = OnboardingData()
        XCTAssertEqual(data.periodLength, 5)
    }

    func testDefaultGoalIsTrackCycle() {
        let data = OnboardingData()
        XCTAssertEqual(data.goals.first, .trackCycle)
    }

    func testNotificationsEnabledByDefault() {
        let data = OnboardingData()
        XCTAssertTrue(data.notificationsEnabled)
    }

    func testHealthKitDisabledByDefault() {
        let data = OnboardingData()
        XCTAssertFalse(data.healthKitEnabled)
    }

    // ─── Clamping ───

    func testCycleLengthClampedMin() {
        let data = OnboardingData(cycleLength: 15)
        XCTAssertEqual(data.cycleLength, 21)
    }

    func testCycleLengthClampedMax() {
        let data = OnboardingData(cycleLength: 60)
        XCTAssertEqual(data.cycleLength, 45)
    }

    func testPeriodLengthClampedMin() {
        let data = OnboardingData(periodLength: 1)
        XCTAssertEqual(data.periodLength, 2)
    }

    func testPeriodLengthClampedMax() {
        let data = OnboardingData(periodLength: 15)
        XCTAssertEqual(data.periodLength, 10)
    }

    // ─── Goals ───

    func testSixGoalsExist() {
        XCTAssertEqual(OnboardingData.Goal.allCases.count, 6)
    }
}
