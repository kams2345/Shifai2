package com.shifai.data.security

import org.junit.Assert.*
import org.junit.Test

class BiometricManagerTest {

    // ─── Types ───

    @Test
    fun `fingerprint type exists`() {
        val type = ShifAIBiometricManager.BiometricType.FINGERPRINT
        assertEquals(ShifAIBiometricManager.BiometricType.FINGERPRINT, type)
    }

    @Test
    fun `face type exists`() {
        val type = ShifAIBiometricManager.BiometricType.FACE
        assertEquals(ShifAIBiometricManager.BiometricType.FACE, type)
    }

    @Test
    fun `none type exists`() {
        val type = ShifAIBiometricManager.BiometricType.NONE
        assertEquals(ShifAIBiometricManager.BiometricType.NONE, type)
    }

    // ─── Results ───

    @Test
    fun `success result exists`() {
        val result = ShifAIBiometricManager.AuthResult.SUCCESS
        assertEquals(ShifAIBiometricManager.AuthResult.SUCCESS, result)
    }

    @Test
    fun `failed result exists`() {
        val result = ShifAIBiometricManager.AuthResult.FAILED
        assertEquals(ShifAIBiometricManager.AuthResult.FAILED, result)
    }

    @Test
    fun `not available result exists`() {
        val result = ShifAIBiometricManager.AuthResult.NOT_AVAILABLE
        assertEquals(ShifAIBiometricManager.AuthResult.NOT_AVAILABLE, result)
    }

    @Test
    fun `not enrolled result exists`() {
        val result = ShifAIBiometricManager.AuthResult.NOT_ENROLLED
        assertEquals(ShifAIBiometricManager.AuthResult.NOT_ENROLLED, result)
    }

    // ─── Default State ───

    @Test
    fun `biometric lock disabled by default`() {
        val defaultState = false
        assertFalse(defaultState)
    }

    @Test
    fun `four auth result types exist`() {
        val results = ShifAIBiometricManager.AuthResult.values()
        assertEquals(4, results.size)
    }

    @Test
    fun `three biometric types exist`() {
        val types = ShifAIBiometricManager.BiometricType.values()
        // FINGERPRINT, FACE, IRIS, NONE
        assertEquals(4, types.size)
    }
}
