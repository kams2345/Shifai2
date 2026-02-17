import Foundation
import UserNotifications

// MARK: - Smart Notification Engine (S8-1 through S8-5)
// Max 1/jour, intelligentes, anti-spam, 50%+ action rate
// S8-1: Framework + scheduling
// S8-2: Cycle prediction notifications
// S8-3: Quick Win & educational
// S8-4: Actionable recommendations
// S8-5: Smart anti-spam rules

final class NotificationEngine {

    static let shared = NotificationEngine()
    private let center = UNUserNotificationCenter.current()
    private let prefs = UserDefaults.standard

    // MARK: - Categories

    enum NotificationCategory: String, CaseIterable {
        case prediction = "prediction"
        case quickWin = "quick_win"
        case education = "education"
        case recommendation = "recommendation"
        case reminder = "reminder"

        var displayName: String {
            switch self {
            case .prediction: return "Prédictions"
            case .quickWin: return "Quick Wins"
            case .education: return "Éducatif"
            case .recommendation: return "Recommandations"
            case .reminder: return "Rappels"
            }
        }

        var defaultHour: Int {
            switch self {
            case .prediction: return 20     // Evening: prepare for tomorrow
            case .quickWin: return 9        // Morning motivation
            case .education: return 10      // Mid-morning learning
            case .recommendation: return 8  // Morning planning
            case .reminder: return 21       // Evening check-in
            }
        }
    }

    // MARK: - S8-1: Permission Request (optimal timing)

    func requestPermissionIfNeeded() {
        // Don't ask during onboarding — wait for 3+ days of data
        let daysSinceInstall = prefs.integer(forKey: "days_since_install")
        guard daysSinceInstall >= 3 else { return }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted { self.registerCategories() }
                }
            }
        }
    }

    private func registerCategories() {
        // S8-4: Actionable recommendations
        let followAction = UNNotificationAction(
            identifier: "FOLLOW",
            title: "Oui, ajusté ✅",
            options: []
        )
        let skipAction = UNNotificationAction(
            identifier: "SKIP",
            title: "Pas cette fois",
            options: []
        )
        let feedbackCategory = UNNotificationCategory(
            identifier: "RECOMMENDATION",
            actions: [followAction, skipAction],
            intentIdentifiers: [],
            options: []
        )

        // S8-2: Prediction deep link
        let viewAction = UNNotificationAction(
            identifier: "VIEW_PREDICTION",
            title: "Voir les prédictions",
            options: [.foreground]
        )
        let predictionCategory = UNNotificationCategory(
            identifier: "PREDICTION",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([feedbackCategory, predictionCategory])
    }

    // MARK: - S8-1: Max 1/Day Scheduling Engine

    func scheduleIfAllowed(category: NotificationCategory, title: String, body: String, deepLink: String? = nil) {
        // Anti-spam: check if we already sent today
        guard canSendToday() else { return }

        // Check if category is enabled
        guard isCategoryEnabled(category) else { return }

        // S8-5: Check ignore count
        guard !isAutoStopped(category) else { return }

        // S8-5: Night mode (22h-8h default)
        guard !isQuietHours() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue.uppercased()

        if let deepLink = deepLink {
            content.userInfo = ["deep_link": deepLink]
        }

        // Schedule for preferred hour
        let hour = preferredHour(for: category)
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(category.rawValue)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if error == nil {
                self.markSentToday()
                self.trackNotification(category: category, title: title)
            }
        }
    }

    // MARK: - S8-2: Cycle Prediction Notifications

    func schedulePredictionNotification(daysUntilPeriod: Int, dateRange: String) {
        guard daysUntilPeriod <= 3 && daysUntilPeriod > 0 else { return }

        scheduleIfAllowed(
            category: .prediction,
            title: "Règles prévues dans ~\(daysUntilPeriod) jours",
            body: "Période estimée: \(dateRange). Prépare-toi ☁️",
            deepLink: "shifai://predictions"
        )
    }

    func scheduleOvulationNotification(daysUntilOvulation: Int) {
        guard daysUntilOvulation <= 3 && daysUntilOvulation > 0 else { return }

        scheduleIfAllowed(
            category: .prediction,
            title: "Fenêtre d'ovulation dans ~\(daysUntilOvulation) jours",
            body: "Phase la plus fertile prévue bientôt 🌸",
            deepLink: "shifai://predictions"
        )
    }

    // MARK: - S8-3: Quick Win & Educational Notifications

    func scheduleQuickWinNotification(title: String, body: String) {
        // Adaptive frequency: 1x/week M1-3, 1x/2weeks after
        let monthsUsing = prefs.integer(forKey: "months_using_app")
        let lastQuickWin = prefs.object(forKey: "last_quickwin_notif") as? Date ?? .distantPast
        let interval: TimeInterval = monthsUsing <= 3 ? 7 * 86400 : 14 * 86400

        guard Date().timeIntervalSince(lastQuickWin) > interval else { return }

        scheduleIfAllowed(category: .quickWin, title: title, body: body, deepLink: "shifai://insights")
        prefs.set(Date(), forKey: "last_quickwin_notif")
    }

    func scheduleEducationalNotification(day: Int, title: String, body: String) {
        // J4-J13 daily, auto-stop J14
        guard day >= 4 && day <= 13 else { return }

        scheduleIfAllowed(category: .education, title: title, body: body, deepLink: "shifai://insights")
    }

    // MARK: - S8-4: Actionable Recommendation Notifications

    func scheduleRecommendation(energyForecast: String, tip: String) {
        scheduleIfAllowed(
            category: .recommendation,
            title: "☁️ \(energyForecast) prévue demain",
            body: tip,
            deepLink: "shifai://insights"
        )
    }

    // MARK: - S8-5: Smart Anti-Spam Rules

    private func canSendToday() -> Bool {
        let lastSent = prefs.object(forKey: "last_notification_date") as? Date
        guard let last = lastSent else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    private func markSentToday() {
        prefs.set(Date(), forKey: "last_notification_date")
    }

    private func isQuietHours() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        let quietStart = prefs.integer(forKey: "quiet_hours_start")
        let quietEnd = prefs.integer(forKey: "quiet_hours_end")
        let start = quietStart > 0 ? quietStart : 22
        let end = quietEnd > 0 ? quietEnd : 8

        if start > end {  // Overnight (22-8)
            return hour >= start || hour < end
        } else {
            return hour >= start && hour < end
        }
    }

    private func isAutoStopped(_ category: NotificationCategory) -> Bool {
        // If user ignored 3x same type → auto-stop
        let ignoreKey = "notif_ignore_count_\(category.rawValue)"
        return prefs.integer(forKey: ignoreKey) >= 3
    }

    func trackIgnored(category: NotificationCategory) {
        let key = "notif_ignore_count_\(category.rawValue)"
        prefs.set(prefs.integer(forKey: key) + 1, forKey: key)
    }

    func trackOpened(category: NotificationCategory) {
        // Reset ignore count on open
        prefs.set(0, forKey: "notif_ignore_count_\(category.rawValue)")
    }

    // MARK: - Settings

    func isCategoryEnabled(_ category: NotificationCategory) -> Bool {
        prefs.object(forKey: "notif_\(category.rawValue)_enabled") as? Bool ?? true
    }

    func setCategoryEnabled(_ category: NotificationCategory, enabled: Bool) {
        prefs.set(enabled, forKey: "notif_\(category.rawValue)_enabled")
    }

    func preferredHour(for category: NotificationCategory) -> Int {
        let stored = prefs.integer(forKey: "notif_\(category.rawValue)_hour")
        return stored > 0 ? stored : category.defaultHour
    }

    func setPreferredHour(for category: NotificationCategory, hour: Int) {
        prefs.set(hour, forKey: "notif_\(category.rawValue)_hour")
    }

    // MARK: - Analytics

    private func trackNotification(category: NotificationCategory, title: String) {
        // Track: notification_sent event (zero PII)
        let event: [String: Any] = [
            "category": category.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        // TODO: Send to Plausible analytics
        _ = event
    }

    func handleAction(identifier: String, category: String) {
        switch identifier {
        case "FOLLOW":
            // recommendation_followed event
            if let cat = NotificationCategory(rawValue: category.lowercased()) {
                trackOpened(category: cat)
            }
        case "SKIP":
            if let cat = NotificationCategory(rawValue: category.lowercased()) {
                trackIgnored(category: cat)
            }
        default:
            break
        }
    }
}
