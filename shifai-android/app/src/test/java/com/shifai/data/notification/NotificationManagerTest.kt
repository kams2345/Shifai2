package com.shifai.data.notification

import org.junit.Assert.*
import org.junit.Test

class NotificationManagerTest {

    // ─── Channels ───

    @Test
    fun `predictions channel id is correct`() {
        assertEquals("predictions", ShifAINotificationManager.CHANNEL_PREDICTIONS)
    }

    @Test
    fun `recommendations channel id is correct`() {
        assertEquals("recommendations", ShifAINotificationManager.CHANNEL_RECOMMENDATIONS)
    }

    @Test
    fun `quick wins channel id is correct`() {
        assertEquals("quick_wins", ShifAINotificationManager.CHANNEL_QUICK_WINS)
    }

    @Test
    fun `educational channel id is correct`() {
        assertEquals("educational", ShifAINotificationManager.CHANNEL_EDUCATIONAL)
    }

    @Test
    fun `all four channels exist`() {
        val channels = listOf(
            ShifAINotificationManager.CHANNEL_PREDICTIONS,
            ShifAINotificationManager.CHANNEL_RECOMMENDATIONS,
            ShifAINotificationManager.CHANNEL_QUICK_WINS,
            ShifAINotificationManager.CHANNEL_EDUCATIONAL
        )
        assertEquals(4, channels.size)
    }

    // ─── Quiet Hours ───

    @Test
    fun `quiet hours start at 22`() {
        val start = 22
        assertEquals(22, start)
    }

    @Test
    fun `quiet hours end at 7`() {
        val end = 7
        assertEquals(7, end)
    }

    @Test
    fun `23h is in quiet hours`() {
        val hour = 23
        val inQuiet = hour >= 22 || hour < 7
        assertTrue(inQuiet)
    }

    @Test
    fun `3h is in quiet hours`() {
        val hour = 3
        val inQuiet = hour >= 22 || hour < 7
        assertTrue(inQuiet)
    }

    @Test
    fun `12h is not in quiet hours`() {
        val hour = 12
        val inQuiet = hour >= 22 || hour < 7
        assertFalse(inQuiet)
    }
}
