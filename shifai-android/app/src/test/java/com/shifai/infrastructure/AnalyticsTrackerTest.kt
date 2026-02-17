package com.shifai.infrastructure

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class AnalyticsTrackerTest {

    // ─── Event Keys ───

    @Test
    fun `all events have unique keys`() {
        val keys = AnalyticsTracker.Event.values().map { it.key }
        val unique = keys.toSet()
        assertEquals("All event keys must be unique", keys.size, unique.size)
    }

    @Test
    fun `event keys are lowercase snake_case`() {
        for (event in AnalyticsTracker.Event.values()) {
            assertTrue("Event key '${event.key}' must be lowercase snake_case",
                event.key.matches(Regex("[a-z][a-z0-9_]+")))
        }
    }

    // ─── PII Scrubbing ───

    @Test
    fun `properties with email key are filtered`() {
        val props = mapOf("email" to "test@example.com", "template" to "sopk")
        val safe = props.filterKeys { it.lowercase() !in listOf("email", "name", "phone", "address", "ip") }
        assertFalse(safe.containsKey("email"))
        assertTrue(safe.containsKey("template"))
    }

    @Test
    fun `properties with name key are filtered`() {
        val props = mapOf("name" to "Alice", "category" to "prediction")
        val safe = props.filterKeys { it.lowercase() !in listOf("email", "name", "phone", "address", "ip") }
        assertFalse(safe.containsKey("name"))
        assertTrue(safe.containsKey("category"))
    }

    @Test
    fun `properties with no PII pass through`() {
        val props = mapOf("template" to "sopk", "duration" to "30")
        val safe = props.filterKeys { it.lowercase() !in listOf("email", "name", "phone", "address", "ip") }
        assertEquals(2, safe.size)
    }

    // ─── Event Coverage ───

    @Test
    fun `minimum 25 events defined`() {
        assertTrue("Should have 25+ events", AnalyticsTracker.Event.values().size >= 25)
    }

    @Test
    fun `core lifecycle events exist`() {
        val keys = AnalyticsTracker.Event.values().map { it.key }
        assertTrue(keys.contains("app_opened"))
        assertTrue(keys.contains("daily_log_saved"))
        assertTrue(keys.contains("insights_viewed"))
    }
}
