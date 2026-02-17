package com.shifai.data.config

import org.junit.Assert.*
import org.junit.After
import org.junit.Test

class FeatureFlagsTest {

    @After
    fun tearDown() {
        FeatureFlags.reset()
    }

    // ─── Defaults ───

    @Test
    fun `ml predictions disabled by default`() {
        assertFalse(FeatureFlags.mlPredictions)
    }

    @Test
    fun `share links enabled by default`() {
        assertTrue(FeatureFlags.shareLinks)
    }

    @Test
    fun `cycle insights enabled by default`() {
        assertTrue(FeatureFlags.cycleInsights)
    }

    @Test
    fun `body map v2 disabled by default`() {
        assertFalse(FeatureFlags.bodyMapV2)
    }

    @Test
    fun `background sync enabled by default`() {
        assertTrue(FeatureFlags.backgroundSync)
    }

    // ─── Remote Override ───

    @Test
    fun `remote override enables flag`() {
        FeatureFlags.update(mapOf("ml_predictions" to true))
        assertTrue(FeatureFlags.mlPredictions)
    }

    @Test
    fun `remote override disables flag`() {
        FeatureFlags.update(mapOf("share_links" to false))
        assertFalse(FeatureFlags.shareLinks)
    }

    @Test
    fun `reset restores defaults`() {
        FeatureFlags.update(mapOf("ml_predictions" to true))
        FeatureFlags.reset()
        assertFalse(FeatureFlags.mlPredictions)
    }

    // ─── Unknown ───

    @Test
    fun `unknown flag returns false`() {
        assertFalse(FeatureFlags.isEnabled("nonexistent"))
    }

    @Test
    fun `csv export enabled by default`() {
        assertTrue(FeatureFlags.csvExport)
    }
}
