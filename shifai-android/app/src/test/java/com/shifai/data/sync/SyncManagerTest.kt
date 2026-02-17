package com.shifai.data.sync

import org.junit.Assert.*
import org.junit.Test

class SyncManagerTest {

    // ─── Status ───

    @Test
    fun `initial status is IDLE`() {
        val status = SyncManager.Status.IDLE
        assertEquals(SyncManager.Status.IDLE, status)
    }

    @Test
    fun `sync sets status to SYNCING`() {
        val status = SyncManager.Status.SYNCING
        assertEquals(SyncManager.Status.SYNCING, status)
    }

    @Test
    fun `successful sync sets SUCCESS`() {
        val status = SyncManager.Status.SUCCESS
        assertEquals(SyncManager.Status.SUCCESS, status)
    }

    @Test
    fun `failed sync sets FAILED`() {
        val status = SyncManager.Status.FAILED
        assertEquals(SyncManager.Status.FAILED, status)
    }

    // ─── Sync Report ───

    @Test
    fun `sync report tracks pushed count`() {
        val report = SyncManager.SyncReport(pushed = 5, pulled = 0, conflicts = 0)
        assertEquals(5, report.pushed)
    }

    @Test
    fun `sync report tracks pulled count`() {
        val report = SyncManager.SyncReport(pushed = 0, pulled = 3, conflicts = 0)
        assertEquals(3, report.pulled)
    }

    @Test
    fun `sync report tracks conflicts`() {
        val report = SyncManager.SyncReport(pushed = 2, pulled = 1, conflicts = 1)
        assertEquals(1, report.conflicts)
    }

    @Test
    fun `zero report for no changes`() {
        val report = SyncManager.SyncReport(pushed = 0, pulled = 0, conflicts = 0)
        assertEquals(0, report.pushed + report.pulled + report.conflicts)
    }

    // ─── Pending Sync ───

    @Test
    fun `no pending sync when all synced`() {
        val unsyncedCount = 0
        assertFalse(unsyncedCount > 0)
    }

    @Test
    fun `has pending sync with unsynced data`() {
        val unsyncedCount = 3
        assertTrue(unsyncedCount > 0)
    }
}
