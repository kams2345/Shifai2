package com.shifai.presentation.dashboard

import org.junit.Assert.*
import org.junit.Test

class DashboardViewModelTest {

    @Test
    fun `initial state is loading`() {
        val vm = DashboardViewModel()
        assertTrue(vm.state.value.isLoading)
    }

    @Test
    fun `initial cycle day is 1`() {
        val vm = DashboardViewModel()
        assertEquals(1, vm.state.value.cycleDay)
    }

    @Test
    fun `initial cycle total is 28`() {
        val vm = DashboardViewModel()
        assertEquals(28, vm.state.value.cycleDayTotal)
    }

    @Test
    fun `initial phase is Folliculaire`() {
        val vm = DashboardViewModel()
        assertEquals("Folliculaire", vm.state.value.currentPhase)
    }

    @Test
    fun `hasLoggedToday defaults to false`() {
        val vm = DashboardViewModel()
        assertFalse(vm.state.value.hasLoggedToday)
    }

    @Test
    fun `markDayLogged updates state`() {
        val vm = DashboardViewModel()
        vm.markDayLogged()
        assertTrue(vm.state.value.hasLoggedToday)
    }

    @Test
    fun `updateCycleDay changes all cycle fields`() {
        val vm = DashboardViewModel()
        vm.updateCycleDay(day = 14, total = 30, phase = "Ovulatoire", emoji = "☀️")
        assertEquals(14, vm.state.value.cycleDay)
        assertEquals(30, vm.state.value.cycleDayTotal)
        assertEquals("Ovulatoire", vm.state.value.currentPhase)
        assertEquals("☀️", vm.state.value.phaseEmoji)
    }

    @Test
    fun `updateStats sets symptom count, sleep, mood`() {
        val vm = DashboardViewModel()
        vm.updateStats(symptoms = 5, sleep = 7.5f, mood = 8)
        assertEquals(5, vm.state.value.symptomCount)
        assertEquals(7.5f, vm.state.value.sleepHours)
        assertEquals(8, vm.state.value.moodScore)
    }
}
