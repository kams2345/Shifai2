package com.shifai.app

import android.app.Application
import com.shifai.data.monitoring.CrashReporter
import com.shifai.data.monitoring.PerformanceMonitor
import com.shifai.data.notification.ShifAINotificationManager
import com.shifai.data.sync.SyncWorker
import com.shifai.di.AppContainer

/**
 * ShifAI Application — app-level lifecycle management.
 * Initializes: DI, crash reporting, notifications, background sync.
 * Mirrors iOS ShifAIApp.swift init sequence.
 */
class ShifAIApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        PerformanceMonitor.start("cold_start")

        // 1. Initialize DI container
        AppContainer.init(this)

        // 2. Initialize crash reporting
        CrashReporter.init(this, AppContainer.analyticsTracker)

        // 3. Create notification channels
        ShifAINotificationManager(this).createChannels()

        // 4. Schedule background sync
        SyncWorker.schedule(this)

        PerformanceMonitor.end("cold_start")
    }
}
