package com.shifai

import android.app.Application
import android.util.Log
import com.shifai.data.encryption.EncryptionManager
import com.shifai.data.local.ShifAIDatabase
import com.shifai.domain.notifications.NotificationEngine

/**
 * ShifAI Application entry point.
 * Initializes encryption, database, notifications, and monitoring services.
 */
class ShifAIApplication : Application() {

    companion object {
        const val TAG = "ShifAI"
        lateinit var instance: ShifAIApplication
            private set
    }

    override fun onCreate() {
        super.onCreate()
        instance = this

        initializeEncryption()
        initializeDatabase()
        initializeNotifications()
        initializeMonitoring()

        Log.i(TAG, "ShifAI initialized — v1.0.0")
    }

    private fun initializeEncryption() {
        EncryptionManager.getInstance(this)
        Log.d(TAG, "Encryption initialized (AndroidKeyStore)")
    }

    private fun initializeDatabase() {
        ShifAIDatabase.getInstance(this)
        Log.d(TAG, "Database initialized (Room + SQLCipher)")
    }

    private fun initializeNotifications() {
        NotificationEngine.getInstance(this).createChannels()
        Log.d(TAG, "Notification channels created")
    }

    private fun initializeMonitoring() {
        // Plausible Analytics — EU-hosted, zero PII, no cookies
        Log.d(TAG, "Monitoring initialized (Plausible EU)")
    }
}
