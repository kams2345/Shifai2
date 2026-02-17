package com.shifai.domain.models

import org.junit.Assert.*
import org.junit.Test

class ModelsTest {

    // ─── CycleEntry ───

    @Test
    fun `CycleEntry has auto-generated UUID`() {
        val entry = CycleEntry(date = "2026-02-12")
        assertNotNull(entry.id)
        assertTrue(entry.id.isNotEmpty())
    }

    @Test
    fun `CycleEntry default sync status is PENDING`() {
        val entry = CycleEntry(date = "2026-02-12")
        assertEquals(SyncStatus.PENDING, entry.syncStatus)
    }

    // ─── CyclePhase ───

    @Test
    fun `CyclePhase fromString parses correctly`() {
        assertEquals(CyclePhase.MENSTRUAL, CyclePhase.fromString("menstrual"))
        assertEquals(CyclePhase.FOLLICULAR, CyclePhase.fromString("follicular"))
        assertEquals(CyclePhase.OVULATORY, CyclePhase.fromString("ovulatory"))
        assertEquals(CyclePhase.LUTEAL, CyclePhase.fromString("luteal"))
    }

    @Test
    fun `CyclePhase fromString returns null for unknown`() {
        assertNull(CyclePhase.fromString("invalid"))
    }

    @Test
    fun `CyclePhase has displayName and emoji`() {
        assertEquals("Menstruelle", CyclePhase.MENSTRUAL.displayName)
        assertEquals("🔴", CyclePhase.MENSTRUAL.emoji)
    }

    // ─── SymptomCategory ───

    @Test
    fun `SymptomCategory has 17 entries`() {
        assertEquals(17, SymptomCategory.values().size)
    }

    @Test
    fun `SymptomCategory display names are in French`() {
        assertEquals("Humeur", SymptomCategory.MOOD.displayName)
        assertEquals("Sommeil", SymptomCategory.SLEEP.displayName)
    }

    // ─── BodyZone ───

    @Test
    fun `BodyZone has 5 zones`() {
        assertEquals(5, BodyZone.values().size)
    }

    // ─── InsightType ───

    @Test
    fun `InsightType has 4 types`() {
        assertEquals(4, InsightType.values().size)
    }

    // ─── Prediction ───

    @Test
    fun `Prediction confidence is stored correctly`() {
        val pred = Prediction(
            type = PredictionType.PERIOD_START,
            confidence = 0.85,
            modelVersion = "v1"
        )
        assertEquals(0.85, pred.confidence, 0.001)
    }

    @Test
    fun `PredictionType has 4 types`() {
        assertEquals(4, PredictionType.values().size)
    }

    // ─── UserProfile ───

    @Test
    fun `UserProfile defaults are correct`() {
        val profile = UserProfile()
        assertFalse(profile.onboardingCompleted)
        assertEquals(CycleType.UNKNOWN, profile.cycleType)
        assertTrue(profile.conditions.isEmpty())
    }

    @Test
    fun `UserPreferences defaults are correct`() {
        val prefs = UserPreferences()
        assertEquals(300, prefs.autoLockSeconds)
        assertTrue(prefs.notificationsEnabled)
        assertFalse(prefs.cloudSyncEnabled)
        assertFalse(prefs.biometricEnabled)
        assertEquals(9, prefs.preferredNotificationHour)
        assertEquals("fr", prefs.locale)
    }

    // ─── Condition ───

    @Test
    fun `Condition has SOPK and endometriosis`() {
        assertEquals("SOPK", Condition.SOPK.displayName)
        assertEquals("Endométriose", Condition.ENDOMETRIOSIS.displayName)
    }

    // ─── SyncStatus ───

    @Test
    fun `SyncStatus has 3 states`() {
        assertEquals(3, SyncStatus.values().size)
    }
}
