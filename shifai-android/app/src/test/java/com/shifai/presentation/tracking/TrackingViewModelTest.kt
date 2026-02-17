package com.shifai.presentation.tracking

import com.shifai.domain.models.BodyZone
import com.shifai.domain.models.SymptomCategory
import org.junit.Assert.*
import org.junit.Test

class TrackingViewModelTest {

    // ─── Defaults ───

    @Test
    fun `initial flow intensity is 0`() {
        val vm = TrackingViewModel()
        assertEquals(0, vm.state.value.flowIntensity)
    }

    @Test
    fun `initial mood is 5`() {
        val vm = TrackingViewModel()
        assertEquals(5, vm.state.value.moodScore)
    }

    @Test
    fun `initial symptoms list is empty`() {
        val vm = TrackingViewModel()
        assertTrue(vm.state.value.symptoms.isEmpty())
    }

    @Test
    fun `initial body zones are empty`() {
        val vm = TrackingViewModel()
        assertTrue(vm.state.value.bodyZones.isEmpty())
    }

    // ─── Slider Clamping ───

    @Test
    fun `flow intensity clamped to 0-4`() {
        val vm = TrackingViewModel()
        vm.setFlowIntensity(10)
        assertEquals(4, vm.state.value.flowIntensity)
        vm.setFlowIntensity(-1)
        assertEquals(0, vm.state.value.flowIntensity)
    }

    @Test
    fun `mood clamped to 1-10`() {
        val vm = TrackingViewModel()
        vm.setMoodScore(15)
        assertEquals(10, vm.state.value.moodScore)
        vm.setMoodScore(0)
        assertEquals(1, vm.state.value.moodScore)
    }

    @Test
    fun `energy clamped to 1-10`() {
        val vm = TrackingViewModel()
        vm.setEnergyScore(0)
        assertEquals(1, vm.state.value.energyScore)
    }

    @Test
    fun `sleep clamped to 0-24`() {
        val vm = TrackingViewModel()
        vm.setSleepHours(30f)
        assertEquals(24f, vm.state.value.sleepHours)
        vm.setSleepHours(-2f)
        assertEquals(0f, vm.state.value.sleepHours)
    }

    @Test
    fun `stress clamped to 1-10`() {
        val vm = TrackingViewModel()
        vm.setStressLevel(11)
        assertEquals(10, vm.state.value.stressLevel)
    }

    // ─── Symptoms ───

    @Test
    fun `addSymptom adds to list`() {
        val vm = TrackingViewModel()
        vm.addSymptom(SymptomCategory.MOOD, 7)
        assertEquals(1, vm.state.value.symptoms.size)
        assertEquals(7, vm.state.value.symptoms[0].intensity)
    }

    @Test
    fun `addSymptom replaces existing of same type`() {
        val vm = TrackingViewModel()
        vm.addSymptom(SymptomCategory.MOOD, 5)
        vm.addSymptom(SymptomCategory.MOOD, 8)
        assertEquals(1, vm.state.value.symptoms.size)
        assertEquals(8, vm.state.value.symptoms[0].intensity)
    }

    @Test
    fun `removeSymptom removes by type`() {
        val vm = TrackingViewModel()
        vm.addSymptom(SymptomCategory.MOOD, 7)
        vm.addSymptom(SymptomCategory.SLEEP, 3)
        vm.removeSymptom(SymptomCategory.MOOD)
        assertEquals(1, vm.state.value.symptoms.size)
        assertEquals(SymptomCategory.SLEEP, vm.state.value.symptoms[0].type)
    }

    // ─── Body Map ───

    @Test
    fun `toggleBodyZone adds zone`() {
        val vm = TrackingViewModel()
        vm.toggleBodyZone(BodyZone.HEAD)
        assertTrue(vm.state.value.bodyZones.contains(BodyZone.HEAD))
    }

    @Test
    fun `toggleBodyZone removes existing zone`() {
        val vm = TrackingViewModel()
        vm.toggleBodyZone(BodyZone.HEAD)
        vm.toggleBodyZone(BodyZone.HEAD)
        assertFalse(vm.state.value.bodyZones.contains(BodyZone.HEAD))
    }

    // ─── Notes ───

    @Test
    fun `setNotes updates state`() {
        val vm = TrackingViewModel()
        vm.setNotes("Crampes fortes ce matin")
        assertEquals("Crampes fortes ce matin", vm.state.value.notes)
    }

    // ─── Save ───

    @Test
    fun `isSaved defaults to false`() {
        val vm = TrackingViewModel()
        assertFalse(vm.state.value.isSaved)
    }
}
