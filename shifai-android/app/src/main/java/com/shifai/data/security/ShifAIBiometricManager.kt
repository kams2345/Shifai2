package com.shifai.data.security

import android.content.Context
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity

/**
 * Biometric Manager — fingerprint / face gate for app launch.
 * Privacy feature: requires biometric unlock when enabled.
 * Mirrors iOS BiometricManager.swift.
 */
class ShifAIBiometricManager(private val context: Context) {

    enum class BiometricType { FINGERPRINT, FACE, IRIS, NONE }
    enum class AuthResult { SUCCESS, FAILED, NOT_AVAILABLE, NOT_ENROLLED }

    private val prefs = context.getSharedPreferences("shifai_prefs", Context.MODE_PRIVATE)

    var isEnabled: Boolean
        get() = prefs.getBoolean("biometric_lock", false)
        set(value) { prefs.edit().putBoolean("biometric_lock", value).apply() }

    // ─── Availability ───

    val isAvailable: Boolean
        get() {
            val manager = BiometricManager.from(context)
            return manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) ==
                    BiometricManager.BIOMETRIC_SUCCESS
        }

    fun getAvailableType(): BiometricType {
        val manager = BiometricManager.from(context)
        return when (manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> BiometricType.FINGERPRINT // Generic — Android doesn't distinguish
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> BiometricType.NONE
            else -> BiometricType.NONE
        }
    }

    // ─── Authentication ───

    fun authenticate(
        activity: FragmentActivity,
        onResult: (AuthResult) -> Unit
    ) {
        if (!isAvailable) {
            onResult(AuthResult.NOT_AVAILABLE)
            return
        }

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Déverrouiller ShifAI")
            .setSubtitle("Utilisez votre empreinte ou visage")
            .setNegativeButtonText("Utiliser le code")
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            .build()

        val biometricPrompt = BiometricPrompt(
            activity,
            ContextCompat.getMainExecutor(context),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    onResult(AuthResult.SUCCESS)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    when (errorCode) {
                        BiometricPrompt.ERROR_HW_NOT_PRESENT,
                        BiometricPrompt.ERROR_HW_UNAVAILABLE -> onResult(AuthResult.NOT_AVAILABLE)
                        BiometricPrompt.ERROR_NO_BIOMETRICS -> onResult(AuthResult.NOT_ENROLLED)
                        else -> onResult(AuthResult.FAILED)
                    }
                }

                override fun onAuthenticationFailed() {
                    onResult(AuthResult.FAILED)
                }
            }
        )

        biometricPrompt.authenticate(promptInfo)
    }
}
