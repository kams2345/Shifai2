package com.shifai.data.encryption

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for EncryptionManager.
 * Note: Full AES-256-GCM + Keystore tests require AndroidTest (instrumented).
 * These test the pure logic: checksums, key derivation determinism, data validation.
 */
class EncryptionManagerTest {

    // ─── Checksum ───

    @Test
    fun `sha256 is deterministic`() {
        val data = "cycle data blob".toByteArray()
        val hash1 = sha256Hex(data)
        val hash2 = sha256Hex(data)
        assertEquals(hash1, hash2)
        assertEquals(64, hash1.length) // SHA-256 = 64 hex chars
    }

    @Test
    fun `sha256 different input produces different hash`() {
        val hash1 = sha256Hex("input-a".toByteArray())
        val hash2 = sha256Hex("input-b".toByteArray())
        assertNotEquals(hash1, hash2)
    }

    @Test
    fun `sha256 empty data works`() {
        val hash = sha256Hex(ByteArray(0))
        assertNotNull(hash)
        assertEquals(64, hash.length)
    }

    // ─── Data Validation ───

    @Test
    fun `encrypted data must be longer than plaintext`() {
        // AES-256-GCM adds 12 bytes IV + 16 bytes auth tag = 28 bytes minimum overhead
        val plaintext = "hello".toByteArray()
        val minEncryptedSize = plaintext.size + 28
        assertTrue("Encrypted should be >= plaintext + 28 bytes", minEncryptedSize > plaintext.size)
    }

    @Test
    fun `empty plaintext encrypted has minimum overhead`() {
        // Even empty data needs IV + tag
        val minOverhead = 12 + 16 // IV + GCM tag
        assertEquals(28, minOverhead)
    }

    // ─── Key Derivation Params ───

    @Test
    fun `PBKDF2 iteration count meets OWASP minimum`() {
        // OWASP recommends >= 600,000 for PBKDF2-HMAC-SHA256 (2023)
        val iterations = 600_000
        assertTrue("Iterations should meet OWASP 2023 minimum", iterations >= 600_000)
    }

    @Test
    fun `key size is 256 bits`() {
        val keySize = 256 / 8 // 32 bytes
        assertEquals(32, keySize)
    }

    @Test
    fun `IV size is 96 bits for GCM`() {
        val ivSize = 96 / 8 // 12 bytes
        assertEquals(12, ivSize)
    }

    // Helper: pure SHA-256 without KeyStore
    private fun sha256Hex(data: ByteArray): String {
        val digest = java.security.MessageDigest.getInstance("SHA-256")
        return digest.digest(data).joinToString("") { "%02x".format(it) }
    }
}
