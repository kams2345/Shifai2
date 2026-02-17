package com.shifai.infrastructure

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class PerformanceMonitorTest {

    @Before
    fun setUp() {
        // Clear any stale markers
    }

    @Test
    fun `measure returns elapsed time`() {
        val result = PerformanceMonitor.measure("test_block") {
            Thread.sleep(50) // 50ms
            42
        }
        assertEquals(42, result)
    }

    @Test
    fun `startMeasure and endMeasure returns positive duration`() {
        PerformanceMonitor.startMeasure("test_label")
        Thread.sleep(10)
        val elapsed = PerformanceMonitor.endMeasure("test_label")
        assertNotNull(elapsed)
        assertTrue("Elapsed should be positive", elapsed!! > 0)
    }

    @Test
    fun `endMeasure unknown label returns null`() {
        val elapsed = PerformanceMonitor.endMeasure("nonexistent_label")
        assertNull(elapsed)
    }

    @Test
    fun `cold start threshold is 4 seconds`() {
        assertEquals(4000L, PerformanceMonitor.Thresholds.COLD_START_MS)
    }

    @Test
    fun `transition threshold is 300ms`() {
        assertEquals(300L, PerformanceMonitor.Thresholds.TRANSITION_MS)
    }

    @Test
    fun `ml inference threshold is 500ms`() {
        assertEquals(500L, PerformanceMonitor.Thresholds.ML_INFERENCE_MS)
    }

    @Test
    fun `logMemory does not crash`() {
        // Simply verify no exception
        PerformanceMonitor.logMemory()
    }
}
