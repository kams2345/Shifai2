package com.shifai.data.sync

import org.junit.Assert.*
import org.junit.Test

class SyncEngineTest {

    // ─── Conflict Detection ───

    @Test
    fun `localAhead is not a conflict`() {
        assertFalse(SyncEngine.isConflict(localVersion = 5, serverVersion = 3,
            localModified = true, serverModified = false))
    }

    @Test
    fun `serverAhead is not a conflict`() {
        assertFalse(SyncEngine.isConflict(localVersion = 3, serverVersion = 5,
            localModified = false, serverModified = true))
    }

    @Test
    fun `sameVersion unmodified is not a conflict`() {
        assertFalse(SyncEngine.isConflict(localVersion = 5, serverVersion = 5,
            localModified = false, serverModified = false))
    }

    @Test
    fun `bothModified at sameVersion is a conflict`() {
        assertTrue(SyncEngine.isConflict(localVersion = 5, serverVersion = 5,
            localModified = true, serverModified = true))
    }

    // ─── Sync Actions ───

    @Test
    fun `action is PUSH when local ahead`() {
        assertEquals("push", SyncEngine.determineSyncAction(
            localVersion = 5, serverVersion = 3,
            localModified = true, serverModified = false))
    }

    @Test
    fun `action is PULL when server ahead`() {
        assertEquals("pull", SyncEngine.determineSyncAction(
            localVersion = 3, serverVersion = 5,
            localModified = false, serverModified = true))
    }

    @Test
    fun `action is IN_SYNC when equal and unmodified`() {
        assertEquals("in_sync", SyncEngine.determineSyncAction(
            localVersion = 5, serverVersion = 5,
            localModified = false, serverModified = false))
    }

    @Test
    fun `action is CONFLICT when both modified`() {
        assertEquals("conflict", SyncEngine.determineSyncAction(
            localVersion = 5, serverVersion = 5,
            localModified = true, serverModified = true))
    }

    // ─── Merge ───

    @Test
    fun `lastWriteWins selects newer timestamp`() {
        val now = System.currentTimeMillis()
        val older = now - 60_000L
        val winner = SyncEngine.lastWriteWins(localTimestamp = older, serverTimestamp = now)
        assertEquals("server", winner)
    }

    @Test
    fun `lastWriteWins selects local when local is newer`() {
        val now = System.currentTimeMillis()
        val older = now - 60_000L
        val winner = SyncEngine.lastWriteWins(localTimestamp = now, serverTimestamp = older)
        assertEquals("local", winner)
    }
}
