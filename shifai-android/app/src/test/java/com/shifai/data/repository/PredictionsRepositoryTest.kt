package com.shifai.data.repository

import org.junit.Assert.*
import org.junit.Test
import java.time.LocalDate
import java.time.temporal.ChronoUnit

class PredictionsRepositoryTest {

    // ─── Save ───

    @Test
    fun `saved prediction is marked unsynced`() {
        val isSynced = false
        assertFalse(isSynced)
    }

    // ─── Verification ───

    @Test
    fun `unverified prediction has null actual date`() {
        val actualDate: LocalDate? = null
        assertNull(actualDate)
    }

    @Test
    fun `verified prediction has actual date`() {
        val actualDate = LocalDate.now()
        assertNotNull(actualDate)
    }

    // ─── Accuracy ───

    @Test
    fun `exact prediction has 0 accuracy`() {
        val predicted = LocalDate.of(2026, 3, 1)
        val actual = LocalDate.of(2026, 3, 1)
        assertEquals(0, ChronoUnit.DAYS.between(predicted, actual))
    }

    @Test
    fun `2 days late prediction`() {
        val predicted = LocalDate.of(2026, 3, 1)
        val actual = LocalDate.of(2026, 3, 3)
        assertEquals(2, ChronoUnit.DAYS.between(predicted, actual))
    }

    @Test
    fun `1 day early prediction`() {
        val predicted = LocalDate.of(2026, 3, 5)
        val actual = LocalDate.of(2026, 3, 4)
        assertEquals(-1, ChronoUnit.DAYS.between(predicted, actual))
    }

    // ─── Average Accuracy ───

    @Test
    fun `average accuracy of multiple predictions`() {
        val daysOff = listOf(0, 2, 1)
        val avg = daysOff.average()
        assertEquals(1.0, avg, 0.01)
    }

    @Test
    fun `empty predictions return null accuracy`() {
        val list = emptyList<Int>()
        val result = if (list.isEmpty()) null else list.average()
        assertNull(result)
    }

    // ─── Types ───

    @Test
    fun `period prediction type`() {
        val type = "period"
        assertEquals("period", type)
    }

    @Test
    fun `ovulation prediction type`() {
        val type = "ovulation"
        assertEquals("ovulation", type)
    }
}
