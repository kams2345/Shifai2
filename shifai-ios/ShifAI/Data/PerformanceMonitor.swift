import Foundation
import os.signpost

/// Performance Monitor — lightweight instrumentation for production.
/// Tracks startup time, DB queries, sync duration, and screen transitions.
/// No third-party dependency.
final class PerformanceMonitor {

    static let shared = PerformanceMonitor()

    private let log = OSLog(subsystem: "com.shifai", category: "performance")
    private var marks: [String: CFAbsoluteTime] = [:]

    private init() {}

    // MARK: - Measurement

    func start(_ label: String) {
        marks[label] = CFAbsoluteTimeGetCurrent()
        os_signpost(.begin, log: log, name: "measure", "%{public}s", label)
    }

    func end(_ label: String) -> TimeInterval? {
        guard let startTime = marks.removeValue(forKey: label) else { return nil }
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        os_signpost(.end, log: log, name: "measure", "%{public}s", label)

        // Log if slow
        let threshold = thresholdFor(label)
        if duration > threshold {
            CrashReporter.shared.log(
                .performanceBudgetExceeded,
                context: "\(label): \(String(format: "%.0f", duration * 1000))ms (budget: \(String(format: "%.0f", threshold * 1000))ms)"
            )
        }

        return duration
    }

    // MARK: - Convenience

    func measure<T>(_ label: String, block: () throws -> T) rethrows -> T {
        start(label)
        let result = try block()
        _ = end(label)
        return result
    }

    func measureAsync<T>(_ label: String, block: () async throws -> T) async rethrows -> T {
        start(label)
        let result = try await block()
        _ = end(label)
        return result
    }

    // MARK: - Budgets

    private func thresholdFor(_ label: String) -> TimeInterval {
        switch label {
        case "cold_start":          return 1.5
        case "warm_start":          return 0.5
        case "db_open":             return 0.2
        case "save_daily_log":      return 0.2
        case "load_chart":          return 0.3
        case "ml_prediction":       return 0.5
        case "pdf_generation":      return 3.0
        case "sync":                return 5.0
        case "tab_switch":          return 0.1
        case "widget_refresh":      return 1.0
        default:                    return 1.0
        }
    }
}
