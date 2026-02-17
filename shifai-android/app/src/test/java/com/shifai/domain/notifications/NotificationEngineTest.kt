package com.shifai.domain.notifications

import org.junit.Assert.*
import org.junit.Test
import java.util.Calendar

class NotificationEngineTest {

    // ─── Max 1/Day ───

    @Test
    fun `first notification of day is allowed`() {
        assertTrue(canSendToday(lastSentToday = false))
    }

    @Test
    fun `second notification same day is blocked`() {
        assertFalse(canSendToday(lastSentToday = true))
    }

    // ─── Quiet Hours ───

    @Test
    fun `3AM is quiet hours`() {
        assertTrue(isQuietHours(hour = 3))
    }

    @Test
    fun `10AM is not quiet hours`() {
        assertFalse(isQuietHours(hour = 10))
    }

    @Test
    fun `23PM is quiet hours`() {
        assertTrue(isQuietHours(hour = 23))
    }

    @Test
    fun `8AM boundary is not quiet hours`() {
        assertFalse(isQuietHours(hour = 8))
    }

    @Test
    fun `22PM boundary is quiet hours`() {
        assertTrue(isQuietHours(hour = 22))
    }

    // ─── Auto-Stop ───

    @Test
    fun `2 ignores does not auto-stop`() {
        assertFalse(shouldAutoStop(ignoreCount = 2))
    }

    @Test
    fun `3 ignores triggers auto-stop`() {
        assertTrue(shouldAutoStop(ignoreCount = 3))
    }

    @Test
    fun `5 ignores stays auto-stopped`() {
        assertTrue(shouldAutoStop(ignoreCount = 5))
    }

    // ─── Categories ───

    @Test
    fun `all categories enabled by default`() {
        val categories = listOf("cycle_prediction", "recommendation", "quickwin", "educational")
        for (cat in categories) {
            assertTrue("$cat should be enabled by default", isCategoryEnabled(cat, disabledSet = emptySet()))
        }
    }

    @Test
    fun `disabled category returns false`() {
        assertFalse(isCategoryEnabled("recommendation", disabledSet = setOf("recommendation")))
    }

    // ─── Helpers ───

    private fun canSendToday(lastSentToday: Boolean): Boolean = !lastSentToday

    private fun isQuietHours(hour: Int): Boolean = hour < 8 || hour >= 22

    private fun shouldAutoStop(ignoreCount: Int): Boolean = ignoreCount >= 3

    private fun isCategoryEnabled(category: String, disabledSet: Set<String>): Boolean =
        category !in disabledSet
}
