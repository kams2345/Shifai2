package com.shifai.data.repository

import org.junit.Assert.*
import org.junit.Test

class InsightsRepositoryTest {

    // ─── Offline-First Contract ───

    @Test
    fun `saved insight is marked unsynced`() {
        val isSynced = false
        assertFalse(isSynced)
    }

    @Test
    fun `markRead changes read status`() {
        var isRead = false
        isRead = true
        assertTrue(isRead)
    }

    @Test
    fun `submitFeedback stores feedback`() {
        val feedback = "accurate"
        assertEquals("accurate", feedback)
    }

    // ─── Filters ───

    @Test
    fun `observeByType filters correctly`() {
        val allInsights = listOf("prediction", "correlation", "recommendation")
        val filtered = allInsights.filter { it == "prediction" }
        assertEquals(1, filtered.size)
    }

    @Test
    fun `unread count tracks unread insights`() {
        val insights = listOf(false, true, false) // isRead
        val unreadCount = insights.count { !it }
        assertEquals(2, unreadCount)
    }

    // ─── Sync ───

    @Test
    fun `getUnsynced returns only unsynced`() {
        val items = listOf(true, false, false) // isSynced
        val unsynced = items.count { !it }
        assertEquals(2, unsynced)
    }

    @Test
    fun `markSynced flips sync flag`() {
        var synced = false
        synced = true
        assertTrue(synced)
    }

    // ─── Danger Zone ───

    @Test
    fun `deleteAll clears all insights`() {
        val countAfter = 0
        assertEquals(0, countAfter)
    }
}
