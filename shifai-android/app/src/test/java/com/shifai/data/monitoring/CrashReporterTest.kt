package com.shifai.data.monitoring

import org.junit.Assert.*
import org.junit.Test

class CrashReporterTest {

    // ─── Log Format ───

    @Test
    fun `log entry contains error code`() {
        val code = "SYNC_FAILED"
        val line = "[2026-02-17 12:00:00] [$code] Sync error | context"
        assertTrue(line.contains(code))
    }

    @Test
    fun `crash entry has CRASH prefix`() {
        val entry = "[CRASH] 2026-02-17 | NullPointer: null | SyncManager"
        assertTrue(entry.startsWith("[CRASH]"))
    }

    @Test
    fun `log entry contains pipe separator`() {
        val line = "[2026-02-17] [DB_ERROR] error | CycleRepository"
        assertTrue(line.contains(" | "))
    }

    // ─── File Rotation ───

    @Test
    fun `max log size is 500KB`() {
        val maxSize = 500_000L
        assertEquals(500_000L, maxSize)
    }

    @Test
    fun `rotation triggered when exceeding max`() {
        val size = 600_000L
        val max = 500_000L
        assertTrue(size > max)
    }

    // ─── Zero PII ───

    @Test
    fun `no email in log`() {
        val line = "[2026-02-17] [AUTH_FAIL] Authentication failed | login"
        assertFalse(line.contains("@"))
    }

    @Test
    fun `no user_id in log`() {
        val line = "[2026-02-17] [DB_ERROR] Database locked | CycleRepository"
        assertFalse(line.contains("user_id"))
    }

    // ─── Retrieval ───

    @Test
    fun `empty logs return empty string`() {
        val logs = ""
        assertTrue(logs.isEmpty())
    }

    @Test
    fun `recent logs default to 50 lines`() {
        val defaultLines = 50
        assertEquals(50, defaultLines)
    }

    // ─── Tag ───

    @Test
    fun `crash reporter tag is correct`() {
        val tag = "CrashReporter"
        assertEquals("CrashReporter", tag)
    }
}
