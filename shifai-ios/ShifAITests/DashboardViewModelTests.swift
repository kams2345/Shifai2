import XCTest
@testable import ShifAI

final class DashboardViewModelTests: XCTestCase {

    func testInitialCycleDay() {
        let vm = DashboardViewModel()
        XCTAssertEqual(vm.cycleDay, 1)
    }

    func testInitialHasNotLoggedToday() {
        let vm = DashboardViewModel()
        XCTAssertFalse(vm.hasLoggedToday)
    }

    func testMarkDayLogged() {
        let vm = DashboardViewModel()
        vm.markDayLogged()
        XCTAssertTrue(vm.hasLoggedToday)
    }

    func testUpdateCycleInfo() {
        let vm = DashboardViewModel()
        vm.updateCycleInfo(day: 14, total: 30, phase: .ovulatory)
        XCTAssertEqual(vm.cycleDay, 14)
        XCTAssertEqual(vm.cycleDayTotal, 30)
    }

    func testUpdateStats() {
        let vm = DashboardViewModel()
        vm.updateStats(symptoms: 5, sleep: 7.5, mood: 8)
        XCTAssertEqual(vm.symptomCount, 5)
    }

    func testEnergyForecastDefault() {
        let vm = DashboardViewModel()
        XCTAssertNotNil(vm.energyForecast)
    }
}
