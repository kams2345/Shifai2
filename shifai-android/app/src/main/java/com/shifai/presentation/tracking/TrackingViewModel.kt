package com.shifai.presentation.tracking

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.shifai.domain.models.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * Tracking ViewModel — manages daily log form state.
 * Handles flow, mood, energy, sleep, stress, symptoms, and body map.
 */
class TrackingViewModel : ViewModel() {

    data class TrackingState(
        val date: String = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date()),
        val flowIntensity: Int = 0,        // 0-4
        val moodScore: Int = 5,            // 1-10
        val energyScore: Int = 5,          // 1-10
        val sleepHours: Float = 0f,
        val stressLevel: Int = 5,          // 1-10
        val symptoms: List<SymptomEntry> = emptyList(),
        val bodyZones: Set<BodyZone> = emptySet(),
        val notes: String = "",
        val isSaving: Boolean = false,
        val isSaved: Boolean = false,
        val hasExistingEntry: Boolean = false
    )

    data class SymptomEntry(
        val type: SymptomCategory,
        val intensity: Int  // 1-10
    )

    private val _state = MutableStateFlow(TrackingState())
    val state: StateFlow<TrackingState> = _state.asStateFlow()

    init {
        loadExistingEntry()
    }

    // ─── Slider Updates ───

    fun setFlowIntensity(value: Int) {
        _state.value = _state.value.copy(flowIntensity = value.coerceIn(0, 4))
    }

    fun setMoodScore(value: Int) {
        _state.value = _state.value.copy(moodScore = value.coerceIn(1, 10))
    }

    fun setEnergyScore(value: Int) {
        _state.value = _state.value.copy(energyScore = value.coerceIn(1, 10))
    }

    fun setSleepHours(value: Float) {
        _state.value = _state.value.copy(sleepHours = value.coerceIn(0f, 24f))
    }

    fun setStressLevel(value: Int) {
        _state.value = _state.value.copy(stressLevel = value.coerceIn(1, 10))
    }

    fun setNotes(text: String) {
        _state.value = _state.value.copy(notes = text)
    }

    // ─── Symptoms ───

    fun addSymptom(type: SymptomCategory, intensity: Int) {
        val current = _state.value.symptoms.toMutableList()
        // Remove existing of same type, then add
        current.removeAll { it.type == type }
        current.add(SymptomEntry(type, intensity.coerceIn(1, 10)))
        _state.value = _state.value.copy(symptoms = current)
    }

    fun removeSymptom(type: SymptomCategory) {
        _state.value = _state.value.copy(
            symptoms = _state.value.symptoms.filter { it.type != type }
        )
    }

    // ─── Body Map ───

    fun toggleBodyZone(zone: BodyZone) {
        val current = _state.value.bodyZones.toMutableSet()
        if (current.contains(zone)) current.remove(zone) else current.add(zone)
        _state.value = _state.value.copy(bodyZones = current)
    }

    // ─── Persistence ───

    fun save() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isSaving = true)
            try {
                // TODO: cycleRepo.save(buildCycleEntry())
                // TODO: symptoms.forEach { symptomRepo.save(buildSymptomLog(it)) }
                _state.value = _state.value.copy(isSaving = false, isSaved = true)
            } catch (e: Exception) {
                _state.value = _state.value.copy(isSaving = false)
            }
        }
    }

    private fun loadExistingEntry() {
        viewModelScope.launch {
            // TODO: val existing = cycleRepo.fetchByDate(state.value.date)
            // if (existing != null) { populate state from existing }
        }
    }
}
