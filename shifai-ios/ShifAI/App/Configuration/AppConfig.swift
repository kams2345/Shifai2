import Foundation

// MARK: - App Configuration

enum AppConfig {
    // MARK: Environment
    enum Environment: String {
        case development
        case staging
        case production
    }

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    // MARK: Supabase
    enum Supabase {
        static var url: String {
            switch AppConfig.current {
            case .development:
                return "https://dev.supabase.shifai.app"
            case .staging:
                return "https://staging.supabase.shifai.app"
            case .production:
                return "https://api.supabase.shifai.app"
            }
        }

        // IMPORTANT: Store in Secrets.xcconfig, never commit
        static var anonKey: String {
            guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
                fatalError("SUPABASE_ANON_KEY not set in Secrets.xcconfig")
            }
            return key
        }

        static let region = "eu-west-1" // EU ONLY — GDPR requirement
    }

    // MARK: Encryption
    enum Encryption {
        static let pbkdf2Iterations = 100_000
        static let saltLength = 32 // bytes
        static let keyLength = 256 // bits (AES-256)
        static let gcmNonceLength = 12 // bytes
    }

    // MARK: Sync
    enum Sync {
        static let backgroundIntervalHours = 6.0
        static let maxBlobSizeMB = 10
        static let wifiOnlyDefault = true
    }

    // MARK: Security
    enum Security {
        static let autoLockDefaultSeconds: TimeInterval = 300 // 5 min
        static let autoLockMinSeconds: TimeInterval = 60 // 1 min
        static let autoLockMaxSeconds: TimeInterval = 900 // 15 min
        static let maxFailedAuthAttempts = 5
        static let authLockoutDurationSeconds: TimeInterval = 900 // 15 min
    }

    // MARK: Performance Targets (from PRD NFRs)
    enum Performance {
        static let coldStartMaxSeconds = 4.0
        static let warmStartMaxSeconds = 1.0
        static let screenTransitionMaxMs = 300
        static let mlInferenceMaxMs = 150
        static let syncUploadMaxSeconds = 2.0
    }

    // MARK: Feature Flags
    enum FeatureFlags {
        static var mlEngineEnabled: Bool { false } // Phase 2
        static var cloudSyncAvailable: Bool { true }
        static var shareableLinkEnabled: Bool { true }
        static var lockScreenWidgetEnabled: Bool { true }
    }

    // MARK: App Info
    static let appName = "ShifAI"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let minimumIOSVersion = "16.0"
}
