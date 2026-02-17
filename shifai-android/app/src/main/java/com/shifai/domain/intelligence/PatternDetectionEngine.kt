package com.shifai.domain.intelligence

import com.shifai.domain.models.*
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * Pattern Detection + ML Engine — Android
 * S4-1/S4-2: Correlation detection, cycle analysis, explainable AI
 * S4-4: TFLite integration stub (mirrors iOS MLEngine)
 */
class PatternDetectionEngine {

    data class CycleLengthAnalysis(
        val average: Double,
        val stdDeviation: Double,
        val trend: CycleTrend,
        val lengths: List<Int>,
        val isRegular: Boolean       // std dev < 3
    )

    enum class CycleTrend { SHORTENING, LENGTHENING, STABLE, INSUFFICIENT }

    data class Correlation(
        val factor1: String,
        val factor2: String,
        val strength: Double,        // -1.0 to 1.0
        val sampleSize: Int
    ) {
        val isSignificant: Boolean get() = abs(strength) > 0.3 && sampleSize >= 7
    }

    // MARK: - Cycle Length Analysis

    fun analyzeCycleLengths(entries: List<CycleEntry>): CycleLengthAnalysis {
        val lengths = mutableListOf<Int>()
        var currentLength = 0

        for ((i, entry) in entries.withIndex()) {
            if (entry.cycleDay == 1 && i > 0) {
                if (currentLength > 0) lengths.add(currentLength)
                currentLength = 1
            } else {
                currentLength++
            }
        }

        if (lengths.size < 2) {
            return CycleLengthAnalysis(28.0, 0.0, CycleTrend.INSUFFICIENT, lengths, false)
        }

        val avg = lengths.average()
        val variance = lengths.map { (it - avg).pow(2) }.average()
        val stdDev = sqrt(variance)

        val mid = lengths.size / 2
        val firstHalfAvg = lengths.take(mid).average()
        val secondHalfAvg = lengths.drop(mid).average()

        val trend = when {
            abs(firstHalfAvg - secondHalfAvg) < 1.5 -> CycleTrend.STABLE
            secondHalfAvg < firstHalfAvg -> CycleTrend.SHORTENING
            else -> CycleTrend.LENGTHENING
        }

        return CycleLengthAnalysis(avg, stdDev, trend, lengths, stdDev < 3.0)
    }

    // MARK: - Pearson Correlation

    fun pearsonR(pairs: List<Pair<Double, Double>>): Double {
        val n = pairs.size.toDouble()
        val sumX = pairs.sumOf { it.first }
        val sumY = pairs.sumOf { it.second }
        val sumXY = pairs.sumOf { it.first * it.second }
        val sumX2 = pairs.sumOf { it.first.pow(2) }
        val sumY2 = pairs.sumOf { it.second.pow(2) }

        val numerator = n * sumXY - sumX * sumY
        val denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        return if (denominator > 0) numerator / denominator else 0.0
    }

    // MARK: - Period Prediction (Weighted Average)

    fun predictNextPeriod(analysis: CycleLengthAnalysis, lastPeriodStartMs: Long): PredictionResult? {
        if (analysis.lengths.size < 2) return null

        val weights = analysis.lengths.indices.map { it + 1.0 }
        val totalWeight = weights.sum()
        val weightedAvg = analysis.lengths.zip(weights).sumOf { it.first * it.second } / totalWeight

        val predictedMs = lastPeriodStartMs + (weightedAvg * 86_400_000).toLong()
        val confidence = (1.0 - analysis.stdDeviation / 10.0).coerceIn(0.35, 0.85)
        val range = analysis.stdDeviation.toInt().coerceAtLeast(1)

        val reasoning = buildString {
            append("Moyenne pondérée de ${analysis.lengths.size} cycles: ${"%.1f".format(weightedAvg)}j. ")
            append("Écart-type: ${"%.1f".format(analysis.stdDeviation)}j. ")
            append(if (analysis.isRegular) "Cycle régulier → haute fiabilité." else "Cycle irrégulier → fiabilité réduite.")
        }

        return PredictionResult(
            type = "period_start",
            predictedDateMs = predictedMs,
            confidence = confidence,
            confidenceRange = range,
            reasoning = reasoning
        )
    }

    data class PredictionResult(
        val type: String,
        val predictedDateMs: Long,
        val confidence: Double,
        val confidenceRange: Int,
        val reasoning: String
    )
}

/**
 * ML Engine — Android (TFLite)
 * S4-4: On-device inference, auto-transition Rules→ML at 14+ days
 */
class MLEngine {

    enum class EngineMode { RULE_BASED, ML_POWERED, FALLBACK }

    var mode: EngineMode = EngineMode.RULE_BASED
        private set

    var modelVersion: String = "rule_v1"
        private set

    private val patternEngine = PatternDetectionEngine()

    fun loadModelIfReady(daysSinceOnboarding: Int) {
        if (daysSinceOnboarding < 14) {
            mode = EngineMode.RULE_BASED
            return
        }

        // Attempt TFLite model load
        try {
            // TODO: Load TFLite model from assets
            // val model = Interpreter(loadModelFile(context, "shifai_cycle_v1.tflite"))
            // mode = EngineMode.ML_POWERED
            // modelVersion = "ml_v1"

            // For now, stay rule-based
            mode = EngineMode.RULE_BASED
        } catch (e: Exception) {
            mode = EngineMode.FALLBACK
        }
    }

    fun predict(entries: List<CycleEntry>, lastPeriodStartMs: Long): MLPredictionResult {
        val analysis = patternEngine.analyzeCycleLengths(entries)
        val periodPrediction = patternEngine.predictNextPeriod(analysis, lastPeriodStartMs)

        return MLPredictionResult(
            periodPrediction = periodPrediction,
            analysis = analysis,
            source = mode.name
        )
    }

    data class MLPredictionResult(
        val periodPrediction: PatternDetectionEngine.PredictionResult?,
        val analysis: PatternDetectionEngine.CycleLengthAnalysis,
        val source: String
    )
}
