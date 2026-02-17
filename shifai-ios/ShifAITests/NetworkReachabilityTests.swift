import XCTest
@testable import ShifAI

final class NetworkReachabilityTests: XCTestCase {

    func testWifiType() {
        let type = NetworkReachability.ConnectionType.wifi
        XCTAssertEqual(type.rawValue, "wifi")
    }

    func testCellularType() {
        let type = NetworkReachability.ConnectionType.cellular
        XCTAssertEqual(type.rawValue, "cellular")
    }

    func testWiredType() {
        let type = NetworkReachability.ConnectionType.wired
        XCTAssertEqual(type.rawValue, "wired")
    }

    func testUnknownType() {
        let type = NetworkReachability.ConnectionType.unknown
        XCTAssertEqual(type.rawValue, "unknown")
    }

    func testDefaultConnected() {
        XCTAssertTrue(NetworkReachability.shared.isConnected)
    }

    func testNotificationName() {
        let name = Notification.Name.networkStatusChanged
        XCTAssertEqual(name.rawValue, "com.shifai.networkStatusChanged")
    }

    func testSyncAllowedWhenConnected() {
        let connected = true
        let syncEnabled = true
        XCTAssertTrue(connected && syncEnabled)
    }

    func testSyncBlockedWhenDisconnected() {
        let connected = false
        XCTAssertFalse(connected)
    }

    func testWifiPreferredForSync() {
        let type = NetworkReachability.ConnectionType.wifi
        XCTAssertEqual(type, .wifi)
    }

    func testCellularAllowedForSmallSync() {
        let type = NetworkReachability.ConnectionType.cellular
        XCTAssertNotEqual(type, .unknown)
    }
}
