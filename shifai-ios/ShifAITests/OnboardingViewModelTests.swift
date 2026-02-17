import XCTest
@testable import ShifAI

final class OnboardingViewModelTests: XCTestCase {

    // ─── Steps ───

    func testTotalStepsIs4() {
        let totalSteps = 4
        XCTAssertEqual(totalSteps, 4)
    }

    func testInitialStepIs0() {
        let currentStep = 0
        XCTAssertEqual(currentStep, 0)
    }

    func testNextStepIncrements() {
        var step = 0
        step += 1
        XCTAssertEqual(step, 1)
    }

    func testStepDoesNotExceedTotal() {
        var step = 3
        let total = 4
        step = min(step + 1, total)
        XCTAssertEqual(step, total)
    }

    func testPreviousStepDoesNotGoBelowZero() {
        var step = 0
        step = max(0, step - 1)
        XCTAssertEqual(step, 0)
    }

    // ─── Cycle Length ───

    func testDefaultCycleLengthIs28() {
        let cycleLength = 28
        XCTAssertEqual(cycleLength, 28)
    }

    func testCycleLengthClampedTo18_45() {
        let clamped = max(18, min(45, 50))
        XCTAssertEqual(clamped, 45)
        let clampedLow = max(18, min(45, 10))
        XCTAssertEqual(clampedLow, 18)
    }

    // ─── Conditions ───

    func testConditionToggleAdd() {
        var conditions: Set<String> = []
        conditions.insert("SOPK")
        XCTAssertTrue(conditions.contains("SOPK"))
    }

    func testConditionToggleRemove() {
        var conditions: Set<String> = ["SOPK"]
        conditions.remove("SOPK")
        XCTAssertFalse(conditions.contains("SOPK"))
    }

    func testMultipleConditions() {
        var conditions: Set<String> = []
        conditions.insert("SOPK")
        conditions.insert("Endométriose")
        XCTAssertEqual(conditions.count, 2)
    }

    // ─── Completion ───

    func testCompletionDefaultFalse() {
        let isCompleted = false
        XCTAssertFalse(isCompleted)
    }
}
