package com.shifai.presentation.tracking

import com.shifai.domain.models.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.LocalDate
import java.time.temporal.ChronoUnit

/**
 * Cycle Tracking ViewModel — Android
 * S2-1: Period logging, phase detection, history, predictions
 *
 * Mirrors iOS CycleTrackingViewModel
 */
class CycleTrackingViewModel {

    private val _cycleDay = MutableStateFlow(1)
    val cycleDay: StateFlow<Int> = _cycleDay.asStateFlow()

    private val _phase = MutableStateFlow(CyclePhase.UNKNOWN)
    val phase: StateFlow<CyclePhase> = _phase.asStateFlow()

    private val _isOnPeriod = MutableStateFlow(false)
    val isOnPeriod: StateFlow<Boolean> = _isOnPeriod.asStateFlow()

    private val _flowIntensity = MutableStateFlow(0)
    val flowIntensity: StateFlow<Int> = _flowIntensity.asStateFlow()

    private val _daysUntilPeriod = MutableStateFlow<Int?>(null)
    val daysUntilPeriod: StateFlow<Int?> = _daysUntilPeriod.asStateFlow()

    private val _averageCycleLength = MutableStateFlow<Int?>(null)
    val averageCycleLength: StateFlow<Int?> = _averageCycleLength.asStateFlow()

    private val _recentEntries = MutableStateFlow<List<CycleEntry>>(emptyList())
    val recentEntries: StateFlow<List<CycleEntry>> = _recentEntries.asStateFlow()

    // TODO: Inject via Hilt when DI is set up
    // private val cycleDao: CycleEntryDao
    // private val ruleEngine: RuleEngine

    fun loadData() {
        // Load from Room DAO
        // loadCurrentCycle()
        // loadRecentEntries()
        // computePredictions()

        // Mock data for now
        _cycleDay.value = 14
        _phase.value = CyclePhase.OVULATORY
        _daysUntilPeriod.value = 14
        _averageCycleLength.value = 28
    }

    fun togglePeriod() {
        _isOnPeriod.value = !_isOnPeriod.value
        if (_isOnPeriod.value) {
            _flowIntensity.value = 3
            _cycleDay.value = 1
            _phase.value = CyclePhase.MENSTRUAL
        } else {
            _flowIntensity.value = 0
        }
    }

    fun setFlowIntensity(intensity: Int) {
        _flowIntensity.value = intensity
    }

    fun detectPhase(cycleDay: Int, cycleLength: Int = 28): CyclePhase {
        val avgLen = _averageCycleLength.value ?: cycleLength
        return when {
            cycleDay <= 5 -> CyclePhase.MENSTRUAL
            cycleDay <= (avgLen / 2 - 2) -> CyclePhase.FOLLICULAR
            cycleDay <= (avgLen / 2 + 2) -> CyclePhase.OVULATORY
            cycleDay <= avgLen -> CyclePhase.LUTEAL
            else -> CyclePhase.UNKNOWN
        }
    }
}

/**
 * Daily Log ViewModel — Android
 * S2-4 to S2-7: Mood, Energy, Sleep, Stress
 */
class DailyLogViewModel {

    data class MoodOption(val emoji: String, val label: String)

    val moodOptions = listOf(
        MoodOption("😄", "Super"),
        MoodOption("😊", "Bien"),
        MoodOption("😐", "Neutre"),
        MoodOption("😔", "Triste"),
        MoodOption("😢", "Mal"),
        MoodOption("😤", "En colère"),
        MoodOption("😰", "Anxieuse"),
    )

    private val _selectedMood = MutableStateFlow<Int?>(null)
    val selectedMood: StateFlow<Int?> = _selectedMood.asStateFlow()

    private val _energy = MutableStateFlow(5f)
    val energy: StateFlow<Float> = _energy.asStateFlow()

    private val _sleepHours = MutableStateFlow(7)
    val sleepHours: StateFlow<Int> = _sleepHours.asStateFlow()

    private val _sleepMinutes = MutableStateFlow(30)
    val sleepMinutes: StateFlow<Int> = _sleepMinutes.asStateFlow()

    private val _sleepQuality = MutableStateFlow(3)
    val sleepQuality: StateFlow<Int> = _sleepQuality.asStateFlow()

    private val _stress = MutableStateFlow(3)
    val stress: StateFlow<Int> = _stress.asStateFlow()

    fun setMood(index: Int) { _selectedMood.value = index }
    fun setEnergy(value: Float) { _energy.value = value }
    fun setSleepHours(h: Int) { _sleepHours.value = h }
    fun setSleepMinutes(m: Int) { _sleepMinutes.value = m }
    fun setSleepQuality(q: Int) { _sleepQuality.value = q }
    fun setStress(level: Int) { _stress.value = level }

    suspend fun saveAll() {
        // TODO: Save via Room DAOs when DI is set up
        // val today = System.currentTimeMillis()
        // Save mood, energy, sleep, stress as symptom logs
    }
}

/**
 * Symptom Logging ViewModel — Android
 * S2-2: 30+ symptoms, categories, intensity
 */
class SymptomLoggingViewModel {

    private val _selectedSymptoms = MutableStateFlow<Map<SymptomType, Int>>(emptyMap())
    val selectedSymptoms: StateFlow<Map<SymptomType, Int>> = _selectedSymptoms.asStateFlow()

    private val _searchText = MutableStateFlow("")
    val searchText: StateFlow<String> = _searchText.asStateFlow()

    fun toggleSymptom(type: SymptomType) {
        val current = _selectedSymptoms.value.toMutableMap()
        if (current.containsKey(type)) {
            current.remove(type)
        } else {
            current[type] = 5
        }
        _selectedSymptoms.value = current
    }

    fun setIntensity(type: SymptomType, intensity: Int) {
        val current = _selectedSymptoms.value.toMutableMap()
        current[type] = intensity
        _selectedSymptoms.value = current
    }

    fun setSearchText(text: String) {
        _searchText.value = text
    }

    fun filteredSymptoms(category: SymptomCategory): List<SymptomType> {
        val search = _searchText.value
        val types = category.symptoms
        return if (search.isEmpty()) types
        else types.filter { it.displayName.contains(search, ignoreCase = true) }
    }

    suspend fun saveAll() {
        // TODO: Save via Room DAOs
    }
}

/**
 * Body Map ViewModel — Android
 * S2-3: 5 zones, pain types, intensity
 */
class BodyMapViewModel {

    data class ZoneEntry(
        val painType: PainType,
        val intensity: Int
    )

    private val _selectedZone = MutableStateFlow<BodyZone?>(null)
    val selectedZone: StateFlow<BodyZone?> = _selectedZone.asStateFlow()

    private val _zoneData = MutableStateFlow<Map<BodyZone, ZoneEntry>>(emptyMap())
    val zoneData: StateFlow<Map<BodyZone, ZoneEntry>> = _zoneData.asStateFlow()

    fun selectZone(zone: BodyZone) { _selectedZone.value = zone }

    fun setPainType(zone: BodyZone, type: PainType) {
        val current = _zoneData.value.toMutableMap()
        current[zone] = current[zone]?.copy(painType = type)
            ?: ZoneEntry(painType = type, intensity = 5)
        _zoneData.value = current
    }

    fun setIntensity(zone: BodyZone, intensity: Int) {
        val current = _zoneData.value.toMutableMap()
        current[zone] = current[zone]?.copy(intensity = intensity)
            ?: ZoneEntry(painType = PainType.CRAMPING, intensity = intensity)
        _zoneData.value = current
    }

    suspend fun saveAll() {
        // TODO: Save via Room DAOs
    }
}

// MARK: - Enum Extensions

enum class SymptomCategory(val displayName: String, val emoji: String) {
    PAIN("Douleur", "🔴"),
    DIGESTIVE("Digestif", "🫄"),
    EMOTIONAL("Émotionnel", "💭"),
    PHYSICAL("Physique", "🤕"),
    HORMONAL("Hormonal", "⚡"),
    OTHER("Autre", "📝");

    val symptoms: List<SymptomType>
        get() = when (this) {
            PAIN -> listOf(
                SymptomType.CRAMPS, SymptomType.HEADACHE, SymptomType.BACK_PAIN,
                SymptomType.BREAST_TENDERNESS, SymptomType.JOINT_PAIN, SymptomType.PELVIC_PAIN
            )
            DIGESTIVE -> listOf(
                SymptomType.BLOATING, SymptomType.NAUSEA, SymptomType.CONSTIPATION,
                SymptomType.DIARRHEA, SymptomType.CRAVINGS, SymptomType.APPETITE_LOSS
            )
            EMOTIONAL -> listOf(
                SymptomType.ANXIOUS, SymptomType.IRRITABLE, SymptomType.SAD,
                SymptomType.MOOD_SWINGS, SymptomType.BRAIN_FOG, SymptomType.CRYING
            )
            PHYSICAL -> listOf(
                SymptomType.FATIGUE, SymptomType.INSOMNIA, SymptomType.HOT_FLASHES,
                SymptomType.DIZZINESS, SymptomType.ACNE, SymptomType.HAIR_LOSS
            )
            HORMONAL -> listOf(
                SymptomType.SPOTTING, SymptomType.HEAVY_FLOW,
                SymptomType.IRREGULAR_CYCLE, SymptomType.NIGHT_SWEATS
            )
            OTHER -> listOf(SymptomType.OTHER)
        }
}

// Display names for Android domain enums
val CyclePhase.displayName: String
    get() = when (this) {
        CyclePhase.MENSTRUAL -> "Menstruelle"
        CyclePhase.FOLLICULAR -> "Folliculaire"
        CyclePhase.OVULATORY -> "Ovulatoire"
        CyclePhase.LUTEAL -> "Lutéale"
        CyclePhase.UNKNOWN -> "—"
    }

val CyclePhase.emoji: String
    get() = when (this) {
        CyclePhase.MENSTRUAL -> "🔴"
        CyclePhase.FOLLICULAR -> "🌱"
        CyclePhase.OVULATORY -> "🌸"
        CyclePhase.LUTEAL -> "🌙"
        CyclePhase.UNKNOWN -> "❓"
    }

val SymptomType.displayName: String
    get() = when (this) {
        SymptomType.CRAMPS -> "Crampes"
        SymptomType.HEADACHE -> "Migraine"
        SymptomType.BACK_PAIN -> "Mal de dos"
        SymptomType.BREAST_TENDERNESS -> "Seins sensibles"
        SymptomType.JOINT_PAIN -> "Douleurs articulaires"
        SymptomType.PELVIC_PAIN -> "Douleur pelvienne"
        SymptomType.BLOATING -> "Ballonnement"
        SymptomType.NAUSEA -> "Nausée"
        SymptomType.CONSTIPATION -> "Constipation"
        SymptomType.DIARRHEA -> "Diarrhée"
        SymptomType.CRAVINGS -> "Envies alimentaires"
        SymptomType.APPETITE_LOSS -> "Perte d'appétit"
        SymptomType.ANXIOUS -> "Anxiété"
        SymptomType.IRRITABLE -> "Irritabilité"
        SymptomType.SAD -> "Tristesse"
        SymptomType.MOOD_SWINGS -> "Sautes d'humeur"
        SymptomType.BRAIN_FOG -> "Brouillard mental"
        SymptomType.CRYING -> "Envie de pleurer"
        SymptomType.FATIGUE -> "Fatigue"
        SymptomType.INSOMNIA -> "Insomnie"
        SymptomType.HOT_FLASHES -> "Bouffées de chaleur"
        SymptomType.DIZZINESS -> "Vertiges"
        SymptomType.ACNE -> "Acné"
        SymptomType.HAIR_LOSS -> "Chute de cheveux"
        SymptomType.SPOTTING -> "Spotting"
        SymptomType.HEAVY_FLOW -> "Flux abondant"
        SymptomType.IRREGULAR_CYCLE -> "Cycle irrégulier"
        SymptomType.NIGHT_SWEATS -> "Sueurs nocturnes"
        SymptomType.OTHER -> "Autre"
    }

val BodyZone.displayName: String
    get() = when (this) {
        BodyZone.UTERUS -> "Utérus"
        BodyZone.LEFT_OVARY -> "Ovaire gauche"
        BodyZone.RIGHT_OVARY -> "Ovaire droit"
        BodyZone.LOWER_BACK -> "Bas du dos"
        BodyZone.THIGHS -> "Cuisses"
    }

val PainType.displayName: String
    get() = when (this) {
        PainType.CRAMPING -> "Crampes"
        PainType.BURNING -> "Brûlure"
        PainType.PRESSURE -> "Pression"
        PainType.SHARP -> "Aiguë"
        PainType.OTHER -> "Autre"
    }
