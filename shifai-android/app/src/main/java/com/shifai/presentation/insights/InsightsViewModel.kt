package com.shifai.presentation.insights

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.shifai.domain.models.Insight
import com.shifai.domain.models.InsightType
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Insights ViewModel — manages filter state, insight list, and ML engine status.
 */
class InsightsViewModel : ViewModel() {

    data class InsightsState(
        val insights: List<Insight> = emptyList(),
        val filteredInsights: List<Insight> = emptyList(),
        val activeFilter: InsightFilter = InsightFilter.ALL,
        val mlStatus: MLStatus = MLStatus.RULE_BASED,
        val isLoading: Boolean = true
    )

    enum class InsightFilter { ALL, PREDICTIONS, CORRELATIONS, RECOMMENDATIONS }
    enum class MLStatus { RULE_BASED, ML_ACTIVE, TRAINING }

    private val _state = MutableStateFlow(InsightsState())
    val state: StateFlow<InsightsState> = _state.asStateFlow()

    init {
        loadInsights()
    }

    fun loadInsights() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            try {
                // TODO: val insights = insightRepo.fetchRecent(limit = 50)
                _state.value = _state.value.copy(isLoading = false)
            } catch (e: Exception) {
                _state.value = _state.value.copy(isLoading = false)
            }
        }
    }

    fun setFilter(filter: InsightFilter) {
        val filtered = when (filter) {
            InsightFilter.ALL -> _state.value.insights
            InsightFilter.PREDICTIONS -> _state.value.insights.filter {
                it.type == InsightType.PREDICTION
            }
            InsightFilter.CORRELATIONS -> _state.value.insights.filter {
                it.type == InsightType.PATTERN
            }
            InsightFilter.RECOMMENDATIONS -> _state.value.insights.filter {
                it.type == InsightType.RECOMMENDATION
            }
        }
        _state.value = _state.value.copy(
            activeFilter = filter,
            filteredInsights = filtered
        )
    }

    fun submitFeedback(insightId: String, isAccurate: Boolean) {
        viewModelScope.launch {
            // TODO: predictionRepo.submitFeedback(insightId, if (isAccurate) "accurate" else "inaccurate")
            // Refresh insights
        }
    }

    fun markAsRead(insightId: String) {
        viewModelScope.launch {
            // TODO: insightRepo.markAsRead(insightId)
        }
    }
}
