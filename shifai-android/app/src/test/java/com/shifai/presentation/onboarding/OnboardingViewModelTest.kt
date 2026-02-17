package com.shifai.presentation.onboarding

import com.shifai.domain.models.Condition
import org.junit.Assert.*
import org.junit.Test

class OnboardingViewModelTest {

    @Test
    fun `initial step is 0`() {
        val vm = OnboardingViewModel()
        assertEquals(0, vm.state.value.currentStep)
    }

    @Test
    fun `total steps is 4`() {
        val vm = OnboardingViewModel()
        assertEquals(4, vm.state.value.totalSteps)
    }

    @Test
    fun `default cycle length is 28`() {
        val vm = OnboardingViewModel()
        assertEquals(28, vm.state.value.cycleLength)
    }

    @Test
    fun `setCycleLength clamped to 18-45`() {
        val vm = OnboardingViewModel()
        vm.setCycleLength(50)
        assertEquals(45, vm.state.value.cycleLength)
        vm.setCycleLength(10)
        assertEquals(18, vm.state.value.cycleLength)
    }

    @Test
    fun `valid cycle lengths accepted`() {
        val vm = OnboardingViewModel()
        vm.setCycleLength(30)
        assertEquals(30, vm.state.value.cycleLength)
    }

    @Test
    fun `nextStep increments`() {
        val vm = OnboardingViewModel()
        vm.nextStep()
        assertEquals(1, vm.state.value.currentStep)
    }

    @Test
    fun `nextStep does not exceed total`() {
        val vm = OnboardingViewModel()
        repeat(10) { vm.nextStep() }
        assertTrue(vm.state.value.currentStep <= vm.state.value.totalSteps)
    }

    @Test
    fun `previousStep decrements`() {
        val vm = OnboardingViewModel()
        vm.nextStep()
        vm.nextStep()
        vm.previousStep()
        assertEquals(1, vm.state.value.currentStep)
    }

    @Test
    fun `previousStep does not go below 0`() {
        val vm = OnboardingViewModel()
        vm.previousStep()
        assertEquals(0, vm.state.value.currentStep)
    }

    @Test
    fun `toggleCondition adds condition`() {
        val vm = OnboardingViewModel()
        vm.toggleCondition(Condition.SOPK)
        assertTrue(vm.state.value.selectedConditions.contains(Condition.SOPK))
    }

    @Test
    fun `toggleCondition removes existing`() {
        val vm = OnboardingViewModel()
        vm.toggleCondition(Condition.SOPK)
        vm.toggleCondition(Condition.SOPK)
        assertFalse(vm.state.value.selectedConditions.contains(Condition.SOPK))
    }

    @Test
    fun `multiple conditions can be selected`() {
        val vm = OnboardingViewModel()
        vm.toggleCondition(Condition.SOPK)
        vm.toggleCondition(Condition.ENDOMETRIOSIS)
        assertEquals(2, vm.state.value.selectedConditions.size)
    }

    @Test
    fun `isCompleted defaults to false`() {
        val vm = OnboardingViewModel()
        assertFalse(vm.state.value.isCompleted)
    }
}
