import Foundation

/// Onboarding Data — stores user profile from onboarding flow.
/// Persisted to UserDefaults, synced to Supabase profiles table.
struct OnboardingData: Codable {
    var cycleLength: Int
    var periodLength: Int
    var birthYear: Int?
    var lastPeriodDate: Date?
    var goals: [Goal]
    var notificationsEnabled: Bool
    var healthKitEnabled: Bool

    enum Goal: String, Codable, CaseIterable {
        case trackCycle = "track_cycle"
        case predictPeriod = "predict_period"
        case monitorSymptoms = "monitor_symptoms"
        case fertilityAwareness = "fertility_awareness"
        case medicalExport = "medical_export"
        case understandPatterns = "understand_patterns"
    }

    // MARK: - Defaults

    static let defaultCycleLength = 28
    static let defaultPeriodLength = 5

    init(
        cycleLength: Int = Self.defaultCycleLength,
        periodLength: Int = Self.defaultPeriodLength,
        birthYear: Int? = nil,
        lastPeriodDate: Date? = nil,
        goals: [Goal] = [.trackCycle],
        notificationsEnabled: Bool = true,
        healthKitEnabled: Bool = false
    ) {
        self.cycleLength = max(21, min(45, cycleLength))
        self.periodLength = max(2, min(10, periodLength))
        self.birthYear = birthYear
        self.lastPeriodDate = lastPeriodDate
        self.goals = goals
        self.notificationsEnabled = notificationsEnabled
        self.healthKitEnabled = healthKitEnabled
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "onboarding_data")
        }
    }

    static func load() -> OnboardingData? {
        guard let data = UserDefaults.standard.data(forKey: "onboarding_data") else { return nil }
        return try? JSONDecoder().decode(OnboardingData.self, from: data)
    }
}
