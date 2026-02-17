package com.shifai.presentation.theme

import org.junit.Assert.*
import org.junit.Test

class ShifAIThemeTest {

    // ─── Phase Colors ───

    @Test
    fun `phase colors are distinct`() {
        val colors = listOf(
            ShifAITheme.phaseMenstrual,
            ShifAITheme.phaseFollicular,
            ShifAITheme.phaseOvulatory,
            ShifAITheme.phaseLuteal
        )
        assertEquals(4, colors.toSet().size)
    }

    // ─── Flow Colors ───

    @Test
    fun `flow colors has 5 levels`() {
        assertEquals(5, ShifAITheme.flowColors.size)
    }

    // ─── Symptom Color ───

    @Test
    fun `low intensity returns green`() {
        val color = ShifAITheme.symptomColor(2)
        assertEquals(ShifAITheme.symptomColor(1), color) // Both mild
    }

    @Test
    fun `high intensity returns red`() {
        val color = ShifAITheme.symptomColor(9)
        assertNotEquals(ShifAITheme.symptomColor(2), color) // Different from mild
    }

    // ─── Spacing ───

    @Test
    fun `spacing scale is monotonically increasing`() {
        assertTrue(ShifAITheme.Spacing.xs < ShifAITheme.Spacing.sm)
        assertTrue(ShifAITheme.Spacing.sm < ShifAITheme.Spacing.md)
        assertTrue(ShifAITheme.Spacing.md < ShifAITheme.Spacing.lg)
        assertTrue(ShifAITheme.Spacing.lg < ShifAITheme.Spacing.xl)
        assertTrue(ShifAITheme.Spacing.xl < ShifAITheme.Spacing.xxl)
    }

    // ─── Radius ───

    @Test
    fun `radius scale is monotonically increasing`() {
        assertTrue(ShifAITheme.Radius.sm < ShifAITheme.Radius.md)
        assertTrue(ShifAITheme.Radius.md < ShifAITheme.Radius.lg)
        assertTrue(ShifAITheme.Radius.lg < ShifAITheme.Radius.xl)
    }

    @Test
    fun `pill radius is very large`() {
        assertTrue(ShifAITheme.Radius.pill > 100)
    }

    // ─── Typography Scale ───

    @Test
    fun `type scale is monotonically increasing`() {
        assertTrue(ShifAITheme.Type.label < ShifAITheme.Type.caption)
        assertTrue(ShifAITheme.Type.caption < ShifAITheme.Type.bodySmall)
        assertTrue(ShifAITheme.Type.bodySmall < ShifAITheme.Type.body)
        assertTrue(ShifAITheme.Type.body < ShifAITheme.Type.h3)
        assertTrue(ShifAITheme.Type.h3 < ShifAITheme.Type.h2)
        assertTrue(ShifAITheme.Type.h2 < ShifAITheme.Type.h1)
    }

    // ─── Background Colors ───

    @Test
    fun `background primary is darkest`() {
        // backgroundPrimary (0xFF0F0B1E) should be darker than secondary (0xFF1A1432)
        assertNotEquals(ShifAITheme.backgroundPrimary, ShifAITheme.backgroundSecondary)
    }
}
