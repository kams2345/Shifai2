import XCTest
@testable import ShifAI

final class DeepLinkRouterTests: XCTestCase {

    var router: DeepLinkRouter!

    override func setUp() {
        router = DeepLinkRouter()
    }

    // ─── Tab Routes ───

    func testDashboardRoute() {
        router.handle(URL(string: "shifai://dashboard")!)
        XCTAssertEqual(router.activeDestination, .dashboard)
    }

    func testTrackingRoute() {
        router.handle(URL(string: "shifai://tracking")!)
        XCTAssertEqual(router.activeDestination, .tracking)
    }

    func testInsightsRoute() {
        router.handle(URL(string: "shifai://insights")!)
        XCTAssertEqual(router.activeDestination, .insights)
    }

    func testExportRoute() {
        router.handle(URL(string: "shifai://export")!)
        XCTAssertEqual(router.activeDestination, .export)
    }

    func testSettingsRoute() {
        router.handle(URL(string: "shifai://settings")!)
        XCTAssertEqual(router.activeDestination, .settings)
    }

    // ─── Special Routes ───

    func testSyncConflictRoute() {
        router.handle(URL(string: "shifai://sync/conflict")!)
        XCTAssertEqual(router.activeDestination, .syncConflict)
    }

    func testAppDefaultToDashboard() {
        router.handle(URL(string: "shifai://app")!)
        XCTAssertEqual(router.activeDestination, .dashboard)
    }

    func testUnknownHostReturnsUnknown() {
        router.handle(URL(string: "shifai://nonexistent")!)
        XCTAssertEqual(router.activeDestination, .unknown)
    }

    func testWrongSchemeIgnored() {
        router.handle(URL(string: "https://shifai.app")!)
        XCTAssertNil(router.activeDestination)
    }

    func testClearDestination() {
        router.handle(URL(string: "shifai://dashboard")!)
        router.clearDestination()
        XCTAssertNil(router.activeDestination)
    }
}
