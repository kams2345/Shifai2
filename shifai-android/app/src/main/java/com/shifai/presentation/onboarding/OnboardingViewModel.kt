package com.shifai.presentation.onboarding

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Onboarding ViewModel — Android
 * S3-1 to S3-5: Manages 5-step onboarding state, profile setup, and completion
 *
 * Mirrors iOS OnboardingViewModel
 */
class OnboardingViewModel {

    // S3-1: Welcome
    private val _cycleDescription = MutableStateFlow("")
    val cycleDescription: StateFlow<String> = _cycleDescription.asStateFlow()

    // S3-2: Disclaimer
    private val _disclaimerAccepted = MutableStateFlow(false)
    val disclaimerAccepted: StateFlow<Boolean> = _disclaimerAccepted.asStateFlow()

    // S3-4: Profile Setup
    private val _ageRange = MutableStateFlow<String?>(null)
    val ageRange: StateFlow<String?> = _ageRange.asStateFlow()

    private val _cycleLength = MutableStateFlow<String?>(null)
    val cycleLength: StateFlow<String?> = _cycleLength.asStateFlow()

    private val _selectedConditions = MutableStateFlow<Set<String>>(emptySet())
    val selectedConditions: StateFlow<Set<String>> = _selectedConditions.asStateFlow()

    private val _trackedSymptoms = MutableStateFlow<Set<String>>(emptySet())
    val trackedSymptoms: StateFlow<Set<String>> = _trackedSymptoms.asStateFlow()

    // S3-5: Body Map
    data class BodyZoneEntry(val zone: String, val selected: Boolean = false)

    private val _markedZones = MutableStateFlow<Set<String>>(emptySet())
    val markedZones: StateFlow<Set<String>> = _markedZones.asStateFlow()

    // Preselected symptoms based on conditions
    val preselectedSymptoms: List<String>
        get() {
            val base = mutableListOf("Crampes", "Fatigue", "Migraine", "Ballonnement", "Anxiété", "Insomnie")
            val conditions = _selectedConditions.value

            if ("SOPK" in conditions) {
                base += listOf("Acné", "Chute de cheveux", "Cycle irrégulier", "Envies alimentaires")
            }
            if ("Endométriose" in conditions) {
                base += listOf("Douleur pelvienne", "Mal de dos", "Nausée", "Diarrhée")
            }

            return base.distinct().sorted()
        }

    // MARK: - Actions

    fun setCycleDescription(text: String) { _cycleDescription.value = text }
    fun toggleDisclaimer() { _disclaimerAccepted.value = !_disclaimerAccepted.value }
    fun setAgeRange(range: String) { _ageRange.value = range }
    fun setCycleLength(length: String) { _cycleLength.value = length }

    fun toggleCondition(condition: String) {
        val current = _selectedConditions.value.toMutableSet()
        if (condition in current) {
            current.remove(condition)
        } else {
            if (condition == "Aucune" || condition == "Je ne sais pas") {
                current.clear()
            } else {
                current.remove("Aucune")
                current.remove("Je ne sais pas")
            }
            current.add(condition)
        }
        _selectedConditions.value = current
        _trackedSymptoms.value = preselectedSymptoms.toSet()
    }

    fun toggleTrackedSymptom(symptom: String) {
        val current = _trackedSymptoms.value.toMutableSet()
        if (symptom in current) current.remove(symptom) else current.add(symptom)
        _trackedSymptoms.value = current
    }

    fun toggleBodyZone(zone: String) {
        val current = _markedZones.value.toMutableSet()
        if (zone in current) current.remove(zone) else current.add(zone)
        _markedZones.value = current
    }

    suspend fun saveProfile() {
        // TODO: Save via Room when DI is set up
    }

    suspend fun completeOnboarding() {
        // TODO: Save body map data and trigger J1 Quick Win
    }
}

/**
 * Quick Win Engine — Android
 * S3-6 (J1 Benchmark) + S3-7 (J3 Mini-Pattern) + S3-8 (Educational Drip)
 *
 * Mirrors iOS QuickWinEngine
 */
class QuickWinEngine {

    data class EducationalTip(
        val title: String,
        val body: String,
        val source: String?
    )

    val educationalTips = listOf(
        EducationalTip(
            "Phase menstruelle : le repos a du sens 🔴",
            "Pendant tes règles, le taux de progestérone et d'œstrogène chute. C'est normal de ressentir de la fatigue.",
            "ACOG"
        ),
        EducationalTip(
            "Stress et cycles : une connexion puissante 🧠",
            "Le cortisol peut retarder l'ovulation et allonger ton cycle. ShifAI va traquer cette corrélation.",
            "Harvard Health"
        ),
        EducationalTip(
            "Sommeil et hormones : un duo critique 😴",
            "La mélatonine influence directement la production de GnRH. Vise 7-8h régulières.",
            "Sleep Foundation"
        ),
        EducationalTip(
            "Phase folliculaire : ton énergie remonte 🌱",
            "Après les règles, les œstrogènes augmentent. C'est souvent le moment le plus dynamique.",
            "Clue"
        ),
        EducationalTip(
            "SOPK : comprendre les bases 💜",
            "Le SOPK touche 1 femme sur 10 — excès d'androgènes et résistance à l'insuline.",
            "WHO"
        ),
        EducationalTip(
            "Nutrition et cycle 🥗",
            "Les aliments anti-inflammatoires peuvent réduire les douleurs. En phase lutéale, +100-300 calories/jour.",
            "British Journal of Nutrition"
        ),
        EducationalTip(
            "Exercice et cycle 🏃‍♀️",
            "Folliculaire → HIIT/cardio. Lutéale → yoga/pilates. Écouter son énergie optimise les performances.",
            "British Journal of Sports Medicine"
        ),
        EducationalTip(
            "Endométriose : 7 ans pour un diagnostic ⏳",
            "Le suivi régulier de tes douleurs est l'un des meilleurs outils pour accélérer le diagnostic.",
            "Endometriosis UK"
        ),
        EducationalTip(
            "Phase ovulatoire : pic d'énergie 🌸",
            "Le pic de LH et d'œstrogène donne un boost d'énergie et de confiance.",
            "Healthline"
        ),
        EducationalTip(
            "Tu es unique 🌈",
            "Les normes sont des moyennes. ShifAI apprend TON rythme unique.",
            null
        ),
    )

    fun checkAndGenerateInsights(daysSinceOnboarding: Int) {
        when (daysSinceOnboarding) {
            0 -> generateJ1Benchmark()
            2 -> generateJ3MiniPattern()
            in 3..12 -> deliverEducationalTip(daysSinceOnboarding - 3)
        }
    }

    private fun generateJ1Benchmark() {
        // TODO: Create benchmark insight via Room DAO
    }

    private fun generateJ3MiniPattern() {
        // TODO: Analyze 3-day energy trend + symptom frequency via Room DAO
    }

    private fun deliverEducationalTip(index: Int) {
        if (index in educationalTips.indices) {
            val tip = educationalTips[index]
            // TODO: Save educational insight via Room DAO
        }
    }
}
