package com.shifai.infrastructure

import android.os.SystemClock
import android.util.Log
import java.util.concurrent.ConcurrentHashMap

/**
 * Performance Monitoring — mirrors iOS PerformanceMonitor.swift
 * Uses os.log equivalent (android.util.Log) with NFR threshold checks.
 */
object PerformanceMonitor {

    private const val TAG = "ShifAI.Perf"

    // NFR thresholds (milliseconds)
    object Thresholds {
        const val COLD_START_MS = 4000L      // < 4s
        const val WARM_START_MS = 2000L      // < 2s
        const val TRANSITION_MS = 300L       // < 300ms
        const val ML_INFERENCE_MS = 500L     // < 500ms
        const val SYNC_PUSH_MS = 5000L       // < 5s
        const val PDF_GENERATION_MS = 3000L  // < 3s
    }

    private val markers = ConcurrentHashMap<String, Long>()

    /**
     * Start a timing measurement.
     */
    fun startMeasure(label: String) {
        markers[label] = SystemClock.elapsedRealtime()
        Log.d(TAG, "⏱ START: $label")
    }

    /**
     * End a timing measurement. Returns elapsed ms.
     * Logs warnings if NFR thresholds are exceeded.
     */
    fun endMeasure(label: String): Long? {
        val start = markers.remove(label) ?: return null
        val elapsed = SystemClock.elapsedRealtime() - start

        // Check against thresholds
        when {
            label.contains("cold_start") && elapsed > Thresholds.COLD_START_MS ->
                Log.w(TAG, "⚠️ Cold start ${elapsed}ms > ${Thresholds.COLD_START_MS}ms target")
            label.contains("warm_start") && elapsed > Thresholds.WARM_START_MS ->
                Log.w(TAG, "⚠️ Warm start ${elapsed}ms > ${Thresholds.WARM_START_MS}ms target")
            label.contains("transition") && elapsed > Thresholds.TRANSITION_MS ->
                Log.w(TAG, "⚠️ Transition ${elapsed}ms > ${Thresholds.TRANSITION_MS}ms target")
            label.contains("ml_inference") && elapsed > Thresholds.ML_INFERENCE_MS ->
                Log.w(TAG, "⚠️ ML inference ${elapsed}ms > ${Thresholds.ML_INFERENCE_MS}ms target")
            label.contains("sync") && elapsed > Thresholds.SYNC_PUSH_MS ->
                Log.w(TAG, "⚠️ Sync ${elapsed}ms > ${Thresholds.SYNC_PUSH_MS}ms target")
            label.contains("pdf") && elapsed > Thresholds.PDF_GENERATION_MS ->
                Log.w(TAG, "⚠️ PDF gen ${elapsed}ms > ${Thresholds.PDF_GENERATION_MS}ms target")
        }

        Log.d(TAG, "⏱ END: $label = ${elapsed}ms")
        return elapsed
    }

    /**
     * Log memory usage.
     */
    fun logMemory() {
        val runtime = Runtime.getRuntime()
        val used = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024)
        val max = runtime.maxMemory() / (1024 * 1024)
        Log.d(TAG, "📊 Memory: ${used}MB / ${max}MB")
    }

    /**
     * Convenience: measure a block of code.
     */
    inline fun <T> measure(label: String, block: () -> T): T {
        startMeasure(label)
        val result = block()
        endMeasure(label)
        return result
    }
}
