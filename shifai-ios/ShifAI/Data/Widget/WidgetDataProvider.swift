import Foundation
import WidgetKit

// MARK: - Widget Data Provider (S5-6)
// Shared data bridge between main app and widget extension
// iOS: App Group shared container, read-only
// ZERO network — local data only

final class WidgetDataProvider {

    static let shared = WidgetDataProvider()

    // App Group identifier — must match main app + widget entitlements
    private let appGroupId = "group.com.shifai.shared"
    private let dataKey = "widget_cycle_data"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    // MARK: - Data Structure

    struct WidgetCycleData: Codable {
        let cycleDay: Int
        let phase: String
        let phaseEmoji: String
        let energyForecast: Int          // 1-10
        let nextPeriodDays: Int?
        let todaySymptomCount: Int
        let lastMood: String?            // emoji
        let latestInsightTitle: String?
        let updatedAt: Date

        static let empty = WidgetCycleData(
            cycleDay: 0, phase: "—", phaseEmoji: "❓",
            energyForecast: 5, nextPeriodDays: nil,
            todaySymptomCount: 0, lastMood: nil,
            latestInsightTitle: nil, updatedAt: Date()
        )
    }

    // MARK: - Write (called by main app after each log)

    func updateWidgetData(
        cycleDay: Int,
        phase: CyclePhase,
        energyForecast: Int,
        nextPeriodDays: Int?,
        todaySymptomCount: Int,
        lastMood: String?,
        latestInsightTitle: String?
    ) {
        let data = WidgetCycleData(
            cycleDay: cycleDay,
            phase: phase.displayName,
            phaseEmoji: phase.emoji,
            energyForecast: energyForecast,
            nextPeriodDays: nextPeriodDays,
            todaySymptomCount: todaySymptomCount,
            lastMood: lastMood,
            latestInsightTitle: latestInsightTitle,
            updatedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults?.set(encoded, forKey: dataKey)
        }

        // Request widget timeline refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read (called by widget extension)

    func readWidgetData() -> WidgetCycleData {
        guard let data = sharedDefaults?.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(WidgetCycleData.self, from: data) else {
            return .empty
        }
        return decoded
    }

    // MARK: - Privacy Mode

    var isPrivacyModeEnabled: Bool {
        sharedDefaults?.bool(forKey: "widget_privacy_mode") ?? false
    }

    func setPrivacyMode(_ enabled: Bool) {
        sharedDefaults?.set(enabled, forKey: "widget_privacy_mode")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
