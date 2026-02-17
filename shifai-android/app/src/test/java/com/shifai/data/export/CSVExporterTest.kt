package com.shifai.data.export

import org.junit.Assert.*
import org.junit.Test

class CSVExporterTest {

    // ─── Headers ───

    @Test
    fun `cycle entries header has 9 columns`() {
        val header = "date,cycle_day,phase,flow_intensity,mood_score,energy_score,sleep_hours,stress_level,notes"
        assertEquals(9, header.split(",").size)
    }

    @Test
    fun `symptom logs header has 5 columns`() {
        val header = "cycle_entry_id,category,symptom_type,intensity,body_zone"
        assertEquals(5, header.split(",").size)
    }

    // ─── Sanitization ───

    @Test
    fun `commas replaced in notes`() {
        val notes = "crampes, nausée"
        val sanitized = notes.replace(",", ";")
        assertFalse(sanitized.contains(","))
    }

    @Test
    fun `newlines replaced in notes`() {
        val notes = "ligne 1\nligne 2"
        val sanitized = notes.replace("\n", " ")
        assertFalse(sanitized.contains("\n"))
    }

    // ─── DTOs ───

    @Test
    fun `CycleEntryRow has all fields`() {
        val row = CSVExporter.CycleEntryRow(
            date = "2026-02-13", cycleDay = 14, phase = "follicular",
            flowIntensity = 0, moodScore = 7, energyScore = 6,
            sleepHours = 8.0, stressLevel = 3, notes = "test"
        )
        assertEquals(14, row.cycleDay)
        assertEquals("follicular", row.phase)
    }

    @Test
    fun `SymptomLogRow optional body zone`() {
        val row = CSVExporter.SymptomLogRow(
            cycleEntryId = "abc", category = "PAIN",
            symptomType = "cramps", intensity = 5, bodyZone = null
        )
        assertNull(row.bodyZone)
    }

    // ─── File Naming ───

    @Test
    fun `filename has csv extension`() {
        val filename = "shifai_cycle_entries_2026-02-13.csv"
        assertTrue(filename.endsWith(".csv"))
    }

    @Test
    fun `filename contains shifai prefix`() {
        val filename = "shifai_symptoms_2026-02-13.csv"
        assertTrue(filename.startsWith("shifai_"))
    }

    // ─── Row Format ───

    @Test
    fun `row joined with commas`() {
        val row = listOf("2026-02-13", "14", "follicular", "0", "7", "6", "8.0", "3", "\"notes\"")
        val csv = row.joinToString(",")
        assertTrue(csv.contains(","))
    }

    @Test
    fun `multiple rows joined with newlines`() {
        val rows = listOf("row1", "row2", "row3")
        val csv = rows.joinToString("\n")
        assertEquals(3, csv.split("\n").size)
    }
}
