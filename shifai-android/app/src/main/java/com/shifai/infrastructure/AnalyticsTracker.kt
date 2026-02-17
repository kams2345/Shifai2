package com.shifai.infrastructure

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

/**
 * Privacy-Safe Analytics — Plausible EU, zero PII, GDPR-safe.
 * Mirrors iOS AnalyticsTracker.swift for full parity.
 */
class AnalyticsTracker private constructor(context: Context) {

    companion object {
        private const val TAG = "AnalyticsTracker"
        private const val PREFS_NAME = "shifai_analytics"
        private const val PLAUSIBLE_DOMAIN = "shifai.app"
        private const val PLAUSIBLE_ENDPOINT = "https://plausible.io/api/event"
        private const val BUFFER_FLUSH_SIZE = 20

        @Volatile private var instance: AnalyticsTracker? = null
        fun getInstance(context: Context): AnalyticsTracker =
            instance ?: synchronized(this) {
                instance ?: AnalyticsTracker(context.applicationContext).also { instance = it }
            }
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private var sessionStart: Long? = null

    // Mirror of iOS events
    enum class Event(val key: String) {
        // Onboarding
        ONBOARDING_STARTED("onboarding_started"),
        ONBOARDING_COMPLETED("onboarding_completed"),
        ONBOARDING_SKIPPED("onboarding_skipped"),
        // Core Usage
        DAILY_LOG_SAVED("daily_log_saved"),
        SYMPTOM_LOGGED("symptom_logged"),
        BODY_MAP_USED("body_map_used"),
        // Intelligence
        INSIGHTS_VIEWED("insights_viewed"),
        PREDICTION_VIEWED("prediction_viewed"),
        FEEDBACK_GIVEN("feedback_given"),
        RECOMMENDATION_FOLLOWED("recommendation_followed"),
        // Quick Wins
        QUICKWIN_J1("quickwin_j1"),
        QUICKWIN_J3("quickwin_j3"),
        QUICKWIN_J7("quickwin_j7"),
        QUICKWIN_J14("quickwin_j14"),
        QUICKWIN_CYCLE1("quickwin_cycle1"),
        // Export
        EXPORT_GENERATED("export_generated"),
        EXPORT_SHARED("export_shared"),
        // Sync
        SYNC_COMPLETED("sync_completed"),
        SYNC_CONFLICT("sync_conflict"),
        SYNC_CONFLICT_RESOLVED("sync_conflict_resolved"),
        // Notifications
        NOTIFICATION_SENT("notification_sent"),
        NOTIFICATION_OPENED("notification_opened"),
        // Settings
        SETTINGS_OPENED("settings_opened"),
        DATA_EXPORTED("data_exported"),
        ACCOUNT_DELETED("account_deleted"),
        // Retention
        APP_OPENED("app_opened"),
        SESSION_DURATION("session_duration")
    }

    fun track(event: Event, properties: Map<String, String> = emptyMap()) {
        if (!isEnabled()) return

        // Scrub potential PII
        val safeProps = properties.filterKeys { key ->
            key.lowercase() !in listOf("email", "name", "phone", "address", "ip")
        }

        sendToPlausible(event.key, safeProps)
        bufferLocally(event.key, safeProps)
    }

    private fun sendToPlausible(eventName: String, props: Map<String, String>) {
        Thread {
            try {
                val url = URL(PLAUSIBLE_ENDPOINT)
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.doOutput = true

                val payload = JSONObject().apply {
                    put("name", eventName)
                    put("domain", PLAUSIBLE_DOMAIN)
                    put("url", "app://$eventName")
                    if (props.isNotEmpty()) {
                        put("props", JSONObject(props as Map<*, *>))
                    }
                }

                conn.outputStream.use { it.write(payload.toString().toByteArray()) }
                conn.responseCode // trigger send
                conn.disconnect()
            } catch (e: Exception) {
                Log.w(TAG, "Plausible send failed: ${e.message}")
            }
        }.start()
    }

    private fun bufferLocally(event: String, props: Map<String, String>) {
        val buffer = prefs.getStringSet("buffer", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        val entry = JSONObject().apply {
            put("event", event)
            put("ts", System.currentTimeMillis())
            props.forEach { (k, v) -> put(k, v) }
        }.toString()

        buffer.add(entry)

        if (buffer.size >= BUFFER_FLUSH_SIZE) {
            flushBuffer(buffer)
            prefs.edit().putStringSet("buffer", emptySet()).apply()
        } else {
            prefs.edit().putStringSet("buffer", buffer).apply()
        }
    }

    private fun flushBuffer(buffer: Set<String>) {
        // TODO: Batch insert into Supabase analytics_events table
        Log.d(TAG, "Flushing ${buffer.size} analytics events")
    }

    // Session
    fun startSession() {
        sessionStart = System.currentTimeMillis()
        track(Event.APP_OPENED)
    }

    fun endSession() {
        sessionStart?.let { start ->
            val seconds = (System.currentTimeMillis() - start) / 1000
            track(Event.SESSION_DURATION, mapOf("seconds" to "$seconds"))
        }
        sessionStart = null
    }

    // Consent
    fun isEnabled(): Boolean = prefs.getBoolean("enabled", false)
    fun setEnabled(enabled: Boolean) { prefs.edit().putBoolean("enabled", enabled).apply() }
}
