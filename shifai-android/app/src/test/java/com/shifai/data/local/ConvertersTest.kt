package com.shifai.data.local

import com.shifai.domain.models.*
import org.junit.Assert.*
import org.junit.Test

class ConvertersTest {

    private val converters = Converters()

    // ─── CyclePhase ───

    @Test
    fun `CyclePhase round-trips correctly`() {
        val original = CyclePhase.OVULATORY
        val stored = converters.fromCyclePhase(original)
        val restored = converters.toCyclePhase(stored)
        assertEquals(original, restored)
    }

    @Test
    fun `null CyclePhase round-trips`() {
        assertNull(converters.fromCyclePhase(null))
        assertNull(converters.toCyclePhase(null))
    }

    // ─── SymptomCategory ───

    @Test
    fun `SymptomCategory round-trips`() {
        val original = SymptomCategory.MOOD
        assertEquals(original, converters.toSymptomCategory(converters.fromSymptomCategory(original)))
    }

    // ─── BodyZone ───

    @Test
    fun `BodyZone round-trips`() {
        val original = BodyZone.HEAD
        assertEquals(original, converters.toBodyZone(converters.fromBodyZone(original)))
    }

    // ─── InsightType ───

    @Test
    fun `InsightType round-trips`() {
        val original = InsightType.PREDICTION
        assertEquals(original, converters.toInsightType(converters.fromInsightType(original)))
    }

    // ─── SyncStatus ───

    @Test
    fun `SyncStatus round-trips`() {
        val original = SyncStatus.SYNCED
        assertEquals(original, converters.toSyncStatus(converters.fromSyncStatus(original)))
    }

    // ─── List<String> ───

    @Test
    fun `String list round-trips`() {
        val original = listOf("a", "b", "c")
        val stored = converters.fromStringList(original)
        val restored = converters.toStringList(stored)
        assertEquals(original, restored)
    }

    @Test
    fun `empty list round-trips`() {
        val stored = converters.fromStringList(emptyList())
        assertEquals("", stored)
    }

    @Test
    fun `null list round-trips`() {
        assertNull(converters.fromStringList(null))
        assertNull(converters.toStringList(null))
    }

    // ─── List<Condition> ───

    @Test
    fun `Condition list round-trips`() {
        val original = listOf(Condition.SOPK, Condition.ENDOMETRIOSIS)
        val stored = converters.fromConditionList(original)
        val restored = converters.toConditionList(stored)
        assertEquals(original, restored)
    }

    // ─── PredictionType ───

    @Test
    fun `PredictionType round-trips`() {
        val original = PredictionType.PERIOD_START
        assertEquals(original, converters.toPredictionType(converters.fromPredictionType(original)))
    }
}
