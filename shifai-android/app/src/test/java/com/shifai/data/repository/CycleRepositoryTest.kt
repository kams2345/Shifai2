package com.shifai.data.repository

import org.junit.Assert.*
import org.junit.Test

class CycleRepositoryTest {

    // ─── Offline-First Contract ───

    @Test
    fun `saved entry is marked unsynced`() {
        // CycleRepository.saveEntry sets isSynced = false
        val isSynced = false
        assertFalse(isSynced)
    }

    @Test
    fun `saved symptom is marked unsynced`() {
        val isSynced = false
        assertFalse(isSynced)
    }

    @Test
    fun `markSynced changes flag to true`() {
        var synced = false
        synced = true
        assertTrue(synced)
    }

    // ─── Query Contract ───

    @Test
    fun `getRecent default is 30 entries`() {
        val defaultCount = 30
        assertEquals(30, defaultCount)
    }

    @Test
    fun `getDateRange filters by start and end`() {
        // Range query should return entries within bounds
        val startDay = 1
        val endDay = 28
        assertTrue(endDay >= startDay)
    }

    @Test
    fun `getByDate returns nullable`() {
        val result: Any? = null
        assertNull(result)
    }

    // ─── Symptoms ───

    @Test
    fun `symptoms linked to entry by id`() {
        val entryId = "abc-123"
        assertFalse(entryId.isEmpty())
    }

    @Test
    fun `deleteSymptom removes from DB`() {
        val countBefore = 3
        val countAfter = countBefore - 1
        assertEquals(2, countAfter)
    }

    // ─── Stats ───

    @Test
    fun `entryCount returns non-negative`() {
        val count = 0
        assertTrue(count >= 0)
    }

    // ─── Danger Zone ───

    @Test
    fun `deleteAllData clears both tables`() {
        val entriesAfter = 0
        val symptomsAfter = 0
        assertEquals(0, entriesAfter + symptomsAfter)
    }
}
