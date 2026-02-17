package com.shifai.app

/**
 * Centralized app configuration.
 * All environment-specific values in one place.
 */
object AppConfig {

    // ─── Supabase ───
    var supabaseURL: String = "https://your-project.supabase.co"
        private set
    var supabaseAnonKey: String = "your-anon-key"
        private set

    fun initializeSupabase(url: String, key: String) {
        supabaseURL = url
        supabaseAnonKey = key
    }

    // ─── Feature Flags ───
    const val ENABLE_ML_PREDICTIONS = true
    const val ENABLE_CLOUD_SYNC = true
    const val ENABLE_WIDGETS = true
    const val ENABLE_SHARE_EXPORT = true
    const val ENABLE_BIOMETRIC = true

    // ─── Thresholds ───
    const val MIN_CYCLES_FOR_ML = 3
    const val MAX_NOTIFICATIONS_PER_DAY = 1
    const val QUIET_HOURS_START = 22
    const val QUIET_HOURS_END = 7
    const val AUTO_STOP_IGNORE_THRESHOLD = 3
    const val SYNC_RETRY_LIMIT = 3
    const val ENCRYPTION_KEY_LENGTH = 256

    // ─── NFR Targets ───
    const val MAX_APP_LAUNCH_MS = 2000L
    const val MAX_SYNC_LATENCY_MS = 3000L
    const val MAX_ML_INFERENCE_MS = 500L
    const val TARGET_CRASH_FREE_RATE = 99.5
    const val MIN_ACCESSIBILITY_SCORE = 90.0

    // ─── URLs ───
    const val PRIVACY_POLICY_URL = "https://shifai.app/privacy"
    const val TERMS_OF_SERVICE_URL = "https://shifai.app/terms"
    const val SUPPORT_URL = "https://shifai.app/support"

    // ─── Analytics ───
    const val ANALYTICS_ENDPOINT = "https://plausible.io/api/event"
    const val ANALYTICS_DOMAIN = "shifai.app"

    // ─── Storage ───
    const val MAX_EXPORT_SIZE_MB = 10
    const val SHARE_LINK_EXPIRY_HOURS = 24
    const val DATABASE_NAME = "shifai_encrypted.db"
}
