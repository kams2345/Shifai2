package com.shifai.data.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.shifai.config.AppConfig

/**
 * Notification Manager — schedules and manages local notifications.
 * Categories: predictions, recommendations, quick_wins, educational.
 * Respects quiet hours (22:00 - 07:00).
 */
class ShifAINotificationManager(private val context: Context) {

    companion object {
        const val CHANNEL_PREDICTIONS = "predictions"
        const val CHANNEL_RECOMMENDATIONS = "recommendations"
        const val CHANNEL_QUICK_WINS = "quick_wins"
        const val CHANNEL_EDUCATIONAL = "educational"
    }

    /**
     * Create notification channels (Android 8+).
     * Called once at app startup.
     */
    fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = context.getSystemService(NotificationManager::class.java)

        val channels = listOf(
            NotificationChannel(
                CHANNEL_PREDICTIONS,
                "Prédictions de cycle",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply { description = "Alertes pour les prédictions de phases et dates" },

            NotificationChannel(
                CHANNEL_RECOMMENDATIONS,
                "Recommandations",
                NotificationManager.IMPORTANCE_LOW
            ).apply { description = "Conseils personnalisés basés sur vos données" },

            NotificationChannel(
                CHANNEL_QUICK_WINS,
                "Astuces rapides",
                NotificationManager.IMPORTANCE_LOW
            ).apply { description = "Petits conseils quotidiens" },

            NotificationChannel(
                CHANNEL_EDUCATIONAL,
                "Contenu éducatif",
                NotificationManager.IMPORTANCE_MIN
            ).apply { description = "Articles et informations sur le cycle menstruel" }
        )

        channels.forEach { manager.createNotificationChannel(it) }
    }

    /**
     * Check if a notification should be sent based on quiet hours.
     */
    fun isInQuietHours(): Boolean {
        val now = java.util.Calendar.getInstance()
        val hour = now.get(java.util.Calendar.HOUR_OF_DAY)
        val start = AppConfig.quietHoursStart
        val end = AppConfig.quietHoursEnd
        return if (start > end) {
            hour >= start || hour < end  // e.g., 22:00 - 07:00
        } else {
            hour in start until end
        }
    }

    /**
     * Schedule a prediction notification for a future date.
     */
    fun schedulePredictionAlert(
        title: String,
        body: String,
        triggerAtMillis: Long
    ) {
        if (isInQuietHours()) return
        // TODO: use AlarmManager or WorkManager for exact scheduling
    }
}
