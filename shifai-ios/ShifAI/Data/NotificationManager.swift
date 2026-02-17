import Foundation
import UserNotifications

/// Notification Manager — schedules and manages local notifications.
/// Categories: predictions, recommendations, quick_wins, educational.
/// Respects quiet hours (22:00 - 07:00).
/// Mirrors Android ShifAINotificationManager.kt.
final class NotificationManager {

    enum Category: String, CaseIterable {
        case predictions = "predictions"
        case recommendations = "recommendations"
        case quickWins = "quick_wins"
        case educational = "educational"

        var title: String {
            switch self {
            case .predictions: return "Prédictions de cycle"
            case .recommendations: return "Recommandations"
            case .quickWins: return "Astuces rapides"
            case .educational: return "Contenu éducatif"
            }
        }
    }

    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Categories

    func registerCategories() {
        let categories = Category.allCases.map { category in
            UNNotificationCategory(
                identifier: category.rawValue,
                actions: [],
                intentIdentifiers: [],
                options: []
            )
        }
        center.setNotificationCategories(Set(categories))
    }

    // MARK: - Scheduling

    func schedulePrediction(title: String, body: String, date: Date) {
        guard !isInQuietHours(date) else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = Category.predictions.rawValue
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Quiet Hours

    func isInQuietHours(_ date: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        let start = AppConfig.quietHoursStart  // 22
        let end = AppConfig.quietHoursEnd      // 7
        if start > end {
            return hour >= start || hour < end
        } else {
            return hour >= start && hour < end
        }
    }

    // MARK: - Management

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    func cancelByCategory(_ category: Category) {
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.content.categoryIdentifier == category.rawValue }
                .map(\.identifier)
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
