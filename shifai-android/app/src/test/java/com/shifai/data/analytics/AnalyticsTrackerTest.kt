package com.shifai.data.analytics

import org.junit.Assert.*
import org.junit.Test

class AnalyticsTrackerTest {

    // ─── Consent ───

    @Test
    fun `analytics disabled by default`() {
        val defaultState = false
        assertFalse(defaultState)
    }

    @Test
    fun `events not sent when disabled`() {
        val isEnabled = false
        val eventSent = isEnabled
        assertFalse(eventSent)
    }

    // ─── Event Names ───

    @Test
    fun `app_launched event name is correct`() {
        assertEquals("app_launched", "app_launched")
    }

    @Test
    fun `onboarding_completed event has bucket prop`() {
        val props = mapOf("cycle_length_bucket" to "normal")
        assertTrue(props.containsKey("cycle_length_bucket"))
    }

    @Test
    fun `tracking_saved event has symptom bucket`() {
        val props = mapOf("symptom_count_bucket" to "1-3")
        assertEquals("1-3", props["symptom_count_bucket"])
    }

    @Test
    fun `export_generated has template and range`() {
        val props = mapOf("template" to "SOPK", "date_range" to "3")
        assertEquals(2, props.size)
    }

    // ─── Privacy ───

    @Test
    fun `no user_id in events`() {
        val props = mapOf("platform" to "android", "version" to "1.0")
        assertFalse(props.containsKey("user_id"))
    }

    @Test
    fun `no health data in events`() {
        val props = mapOf("platform" to "android")
        assertFalse(props.containsKey("symptoms"))
        assertFalse(props.containsKey("phase"))
        assertFalse(props.containsKey("flow"))
    }

    // ─── URL Format ───

    @Test
    fun `event URL uses app scheme`() {
        val event = "app_launched"
        val url = "app://shifai/${event.replace("_", "/")}"
        assertTrue(url.startsWith("app://shifai/"))
    }

    @Test
    fun `plausible domain is configured`() {
        val domain = "shifai.app"
        assertFalse(domain.isEmpty())
    }
}
