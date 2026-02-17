package com.shifai.data.widget

import android.content.Context
import android.content.SharedPreferences

/**
 * Widget Data Provider — SharedPreferences bridge for Glance widget.
 * Mirrors iOS WidgetDataProvider.swift (which uses App Groups).
 */
object WidgetDataProvider {

    private const val PREFS_NAME = "shifai_widget_data"

    private const val KEY_CYCLE_DAY = "cycle_day"
    private const val KEY_CYCLE_TOTAL = "cycle_total"
    private const val KEY_PHASE = "phase"
    private const val KEY_PHASE_EMOJI = "phase_emoji"
    private const val KEY_ENERGY = "energy_forecast"
    private const val KEY_PRIVACY_MODE = "privacy_mode"
    private const val KEY_LAST_UPDATED = "last_updated"

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    // ─── Write (called from main app) ───

    fun updateCycleData(
        context: Context,
        cycleDay: Int,
        cycleDayTotal: Int,
        phase: String,
        phaseEmoji: String,
        energyForecast: String
    ) {
        prefs(context).edit()
            .putInt(KEY_CYCLE_DAY, cycleDay)
            .putInt(KEY_CYCLE_TOTAL, cycleDayTotal)
            .putString(KEY_PHASE, phase)
            .putString(KEY_PHASE_EMOJI, phaseEmoji)
            .putString(KEY_ENERGY, energyForecast)
            .putLong(KEY_LAST_UPDATED, System.currentTimeMillis())
            .apply()
    }

    fun setPrivacyMode(context: Context, enabled: Boolean) {
        prefs(context).edit()
            .putBoolean(KEY_PRIVACY_MODE, enabled)
            .apply()
    }

    // ─── Read (called from widget) ───

    fun getCycleDay(context: Context): Int =
        prefs(context).getInt(KEY_CYCLE_DAY, 1)

    fun getCycleDayTotal(context: Context): Int =
        prefs(context).getInt(KEY_CYCLE_TOTAL, 28)

    fun getPhase(context: Context): String =
        prefs(context).getString(KEY_PHASE, "Folliculaire") ?: "Folliculaire"

    fun getPhaseEmoji(context: Context): String =
        prefs(context).getString(KEY_PHASE_EMOJI, "🌱") ?: "🌱"

    fun getEnergyForecast(context: Context): String =
        prefs(context).getString(KEY_ENERGY, "—") ?: "—"

    fun isPrivacyModeEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_PRIVACY_MODE, false)

    fun getLastUpdated(context: Context): Long =
        prefs(context).getLong(KEY_LAST_UPDATED, 0)

    // ─── Cleanup ───

    fun clearAll(context: Context) {
        prefs(context).edit().clear().apply()
    }
}
