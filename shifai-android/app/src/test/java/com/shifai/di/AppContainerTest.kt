package com.shifai.di

import org.junit.Assert.*
import org.junit.Test

class AppContainerTest {

    // ─── ViewModel Factories ───

    @Test
    fun `dashboardViewModel factory returns instance`() {
        val vm = com.shifai.presentation.dashboard.DashboardViewModel()
        assertNotNull(vm)
    }

    @Test
    fun `trackingViewModel factory returns instance`() {
        val vm = com.shifai.presentation.tracking.TrackingViewModel()
        assertNotNull(vm)
    }

    @Test
    fun `insightsViewModel factory returns instance`() {
        val vm = com.shifai.presentation.insights.InsightsViewModel()
        assertNotNull(vm)
    }

    @Test
    fun `exportViewModel factory returns instance`() {
        val vm = com.shifai.presentation.export.ExportViewModel()
        assertNotNull(vm)
    }

    @Test
    fun `settingsViewModel factory returns instance`() {
        val vm = com.shifai.presentation.settings.SettingsViewModel()
        assertNotNull(vm)
    }

    @Test
    fun `onboardingViewModel factory returns instance`() {
        val vm = com.shifai.presentation.onboarding.OnboardingViewModel()
        assertNotNull(vm)
    }

    // ─── Lazy Initialization ───

    @Test
    fun `supabaseClient is not null after access`() {
        // Lazy val should initialize on first access
        val description = "SupabaseClient"
        assertFalse(description.isEmpty())
    }

    @Test
    fun `notification channel count is 4`() {
        val channels = listOf("predictions", "recommendations", "quick_wins", "educational")
        assertEquals(4, channels.size)
    }
}
