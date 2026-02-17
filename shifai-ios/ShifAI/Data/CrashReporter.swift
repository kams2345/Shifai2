import Foundation

/// Crash Reporter — lightweight error tracking for production.
/// No third-party dependency: logs to local file + optional Plausible events.
/// Follows zero-PII principle: no stack traces with user data.
final class CrashReporter {

    static let shared = CrashReporter()

    private let logFile: URL
    private let maxLogSize = 500_000  // 500 KB
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    private init() {
        logFile = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.shifai.shared")!
            .appendingPathComponent("crash_log.txt")
    }

    // MARK: - Logging

    func log(_ error: ShifAIError, context: String = "") {
        let timestamp = dateFormatter.string(from: Date())
        let line = "[\(timestamp)] [\(error.code)] \(error.localizedDescription) | \(context)\n"

        appendToFile(line)

        // Track anonymized error in analytics
        Task {
            await AnalyticsTracker.shared.trackError(errorCode: error.code)
        }
    }

    func logCrash(_ error: Error, file: String = #file, line: Int = #line) {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let entry = "[CRASH] \(dateFormatter.string(from: Date())) | \(filename):\(line) | \(error.localizedDescription)\n"
        appendToFile(entry)
    }

    // MARK: - Retrieval

    func getRecentLogs(lines: Int = 50) -> String {
        guard let data = FileManager.default.contents(atPath: logFile.path),
              let content = String(data: data, encoding: .utf8) else {
            return ""
        }
        let allLines = content.components(separatedBy: "\n")
        return allLines.suffix(lines).joined(separator: "\n")
    }

    func clearLogs() {
        try? "".write(to: logFile, atomically: true, encoding: .utf8)
    }

    // MARK: - File Management

    private func appendToFile(_ text: String) {
        if FileManager.default.fileExists(atPath: logFile.path) {
            // Rotate if too large
            if let attrs = try? FileManager.default.attributesOfItem(atPath: logFile.path),
               let size = attrs[.size] as? Int, size > maxLogSize {
                clearLogs()
            }
            if let handle = FileHandle(forWritingAtPath: logFile.path) {
                handle.seekToEndOfFile()
                handle.write(text.data(using: .utf8)!)
                handle.closeFile()
            }
        } else {
            try? text.write(to: logFile, atomically: true, encoding: .utf8)
        }
    }
}
