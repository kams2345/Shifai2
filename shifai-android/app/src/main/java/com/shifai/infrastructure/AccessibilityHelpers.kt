package com.shifai.infrastructure

import android.content.Context
import android.view.View
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager
import androidx.compose.ui.semantics.SemanticsPropertyKey
import androidx.compose.ui.semantics.SemanticsPropertyReceiver

/**
 * Accessibility helpers — mirrors iOS AccessibilityHelpers.swift.
 * WCAG 2.1 AA compliance utilities for Compose screens.
 */
object AccessibilityHelpers {

    // ─── Semantic Labels ───

    /**
     * Cycle day announcement for screen readers.
     * Example: "Jour 14 sur 28 - Phase ovulatoire"
     */
    fun cycleLabel(day: Int, total: Int, phase: String): String =
        "Jour $day sur $total - Phase $phase"

    /**
     * Symptom intensity label.
     * Example: "Crampes, intensité 7 sur 10"
     */
    fun symptomLabel(name: String, intensity: Int): String =
        "$name, intensité $intensity sur 10"

    /**
     * Slider value announcement.
     * Example: "Humeur : 8 sur 10"
     */
    fun sliderLabel(name: String, value: Int, max: Int = 10): String =
        "$name : $value sur $max"

    /**
     * Flow intensity label.
     * Example: "Flux : moyen"
     */
    fun flowLabel(intensity: Int): String {
        val label = when (intensity) {
            0 -> "aucun"
            1 -> "léger"
            2 -> "moyen"
            3 -> "abondant"
            4 -> "très abondant"
            else -> "inconnu"
        }
        return "Flux : $label"
    }

    /**
     * Prediction confidence label.
     * Example: "Confiance : 85 %"
     */
    fun confidenceLabel(confidence: Double): String {
        val percent = (confidence * 100).toInt()
        return "Confiance : $percent %"
    }

    /**
     * Insight type label.
     * Example: "Recommandation - Confiance 90 %"
     */
    fun insightLabel(type: String, confidence: Double?): String {
        val confStr = confidence?.let { " - Confiance ${(it * 100).toInt()} %" } ?: ""
        return "$type$confStr"
    }

    // ─── Minimum Touch Target ───

    /** WCAG 2.1 minimum touch target: 44dp × 44dp */
    const val MIN_TOUCH_TARGET_DP = 44

    // ─── Contrast Checks ───

    /**
     * WCAG 2.1 AA requires minimum 4.5:1 contrast for normal text
     * and 3:1 for large text (>= 18sp or >= 14sp bold).
     */
    fun meetsContrastAA(foreground: Long, background: Long): Boolean {
        val ratio = calculateContrastRatio(foreground, background)
        return ratio >= 4.5
    }

    fun meetsContrastAALargeText(foreground: Long, background: Long): Boolean {
        val ratio = calculateContrastRatio(foreground, background)
        return ratio >= 3.0
    }

    private fun calculateContrastRatio(color1: Long, color2: Long): Double {
        val l1 = relativeLuminance(color1)
        val l2 = relativeLuminance(color2)
        val lighter = maxOf(l1, l2)
        val darker = minOf(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private fun relativeLuminance(color: Long): Double {
        val r = linearize(((color shr 16) and 0xFF).toDouble() / 255.0)
        val g = linearize(((color shr 8) and 0xFF).toDouble() / 255.0)
        val b = linearize((color and 0xFF).toDouble() / 255.0)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private fun linearize(value: Double): Double =
        if (value <= 0.03928) value / 12.92
        else Math.pow((value + 0.055) / 1.055, 2.4)

    // ─── Announcements ───

    fun announce(context: Context, message: String) {
        val manager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
        if (manager?.isEnabled == true) {
            val event = AccessibilityEvent.obtain(AccessibilityEvent.TYPE_ANNOUNCEMENT)
            event.text.add(message)
            manager.sendAccessibilityEvent(event)
        }
    }
}
