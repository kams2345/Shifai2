package com.shifai.data.auth

import android.content.Context
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.Timer
import kotlin.concurrent.schedule

/**
 * Biometric Authentication Manager — Android
 * S1-9: BiometricPrompt + PIN fallback + auto-lock + rate limiting
 *
 * Mirrors iOS BiometricAuthManager.swift
 */
class BiometricAuthManager(private val context: Context) {

    // ─── Configuration ───
    companion object {
        const val MAX_FAILED_ATTEMPTS = 5
        const val LOCKOUT_DURATION_MS = 15 * 60 * 1000L // 15 min
        const val DEFAULT_AUTO_LOCK_TIMEOUT_MS = 5 * 60 * 1000L // 5 min
        val PIN_LENGTH_RANGE = 4..6
    }

    // ─── State ───
    private val _isLocked = MutableStateFlow(true)
    val isLocked: StateFlow<Boolean> = _isLocked.asStateFlow()

    private val _failedAttempts = MutableStateFlow(0)
    val failedAttempts: StateFlow<Int> = _failedAttempts.asStateFlow()

    private val _isLockedOut = MutableStateFlow(false)
    val isLockedOut: StateFlow<Boolean> = _isLockedOut.asStateFlow()

    private val _authError = MutableStateFlow<String?>(null)
    val authError: StateFlow<String?> = _authError.asStateFlow()

    private var autoLockTimer: Timer? = null
    private var lockoutTimer: Timer? = null

    // ─── Biometric Capability ───

    enum class BiometricType { FINGERPRINT, FACE, NONE }

    val biometricType: BiometricType
        get() {
            val biometricManager = BiometricManager.from(context)
            return when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
                BiometricManager.BIOMETRIC_SUCCESS -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) BiometricType.FACE
                    else BiometricType.FINGERPRINT
                }
                else -> BiometricType.NONE
            }
        }

    val isBiometricAvailable: Boolean
        get() = biometricType != BiometricType.NONE

    // ─── Biometric Authentication ───

    fun authenticateWithBiometrics(activity: FragmentActivity) {
        if (_isLockedOut.value) {
            _authError.value = "Trop de tentatives. Réessaie dans 15 min."
            return
        }

        val executor = ContextCompat.getMainExecutor(context)

        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                onAuthSuccess()
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                when (errorCode) {
                    BiometricPrompt.ERROR_USER_CANCELED,
                    BiometricPrompt.ERROR_NEGATIVE_BUTTON -> {
                        _authError.value = null // User chose PIN fallback
                    }
                    BiometricPrompt.ERROR_LOCKOUT,
                    BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                        _authError.value = "Biométrie verrouillée. Utilise le code PIN."
                    }
                    else -> onAuthFailure()
                }
            }

            override fun onAuthenticationFailed() {
                onAuthFailure()
            }
        }

        val prompt = BiometricPrompt(activity, executor, callback)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Déverrouiller ShifAI")
            .setSubtitle("Utilise la biométrie pour accéder à tes données")
            .setNegativeButtonText("Utiliser le code PIN")
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            .build()

        prompt.authenticate(promptInfo)
    }

    // ─── PIN Authentication ───

    fun authenticateWithPIN(pin: String): Boolean {
        if (_isLockedOut.value) {
            _authError.value = "Trop de tentatives. Réessaie dans 15 min."
            return false
        }

        // TODO: Retrieve stored PIN hash from Android KeyStore
        // For now, compare using PBKDF2 hash
        val encryptionManager = com.shifai.data.encryption.EncryptionManager()
        val pinBytes = pin.toByteArray()
        val salt = "shifai-pin-salt-v1".toByteArray() // Fixed salt for PIN
        val enteredHash = encryptionManager.deriveMasterKey(pinBytes, salt)

        // TODO: Compare with stored hash from KeyStore
        // val storedHash = keyStoreManager.retrievePINHash()
        // if (enteredHash.contentEquals(storedHash))

        // Placeholder — actual comparison needs KeyStore integration
        onAuthSuccess()
        return true
    }

    // ─── Auto-Lock ───

    fun resetAutoLockTimer() {
        autoLockTimer?.cancel()

        val timeout = DEFAULT_AUTO_LOCK_TIMEOUT_MS // TODO: Read from preferences
        autoLockTimer = Timer().apply {
            schedule(timeout) { lock() }
        }
    }

    fun lock() {
        _isLocked.value = true
        autoLockTimer?.cancel()
    }

    // ─── Private Helpers ───

    private fun onAuthSuccess() {
        _isLocked.value = false
        _failedAttempts.value = 0
        _authError.value = null
        resetAutoLockTimer()
    }

    private fun onAuthFailure() {
        _failedAttempts.value++

        if (_failedAttempts.value >= MAX_FAILED_ATTEMPTS) {
            _isLockedOut.value = true
            _authError.value = "Trop de tentatives. Verrouillé pour 15 min."

            lockoutTimer = Timer().apply {
                schedule(LOCKOUT_DURATION_MS) {
                    _isLockedOut.value = false
                    _failedAttempts.value = 0
                    _authError.value = null
                }
            }
        } else {
            val remaining = MAX_FAILED_ATTEMPTS - _failedAttempts.value
            _authError.value = "Identifiant incorrect. $remaining tentative${if (remaining > 1) "s" else ""} restante${if (remaining > 1) "s" else ""}."
        }
    }
}
