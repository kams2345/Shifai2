package com.shifai.presentation.export

import org.junit.Assert.*
import org.junit.Test

class ExportViewModelTest {

    @Test
    fun `initial template is SOPK`() {
        val vm = ExportViewModel()
        assertEquals(ExportViewModel.ExportTemplate.SOPK, vm.state.value.selectedTemplate)
    }

    @Test
    fun `initial date range is 3 months`() {
        val vm = ExportViewModel()
        assertEquals(ExportViewModel.DateRangeOption.MONTHS_3, vm.state.value.dateRange)
    }

    @Test
    fun `selectTemplate updates state`() {
        val vm = ExportViewModel()
        vm.selectTemplate(ExportViewModel.ExportTemplate.ENDOMETRIOSIS)
        assertEquals(ExportViewModel.ExportTemplate.ENDOMETRIOSIS, vm.state.value.selectedTemplate)
    }

    @Test
    fun `selectDateRange updates state`() {
        val vm = ExportViewModel()
        vm.selectDateRange(ExportViewModel.DateRangeOption.MONTHS_12)
        assertEquals(ExportViewModel.DateRangeOption.MONTHS_12, vm.state.value.dateRange)
    }

    @Test
    fun `isGenerating defaults to false`() {
        val vm = ExportViewModel()
        assertFalse(vm.state.value.isGenerating)
    }

    @Test
    fun `generatedFilePath defaults to null`() {
        val vm = ExportViewModel()
        assertNull(vm.state.value.generatedFilePath)
    }

    @Test
    fun `clearExport resets path and error`() {
        val vm = ExportViewModel()
        vm.clearExport()
        assertNull(vm.state.value.generatedFilePath)
        assertNull(vm.state.value.error)
    }

    @Test
    fun `ExportTemplate has 3 options`() {
        assertEquals(3, ExportViewModel.ExportTemplate.values().size)
    }

    @Test
    fun `DateRangeOption has 3 options`() {
        assertEquals(3, ExportViewModel.DateRangeOption.values().size)
    }

    @Test
    fun `template display names are French`() {
        assertEquals("Rapport SOPK", ExportViewModel.ExportTemplate.SOPK.displayName)
        assertEquals("Rapport Endométriose", ExportViewModel.ExportTemplate.ENDOMETRIOSIS.displayName)
        assertEquals("Rapport personnalisé", ExportViewModel.ExportTemplate.CUSTOM.displayName)
    }
}
