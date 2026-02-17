package com.shifai.app

import org.junit.Assert.*
import org.junit.Test

class AppStateTest {

    // ─── Launch Flow ───

    @Test
    fun `new user starts with onboarding`() {
        val state = AppState()
        assertEquals(AppState.LaunchState.ONBOARDING, state.launchState)
    }

    @Test
    fun `onboarding completion changes state`() {
        val state = AppState()
        state.completeOnboarding()
        assertEquals(AppState.LaunchState.AUTHENTICATED, state.launchState)
    }

    @Test
    fun `biometric lock after onboarding`() {
        val state = AppState()
        state.loadPreferences(onboardingDone = true, biometricOn = true)
        assertEquals(AppState.LaunchState.BIOMETRIC_LOCK, state.launchState)
    }

    @Test
    fun `authenticated when no biometric`() {
        val state = AppState()
        state.loadPreferences(onboardingDone = true, biometricOn = false)
        assertEquals(AppState.LaunchState.AUTHENTICATED, state.launchState)
    }

    @Test
    fun `unlock sets authenticated`() {
        val state = AppState()
        state.loadPreferences(onboardingDone = true, biometricOn = true)
        state.unlockWithBiometrics()
        assertEquals(AppState.LaunchState.AUTHENTICATED, state.launchState)
    }

    // ─── Tabs ───

    @Test
    fun `default tab is dashboard`() {
        val state = AppState()
        assertEquals(AppState.MainTab.DASHBOARD, state.selectedTab)
    }

    @Test
    fun `switch to insights tab`() {
        val state = AppState()
        state.switchToTab(AppState.MainTab.INSIGHTS)
        assertEquals(AppState.MainTab.INSIGHTS, state.selectedTab)
    }

    @Test
    fun `reset to home goes to dashboard`() {
        val state = AppState()
        state.switchToTab(AppState.MainTab.SETTINGS)
        state.resetToHome()
        assertEquals(AppState.MainTab.DASHBOARD, state.selectedTab)
    }

    @Test
    fun `four tabs exist`() {
        assertEquals(4, AppState.MainTab.values().size)
    }

    @Test
    fun `four launch states exist`() {
        assertEquals(4, AppState.LaunchState.values().size)
    }
}
