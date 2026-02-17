package com.shifai.data.analytics

import android.content.SharedPreferences
import com.shifai.config.AppConfig
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject

/**
 * Analytics Tracker — privacy-safe event tracking via Plausible.
 * Zero PII: no user_id, no health data, no device fingerprints.
 * Consent-based: disabled by default, user enables in Settings.
 */
class AnalyticsTracker(private val prefs: SharedPreferences) {

    companion object {
        private const val KEY_CONSENT = "analytics_consent"
        private const val PLAUSIBLE_URL = "https://plausible.io/api/event"
    }

    var isEnabled: Boolean
        get() = prefs.getBoolean(KEY_CONSENT, false)
        set(value) { prefs.edit().putBoolean(KEY_CONSENT, value).apply() }

    /**
     * Track a privacy-safe event.
     * Only sends if user has given consent.
     */
    suspend fun track(event: String, props: Map<String, String> = emptyMap()) {
        if (!isEnabled) return

        withContext(Dispatchers.IO) {
            try {
                val body = JSONObject().apply {
                    put("name", event)
                    put("url", "app://shifai/${event.replace("_", "/")}")
                    put("domain", AppConfig.plausibleDomain)
                    if (props.isNotEmpty()) {
                        put("props", JSONObject(props))
                    }
                }

                val conn = URL(PLAUSIBLE_URL).openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.setRequestProperty("User-Agent", "ShifAI Android/${AppConfig.appVersion}")
                conn.doOutput = true
                conn.connectTimeout = 5000
                conn.readTimeout = 5000

                conn.outputStream.use { it.write(body.toString().toByteArray()) }
                conn.responseCode // trigger send
                conn.disconnect()
            } catch (_: Exception) {
                // Analytics failures are silent — never block user flow
            }
        }
    }

    // ─── Convenience Events ───

    suspend fun trackAppLaunched() = track("app_launched", mapOf("platform" to "android"))

    suspend fun trackOnboardingCompleted(cycleLengthBucket: String) =
        track("onboarding_completed", mapOf("cycle_length_bucket" to cycleLengthBucket))

    suspend fun trackTrackingSaved(symptomCountBucket: String) =
        track("tracking_saved", mapOf("symptom_count_bucket" to symptomCountBucket))

    suspend fun trackExportGenerated(template: String, dateRange: String) =
        track("export_generated", mapOf("template" to template, "date_range" to dateRange))

    suspend fun trackSyncCompleted(conflictBucket: String) =
        track("sync_completed", mapOf("conflict_count_bucket" to conflictBucket))

    suspend fun trackError(errorCode: String) =
        track("error_occurred", mapOf("error_code" to errorCode))
}
