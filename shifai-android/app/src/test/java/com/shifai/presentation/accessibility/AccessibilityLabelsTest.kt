package com.shifai.presentation.accessibility

import org.junit.Assert.*
import org.junit.Test

class AccessibilityLabelsTest {

    @Test
    fun `dashboard cycle day label`() {
        assertEquals("Jour du cycle", AccessibilityLabels.Dashboard.CYCLE_DAY)
    }

    @Test
    fun `tracking save button`() {
        assertEquals("Enregistrer les données du jour", AccessibilityLabels.Tracking.SAVE_BUTTON)
    }

    @Test
    fun `tracking body map`() {
        assertEquals("Carte corporelle interactive", AccessibilityLabels.Tracking.BODY_MAP)
    }

    @Test
    fun `insights filter menu`() {
        assertEquals("Filtrer les analyses", AccessibilityLabels.Insights.FILTER_MENU)
    }

    @Test
    fun `settings sync toggle`() {
        assertEquals("Synchronisation automatique", AccessibilityLabels.Settings.SYNC_TOGGLE)
    }

    @Test
    fun `settings delete hint contains irreversible`() {
        assertTrue(AccessibilityLabels.Settings.DELETE_HINT.contains("irréversible"))
    }

    @Test
    fun `common loading`() {
        assertEquals("Chargement en cours", AccessibilityLabels.Common.LOADING)
    }

    @Test
    fun `common retry`() {
        assertEquals("Réessayer", AccessibilityLabels.Common.RETRY)
    }

    @Test
    fun `flow slider hint`() {
        assertEquals("Ajustez entre 0 et 4", AccessibilityLabels.Tracking.FLOW_HINT)
    }

    @Test
    fun `all labels non empty`() {
        assertTrue(AccessibilityLabels.Dashboard.PHASE_INDICATOR.isNotEmpty())
        assertTrue(AccessibilityLabels.Tracking.FLOW_SLIDER.isNotEmpty())
    }
}
