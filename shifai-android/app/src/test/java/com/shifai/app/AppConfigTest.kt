package com.shifai.app

import org.junit.Assert.*
import org.junit.Test

class AppConfigTest {

    // ─── Feature Flags ───

    @Test
    fun `ML predictions enabled by default`() {
        assertTrue(AppConfig.ENABLE_ML_PREDICTIONS)
    }

    @Test
    fun `cloud sync enabled by default`() {
        assertTrue(AppConfig.ENABLE_CLOUD_SYNC)
    }

    @Test
    fun `widgets enabled by default`() {
        assertTrue(AppConfig.ENABLE_WIDGETS)
    }

    @Test
    fun `biometric enabled by default`() {
        assertTrue(AppConfig.ENABLE_BIOMETRIC)
    }

    // ─── Thresholds ───

    @Test
    fun `min cycles for ML is 3`() {
        assertEquals(3, AppConfig.MIN_CYCLES_FOR_ML)
    }

    @Test
    fun `max notifications per day is 1`() {
        assertEquals(1, AppConfig.MAX_NOTIFICATIONS_PER_DAY)
    }

    @Test
    fun `quiet hours are 22-07`() {
        assertEquals(22, AppConfig.QUIET_HOURS_START)
        assertEquals(7, AppConfig.QUIET_HOURS_END)
    }

    @Test
    fun `encryption key length is 256`() {
        assertEquals(256, AppConfig.ENCRYPTION_KEY_LENGTH)
    }

    // ─── NFR Targets ───

    @Test
    fun `app launch target under 2 seconds`() {
        assertEquals(2000L, AppConfig.MAX_APP_LAUNCH_MS)
    }

    @Test
    fun `crash free rate target is 99_5 percent`() {
        assertEquals(99.5, AppConfig.TARGET_CRASH_FREE_RATE, 0.01)
    }

    // ─── URLs ───

    @Test
    fun `privacy URL is HTTPS`() {
        assertTrue(AppConfig.PRIVACY_POLICY_URL.startsWith("https://"))
    }

    @Test
    fun `analytics domain is shifai_app`() {
        assertEquals("shifai.app", AppConfig.ANALYTICS_DOMAIN)
    }

    // ─── Database ───

    @Test
    fun `database name includes encrypted`() {
        assertTrue(AppConfig.DATABASE_NAME.contains("encrypted"))
    }

    // ─── Supabase init ───

    @Test
    fun `initializeSupabase sets values`() {
        AppConfig.initializeSupabase("https://test.supabase.co", "test-key")
        assertEquals("https://test.supabase.co", AppConfig.supabaseURL)
        assertEquals("test-key", AppConfig.supabaseAnonKey)
    }
}
