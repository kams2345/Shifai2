import XCTest
@testable import ShifAI

final class QuickWinEngineTests: XCTestCase {

    var engine: QuickWinEngine!

    override func setUp() {
        engine = QuickWinEngine()
        UserDefaults.standard.removeObject(forKey: "quickwin_shown")
        UserDefaults.standard.removeObject(forKey: "log_count")
    }

    // MARK: - Milestone Detection

    func testJ1Milestone_FirstLog_Triggers() {
        let milestone = engine.checkMilestones(logCount: 1, daysSinceInstall: 1)
        XCTAssertEqual(milestone?.id, "quickwin_j1", "First log should trigger J1")
    }

    func testJ3Milestone_ThreeDays_Triggers() {
        // Mark J1 as shown
        engine.markShown("quickwin_j1")
        let milestone = engine.checkMilestones(logCount: 3, daysSinceInstall: 3)
        XCTAssertEqual(milestone?.id, "quickwin_j3", "3 days should trigger J3")
    }

    func testJ7Milestone_SevenDays_Triggers() {
        engine.markShown("quickwin_j1")
        engine.markShown("quickwin_j3")
        let milestone = engine.checkMilestones(logCount: 7, daysSinceInstall: 7)
        XCTAssertEqual(milestone?.id, "quickwin_j7", "7 days should trigger J7")
    }

    func testMilestone_AlreadyShown_ReturnsNil() {
        engine.markShown("quickwin_j1")
        let milestone = engine.checkMilestones(logCount: 1, daysSinceInstall: 1)
        XCTAssertNil(milestone, "Already-shown milestones should not re-trigger")
    }

    func testMilestone_InsufficientData_ReturnsNil() {
        let milestone = engine.checkMilestones(logCount: 0, daysSinceInstall: 0)
        XCTAssertNil(milestone, "No logs should not trigger any milestone")
    }

    // MARK: - Adaptive Frequency

    func testAdaptiveFrequency_Week1_IsDaily() {
        let frequency = engine.recommendedFrequency(daysSinceInstall: 3)
        XCTAssertEqual(frequency, .daily, "First week should be daily")
    }

    func testAdaptiveFrequency_Week3_IsWeekly() {
        let frequency = engine.recommendedFrequency(daysSinceInstall: 18)
        XCTAssertEqual(frequency, .weekly, "Week 3 should be weekly")
    }

    func testAdaptiveFrequency_Month2_IsBiweekly() {
        let frequency = engine.recommendedFrequency(daysSinceInstall: 45)
        XCTAssertEqual(frequency, .biweekly, "Month 2+ should be biweekly")
    }
}
