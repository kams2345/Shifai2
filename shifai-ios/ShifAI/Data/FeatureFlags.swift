import Foundation

/// Feature Flags — remote config for gradual feature rollout.
/// Defaults to local values, overridden by Supabase app_config table.
final class FeatureFlags {

    static let shared = FeatureFlags()

    private var remoteFlags: [String: Bool] = [:]
    private let defaults: [String: Bool] = [
        "ml_predictions": false,
        "share_links": true,
        "cycle_insights": true,
        "body_map_v2": false,
        "pdf_export": true,
        "widget_predictions": false,
        "biometric_lock": true,
        "analytics_v2": false,
        "background_sync": true,
        "csv_export": true,
    ]

    private init() {}

    // MARK: - Access

    func isEnabled(_ flag: String) -> Bool {
        remoteFlags[flag] ?? defaults[flag] ?? false
    }

    var mlPredictions: Bool { isEnabled("ml_predictions") }
    var shareLinks: Bool { isEnabled("share_links") }
    var cycleInsights: Bool { isEnabled("cycle_insights") }
    var bodyMapV2: Bool { isEnabled("body_map_v2") }
    var pdfExport: Bool { isEnabled("pdf_export") }
    var widgetPredictions: Bool { isEnabled("widget_predictions") }
    var biometricLock: Bool { isEnabled("biometric_lock") }
    var backgroundSync: Bool { isEnabled("background_sync") }
    var csvExport: Bool { isEnabled("csv_export") }

    // MARK: - Remote Update

    func update(from remote: [String: Bool]) {
        remoteFlags = remote
    }

    func reset() {
        remoteFlags.removeAll()
    }
}
