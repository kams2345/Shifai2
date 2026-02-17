package com.shifai.data.export

import android.content.Context
import java.io.File
import java.time.LocalDate
import java.time.format.DateTimeFormatter

/**
 * CSV Exporter — exports user data for GDPR portability (Art. 20).
 * Mirrors iOS CSVExporter.swift.
 */
object CSVExporter {

    private val dateFormatter = DateTimeFormatter.ISO_LOCAL_DATE

    /**
     * Export cycle entries to CSV file.
     */
    fun exportCycleEntries(
        context: Context,
        entries: List<CycleEntryRow>
    ): File {
        val header = "date,cycle_day,phase,flow_intensity,mood_score,energy_score,sleep_hours,stress_level,notes\n"
        val rows = entries.joinToString("\n") { e ->
            val notes = e.notes.replace(",", ";").replace("\n", " ")
            "${e.date},${e.cycleDay},${e.phase},${e.flowIntensity},${e.moodScore},${e.energyScore},${e.sleepHours},${e.stressLevel},\"$notes\""
        }

        val file = File(context.cacheDir, "shifai_cycle_entries_${dateStamp()}.csv")
        file.writeText(header + rows)
        return file
    }

    /**
     * Export symptom logs to CSV file.
     */
    fun exportSymptomLogs(
        context: Context,
        symptoms: List<SymptomLogRow>
    ): File {
        val header = "cycle_entry_id,category,symptom_type,intensity,body_zone\n"
        val rows = symptoms.joinToString("\n") { s ->
            "${s.cycleEntryId},${s.category},${s.symptomType},${s.intensity},${s.bodyZone ?: ""}"
        }

        val file = File(context.cacheDir, "shifai_symptoms_${dateStamp()}.csv")
        file.writeText(header + rows)
        return file
    }

    private fun dateStamp(): String = LocalDate.now().format(dateFormatter)

    // ─── Data Transfer Objects ───

    data class CycleEntryRow(
        val date: String,
        val cycleDay: Int,
        val phase: String,
        val flowIntensity: Int,
        val moodScore: Int,
        val energyScore: Int,
        val sleepHours: Double,
        val stressLevel: Int,
        val notes: String
    )

    data class SymptomLogRow(
        val cycleEntryId: String,
        val category: String,
        val symptomType: String,
        val intensity: Int,
        val bodyZone: String?
    )
}
