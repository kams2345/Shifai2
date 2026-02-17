package com.shifai.domain.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import java.util.*

/**
 * Smart Notification Engine — Android (S8-1 through S8-5)
 * Max 1/jour, per-category channels, anti-spam, actionable
 */
class NotificationEngine private constructor(private val context: Context) {

    companion object {
        @Volatile private var instance: NotificationEngine? = null
        fun getInstance(context: Context) = instance ?: synchronized(this) {
            instance ?: NotificationEngine(context.applicationContext).also { instance = it }
        }
    }

    enum class Category(
        val channelId: String,
        val displayName: String,
        val defaultHour: Int
    ) {
        PREDICTION("shifai_prediction", "Prédictions", 20),
        QUICK_WIN("shifai_quick_win", "Quick Wins", 9),
        EDUCATION("shifai_education", "Éducatif", 10),
        RECOMMENDATION("shifai_recommendation", "Recommandations", 8),
        REMINDER("shifai_reminder", "Rappels", 21)
    }

    private val prefs = context.getSharedPreferences("shifai_notifications", Context.MODE_PRIVATE)
    private var notifId = 1000

    // MARK: - S8-1: Create Channels (call from Application.onCreate)

    fun createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(NotificationManager::class.java)
            for (cat in Category.values()) {
                val channel = NotificationChannel(
                    cat.channelId, cat.displayName,
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Notifications ${cat.displayName} ShifAI"
                }
                manager.createNotificationChannel(channel)
            }
        }
    }

    // MARK: - S8-1: Max 1/Day Scheduler

    fun scheduleIfAllowed(category: Category, title: String, body: String, deepLink: String? = null) {
        if (!canSendToday()) return
        if (!isCategoryEnabled(category)) return
        if (isAutoStopped(category)) return
        if (isQuietHours()) return

        // Check POST_NOTIFICATIONS permission (Android 13+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) return
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            deepLink?.let { data = android.net.Uri.parse(it) }
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context, notifId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, category.channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        NotificationManagerCompat.from(context).notify(notifId++, notification)
        markSentToday()
    }

    // MARK: - S8-2: Cycle Predictions

    fun schedulePredictionNotification(daysUntilPeriod: Int, dateRange: String) {
        if (daysUntilPeriod !in 1..3) return
        scheduleIfAllowed(
            Category.PREDICTION,
            "Règles prévues dans ~$daysUntilPeriod jours",
            "Période estimée: $dateRange. Prépare-toi ☁️",
            "shifai://predictions"
        )
    }

    fun scheduleOvulationNotification(daysUntilOvulation: Int) {
        if (daysUntilOvulation !in 1..3) return
        scheduleIfAllowed(
            Category.PREDICTION,
            "Fenêtre d'ovulation dans ~$daysUntilOvulation jours",
            "Phase la plus fertile prévue bientôt 🌸",
            "shifai://predictions"
        )
    }

    // MARK: - S8-3: Quick Win & Educational

    fun scheduleQuickWinNotification(title: String, body: String) {
        val monthsUsing = prefs.getInt("months_using", 0)
        val lastTime = prefs.getLong("last_quickwin", 0L)
        val interval = if (monthsUsing <= 3) 7 * 86400_000L else 14 * 86400_000L
        if (System.currentTimeMillis() - lastTime < interval) return

        scheduleIfAllowed(Category.QUICK_WIN, title, body, "shifai://insights")
        prefs.edit().putLong("last_quickwin", System.currentTimeMillis()).apply()
    }

    fun scheduleEducationalNotification(day: Int, title: String, body: String) {
        if (day !in 4..13) return
        scheduleIfAllowed(Category.EDUCATION, title, body, "shifai://insights")
    }

    // MARK: - S8-4: Actionable Recommendations

    fun scheduleRecommendation(energyForecast: String, tip: String) {
        scheduleIfAllowed(
            Category.RECOMMENDATION,
            "☁️ $energyForecast prévue demain",
            tip, "shifai://insights"
        )
    }

    // MARK: - S8-5: Anti-Spam

    private fun canSendToday(): Boolean {
        val lastSent = prefs.getLong("last_notif_date", 0L)
        val cal = Calendar.getInstance()
        cal.timeInMillis = lastSent
        val today = Calendar.getInstance()
        return cal.get(Calendar.DAY_OF_YEAR) != today.get(Calendar.DAY_OF_YEAR) ||
                cal.get(Calendar.YEAR) != today.get(Calendar.YEAR)
    }

    private fun markSentToday() {
        prefs.edit().putLong("last_notif_date", System.currentTimeMillis()).apply()
    }

    private fun isQuietHours(): Boolean {
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val start = prefs.getInt("quiet_start", 22)
        val end = prefs.getInt("quiet_end", 8)
        return if (start > end) hour >= start || hour < end else hour in start until end
    }

    private fun isAutoStopped(category: Category): Boolean {
        return prefs.getInt("ignore_${category.channelId}", 0) >= 3
    }

    fun trackIgnored(category: Category) {
        val key = "ignore_${category.channelId}"
        prefs.edit().putInt(key, prefs.getInt(key, 0) + 1).apply()
    }

    fun trackOpened(category: Category) {
        prefs.edit().putInt("ignore_${category.channelId}", 0).apply()
    }

    // MARK: - Settings

    fun isCategoryEnabled(category: Category): Boolean {
        return prefs.getBoolean("${category.channelId}_enabled", true)
    }

    fun setCategoryEnabled(category: Category, enabled: Boolean) {
        prefs.edit().putBoolean("${category.channelId}_enabled", enabled).apply()
    }
}
