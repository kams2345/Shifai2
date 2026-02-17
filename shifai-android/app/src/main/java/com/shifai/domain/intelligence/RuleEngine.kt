package com.shifai.domain.intelligence

import com.shifai.domain.models.*
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import kotlin.math.abs
import kotlin.math.roundToInt
import kotlin.math.sqrt

/**
 * Phase 1 Rule Engine — Heuristic-based predictions (Days 1-13)
 * Mirrors iOS RuleEngine.swift
 */
class RuleEngine {

    private val dateFormatter = DateTimeFormatter.ISO_LOCAL_DATE

    /**
     * Predict next period start date using weighted average of last 3 cycles
     */
    fun predictNextPeriod(cycleEntries: List<CycleEntry>): Prediction? {
        val cycleLengths = calculateCycleLengths(cycleEntries)
        if (cycleLengths.size < 2) return null

        val lastCycles = cycleLengths.takeLast(3)
        val weights = if (lastCycles.size == 3) listOf(0.5, 0.3, 0.2) else listOf(0.6, 0.4)
        val weightedAvg = lastCycles.zip(weights).sumOf { (len, w) -> len * w }
        val predictedCycleLength = weightedAvg.roundToInt()

        val stdDev = standardDeviation(cycleLengths.map { it.toDouble() })
        val confidence = (1.0 - (stdDev / 10.0)).coerceIn(0.3, 0.85)

        val lastPeriodStart = findLastPeriodStart(cycleEntries) ?: return null
        val predictedDate = lastPeriodStart.plusDays(predictedCycleLength.toLong())

        return Prediction(
            type = PredictionType.PERIOD_START,
            predictedDate = predictedDate.format(dateFormatter),
            confidence = confidence,
            modelVersion = "rule_engine_v1"
        )
    }

    /**
     * Generate Day 1 Quick Win: sleep benchmark
     */
    fun generateQuickWinDay1(symptoms: List<SymptomLog>): Insight? {
        val sleepLogs = symptoms.filter { it.symptomType == SymptomCategory.SLEEP }
        if (sleepLogs.isEmpty()) return null

        val avgSleep = sleepLogs.map { it.value }.average()
        val benchmarkAvg = 7.0
        val comparison = if (avgSleep >= benchmarkAvg) "meilleur" else "en dessous de"
        val percentage = abs(((avgSleep - benchmarkAvg) / benchmarkAvg) * 100).roundToInt()

        return Insight(
            date = LocalDate.now().format(dateFormatter),
            type = InsightType.QUICK_WIN,
            title = "Ton sommeil est $percentage% $comparison la moyenne 🎉",
            body = "La moyenne recommandée est de ${benchmarkAvg}h. Tu es à ~${"%.1f".format(avgSleep)}h.",
            confidence = 0.9,
            reasoning = "Basé sur tes ${sleepLogs.size} entrées de sommeil.",
            source = IntelligenceSource.RULE_BASED
        )
    }

    /**
     * Generate Day 3 Quick Win: energy mini-pattern
     */
    fun generateQuickWinDay3(symptoms: List<SymptomLog>): Insight? {
        val energyLogs = symptoms
            .filter { it.symptomType == SymptomCategory.ENERGY }
            .sortedBy { it.date }
        if (energyLogs.size < 3) return null

        val trend = energyLogs.last().value - energyLogs.first().value
        val trendText = when {
            trend > 0 -> "augmenté"
            trend < 0 -> "diminué"
            else -> "resté stable"
        }

        return Insight(
            date = LocalDate.now().format(dateFormatter),
            type = InsightType.QUICK_WIN,
            title = "Ton énergie a $trendText ces 3 jours 📈",
            body = "Ton corps suit un rythme. Continue à logger pour découvrir tes patterns !",
            confidence = 0.7,
            reasoning = "Basé sur tes 3 dernières entrées: ${energyLogs.map { it.value }.joinToString(" → ")}",
            source = IntelligenceSource.RULE_BASED
        )
    }

    // ─── Private Helpers ───

    private fun calculateCycleLengths(entries: List<CycleEntry>): List<Int> {
        val periodStarts = entries
            .filter { (it.flowIntensity ?: 0) > 0 }
            .sortedBy { it.date }

        val cycleStarts = mutableListOf<String>()
        var lastDate: String? = null

        for (entry in periodStarts) {
            if (lastDate != null) {
                if (daysBetween(lastDate, entry.date) > 3) {
                    cycleStarts.add(entry.date)
                }
            } else {
                cycleStarts.add(entry.date)
            }
            lastDate = entry.date
        }

        return (1 until cycleStarts.size).map {
            daysBetween(cycleStarts[it - 1], cycleStarts[it])
        }
    }

    private fun findLastPeriodStart(entries: List<CycleEntry>): LocalDate? {
        return entries
            .filter { (it.flowIntensity ?: 0) > 0 }
            .sortedByDescending { it.date }
            .firstOrNull()
            ?.let { LocalDate.parse(it.date, dateFormatter) }
    }

    private fun daysBetween(date1: String, date2: String): Int {
        val d1 = LocalDate.parse(date1, dateFormatter)
        val d2 = LocalDate.parse(date2, dateFormatter)
        return ChronoUnit.DAYS.between(d1, d2).toInt()
    }

    private fun standardDeviation(values: List<Double>): Double {
        val mean = values.average()
        val variance = values.map { (it - mean) * (it - mean) }.average()
        return sqrt(variance)
    }
}
