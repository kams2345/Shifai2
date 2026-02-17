package com.shifai.domain.intelligence

import org.junit.Assert.*
import org.junit.Test

class MLEngineTest {

    // ─── Feature Vector ───

    @Test
    fun `buildFeatureVector returns correct size`() {
        val engine = createTestEngine()
        val vector = engine.buildFeatureVector(
            cycleLengths = listOf(28, 27, 29),
            symptomIntensities = listOf(3f, 5f),
            moodAverages = listOf(7f),
            energyAverages = listOf(6f)
        )
        assertEquals(30, vector.size)
    }

    @Test
    fun `feature vector pads missing cycles with 28`() {
        val engine = createTestEngine()
        val vector = engine.buildFeatureVector(
            cycleLengths = listOf(30),
            symptomIntensities = emptyList(),
            moodAverages = emptyList(),
            energyAverages = emptyList()
        )
        assertEquals(30f, vector[0]) // actual
        assertEquals(28f, vector[1]) // padded
        assertEquals(28f, vector[9]) // padded
    }

    @Test
    fun `feature vector pads missing symptoms with 0`() {
        val engine = createTestEngine()
        val vector = engine.buildFeatureVector(
            cycleLengths = emptyList(),
            symptomIntensities = listOf(5f),
            moodAverages = emptyList(),
            energyAverages = emptyList()
        )
        assertEquals(5f, vector[10]) // actual
        assertEquals(0f, vector[11]) // padded
    }

    @Test
    fun `feature vector pads missing mood with 5`() {
        val engine = createTestEngine()
        val vector = engine.buildFeatureVector(
            cycleLengths = emptyList(),
            symptomIntensities = emptyList(),
            moodAverages = listOf(8f),
            energyAverages = emptyList()
        )
        assertEquals(8f, vector[20]) // actual
        assertEquals(5f, vector[21]) // padded
    }

    // ─── Readiness ───

    @Test
    fun `shouldUseML returns false with less than 3 cycles`() {
        val engine = createTestEngine()
        assertFalse(engine.shouldUseML(completedCycles = 2))
    }

    @Test
    fun `shouldUseML returns false when model not loaded`() {
        val engine = createTestEngine()
        assertFalse(engine.shouldUseML(completedCycles = 5))
    }

    @Test
    fun `getStatus returns RULE_BASED when model not loaded`() {
        val engine = createTestEngine()
        assertEquals(MLEngine.EngineStatus.RULE_BASED, engine.getStatus())
    }

    // ─── Prediction ───

    @Test
    fun `predictNextPeriod returns null when model not loaded`() {
        val engine = createTestEngine()
        val result = engine.predictNextPeriod(FloatArray(30))
        assertNull(result)
    }

    @Test
    fun `predictNextPeriod returns null with wrong vector size`() {
        val engine = createTestEngine()
        val result = engine.predictNextPeriod(FloatArray(10))
        assertNull(result)
    }

    // ─── MLPrediction data class ───

    @Test
    fun `MLPrediction holds correct values`() {
        val prediction = MLEngine.MLPrediction(
            predictedDays = 8,
            confidence = 0.75,
            modelVersion = "mlp_v1"
        )
        assertEquals(8, prediction.predictedDays)
        assertEquals(0.75, prediction.confidence, 0.001)
        assertEquals("mlp_v1", prediction.modelVersion)
    }

    // Helper: create engine without Android context (for pure unit tests)
    private fun createTestEngine(): MLEngine {
        // Using reflection to create without context for unit testing
        return try {
            val constructor = MLEngine::class.java.getDeclaredConstructor(android.content.Context::class.java)
            constructor.isAccessible = true
            constructor.newInstance(null)
        } catch (e: Exception) {
            // Fallback: create a minimal mock
            MLEngine::class.java.getDeclaredConstructor(android.content.Context::class.java)
                .apply { isAccessible = true }
                .newInstance(null)
        }
    }
}
