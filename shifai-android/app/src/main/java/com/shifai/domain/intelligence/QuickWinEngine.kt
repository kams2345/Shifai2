package com.shifai.domain.intelligence

import android.content.Context
import android.util.Log

/**
 * Quick Win Engine — mirrors iOS QuickWinEngine.swift
 * Manages milestone detection, educational drip, and adaptive notification frequency.
 */
class QuickWinEngine(private val context: Context) {

    companion object {
        private const val TAG = "QuickWin"
        private const val PREFS_NAME = "quickwin_prefs"
    }

    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    // ─── Milestones ───

    data class Milestone(
        val id: String,
        val title: String,
        val body: String,
        val emoji: String
    )

    private val milestones = listOf(
        Milestone("quickwin_j1", "Première entrée !", "Tu as fait le premier pas. L'IA commence à apprendre.", "🎉"),
        Milestone("quickwin_j3", "3 jours consécutifs", "Tes premières données prennent forme.", "📊"),
        Milestone("quickwin_j7", "1 semaine complète !", "L'IA détecte tes premiers patterns d'énergie.", "🧠"),
        Milestone("quickwin_j14", "2 semaines de suivi", "Les corrélations symptômes-cycle émergent.", "💡"),
        Milestone("quickwin_cycle1", "Premier cycle complet", "Les prédictions ML sont maintenant actives !", "🚀")
    )

    fun checkMilestones(logCount: Int, daysSinceInstall: Int): Milestone? {
        val shownIds = getShownIds()
        val thresholds = listOf(1, 3, 7, 14, 28)

        for ((index, milestone) in milestones.withIndex()) {
            if (milestone.id !in shownIds &&
                logCount >= thresholds[index] &&
                daysSinceInstall >= thresholds[index]) {
                return milestone
            }
        }
        return null
    }

    fun markShown(milestoneId: String) {
        val shown = getShownIds().toMutableSet()
        shown.add(milestoneId)
        prefs.edit().putStringSet("shown_ids", shown).apply()
    }

    private fun getShownIds(): Set<String> =
        prefs.getStringSet("shown_ids", emptySet()) ?: emptySet()

    // ─── Educational Drip (J4-J13) ───

    data class DripTip(val day: Int, val title: String, val body: String)

    private val dripTips = listOf(
        DripTip(4, "Phase folliculaire", "Après les règles, ton énergie remonte naturellement. C'est le moment idéal pour les projets."),
        DripTip(5, "Sommeil et cycle", "La qualité de sommeil varie selon la phase du cycle. Le suivi t'aidera à comprendre tes patterns."),
        DripTip(6, "Hydratation", "Boire suffisamment aide à réduire ballonnements et maux de tête liés au cycle."),
        DripTip(7, "Correlations", "ShifAI analyse les liens entre tes symptômes. Plus tu logges, plus les corrélations sont précises."),
        DripTip(8, "Phase ovulatoire", "Autour de J14, l'énergie et la libido sont souvent au plus haut. Observe tes propres patterns."),
        DripTip(9, "Exercice adapté", "L'activité physique peut soulager les crampes. Adapte l'intensité selon ta phase."),
        DripTip(10, "Phase lutéale", "Les 2 dernières semaines du cycle peuvent amener fatigue et irritabilité. C'est normal."),
        DripTip(11, "Alimentation", "Les fringales en phase lutéale sont hormonales. Des protéines et glucides complexes aident."),
        DripTip(12, "Prédictions", "Après un cycle complet, ShifAI pourra prédire tes prochaines règles avec 85%+ de précision."),
        DripTip(13, "Ton corps", "Chaque corps est unique. Les patterns que ShifAI détecte sont les tiens, pas des moyennes.")
    )

    fun getDripTip(daysSinceInstall: Int): DripTip? {
        if (daysSinceInstall !in 4..13) return null
        val tipId = "drip_j$daysSinceInstall"
        if (tipId in getShownIds()) return null
        return dripTips.getOrNull(daysSinceInstall - 4)
    }

    // ─── Adaptive Frequency ───

    enum class Frequency { DAILY, WEEKLY, BIWEEKLY }

    fun recommendedFrequency(daysSinceInstall: Int): Frequency = when {
        daysSinceInstall <= 7 -> Frequency.DAILY
        daysSinceInstall <= 28 -> Frequency.WEEKLY
        else -> Frequency.BIWEEKLY
    }
}
