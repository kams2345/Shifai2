import Foundation
import os.log

// MARK: - Performance Monitor (S10-1)
// NFR-P1→P7: Cold start <4s, warm <1s, transitions <300ms, ML <150ms, battery <5%

final class PerformanceMonitor {

    static let shared = PerformanceMonitor()
    private let logger = Logger(subsystem: "com.shifai", category: "Performance")

    // MARK: - Timing

    private var markers: [String: CFAbsoluteTime] = [:]

    func startMeasure(_ label: String) {
        markers[label] = CFAbsoluteTimeGetCurrent()
    }

    func endMeasure(_ label: String) -> TimeInterval? {
        guard let start = markers.removeValue(forKey: label) else { return nil }
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        let ms = elapsed * 1000

        // Log with threshold warnings
        switch label {
        case let l where l.contains("cold_start"):
            if ms > 4000 { logger.warning("⚠️ Cold start \(ms, privacy: .public)ms > 4000ms target") }
            else { logger.info("✅ Cold start \(ms, privacy: .public)ms") }
        case let l where l.contains("warm_start"):
            if ms > 1000 { logger.warning("⚠️ Warm start \(ms, privacy: .public)ms > 1000ms target") }
        case let l where l.contains("transition"):
            if ms > 300 { logger.warning("⚠️ Transition \(ms, privacy: .public)ms > 300ms target") }
        case let l where l.contains("ml_inference"):
            if ms > 150 { logger.warning("⚠️ ML inference \(ms, privacy: .public)ms > 150ms target") }
        case let l where l.contains("sync"):
            if ms > 2000 { logger.warning("⚠️ Sync \(ms, privacy: .public)ms > 2000ms target") }
        default:
            logger.info("📊 \(label, privacy: .public): \(ms, privacy: .public)ms")
        }

        return elapsed
    }

    // MARK: - Memory

    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let mb = Double(info.resident_size) / 1024 / 1024
            logger.info("💾 Memory: \(mb, privacy: .public)MB")
        }
    }

    // MARK: - NFR Thresholds

    struct Thresholds {
        static let coldStartMs: Double = 4000
        static let warmStartMs: Double = 1000
        static let transitionMs: Double = 300
        static let mlInferenceMs: Double = 150
        static let syncMs: Double = 2000
        static let batteryPercentDay: Double = 5.0
    }
}
