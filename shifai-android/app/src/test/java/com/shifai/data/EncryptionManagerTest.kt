package com.shifai.data

import com.shifai.data.encryption.EncryptionManager
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * Encryption Manager Tests — Spike S0-1
 * Validates the full encryption round-trip on Android
 */
class EncryptionManagerTest {

    private lateinit var sut: EncryptionManager

    @Before
    fun setUp() {
        sut = EncryptionManager()
    }

    // ─── Salt Generation ───

    @Test
    fun `generateSalt returns 32 bytes`() {
        val salt = sut.generateSalt()
        assertEquals(32, salt.size)
    }

    @Test
    fun `generateSalt returns unique values`() {
        val salt1 = sut.generateSalt()
        val salt2 = sut.generateSalt()
        assertFalse(salt1.contentEquals(salt2))
    }

    // ─── PBKDF2 Key Derivation ───

    @Test
    fun `deriveMasterKey returns 32 bytes`() {
        val password = "test-pin-1234".toCharArray()
        val salt = sut.generateSalt()
        val key = sut.deriveMasterKey(password, salt)
        assertEquals(32, key.size)
    }

    @Test
    fun `deriveMasterKey same input produces same key`() {
        val salt = sut.generateSalt()
        val key1 = sut.deriveMasterKey("pin".toCharArray(), salt)
        val key2 = sut.deriveMasterKey("pin".toCharArray(), salt)
        assertTrue(key1.contentEquals(key2))
    }

    @Test
    fun `deriveMasterKey different salt produces different key`() {
        val key1 = sut.deriveMasterKey("pin".toCharArray(), sut.generateSalt())
        val key2 = sut.deriveMasterKey("pin".toCharArray(), sut.generateSalt())
        assertFalse(key1.contentEquals(key2))
    }

    @Test
    fun `deriveMasterKey different password produces different key`() {
        val salt = sut.generateSalt()
        val key1 = sut.deriveMasterKey("pin1".toCharArray(), salt)
        val key2 = sut.deriveMasterKey("pin2".toCharArray(), salt)
        assertFalse(key1.contentEquals(key2))
    }

    // ─── AES-256-GCM Round-Trip ───

    @Test
    fun `encrypt decrypt round trip small data`() {
        val key = sut.generateRandomKey()
        val plaintext = "Hello ShifAI 🌙".toByteArray()

        val encrypted = sut.encrypt(plaintext, key)
        val decrypted = sut.decrypt(encrypted, key)

        assertTrue(plaintext.contentEquals(decrypted))
    }

    @Test
    fun `encrypt decrypt round trip large data`() {
        val key = sut.generateRandomKey()
        val largePayload = ByteArray(5 * 1024 * 1024) { 0xAB.toByte() }

        val encrypted = sut.encrypt(largePayload, key)
        val decrypted = sut.decrypt(encrypted, key)

        assertTrue(largePayload.contentEquals(decrypted))
    }

    @Test
    fun `encrypt decrypt round trip JSON payload`() {
        val key = sut.generateRandomKey()
        val json = """{"date":"2026-02-10","symptoms":[{"type":"pain","value":7}]}"""
        val plaintext = json.toByteArray()

        val encrypted = sut.encrypt(plaintext, key)
        val decrypted = sut.decrypt(encrypted, key)

        assertEquals(json, String(decrypted))
    }

    @Test
    fun `encrypt produces different ciphertext each time`() {
        val key = sut.generateRandomKey()
        val plaintext = "same text".toByteArray()

        val enc1 = sut.encrypt(plaintext, key)
        val enc2 = sut.encrypt(plaintext, key)

        assertFalse(enc1.contentEquals(enc2))
    }

    @Test
    fun `encrypt output size is correct`() {
        val key = sut.generateRandomKey()
        val plaintext = "Test".toByteArray()

        val encrypted = sut.encrypt(plaintext, key)
        // nonce (12) + ciphertext (4) + tag (16) = 32
        assertEquals(12 + plaintext.size + 16, encrypted.size)
    }

    @Test(expected = EncryptionManager.EncryptionError.DecryptionFailed::class)
    fun `decrypt fails with wrong key`() {
        val key1 = sut.generateRandomKey()
        val key2 = sut.generateRandomKey()
        val encrypted = sut.encrypt("secret".toByteArray(), key1)
        sut.decrypt(encrypted, key2)
    }

    @Test(expected = EncryptionManager.EncryptionError.DecryptionFailed::class)
    fun `decrypt fails with tampered data`() {
        val key = sut.generateRandomKey()
        val encrypted = sut.encrypt("data".toByteArray(), key)
        encrypted[encrypted.size - 1] = (encrypted.last().toInt() xor 0xFF).toByte()
        sut.decrypt(encrypted, key)
    }

    @Test(expected = EncryptionManager.EncryptionError.InvalidKeyLength::class)
    fun `encrypt fails with short key`() {
        val shortKey = ByteArray(16) // 128 bits
        sut.encrypt("test".toByteArray(), shortKey)
    }

    // ─── SHA-256 ───

    @Test
    fun `sha256 produces consistent hash`() {
        val data = "test data".toByteArray()
        val hash1 = sut.sha256Hex(data)
        val hash2 = sut.sha256Hex(data)
        assertEquals(hash1, hash2)
        assertEquals(64, hash1.length) // SHA-256 hex = 64 chars
    }

    // ─── Sync Blob ───

    @Test
    fun `sync blob round trip`() {
        val syncKey = sut.generateRandomKey()
        val dataset = """{"cycles":[{"date":"2026-01-15","flow":3}]}""".toByteArray()

        val (blob, checksum) = sut.encryptForSync(dataset, syncKey)
        assertFalse(blob.contentEquals(dataset))

        val decrypted = sut.decryptFromSync(blob, syncKey, checksum)
        assertTrue(dataset.contentEquals(decrypted))
    }

    @Test(expected = EncryptionManager.EncryptionError.InvalidData::class)
    fun `sync decrypt fails with wrong checksum`() {
        val syncKey = sut.generateRandomKey()
        val (blob, _) = sut.encryptForSync("test".toByteArray(), syncKey)
        sut.decryptFromSync(blob, syncKey, "wrong-checksum")
    }

    // ─── Full Pipeline ───

    @Test
    fun `full pipeline PIN to encrypt decrypt`() {
        val pin = "1234".toCharArray()
        val salt = sut.generateSalt()

        val masterKey = sut.deriveMasterKey(pin, salt)
        assertEquals(32, masterKey.size)

        val healthData = """{"symptoms":[{"type":"pain","value":7}]}""".toByteArray()
        val encrypted = sut.encrypt(healthData, masterKey)

        val sameKey = sut.deriveMasterKey("1234".toCharArray(), salt)
        val decrypted = sut.decrypt(encrypted, sameKey)

        assertTrue(healthData.contentEquals(decrypted))
    }
}
