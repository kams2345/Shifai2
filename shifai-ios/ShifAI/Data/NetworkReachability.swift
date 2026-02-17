import Network

/// Network Reachability — monitors connectivity for offline-first UX.
/// Uses NWPathMonitor for real-time updates.
final class NetworkReachability {

    static let shared = NetworkReachability()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.shifai.reachability")

    private(set) var isConnected = true
    private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType: String {
        case wifi, cellular, wired, unknown
    }

    private init() {}

    // MARK: - Start / Stop

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            self?.connectionType = self?.determineType(path) ?? .unknown

            NotificationCenter.default.post(
                name: .networkStatusChanged,
                object: nil,
                userInfo: ["isConnected": path.status == .satisfied]
            )
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    // MARK: - Type

    private func determineType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .wired }
        return .unknown
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("com.shifai.networkStatusChanged")
}
