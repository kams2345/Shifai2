import Foundation

/// Centralized app configuration.
/// All environment-specific values in one place.
enum AppConfig {

    // MARK: - Supabase

    static let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        ?? "https://your-project.supabase.co"

    static let supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
        ?? "your-anon-key"

    // MARK: - Feature Flags

    static let enableMLPredictions = true
    static let enableCloudSync = true
    static let enableWidgets = true
    static let enableShareExport = true
    static let enableBiometric = true

    // MARK: - Thresholds

    static let minCyclesForML = 3
    static let maxNotificationsPerDay = 1
    static let quietHoursStart = 22  // 22:00
    static let quietHoursEnd = 7     // 07:00
    static let autoStopIgnoreThreshold = 3
    static let syncRetryLimit = 3
    static let encryptionKeyLength = 256

    // MARK: - NFR Targets

    static let maxAppLaunchMs: Double = 2000
    static let maxSyncLatencyMs: Double = 3000
    static let maxMLInferenceMs: Double = 500
    static let targetCrashFreeRate: Double = 99.5
    static let minAccessibilityScore: Double = 90

    // MARK: - URLs

    static let privacyPolicyURL = URL(string: "https://shifai.app/privacy")!
    static let termsOfServiceURL = URL(string: "https://shifai.app/terms")!
    static let supportURL = URL(string: "https://shifai.app/support")!

    // MARK: - Analytics

    static let analyticsEndpoint = "https://plausible.io/api/event"
    static let analyticsDomain = "shifai.app"

    // MARK: - Storage

    static let maxExportSizeMB = 10
    static let shareLinkExpiryHours = 24
    static let databaseName = "shifai_encrypted.db"
}
