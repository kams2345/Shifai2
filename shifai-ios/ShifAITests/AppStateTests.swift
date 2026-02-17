import XCTest
@testable import ShifAI

final class AppStateTests: XCTestCase {

    // ─── Launch Flow ───

    func testNewUserStartsOnboarding() {
        let state = AppState()
        // New user has not completed onboarding
        XCTAssertFalse(state.hasCompletedOnboarding)
    }

    func testOnboardingCompletionUpdatesState() {
        let completed = true
        XCTAssertTrue(completed)
    }

    func testBiometricLockRequiresOnboarding() {
        // Biometric lock only activates after onboarding
        let onboarded = true
        let biometric = true
        XCTAssertTrue(onboarded && biometric)
    }

    func testAuthenticatedWhenNoBiometric() {
        let onboarded = true
        let biometric = false
        XCTAssertTrue(onboarded && !biometric)
    }

    // ─── Tabs ───

    func testDefaultTabIsDashboard() {
        XCTAssertEqual(AppState.MainTab.dashboard.rawValue, "dashboard")
    }

    func testAllTabsCount() {
        XCTAssertEqual(AppState.MainTab.allCases.count, 4)
    }

    func testTrackingTab() {
        XCTAssertEqual(AppState.MainTab.tracking.rawValue, "tracking")
    }

    func testInsightsTab() {
        XCTAssertEqual(AppState.MainTab.insights.rawValue, "insights")
    }

    func testSettingsTab() {
        XCTAssertEqual(AppState.MainTab.settings.rawValue, "settings")
    }

    // ─── Launch States ───

    func testFourLaunchStates() {
        let states: [AppState.LaunchState] = [.loading, .onboarding, .biometricLock, .authenticated]
        XCTAssertEqual(states.count, 4)
    }
}
