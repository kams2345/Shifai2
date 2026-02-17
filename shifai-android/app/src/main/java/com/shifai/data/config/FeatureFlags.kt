package com.shifai.data.config

/**
 * Feature Flags — remote config for gradual feature rollout.
 * Defaults to local values, overridden by Supabase app_config table.
 * Mirrors iOS FeatureFlags.swift.
 */
object FeatureFlags {

    private var remoteFlags = mutableMapOf<String, Boolean>()
    private val defaults = mapOf(
        "ml_predictions" to false,
        "share_links" to true,
        "cycle_insights" to true,
        "body_map_v2" to false,
        "pdf_export" to true,
        "widget_predictions" to false,
        "biometric_lock" to true,
        "analytics_v2" to false,
        "background_sync" to true,
        "csv_export" to true,
    )

    // ─── Access ───

    fun isEnabled(flag: String): Boolean =
        remoteFlags[flag] ?: defaults[flag] ?: false

    val mlPredictions: Boolean get() = isEnabled("ml_predictions")
    val shareLinks: Boolean get() = isEnabled("share_links")
    val cycleInsights: Boolean get() = isEnabled("cycle_insights")
    val bodyMapV2: Boolean get() = isEnabled("body_map_v2")
    val pdfExport: Boolean get() = isEnabled("pdf_export")
    val widgetPredictions: Boolean get() = isEnabled("widget_predictions")
    val biometricLock: Boolean get() = isEnabled("biometric_lock")
    val backgroundSync: Boolean get() = isEnabled("background_sync")
    val csvExport: Boolean get() = isEnabled("csv_export")

    // ─── Remote Update ───

    fun update(remote: Map<String, Boolean>) {
        remoteFlags.clear()
        remoteFlags.putAll(remote)
    }

    fun reset() {
        remoteFlags.clear()
    }
}
