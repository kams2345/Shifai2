package com.shifai.app

import org.junit.Assert.*
import org.junit.Test

class ShifAIErrorTest {

    // ─── Network Errors ───

    @Test
    fun `NetworkUnavailable has correct code`() {
        val err = ShifAIError.NetworkUnavailable()
        assertEquals("NET_UNAVAILABLE", err.code)
        assertTrue(err.message.contains("connexion"))
    }

    @Test
    fun `ServerError includes status code`() {
        val err = ShifAIError.ServerError(502)
        assertTrue(err.message.contains("502"))
    }

    @Test
    fun `Unauthorized message mentions session`() {
        val err = ShifAIError.Unauthorized()
        assertTrue(err.message.contains("Session"))
    }

    @Test
    fun `Timeout has recovery suggestion`() {
        val err = ShifAIError.Timeout()
        assertTrue(err.recoverySuggestion.contains("Réessaie"))
    }

    // ─── Database Errors ───

    @Test
    fun `DatabaseCorrupted suggests support`() {
        val err = ShifAIError.DatabaseCorrupted()
        assertTrue(err.recoverySuggestion.contains("support"))
    }

    @Test
    fun `MigrationFailed includes version`() {
        val err = ShifAIError.MigrationFailed(3)
        assertTrue(err.message.contains("v3"))
    }

    @Test
    fun `RecordNotFound includes table and id`() {
        val err = ShifAIError.RecordNotFound("cycle_entries", "abc-123")
        assertTrue(err.message.contains("cycle_entries"))
        assertTrue(err.message.contains("abc-123"))
    }

    // ─── Domain Errors ───

    @Test
    fun `InsufficientData shows counts`() {
        val err = ShifAIError.InsufficientData(required = 3, actual = 1)
        assertTrue(err.message.contains("1/3"))
    }

    @Test
    fun `InvalidInput shows field and reason`() {
        val err = ShifAIError.InvalidInput("flow", "doit être entre 0 et 4")
        assertTrue(err.message.contains("flow"))
    }

    @Test
    fun `MLModelUnavailable falls back gracefully`() {
        val err = ShifAIError.MLModelUnavailable()
        assertTrue(err.recoverySuggestion.contains("règles"))
    }

    // ─── Sync Errors ───

    @Test
    fun `SyncConflict has correct code`() {
        val err = ShifAIError.SyncConflict()
        assertEquals("SYNC_CONFLICT", err.code)
    }

    // ─── Export Errors ───

    @Test
    fun `ExportTooLarge includes sizes`() {
        val err = ShifAIError.ExportTooLarge(15, 10)
        assertTrue(err.message.contains("15MB"))
        assertTrue(err.message.contains("10MB"))
    }

    // ─── Auth Errors ───

    @Test
    fun `BiometricNotAvailable suggests settings`() {
        val err = ShifAIError.BiometricNotAvailable()
        assertTrue(err.recoverySuggestion.contains("réglages"))
    }

    @Test
    fun `SessionExpired suggests reconnect`() {
        val err = ShifAIError.SessionExpired()
        assertTrue(err.recoverySuggestion.contains("Reconnecte"))
    }

    // ─── All errors are ShifAIError ───

    @Test
    fun `all errors are ShifAIError subtypes`() {
        val errors: List<ShifAIError> = listOf(
            ShifAIError.NetworkUnavailable(),
            ShifAIError.ServerError(500),
            ShifAIError.Unauthorized(),
            ShifAIError.Timeout(),
            ShifAIError.DatabaseCorrupted(),
            ShifAIError.MigrationFailed(1),
            ShifAIError.RecordNotFound("t", "i"),
            ShifAIError.InsufficientData(3, 1),
            ShifAIError.InvalidInput("f", "r"),
            ShifAIError.MLModelUnavailable(),
            ShifAIError.EncryptionFailed(),
            ShifAIError.SyncConflict(),
            ShifAIError.SyncTimeout(),
            ShifAIError.ExportTooLarge(5, 10),
            ShifAIError.PDFGenerationFailed(),
            ShifAIError.BiometricNotAvailable(),
            ShifAIError.BiometricFailed(),
            ShifAIError.SessionExpired()
        )
        assertEquals(18, errors.size)
        errors.forEach { assertTrue(it is Exception) }
    }
}
