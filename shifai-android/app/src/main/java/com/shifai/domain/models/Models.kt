package com.shifai.domain.models

import java.util.UUID

// MARK: - Domain Models
// Pure data models — zero Android framework dependencies

// ─── Cycle Entry ───

data class CycleEntry(
    val id: String = UUID.randomUUID().toString(),
    val date: String,               // ISO 8601: YYYY-MM-DD
    var flowIntensity: Int? = null,  // 1-5
    var cycleDay: Int? = null,
    var phase: CyclePhase? = null,
    val createdAt: Long = System.currentTimeMillis(),
    var updatedAt: Long = System.currentTimeMillis(),
    var syncStatus: SyncStatus = SyncStatus.PENDING
)

enum class CyclePhase(val displayName: String, val emoji: String) {
    MENSTRUAL("Menstruelle", "🔴"),
    FOLLICULAR("Folliculaire", "🌱"),
    OVULATORY("Ovulatoire", "☀️"),
    LUTEAL("Lutéale", "🌙");

    companion object {
        fun fromString(value: String): CyclePhase? =
            entries.find { it.name.equals(value, ignoreCase = true) }
    }
}

// ─── Symptom Log ───

data class SymptomLog(
    val id: String = UUID.randomUUID().toString(),
    val date: String,
    val symptomType: SymptomCategory,
    var value: Int,                   // 1-10
    var notes: String? = null,
    var bodyZone: BodyZone? = null,
    var painType: PainType? = null,
    val createdAt: Long = System.currentTimeMillis(),
    var updatedAt: Long = System.currentTimeMillis(),
    var syncStatus: SyncStatus = SyncStatus.PENDING
)

enum class SymptomCategory(val displayName: String, val emoji: String) {
    MOOD("Humeur", "😊"),
    ENERGY("Énergie", "⚡"),
    SLEEP("Sommeil", "💤"),
    STRESS("Stress", "😤"),
    HEADACHE("Maux de tête", "🤕"),
    BLOATING("Ballonnements", "🫄"),
    CRAVINGS("Fringales", "🍫"),
    ACNE("Acné", "😣"),
    BREAST_TENDERNESS("Sensibilité poitrine", "💔"),
    NAUSEA("Nausée", "🤢"),
    CONSTIPATION("Constipation", "🫃"),
    DIARRHEA("Diarrhée", "🫃"),
    HOT_FLASHES("Bouffées de chaleur", "🥵"),
    FATIGUE("Fatigue", "😴"),
    DIZZINESS("Vertiges", "💫"),
    BACK_PAIN("Mal de dos", "🔙"),
    PAIN("Douleur", "🔴")
}

enum class BodyZone(val displayName: String) {
    UTERUS("Utérus"),
    LEFT_OVARY("Ovaire gauche"),
    RIGHT_OVARY("Ovaire droit"),
    LOWER_BACK("Bas du dos"),
    THIGHS("Cuisses")
}

enum class PainType(val displayName: String) {
    CRAMPING("Crampes"),
    BURNING("Brûlure"),
    PRESSURE("Pression"),
    OTHER("Autre")
}

// ─── Insight ───

data class Insight(
    val id: String = UUID.randomUUID().toString(),
    val date: String,
    val type: InsightType,
    var title: String,
    var body: String,
    var confidence: Double? = null,
    var reasoning: String? = null,
    var source: IntelligenceSource = IntelligenceSource.RULE_BASED,
    var userFeedback: InsightFeedback? = null,
    val createdAt: Long = System.currentTimeMillis()
)

enum class InsightType(val displayLabel: String) {
    QUICK_WIN("Quick Win"),
    PATTERN("Pattern"),
    PREDICTION("Prédiction"),
    RECOMMENDATION("Recommandation")
}

enum class IntelligenceSource { RULE_BASED, ML_MODEL_V1 }
enum class InsightFeedback { ACCURATE, INACCURATE }

// ─── Prediction ───

data class Prediction(
    val id: String = UUID.randomUUID().toString(),
    val type: PredictionType,
    var predictedDate: String? = null,
    var predictedValue: Int? = null,
    var confidence: Double,
    var actualDate: String? = null,
    var actualValue: Int? = null,
    var accuracyScore: Double? = null,
    var modelVersion: String,
    val createdAt: Long = System.currentTimeMillis()
)

enum class PredictionType { PERIOD_START, OVULATION, ENERGY, MOOD }

// ─── User Profile ───

data class UserProfile(
    val id: String = UUID.randomUUID().toString(),
    val createdAt: Long = System.currentTimeMillis(),
    var onboardingCompleted: Boolean = false,
    var cycleType: CycleType = CycleType.UNKNOWN,
    var conditions: List<Condition> = emptyList(),
    var preferences: UserPreferences = UserPreferences()
)

enum class CycleType { REGULAR, IRREGULAR, UNKNOWN }

enum class Condition(val displayName: String) {
    SOPK("SOPK"),
    ENDOMETRIOSIS("Endométriose"),
    NONE("Aucune"),
    UNKNOWN("Je ne sais pas")
}

data class UserPreferences(
    var autoLockSeconds: Int = 300,
    var notificationsEnabled: Boolean = true,
    var cloudSyncEnabled: Boolean = false,
    var biometricEnabled: Boolean = false,
    var preferredNotificationHour: Int = 9,
    var locale: String = "fr"
)

// ─── Sync ───

enum class SyncStatus { PENDING, SYNCED, CONFLICT }
