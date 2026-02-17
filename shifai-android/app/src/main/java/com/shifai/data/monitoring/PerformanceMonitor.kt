package com.shifai.data.monitoring

import android.os.SystemClock
import android.util.Log

/**
 * Performance Monitor — lightweight instrumentation for production.
 * Tracks startup time, DB queries, sync duration, and screen transitions.
 * Mirrors iOS PerformanceMonitor.swift.
 */
object PerformanceMonitor {

    private const val TAG = "PerfMonitor"
    private val marks = mutableMapOf<String, Long>()

    // ─── Measurement ───

    fun start(label: String) {
        marks[label] = SystemClock.elapsedRealtime()
    }

    fun end(label: String): Long? {
        val startTime = marks.remove(label) ?: return null
        val durationMs = SystemClock.elapsedRealtime() - startTime

        val budgetMs = budgetFor(label)
        if (durationMs > budgetMs) {
            Log.w(TAG, "⚠️ $label: ${durationMs}ms (budget: ${budgetMs}ms)")
            CrashReporter.log("PERF_EXCEEDED", "$label exceeded budget", "${durationMs}ms > ${budgetMs}ms")
        } else {
            Log.d(TAG, "✓ $label: ${durationMs}ms")
        }

        return durationMs
    }

    inline fun <T> measure(label: String, block: () -> T): T {
        start(label)
        val result = block()
        end(label)
        return result
    }

    suspend inline fun <T> measureAsync(label: String, block: () -> T): T {
        start(label)
        val result = block()
        end(label)
        return result
    }

    // ─── Budgets (from PERFORMANCE_BUDGET.md) ───

    private fun budgetFor(label: String): Long = when (label) {
        "cold_start" -> 1500
        "warm_start" -> 500
        "db_open" -> 200
        "save_daily_log" -> 200
        "load_chart" -> 300
        "ml_prediction" -> 500
        "pdf_generation" -> 3000
        "sync" -> 5000
        "tab_switch" -> 100
        "widget_refresh" -> 1000
        else -> 1000
    }
}
