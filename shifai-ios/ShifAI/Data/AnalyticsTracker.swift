import Foundation

/// Analytics Tracker — privacy-safe event tracking via Plausible.
/// Zero PII: no user_id, no health data, no device fingerprints.
/// Consent-based: disabled by default, user enables in Settings.
/// Mirrors Android AnalyticsTracker.kt.
final class AnalyticsTracker {

    static let shared = AnalyticsTracker()

    private let plausibleURL = URL(string: "https://plausible.io/api/event")!

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "analytics_consent") }
        set { UserDefaults.standard.set(newValue, forKey: "analytics_consent") }
    }

    private init() {}

    // MARK: - Core

    func track(_ event: String, props: [String: String] = [:]) async {
        guard isEnabled else { return }

        var body: [String: Any] = [
            "name": event,
            "url": "app://shifai/\(event.replacingOccurrences(of: "_", with: "/"))",
            "domain": AppConfig.plausibleDomain
        ]
        if !props.isEmpty { body["props"] = props }

        guard let data = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: plausibleURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ShifAI iOS/\(AppConfig.appVersion)", forHTTPHeaderField: "User-Agent")
        request.httpBody = data
        request.timeoutInterval = 5

        _ = try? await URLSession.shared.data(for: request)
        // Analytics failures are silent — never block user flow
    }

    // MARK: - Convenience Events

    func trackAppLaunched() async {
        await track("app_launched", props: ["platform": "ios"])
    }

    func trackOnboardingCompleted(cycleLengthBucket: String) async {
        await track("onboarding_completed", props: ["cycle_length_bucket": cycleLengthBucket])
    }

    func trackTrackingSaved(symptomCountBucket: String) async {
        await track("tracking_saved", props: ["symptom_count_bucket": symptomCountBucket])
    }

    func trackExportGenerated(template: String, dateRange: String) async {
        await track("export_generated", props: ["template": template, "date_range": dateRange])
    }

    func trackSyncCompleted(conflictBucket: String) async {
        await track("sync_completed", props: ["conflict_count_bucket": conflictBucket])
    }

    func trackError(errorCode: String) async {
        await track("error_occurred", props: ["error_code": errorCode])
    }
}
