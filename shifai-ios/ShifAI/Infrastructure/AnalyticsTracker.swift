import Foundation

// MARK: - Privacy-Safe Analytics (S9-7)
// Zero PII, Plausible-compatible, GDPR-safe
// Tracks aggregates only — no device IDs, no IP storage

final class AnalyticsTracker {

    static let shared = AnalyticsTracker()
    private let prefs = UserDefaults.standard

    // Plausible Analytics endpoint (EU-hosted)
    private let plausibleDomain = "shifai.app"
    private let plausibleEndpoint = "https://plausible.io/api/event"

    // MARK: - Core Events

    enum Event: String {
        // Onboarding
        case onboardingStarted = "onboarding_started"
        case onboardingCompleted = "onboarding_completed"
        case onboardingSkipped = "onboarding_skipped"

        // Core Usage
        case dailyLogSaved = "daily_log_saved"
        case symptomLogged = "symptom_logged"
        case bodyMapUsed = "body_map_used"

        // Intelligence
        case insightsViewed = "insights_viewed"
        case predictionViewed = "prediction_viewed"
        case feedbackGiven = "feedback_given"
        case recommendationFollowed = "recommendation_followed"

        // Quick Wins
        case quickWinJ1 = "quickwin_j1"
        case quickWinJ3 = "quickwin_j3"
        case quickWinJ7 = "quickwin_j7"
        case quickWinJ14 = "quickwin_j14"
        case quickWinCycle1 = "quickwin_cycle1"

        // Export
        case exportGenerated = "export_generated"
        case exportShared = "export_shared"

        // Sync
        case syncCompleted = "sync_completed"
        case syncConflict = "sync_conflict"
        case syncConflictResolved = "sync_conflict_resolved"

        // Notifications
        case notificationSent = "notification_sent"
        case notificationOpened = "notification_opened"
        case notificationIgnored = "notification_ignored"

        // Settings
        case settingsOpened = "settings_opened"
        case privacyPolicyViewed = "privacy_policy_viewed"
        case dataExported = "data_exported"
        case accountDeleted = "account_deleted"

        // Retention
        case appOpened = "app_opened"
        case sessionDuration = "session_duration"
    }

    // MARK: - Track Event

    func track(_ event: Event, properties: [String: String] = [:]) {
        // Consent check
        guard isAnalyticsEnabled() else { return }

        // Send to Plausible (zero PII, no cookies, GDPR-safe)
        var payload: [String: Any] = [
            "name": event.rawValue,
            "domain": plausibleDomain,
            "url": "app://\(event.rawValue)"
        ]

        if !properties.isEmpty {
            // Scrub any potential PII from properties
            let safeProps = properties.filter { key, _ in
                !["email", "name", "phone", "address", "ip"].contains(key.lowercased())
            }
            payload["props"] = safeProps
        }

        sendToPlausible(payload)

        // Also buffer locally for Supabase analytics_events table
        bufferLocally(event: event, properties: properties)
    }

    // MARK: - Plausible Integration

    private func sendToPlausible(_ payload: [String: Any]) {
        guard let url = URL(string: plausibleEndpoint),
              let body = try? JSONSerialization.data(withJSONObject: payload) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Plausible does not need cookies or user-agents for tracking

        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - Local Buffer (for Supabase batch upload)

    private func bufferLocally(event: Event, properties: [String: String]) {
        var buffer = prefs.array(forKey: "analytics_buffer") as? [[String: Any]] ?? []
        buffer.append([
            "event": event.rawValue,
            "props": properties,
            "ts": ISO8601DateFormatter().string(from: Date())
        ])

        // Batch upload when buffer reaches 20 events
        if buffer.count >= 20 {
            flushBuffer(buffer)
            prefs.set([], forKey: "analytics_buffer")
        } else {
            prefs.set(buffer, forKey: "analytics_buffer")
        }
    }

    private func flushBuffer(_ buffer: [[String: Any]]) {
        // TODO: Batch insert into Supabase analytics_events table
    }

    // MARK: - Session Tracking

    private var sessionStart: Date?

    func startSession() {
        sessionStart = Date()
        track(.appOpened)
    }

    func endSession() {
        guard let start = sessionStart else { return }
        let duration = Int(Date().timeIntervalSince(start))
        track(.sessionDuration, properties: ["seconds": "\(duration)"])
        sessionStart = nil
    }

    // MARK: - Consent

    func isAnalyticsEnabled() -> Bool {
        // Default: opt-in (GDPR compliant — user chooses during onboarding)
        prefs.bool(forKey: "analytics_enabled")
    }

    func setAnalyticsEnabled(_ enabled: Bool) {
        prefs.set(enabled, forKey: "analytics_enabled")
    }
}
