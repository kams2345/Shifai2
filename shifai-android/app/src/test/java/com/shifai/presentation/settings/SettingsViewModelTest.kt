package com.shifai.presentation.settings

import org.junit.Assert.*
import org.junit.Test

class SettingsViewModelTest {

    @Test
    fun `initial sync is disabled`() {
        val vm = SettingsViewModel()
        assertFalse(vm.state.value.isSyncEnabled)
    }

    @Test
    fun `toggleSync enables sync`() {
        val vm = SettingsViewModel()
        vm.toggleSync(true)
        assertTrue(vm.state.value.isSyncEnabled)
    }

    @Test
    fun `all notifications enabled by default`() {
        val vm = SettingsViewModel()
        assertTrue(vm.state.value.notifCyclePrediction)
        assertTrue(vm.state.value.notifRecommendation)
        assertTrue(vm.state.value.notifQuickWin)
        assertTrue(vm.state.value.notifEducational)
    }

    @Test
    fun `toggleNotifCategory disables specific category`() {
        val vm = SettingsViewModel()
        vm.toggleNotifCategory("recommendation", false)
        assertFalse(vm.state.value.notifRecommendation)
        assertTrue(vm.state.value.notifCyclePrediction) // others unchanged
    }

    @Test
    fun `biometric defaults to false`() {
        val vm = SettingsViewModel()
        assertFalse(vm.state.value.biometricEnabled)
    }

    @Test
    fun `toggleBiometric enables biometric`() {
        val vm = SettingsViewModel()
        vm.toggleBiometric(true)
        assertTrue(vm.state.value.biometricEnabled)
    }

    @Test
    fun `analytics defaults to false`() {
        val vm = SettingsViewModel()
        assertFalse(vm.state.value.analyticsEnabled)
    }

    @Test
    fun `delete dialog hidden by default`() {
        val vm = SettingsViewModel()
        assertFalse(vm.state.value.showDeleteDialog)
    }

    @Test
    fun `showDeleteConfirmation opens dialog`() {
        val vm = SettingsViewModel()
        vm.showDeleteConfirmation()
        assertTrue(vm.state.value.showDeleteDialog)
    }

    @Test
    fun `dismissDeleteDialog closes dialog`() {
        val vm = SettingsViewModel()
        vm.showDeleteConfirmation()
        vm.dismissDeleteDialog()
        assertFalse(vm.state.value.showDeleteDialog)
    }
}
