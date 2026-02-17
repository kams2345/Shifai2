package com.shifai.app

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

/**
 * App State — central state for the app lifecycle.
 * Manages launch flow, tab selection, and global state.
 * Mirrors iOS AppState.swift.
 */
class AppState : ViewModel() {

    enum class MainTab { DASHBOARD, TRACKING, INSIGHTS, SETTINGS }

    enum class LaunchState { LOADING, ONBOARDING, BIOMETRIC_LOCK, AUTHENTICATED }

    var selectedTab by mutableStateOf(MainTab.DASHBOARD)
        private set

    var launchState by mutableStateOf(LaunchState.LOADING)
        private set

    var hasCompletedOnboarding = false
        private set

    var isBiometricEnabled = false
        private set

    init {
        determineLaunchState()
    }

    // ─── Launch Flow ───

    fun determineLaunchState() {
        launchState = when {
            !hasCompletedOnboarding -> LaunchState.ONBOARDING
            isBiometricEnabled -> LaunchState.BIOMETRIC_LOCK
            else -> LaunchState.AUTHENTICATED
        }
    }

    fun completeOnboarding() {
        hasCompletedOnboarding = true
        determineLaunchState()
    }

    fun unlockWithBiometrics() {
        launchState = LaunchState.AUTHENTICATED
    }

    fun loadPreferences(onboardingDone: Boolean, biometricOn: Boolean) {
        hasCompletedOnboarding = onboardingDone
        isBiometricEnabled = biometricOn
        determineLaunchState()
    }

    // ─── Tab Management ───

    fun switchToTab(tab: MainTab) {
        selectedTab = tab
    }

    fun resetToHome() {
        selectedTab = MainTab.DASHBOARD
    }
}
