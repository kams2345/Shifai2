package com.shifai.di

import android.content.Context
import com.shifai.data.analytics.AnalyticsTracker
import com.shifai.data.local.AppDatabase
import com.shifai.data.network.SupabaseClient
import com.shifai.data.notification.ShifAINotificationManager
import com.shifai.data.repository.CycleRepository
import com.shifai.data.repository.InsightsRepository
import com.shifai.data.sync.SyncManager
import com.shifai.presentation.dashboard.DashboardViewModel
import com.shifai.presentation.export.ExportViewModel
import com.shifai.presentation.insights.InsightsViewModel
import com.shifai.presentation.onboarding.OnboardingViewModel
import com.shifai.presentation.settings.SettingsViewModel
import com.shifai.presentation.tracking.TrackingViewModel

/**
 * Manual DI Container — lightweight dependency injection.
 * Initializes database, repositories, and provides ViewModel factories.
 * Alternative to Hilt/Koin for a smaller dependency footprint.
 */
object AppContainer {

    private lateinit var appContext: Context
    private lateinit var database: AppDatabase

    // ─── Data Layer ───

    val supabaseClient: SupabaseClient by lazy { SupabaseClient() }

    val cycleRepository: CycleRepository by lazy {
        CycleRepository(
            cycleDao = database.cycleEntryDao(),
            symptomDao = database.symptomLogDao(),
            supabaseClient = supabaseClient
        )
    }

    val insightsRepository: InsightsRepository by lazy {
        InsightsRepository(insightDao = database.insightDao())
    }

    // ─── Services ───

    val syncManager: SyncManager by lazy {
        SyncManager(cycleRepository, insightsRepository, supabaseClient)
    }

    val notificationManager: ShifAINotificationManager by lazy {
        ShifAINotificationManager(appContext)
    }

    val analyticsTracker: AnalyticsTracker by lazy {
        AnalyticsTracker(
            appContext.getSharedPreferences("shifai_prefs", Context.MODE_PRIVATE)
        )
    }

    // ─── Initialization ───

    fun init(context: Context) {
        appContext = context.applicationContext

        // Get database passphrase from Keystore
        val passphrase = com.shifai.data.encryption.EncryptionManager.getDatabaseKey(appContext)
        database = AppDatabase.getInstance(appContext, passphrase)

        // Setup notification channels
        notificationManager.createChannels()
    }

    // ─── ViewModel Factories ───

    fun dashboardViewModel() = DashboardViewModel()
    fun trackingViewModel() = TrackingViewModel()
    fun insightsViewModel() = InsightsViewModel()
    fun exportViewModel() = ExportViewModel()
    fun settingsViewModel() = SettingsViewModel()
    fun onboardingViewModel() = OnboardingViewModel()
}
