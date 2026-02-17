package com.shifai.presentation.insights

import org.junit.Assert.*
import org.junit.Test

class InsightsViewModelTest {

    @Test
    fun `initial filter is ALL`() {
        val vm = InsightsViewModel()
        assertEquals(InsightsViewModel.InsightFilter.ALL, vm.state.value.activeFilter)
    }

    @Test
    fun `initial ML status is rule-based`() {
        val vm = InsightsViewModel()
        assertEquals(InsightsViewModel.MLStatus.RULE_BASED, vm.state.value.mlStatus)
    }

    @Test
    fun `setFilter updates active filter`() {
        val vm = InsightsViewModel()
        vm.setFilter(InsightsViewModel.InsightFilter.PREDICTIONS)
        assertEquals(InsightsViewModel.InsightFilter.PREDICTIONS, vm.state.value.activeFilter)
    }

    @Test
    fun `setFilter to CORRELATIONS works`() {
        val vm = InsightsViewModel()
        vm.setFilter(InsightsViewModel.InsightFilter.CORRELATIONS)
        assertEquals(InsightsViewModel.InsightFilter.CORRELATIONS, vm.state.value.activeFilter)
    }

    @Test
    fun `setFilter to ALL resets filter`() {
        val vm = InsightsViewModel()
        vm.setFilter(InsightsViewModel.InsightFilter.PREDICTIONS)
        vm.setFilter(InsightsViewModel.InsightFilter.ALL)
        assertEquals(InsightsViewModel.InsightFilter.ALL, vm.state.value.activeFilter)
    }

    @Test
    fun `initial insights list is empty`() {
        val vm = InsightsViewModel()
        assertTrue(vm.state.value.insights.isEmpty())
    }
}
