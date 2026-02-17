package com.shifai.data.monitoring

import android.content.Context
import android.util.Log
import com.shifai.data.analytics.AnalyticsTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

/**
 * Crash Reporter — lightweight error tracking for production.
 * No third-party dependency: logs to local file + Plausible events.
 * Follows zero-PII principle.
 * Mirrors iOS CrashReporter.swift.
 */
object CrashReporter {

    private const val LOG_FILE = "crash_log.txt"
    private const val MAX_LOG_SIZE = 500_000L  // 500 KB
    private const val TAG = "CrashReporter"

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.FRANCE)
    private lateinit var logFile: File
    private var analyticsTracker: AnalyticsTracker? = null

    fun init(context: Context, tracker: AnalyticsTracker? = null) {
        logFile = File(context.filesDir, LOG_FILE)
        analyticsTracker = tracker

        // Set global uncaught exception handler
        val default = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            logCrash(throwable, "UncaughtException on ${thread.name}")
            default?.uncaughtException(thread, throwable)
        }
    }

    // ─── Logging ───

    fun log(errorCode: String, message: String, context: String = "") {
        val timestamp = dateFormat.format(Date())
        val line = "[$timestamp] [$errorCode] $message | $context\n"
        appendToFile(line)
        Log.w(TAG, line.trim())

        analyticsTracker?.let { tracker ->
            CoroutineScope(Dispatchers.IO).launch {
                tracker.trackError(errorCode)
            }
        }
    }

    fun logCrash(error: Throwable, context: String = "") {
        val timestamp = dateFormat.format(Date())
        val entry = "[CRASH] $timestamp | ${error::class.simpleName}: ${error.message} | $context\n"
        appendToFile(entry)
        Log.e(TAG, entry.trim())
    }

    // ─── Retrieval ───

    fun getRecentLogs(lines: Int = 50): String {
        if (!::logFile.isInitialized || !logFile.exists()) return ""
        val allLines = logFile.readLines()
        return allLines.takeLast(lines).joinToString("\n")
    }

    fun clearLogs() {
        if (::logFile.isInitialized) {
            logFile.writeText("")
        }
    }

    // ─── File Management ───

    private fun appendToFile(text: String) {
        try {
            if (!::logFile.isInitialized) return

            // Rotate if too large
            if (logFile.exists() && logFile.length() > MAX_LOG_SIZE) {
                clearLogs()
            }
            logFile.appendText(text)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to write log: ${e.message}")
        }
    }
}
