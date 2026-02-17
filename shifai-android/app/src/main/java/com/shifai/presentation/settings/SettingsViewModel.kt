package com.shifai.presentation.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Settings ViewModel — manages preferences, sync state, and account actions.
 */
class SettingsViewModel : ViewModel() {

    data class SettingsState(
        // Sync
        val isSyncEnabled: Boolean = false,
        val lastSyncAt: String? = null,
        val isSyncing: Boolean = false,

        // Notifications per category
        val notifCyclePrediction: Boolean = true,
        val notifRecommendation: Boolean = true,
        val notifQuickWin: Boolean = true,
        val notifEducational: Boolean = true,

        // Privacy
        val biometricEnabled: Boolean = false,
        val widgetPrivacy: Boolean = false,
        val analyticsEnabled: Boolean = false,

        // Account
        val showDeleteDialog: Boolean = false,
        val isExporting: Boolean = false
    )

    private val _state = MutableStateFlow(SettingsState())
    val state: StateFlow<SettingsState> = _state.asStateFlow()

    // ─── Sync ───

    fun toggleSync(enabled: Boolean) {
        _state.value = _state.value.copy(isSyncEnabled = enabled)
        // TODO: SyncEngine.setEnabled(enabled)
    }

    fun syncNow() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isSyncing = true)
            try {
                // TODO: SyncEngine.syncNow()
                _state.value = _state.value.copy(
                    isSyncing = false,
                    lastSyncAt = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
                        .format(java.util.Date())
                )
            } catch (e: Exception) {
                _state.value = _state.value.copy(isSyncing = false)
            }
        }
    }

    // ─── Notifications ───

    fun toggleNotifCategory(category: String, enabled: Boolean) {
        _state.value = when (category) {
            "cycle_prediction" -> _state.value.copy(notifCyclePrediction = enabled)
            "recommendation" -> _state.value.copy(notifRecommendation = enabled)
            "quickwin" -> _state.value.copy(notifQuickWin = enabled)
            "educational" -> _state.value.copy(notifEducational = enabled)
            else -> _state.value
        }
    }

    // ─── Privacy ───

    fun toggleBiometric(enabled: Boolean) {
        _state.value = _state.value.copy(biometricEnabled = enabled)
        // TODO: BiometricAuthManager.setEnabled(enabled)
    }

    fun toggleWidgetPrivacy(enabled: Boolean) {
        _state.value = _state.value.copy(widgetPrivacy = enabled)
    }

    fun toggleAnalytics(enabled: Boolean) {
        _state.value = _state.value.copy(analyticsEnabled = enabled)
        // TODO: AnalyticsTracker.setConsent(enabled)
    }

    // ─── Account ───

    fun showDeleteConfirmation() {
        _state.value = _state.value.copy(showDeleteDialog = true)
    }

    fun dismissDeleteDialog() {
        _state.value = _state.value.copy(showDeleteDialog = false)
    }

    fun deleteAccount() {
        viewModelScope.launch {
            // TODO: Call delete-account Edge Function
            // Clear local data
            // Navigate to login
        }
    }

    fun exportCSV() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isExporting = true)
            // TODO: Generate and share CSV
            _state.value = _state.value.copy(isExporting = false)
        }
    }
}
