package com.shifai.presentation.util

import org.junit.Assert.*
import org.junit.Test
import java.time.LocalDate

class FrenchDateTest {

    // ─── Format Outputs ───

    @Test
    fun `short format uses slashes`() {
        val date = LocalDate.of(2026, 2, 17)
        val formatted = FrenchDate.formatShort(date)
        assertTrue(formatted.contains("/"))
    }

    @Test
    fun `full format contains year`() {
        val date = LocalDate.of(2026, 2, 17)
        val formatted = FrenchDate.formatFull(date)
        assertTrue(formatted.contains("2026"))
    }

    @Test
    fun `full format contains month name`() {
        val date = LocalDate.of(2026, 2, 17)
        val formatted = FrenchDate.formatFull(date)
        assertTrue(formatted.contains("fév") || formatted.contains("février"))
    }

    // ─── Cycle Day ───

    @Test
    fun `cycle day format`() {
        val result = FrenchDate.cycleDay(14, "folliculaire")
        assertEquals("Jour 14 — folliculaire", result)
    }

    @Test
    fun `cycle day 1`() {
        val result = FrenchDate.cycleDay(1, "menstruel")
        assertTrue(result.startsWith("Jour 1"))
    }

    // ─── Days Until ───

    @Test
    fun `days until today`() {
        val result = FrenchDate.daysUntil(LocalDate.now())
        assertEquals("Aujourd'hui", result)
    }

    @Test
    fun `days until tomorrow`() {
        val result = FrenchDate.daysUntil(LocalDate.now().plusDays(1))
        assertEquals("Demain", result)
    }

    @Test
    fun `days until future`() {
        val result = FrenchDate.daysUntil(LocalDate.now().plusDays(5))
        assertEquals("Dans 5 jours", result)
    }

    @Test
    fun `days until yesterday`() {
        val result = FrenchDate.daysUntil(LocalDate.now().minusDays(1))
        assertEquals("Hier", result)
    }

    @Test
    fun `days until past`() {
        val result = FrenchDate.daysUntil(LocalDate.now().minusDays(3))
        assertEquals("Il y a 3 jours", result)
    }
}
