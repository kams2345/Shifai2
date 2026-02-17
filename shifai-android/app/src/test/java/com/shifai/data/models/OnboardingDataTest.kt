package com.shifai.data.models

import org.junit.Assert.*
import org.junit.Test

class OnboardingDataTest {

    @Test
    fun `default cycle length is 28`() {
        val data = OnboardingData()
        assertEquals(28, data.cycleLength)
    }

    @Test
    fun `default period length is 5`() {
        val data = OnboardingData()
        assertEquals(5, data.periodLength)
    }

    @Test
    fun `default goal is track cycle`() {
        val data = OnboardingData()
        assertEquals(OnboardingData.Goal.TRACK_CYCLE, data.goals.first())
    }

    @Test
    fun `notifications enabled by default`() {
        assertTrue(OnboardingData().notificationsEnabled)
    }

    @Test
    fun `health connect disabled by default`() {
        assertFalse(OnboardingData().healthConnectEnabled)
    }

    @Test
    fun `cycle length clamped to min 21`() {
        val data = OnboardingData(cycleLength = 15).validated()
        assertEquals(21, data.cycleLength)
    }

    @Test
    fun `cycle length clamped to max 45`() {
        val data = OnboardingData(cycleLength = 60).validated()
        assertEquals(45, data.cycleLength)
    }

    @Test
    fun `period length clamped to min 2`() {
        val data = OnboardingData(periodLength = 1).validated()
        assertEquals(2, data.periodLength)
    }

    @Test
    fun `period length clamped to max 10`() {
        val data = OnboardingData(periodLength = 15).validated()
        assertEquals(10, data.periodLength)
    }

    @Test
    fun `six goals exist`() {
        assertEquals(6, OnboardingData.Goal.values().size)
    }
}
