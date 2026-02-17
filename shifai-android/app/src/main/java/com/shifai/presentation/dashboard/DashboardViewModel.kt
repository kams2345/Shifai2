package com.shifai.presentation.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Dashboard ViewModel — mirrors iOS DashboardViewModel.
 * Manages cycle state, daily stats, and insight preview.
 */
class DashboardViewModel : ViewModel() {

    data class DashboardState(
        val cycleDay: Int = 1,
        val cycleDayTotal: Int = 28,
        val currentPhase: String = "Folliculaire",
        val phaseEmoji: String = "🌱",
        val energyForecast: String = "Bonne énergie",
        val energyLevel: Float = 0.7f,
        val symptomCount: Int = 0,
        val sleepHours: Float = 0f,
        val moodScore: Int = 0,
        val dailyInsight: String? = null,
        val isLoading: Boolean = true,
        val hasLoggedToday: Boolean = false
    )

    private val _state = MutableStateFlow(DashboardState())
    val state: StateFlow<DashboardState> = _state.asStateFlow()

    init {
        loadDashboardData()
    }

    fun loadDashboardData() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            try {
                // TODO: Load from repository
                // val lastEntry = cycleRepo.fetchCurrent()
                // val symptoms = symptomRepo.fetchForDate(today)
                // val insight = insightRepo.fetchRecent(limit = 1).firstOrNull()

                _state.value = _state.value.copy(
                    isLoading = false,
                    // Populated from repos when available
                )
            } catch (e: Exception) {
                _state.value = _state.value.copy(isLoading = false)
            }
        }
    }

    fun onQuickLogTapped() {
        // Navigate to tracking screen
    }

    fun markDayLogged() {
        _state.value = _state.value.copy(hasLoggedToday = true)
    }

    fun updateCycleDay(day: Int, total: Int, phase: String, emoji: String) {
        _state.value = _state.value.copy(
            cycleDay = day,
            cycleDayTotal = total,
            currentPhase = phase,
            phaseEmoji = emoji
        )
    }

    fun updateStats(symptoms: Int, sleep: Float, mood: Int) {
        _state.value = _state.value.copy(
            symptomCount = symptoms,
            sleepHours = sleep,
            moodScore = mood
        )
    }
}
