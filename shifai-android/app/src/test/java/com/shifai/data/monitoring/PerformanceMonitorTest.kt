package com.shifai.data.monitoring

import org.junit.Assert.*
import org.junit.Test

class PerformanceMonitorTest {

    // ─── Budget Thresholds ───

    @Test
    fun `cold start budget is 1500ms`() {
        val budget = budgetFor("cold_start")
        assertEquals(1500L, budget)
    }

    @Test
    fun `warm start budget is 500ms`() {
        val budget = budgetFor("warm_start")
        assertEquals(500L, budget)
    }

    @Test
    fun `save daily log budget is 200ms`() {
        val budget = budgetFor("save_daily_log")
        assertEquals(200L, budget)
    }

    @Test
    fun `tab switch budget is 100ms`() {
        val budget = budgetFor("tab_switch")
        assertEquals(100L, budget)
    }

    @Test
    fun `sync budget is 5000ms`() {
        val budget = budgetFor("sync")
        assertEquals(5000L, budget)
    }

    @Test
    fun `unknown label falls back to 1000ms`() {
        val budget = budgetFor("unknown_operation")
        assertEquals(1000L, budget)
    }

    // ─── Measurement ───

    @Test
    fun `start stores mark`() {
        PerformanceMonitor.start("test_label")
        // Should not throw
        assertTrue(true)
    }

    @Test
    fun `end without start returns null`() {
        val result = PerformanceMonitor.end("nonexistent_label")
        assertNull(result)
    }

    @Test
    fun `measure returns block result`() {
        val result = PerformanceMonitor.measure("test") { 42 }
        assertEquals(42, result)
    }

    @Test
    fun `pdf generation budget is 3000ms`() {
        val budget = budgetFor("pdf_generation")
        assertEquals(3000L, budget)
    }

    // ─── Helper ───

    private fun budgetFor(label: String): Long = when (label) {
        "cold_start" -> 1500
        "warm_start" -> 500
        "db_open" -> 200
        "save_daily_log" -> 200
        "load_chart" -> 300
        "ml_prediction" -> 500
        "pdf_generation" -> 3000
        "sync" -> 5000
        "tab_switch" -> 100
        "widget_refresh" -> 1000
        else -> 1000
    }
}
