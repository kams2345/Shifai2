package com.shifai.domain.intelligence

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class PatternDetectionEngineTest {

    private lateinit var engine: PatternDetectionEngine

    @Before
    fun setUp() {
        engine = PatternDetectionEngine()
    }

    // ─── Cycle Length ───

    @Test
    fun `calculateAverageCycleLength with regular cycle returns 28`() {
        val lengths = listOf(28, 27, 29, 28, 28)
        val avg = engine.calculateAverageCycleLength(lengths)
        assertEquals(28.0, avg, 0.5)
    }

    @Test
    fun `calculateAverageCycleLength with single length returns it`() {
        val avg = engine.calculateAverageCycleLength(listOf(30))
        assertEquals(30.0, avg, 0.1)
    }

    @Test
    fun `calculateAverageCycleLength with empty list returns null`() {
        assertNull(engine.calculateAverageCycleLength(emptyList()))
    }

    // ─── Regularity ───

    @Test
    fun `isRegular with consistent lengths returns true`() {
        assertTrue(engine.isRegular(listOf(28, 27, 29, 28)))
    }

    @Test
    fun `isRegular with wide variation returns false`() {
        assertFalse(engine.isRegular(listOf(21, 35, 28, 40)))
    }

    // ─── Phase Detection ───

    @Test
    fun `detectPhase day 1 is menstrual`() {
        assertEquals("menstrual", engine.detectPhase(1, 28))
    }

    @Test
    fun `detectPhase day 8 is follicular`() {
        assertEquals("follicular", engine.detectPhase(8, 28))
    }

    @Test
    fun `detectPhase day 14 is ovulatory`() {
        assertEquals("ovulatory", engine.detectPhase(14, 28))
    }

    @Test
    fun `detectPhase day 21 is luteal`() {
        assertEquals("luteal", engine.detectPhase(21, 28))
    }

    // ─── Correlation ───

    @Test
    fun `pearsonCorrelation perfect positive is 1`() {
        val x = doubleArrayOf(1.0, 2.0, 3.0, 4.0, 5.0)
        val y = doubleArrayOf(2.0, 4.0, 6.0, 8.0, 10.0)
        assertEquals(1.0, engine.pearsonCorrelation(x, y), 0.001)
    }

    @Test
    fun `pearsonCorrelation perfect negative is -1`() {
        val x = doubleArrayOf(1.0, 2.0, 3.0, 4.0, 5.0)
        val y = doubleArrayOf(10.0, 8.0, 6.0, 4.0, 2.0)
        assertEquals(-1.0, engine.pearsonCorrelation(x, y), 0.001)
    }

    @Test
    fun `pearsonCorrelation single point returns 0`() {
        assertEquals(0.0, engine.pearsonCorrelation(doubleArrayOf(1.0), doubleArrayOf(1.0)), 0.001)
    }

    // ─── Prediction ───

    @Test
    fun `predictNextPeriod returns future date`() {
        val daysAgo = 20L
        val lastPeriodMillis = System.currentTimeMillis() - (daysAgo * 86400000)
        val prediction = engine.predictNextPeriod(lastPeriodMillis, 28.0)

        assertNotNull(prediction)
        assertTrue("Prediction should be in the future", prediction!! > System.currentTimeMillis())
    }
}
