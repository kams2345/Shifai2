package com.shifai.data.models

/**
 * Onboarding Data — stores user profile from onboarding flow.
 * Persisted to SharedPreferences, synced to Supabase profiles table.
 * Mirrors iOS OnboardingData.swift.
 */
data class OnboardingData(
    val cycleLength: Int = DEFAULT_CYCLE_LENGTH,
    val periodLength: Int = DEFAULT_PERIOD_LENGTH,
    val birthYear: Int? = null,
    val lastPeriodDate: String? = null,  // ISO date
    val goals: List<Goal> = listOf(Goal.TRACK_CYCLE),
    val notificationsEnabled: Boolean = true,
    val healthConnectEnabled: Boolean = false
) {
    enum class Goal(val value: String) {
        TRACK_CYCLE("track_cycle"),
        PREDICT_PERIOD("predict_period"),
        MONITOR_SYMPTOMS("monitor_symptoms"),
        FERTILITY_AWARENESS("fertility_awareness"),
        MEDICAL_EXPORT("medical_export"),
        UNDERSTAND_PATTERNS("understand_patterns")
    }

    companion object {
        const val DEFAULT_CYCLE_LENGTH = 28
        const val DEFAULT_PERIOD_LENGTH = 5
    }

    /**
     * Clamp values to valid ranges.
     */
    fun validated(): OnboardingData = copy(
        cycleLength = cycleLength.coerceIn(21, 45),
        periodLength = periodLength.coerceIn(2, 10)
    )
}
