package com.shifai.data.sync

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.security.KeyStore
import java.security.MessageDigest
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Sync Engine — Android (S7-2)
 * Zero-knowledge, offline-first cloud sync
 * Flow: local DB → JSON → AES-256-GCM encrypt → blob → Supabase
 */
class SyncEngine private constructor(private val context: Context) {

    companion object {
        @Volatile
        private var instance: SyncEngine? = null

        fun getInstance(context: Context): SyncEngine {
            return instance ?: synchronized(this) {
                instance ?: SyncEngine(context.applicationContext).also { instance = it }
            }
        }

        private const val KEY_ALIAS = "shifai_sync_key"
        private const val KEYSTORE = "AndroidKeyStore"
        private const val MAX_BLOB_SIZE = 10 * 1024 * 1024 // 10MB
        private const val GCM_TAG_LENGTH = 128
        private const val GCM_IV_LENGTH = 12
    }

    sealed class SyncState {
        object Idle : SyncState()
        object Syncing : SyncState()
        data class Success(val lastSync: Date) : SyncState()
        data class Error(val message: String) : SyncState()
    }

    private val _state = MutableStateFlow<SyncState>(SyncState.Idle)
    val state: StateFlow<SyncState> = _state

    private val prefs = context.getSharedPreferences("shifai_sync", Context.MODE_PRIVATE)

    var isEnabled: Boolean
        get() = prefs.getBoolean("sync_enabled", false)
        set(value) { prefs.edit().putBoolean("sync_enabled", value).apply() }

    val lastSyncDate: Date?
        get() = prefs.getLong("last_sync_time", -1L).let {
            if (it > 0) Date(it) else null
        }

    private val syncEndpoint: String
        get() {
            val url = context.packageManager
                .getApplicationInfo(context.packageName, android.content.pm.PackageManager.GET_META_DATA)
                .metaData?.getString("SUPABASE_URL") ?: "https://your-project.supabase.co"
            return "$url/functions/v1/sync-data"
        }

    private var isSyncing = false

    // MARK: - Push

    suspend fun push() = withContext(Dispatchers.IO) {
        if (!isEnabled || isSyncing) return@withContext
        isSyncing = true
        _state.value = SyncState.Syncing

        try {
            // 1. Serialize
            val payload = serializeLocalData()

            // 2. Encrypt
            val encrypted = encrypt(payload)

            // 3. Checksum
            val checksum = sha256(encrypted)

            if (encrypted.size > MAX_BLOB_SIZE) {
                _state.value = SyncState.Error("Données trop volumineuses")
                return@withContext
            }

            // 4. Push
            val currentVersion = prefs.getInt("blob_version", 0)
            val conn = URL(syncEndpoint).openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/octet-stream")
            conn.setRequestProperty("Authorization", "Bearer ${getAuthToken()}")
            conn.setRequestProperty("X-Checksum-SHA256", checksum)
            conn.setRequestProperty("X-Blob-Version", "${currentVersion + 1}")
            conn.doOutput = true
            conn.outputStream.use { it.write(encrypted) }

            if (conn.responseCode == 200) {
                prefs.edit()
                    .putInt("blob_version", currentVersion + 1)
                    .putLong("last_sync_time", System.currentTimeMillis())
                    .apply()
                _state.value = SyncState.Success(Date())
            } else {
                _state.value = SyncState.Error("Push failed: ${conn.responseCode}")
            }
        } catch (e: Exception) {
            _state.value = SyncState.Error(e.message ?: "Unknown error")
        } finally {
            isSyncing = false
        }
    }

    // MARK: - Pull

    suspend fun pull() = withContext(Dispatchers.IO) {
        if (!isEnabled || isSyncing) return@withContext
        isSyncing = true
        _state.value = SyncState.Syncing

        try {
            // 1. Check metadata
            val metaConn = URL("$syncEndpoint?action=metadata").openConnection() as HttpURLConnection
            metaConn.setRequestProperty("Authorization", "Bearer ${getAuthToken()}")
            if (metaConn.responseCode != 200) {
                _state.value = SyncState.Error("Metadata check failed")
                return@withContext
            }

            val metaJson = metaConn.inputStream.bufferedReader().readText()
            // Parse version from JSON (simplified)
            val serverVersion = Regex("\"blob_version\":(\\d+)").find(metaJson)?.groupValues?.get(1)?.toIntOrNull() ?: 0
            val localVersion = prefs.getInt("blob_version", 0)

            if (serverVersion <= localVersion) {
                _state.value = SyncState.Success(lastSyncDate ?: Date())
                return@withContext
            }

            // 2. Pull blob
            val blobConn = URL("$syncEndpoint?action=pull").openConnection() as HttpURLConnection
            blobConn.setRequestProperty("Authorization", "Bearer ${getAuthToken()}")
            val blobData = blobConn.inputStream.use { input ->
                ByteArrayOutputStream().use { output ->
                    input.copyTo(output)
                    output.toByteArray()
                }
            }

            // 3. Verify checksum
            val serverChecksum = blobConn.getHeaderField("X-Checksum-SHA256") ?: ""
            val localChecksum = sha256(blobData)
            if (serverChecksum.isNotEmpty() && serverChecksum != localChecksum) {
                _state.value = SyncState.Error("Integrity check failed")
                return@withContext
            }

            // 4. Decrypt
            val decrypted = decrypt(blobData)

            // 5. Merge
            mergeWithLocal(decrypted)

            prefs.edit()
                .putInt("blob_version", serverVersion)
                .putLong("last_sync_time", System.currentTimeMillis())
                .apply()
            _state.value = SyncState.Success(Date())

        } catch (e: Exception) {
            _state.value = SyncState.Error(e.message ?: "Unknown error")
        } finally {
            isSyncing = false
        }
    }

    suspend fun sync() {
        push()
        pull()
    }

    // MARK: - Serialization

    private fun serializeLocalData(): ByteArray {
        // Serialize from Room DB to JSON
        // TODO: Wire to actual Room repositories
        val json = """{"cycles":[],"symptoms":[],"insights":[],"predictions":[],"timestamp":"${Date()}"}"""
        return json.toByteArray(Charsets.UTF_8)
    }

    private fun mergeWithLocal(data: ByteArray) {
        // Last-write-wins merge
        // TODO: Implement full merge with conflict detection
    }

    // MARK: - Encryption (AES-256-GCM via Android Keystore)

    private fun encrypt(data: ByteArray): ByteArray {
        val key = getOrCreateKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val iv = cipher.iv
        val encrypted = cipher.doFinal(data)
        // Prepend IV to ciphertext
        return iv + encrypted
    }

    private fun decrypt(data: ByteArray): ByteArray {
        val key = getOrCreateKey()
        val iv = data.sliceArray(0 until GCM_IV_LENGTH)
        val ciphertext = data.sliceArray(GCM_IV_LENGTH until data.size)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(GCM_TAG_LENGTH, iv))
        return cipher.doFinal(ciphertext)
    }

    private fun getOrCreateKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE).apply { load(null) }
        if (keyStore.containsAlias(KEY_ALIAS)) {
            return (keyStore.getEntry(KEY_ALIAS, null) as KeyStore.SecretKeyEntry).secretKey
        }

        val keyGen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        keyGen.init(
            KeyGenParameterSpec.Builder(KEY_ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .build()
        )
        return keyGen.generateKey()
    }

    // MARK: - Helpers

    private fun sha256(data: ByteArray): String {
        return MessageDigest.getInstance("SHA-256")
            .digest(data)
            .joinToString("") { "%02x".format(it) }
    }

    private fun getAuthToken(): String {
        return prefs.getString("supabase_access_token", "") ?: ""
    }
}
