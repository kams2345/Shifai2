import XCTest
@testable import ShifAI

final class AccessibilityLabelsTests: XCTestCase {

    func testDashboardCycleDay() {
        XCTAssertEqual(AccessibilityLabels.Dashboard.cycleDay, "Jour du cycle")
    }

    func testTrackingSaveButton() {
        XCTAssertEqual(AccessibilityLabels.Tracking.saveButton, "Enregistrer les données du jour")
    }

    func testTrackingBodyMap() {
        XCTAssertEqual(AccessibilityLabels.Tracking.bodyMap, "Carte corporelle interactive")
    }

    func testInsightsFilterMenu() {
        XCTAssertEqual(AccessibilityLabels.Insights.filterMenu, "Filtrer les analyses")
    }

    func testSettingsSyncToggle() {
        XCTAssertEqual(AccessibilityLabels.Settings.syncToggle, "Synchronisation automatique")
    }

    func testSettingsDeleteHint() {
        XCTAssertTrue(AccessibilityLabels.Settings.deleteHint.contains("irréversible"))
    }

    func testCommonLoading() {
        XCTAssertEqual(AccessibilityLabels.Common.loading, "Chargement en cours")
    }

    func testCommonRetry() {
        XCTAssertEqual(AccessibilityLabels.Common.retry, "Réessayer")
    }

    func testAllLabelsInFrench() {
        XCTAssertFalse(AccessibilityLabels.Dashboard.phaseIndicator.isEmpty)
        XCTAssertFalse(AccessibilityLabels.Tracking.flowSlider.isEmpty)
    }

    func testFlowSliderHint() {
        XCTAssertEqual(AccessibilityLabels.Tracking.flowHint, "Ajustez entre 0 et 4")
    }
}
