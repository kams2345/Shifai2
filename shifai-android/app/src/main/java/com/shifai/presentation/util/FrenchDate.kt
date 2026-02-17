package com.shifai.presentation.util

import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.util.Locale

/**
 * French Date Formatters — centralized date formatting.
 * All formats use French locale.
 * Mirrors iOS FrenchDate.swift.
 */
object FrenchDate {

    private val frenchLocale = Locale.FRANCE

    // ─── Formatters ───

    /** "14 février 2026" */
    val full: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMMM yyyy", frenchLocale)

    /** "14 fév. 2026" */
    val medium: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM yyyy", frenchLocale)

    /** "14/02/2026" */
    val short: DateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy", frenchLocale)

    /** "Lundi 14 février" */
    val dayAndMonth: DateTimeFormatter = DateTimeFormatter.ofPattern("EEEE d MMMM", frenchLocale)

    /** "Fév. 2026" */
    val monthYear: DateTimeFormatter = DateTimeFormatter.ofPattern("MMM yyyy", frenchLocale)

    /** "14:30" */
    val time: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm", frenchLocale)

    // ─── Convenience ───

    fun cycleDay(day: Int, phase: String): String = "Jour $day — $phase"

    fun daysUntil(date: LocalDate): String {
        val days = ChronoUnit.DAYS.between(LocalDate.now(), date).toInt()
        return when {
            days == 0 -> "Aujourd'hui"
            days == 1 -> "Demain"
            days > 1 -> "Dans $days jours"
            days == -1 -> "Hier"
            else -> "Il y a ${-days} jours"
        }
    }

    fun formatFull(date: LocalDate): String = date.format(full)
    fun formatShort(date: LocalDate): String = date.format(short)
    fun formatTime(time: LocalTime): String = time.format(this.time)
}
