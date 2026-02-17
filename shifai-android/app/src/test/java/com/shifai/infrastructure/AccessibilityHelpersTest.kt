package com.shifai.infrastructure

import org.junit.Assert.*
import org.junit.Test

class AccessibilityHelpersTest {

    // ─── Semantic Labels ───

    @Test
    fun `cycleLabel formats correctly`() {
        val label = AccessibilityHelpers.cycleLabel(14, 28, "ovulatoire")
        assertEquals("Jour 14 sur 28 - Phase ovulatoire", label)
    }

    @Test
    fun `symptomLabel formats correctly`() {
        val label = AccessibilityHelpers.symptomLabel("Crampes", 7)
        assertEquals("Crampes, intensité 7 sur 10", label)
    }

    @Test
    fun `sliderLabel formats correctly`() {
        val label = AccessibilityHelpers.sliderLabel("Humeur", 8)
        assertEquals("Humeur : 8 sur 10", label)
    }

    @Test
    fun `flowLabel maps all intensities`() {
        assertEquals("Flux : aucun", AccessibilityHelpers.flowLabel(0))
        assertEquals("Flux : léger", AccessibilityHelpers.flowLabel(1))
        assertEquals("Flux : moyen", AccessibilityHelpers.flowLabel(2))
        assertEquals("Flux : abondant", AccessibilityHelpers.flowLabel(3))
        assertEquals("Flux : très abondant", AccessibilityHelpers.flowLabel(4))
        assertEquals("Flux : inconnu", AccessibilityHelpers.flowLabel(99))
    }

    @Test
    fun `confidenceLabel formats percentage`() {
        assertEquals("Confiance : 85 %", AccessibilityHelpers.confidenceLabel(0.85))
        assertEquals("Confiance : 0 %", AccessibilityHelpers.confidenceLabel(0.0))
        assertEquals("Confiance : 100 %", AccessibilityHelpers.confidenceLabel(1.0))
    }

    @Test
    fun `insightLabel with confidence`() {
        val label = AccessibilityHelpers.insightLabel("Prédiction", 0.9)
        assertEquals("Prédiction - Confiance 90 %", label)
    }

    @Test
    fun `insightLabel without confidence`() {
        val label = AccessibilityHelpers.insightLabel("Recommandation", null)
        assertEquals("Recommandation", label)
    }

    // ─── Touch Target ───

    @Test
    fun `minimum touch target is 44dp`() {
        assertEquals(44, AccessibilityHelpers.MIN_TOUCH_TARGET_DP)
    }

    // ─── Contrast ───

    @Test
    fun `white on black meets AA`() {
        assertTrue(AccessibilityHelpers.meetsContrastAA(0xFFFFFF, 0x000000))
    }

    @Test
    fun `black on white meets AA`() {
        assertTrue(AccessibilityHelpers.meetsContrastAA(0x000000, 0xFFFFFF))
    }

    @Test
    fun `similar colors fail AA`() {
        // Light gray on white
        assertFalse(AccessibilityHelpers.meetsContrastAA(0xCCCCCC, 0xFFFFFF))
    }

    @Test
    fun `large text has relaxed ratio`() {
        // Medium gray on white may pass large text but fail normal
        val passes = AccessibilityHelpers.meetsContrastAALargeText(0x767676, 0xFFFFFF)
        // 0x767676 on white is ~4.54:1, which passes both
        assertTrue(passes)
    }
}
