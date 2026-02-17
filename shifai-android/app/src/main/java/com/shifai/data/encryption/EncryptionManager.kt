package com.shifai.data.encryption

import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec

/**
 * Encryption Manager — AES-256-GCM + PBKDF2 key derivation
 * Spike S0-1: IMPLEMENTED — zero-knowledge architecture
 *
 * Mirrors iOS EncryptionManager.swift for cross-platform parity
 */
class EncryptionManager {

    companion object {
        private const val PBKDF2_ITERATIONS = 100_000
        private const val KEY_LENGTH = 256 // bits
        private const val SALT_LENGTH = 32 // bytes
        private const val GCM_NONCE_LENGTH = 12 // bytes
        private const val GCM_TAG_LENGTH = 128 // bits
        private const val AES_GCM_CIPHER = "AES/GCM/NoPadding"
        private const val PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA256"
    }

    sealed class EncryptionError(message: String) : Exception(message) {
        data object KeyDerivationFailed : EncryptionError("Échec de la dérivation de clé")
        data object EncryptionFailed : EncryptionError("Échec du chiffrement")
        data object DecryptionFailed : EncryptionError("Échec du déchiffrement")
        data object InvalidData : EncryptionError("Données invalides")
        data object InvalidKeyLength : EncryptionError("Longueur de clé invalide")
    }

    private val secureRandom = SecureRandom()

    // ─── Key Derivation (PBKDF2) ───

    /**
     * Derive master key from PIN using PBKDF2-SHA256
     * @param password User's PIN as char array (cleared after use)
     * @param salt Random 32-byte salt
     * @return 256-bit derived key
     */
    fun deriveMasterKey(password: CharArray, salt: ByteArray): ByteArray {
        return try {
            val spec = PBEKeySpec(password, salt, PBKDF2_ITERATIONS, KEY_LENGTH)
            val factory = SecretKeyFactory.getInstance(PBKDF2_ALGORITHM)
            factory.generateSecret(spec).encoded.also {
                spec.clearPassword()
            }
        } catch (e: Exception) {
            throw EncryptionError.KeyDerivationFailed
        }
    }

    /**
     * Derive master key from Data (for API parity with iOS)
     */
    fun deriveMasterKey(password: ByteArray, salt: ByteArray): ByteArray {
        val chars = CharArray(password.size) { password[it].toInt().toChar() }
        return deriveMasterKey(chars, salt)
    }

    // ─── Salt / Key Generation ───

    fun generateSalt(): ByteArray {
        val salt = ByteArray(SALT_LENGTH)
        secureRandom.nextBytes(salt)
        return salt
    }

    fun generateRandomKey(): ByteArray {
        val key = ByteArray(32) // 256 bits
        secureRandom.nextBytes(key)
        return key
    }

    // ─── AES-256-GCM Encrypt ───

    /**
     * Encrypt using AES-256-GCM
     * Output format: nonce (12 bytes) + ciphertext + GCM tag (16 bytes)
     * Compatible with iOS CryptoKit AES.GCM combined format
     */
    fun encrypt(plaintext: ByteArray, key: ByteArray): ByteArray {
        if (key.size != 32) throw EncryptionError.InvalidKeyLength

        return try {
            // Generate random 12-byte nonce
            val nonce = ByteArray(GCM_NONCE_LENGTH)
            secureRandom.nextBytes(nonce)

            val cipher = Cipher.getInstance(AES_GCM_CIPHER)
            val keySpec = SecretKeySpec(key, "AES")
            val gcmSpec = GCMParameterSpec(GCM_TAG_LENGTH, nonce)
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec)

            val ciphertextAndTag = cipher.doFinal(plaintext)

            // Combine: nonce + ciphertext + tag (matches iOS format)
            nonce + ciphertextAndTag
        } catch (e: EncryptionError) {
            throw e
        } catch (e: Exception) {
            throw EncryptionError.EncryptionFailed
        }
    }

    // ─── AES-256-GCM Decrypt ───

    /**
     * Decrypt AES-256-GCM data
     * Input format: nonce (12 bytes) + ciphertext + GCM tag (16 bytes)
     */
    fun decrypt(ciphertext: ByteArray, key: ByteArray): ByteArray {
        if (key.size != 32) throw EncryptionError.InvalidKeyLength
        if (ciphertext.size <= GCM_NONCE_LENGTH + GCM_TAG_LENGTH / 8) {
            throw EncryptionError.InvalidData
        }

        return try {
            // Extract nonce (first 12 bytes)
            val nonce = ciphertext.copyOfRange(0, GCM_NONCE_LENGTH)
            val encryptedData = ciphertext.copyOfRange(GCM_NONCE_LENGTH, ciphertext.size)

            val cipher = Cipher.getInstance(AES_GCM_CIPHER)
            val keySpec = SecretKeySpec(key, "AES")
            val gcmSpec = GCMParameterSpec(GCM_TAG_LENGTH, nonce)
            cipher.init(Cipher.DECRYPT_MODE, keySpec, gcmSpec)

            cipher.doFinal(encryptedData)
        } catch (e: EncryptionError) {
            throw e
        } catch (e: Exception) {
            throw EncryptionError.DecryptionFailed
        }
    }

    // ─── Sync Operations ───

    fun encryptForSync(jsonData: ByteArray, syncKey: ByteArray): Pair<ByteArray, String> {
        val encrypted = encrypt(jsonData, syncKey)
        val checksum = sha256Hex(encrypted)
        return Pair(encrypted, checksum)
    }

    fun decryptFromSync(blob: ByteArray, syncKey: ByteArray, expectedChecksum: String): ByteArray {
        val actualChecksum = sha256Hex(blob)
        if (actualChecksum != expectedChecksum) throw EncryptionError.InvalidData
        return decrypt(blob, syncKey)
    }

    // ─── SHA-256 ───

    fun sha256Hex(data: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA-256")
        return digest.digest(data).joinToString("") { "%02x".format(it) }
    }
}
