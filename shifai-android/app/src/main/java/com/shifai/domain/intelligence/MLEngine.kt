package com.shifai.domain.intelligence

import android.content.Context
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

/**
 * ML Engine — TensorFlow Lite on-device inference.
 * Mirrors iOS MLEngine.swift for cross-platform parity.
 *
 * Uses a 200KB MLP model for cycle prediction.
 * Auto-transitions from rule-based to ML after 3 cycles.
 */
class MLEngine(private val context: Context) {

    companion object {
        private const val TAG = "MLEngine"
        private const val MODEL_FILENAME = "cycle_predictor.tflite"
        private const val MIN_CYCLES_FOR_ML = 3
        private const val FEATURE_VECTOR_SIZE = 30
    }

    private var interpreter: Interpreter? = null
    private var isModelLoaded = false

    // ─── Lifecycle ───

    fun loadModel(): Boolean {
        return try {
            val modelBuffer = loadModelFile()
            interpreter = Interpreter(modelBuffer)
            isModelLoaded = true
            Log.i(TAG, "✅ Model loaded: $MODEL_FILENAME")
            true
        } catch (e: Exception) {
            Log.w(TAG, "⚠️ Model not found — using rule-based engine: ${e.message}")
            isModelLoaded = false
            false
        }
    }

    fun close() {
        interpreter?.close()
        interpreter = null
        isModelLoaded = false
    }

    // ─── Prediction ───

    /**
     * Predict next period start date.
     * Input: feature vector of last N cycle lengths + symptom patterns
     * Output: predicted days until next period
     */
    fun predictNextPeriod(featureVector: FloatArray): MLPrediction? {
        if (!isModelLoaded || interpreter == null) return null
        if (featureVector.size != FEATURE_VECTOR_SIZE) {
            Log.w(TAG, "Invalid feature vector size: ${featureVector.size}, expected $FEATURE_VECTOR_SIZE")
            return null
        }

        return try {
            val input = arrayOf(featureVector)
            val output = Array(1) { FloatArray(1) }
            interpreter!!.run(input, output)

            val predictedDays = output[0][0]
            MLPrediction(
                predictedDays = predictedDays.toInt(),
                confidence = calculateConfidence(featureVector),
                modelVersion = "mlp_v1"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Inference failed: ${e.message}")
            null
        }
    }

    // ─── Feature Vector ───

    /**
     * Build feature vector from historical data.
     * [0-9]   Last 10 cycle lengths
     * [10-19] Last 10 average symptom intensities per cycle
     * [20-24] Last 5 mood averages
     * [25-29] Last 5 energy averages
     */
    fun buildFeatureVector(
        cycleLengths: List<Int>,
        symptomIntensities: List<Float>,
        moodAverages: List<Float>,
        energyAverages: List<Float>
    ): FloatArray {
        val vector = FloatArray(FEATURE_VECTOR_SIZE)

        // Cycle lengths (padded with 28 if insufficient data)
        for (i in 0 until 10) {
            vector[i] = (cycleLengths.getOrNull(i) ?: 28).toFloat()
        }
        // Symptom intensities (padded with 0)
        for (i in 0 until 10) {
            vector[10 + i] = symptomIntensities.getOrNull(i) ?: 0f
        }
        // Mood (padded with 5)
        for (i in 0 until 5) {
            vector[20 + i] = moodAverages.getOrNull(i) ?: 5f
        }
        // Energy (padded with 5)
        for (i in 0 until 5) {
            vector[25 + i] = energyAverages.getOrNull(i) ?: 5f
        }

        return vector
    }

    // ─── Readiness ───

    fun shouldUseML(completedCycles: Int): Boolean =
        isModelLoaded && completedCycles >= MIN_CYCLES_FOR_ML

    fun getStatus(): EngineStatus = when {
        !isModelLoaded -> EngineStatus.RULE_BASED
        else -> EngineStatus.ML_ACTIVE
    }

    // ─── Private ───

    private fun loadModelFile(): MappedByteBuffer {
        val fd = context.assets.openFd(MODEL_FILENAME)
        val inputStream = FileInputStream(fd.fileDescriptor)
        val channel = inputStream.channel
        return channel.map(FileChannel.MapMode.READ_ONLY, fd.startOffset, fd.declaredLength)
    }

    private fun calculateConfidence(features: FloatArray): Double {
        // Higher confidence with more data (fewer zero-padded features)
        val nonZeroCount = features.count { it != 0f && it != 28f && it != 5f }
        return (nonZeroCount.toDouble() / FEATURE_VECTOR_SIZE).coerceIn(0.4, 0.95)
    }

    // ─── Models ───

    data class MLPrediction(
        val predictedDays: Int,
        val confidence: Double,
        val modelVersion: String
    )

    enum class EngineStatus {
        RULE_BASED,
        ML_ACTIVE
    }
}
