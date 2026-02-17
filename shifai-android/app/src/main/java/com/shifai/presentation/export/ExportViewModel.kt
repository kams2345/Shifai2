package com.shifai.presentation.export

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Export ViewModel — manages template selection, date range, and PDF generation.
 */
class ExportViewModel : ViewModel() {

    data class ExportState(
        val selectedTemplate: ExportTemplate = ExportTemplate.SOPK,
        val dateRange: DateRangeOption = DateRangeOption.MONTHS_3,
        val isGenerating: Boolean = false,
        val generatedFilePath: String? = null,
        val error: String? = null
    )

    enum class ExportTemplate(val displayName: String) {
        SOPK("Rapport SOPK"),
        ENDOMETRIOSIS("Rapport Endométriose"),
        CUSTOM("Rapport personnalisé")
    }

    enum class DateRangeOption(val months: Int, val label: String) {
        MONTHS_3(3, "3 mois"),
        MONTHS_6(6, "6 mois"),
        MONTHS_12(12, "12 mois")
    }

    private val _state = MutableStateFlow(ExportState())
    val state: StateFlow<ExportState> = _state.asStateFlow()

    fun selectTemplate(template: ExportTemplate) {
        _state.value = _state.value.copy(selectedTemplate = template)
    }

    fun selectDateRange(range: DateRangeOption) {
        _state.value = _state.value.copy(dateRange = range)
    }

    fun generatePDF() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isGenerating = true, error = null)
            try {
                // TODO: val path = MedicalExportEngine.generatePDF(template, dateRange)
                _state.value = _state.value.copy(
                    isGenerating = false,
                    generatedFilePath = "export.pdf" // placeholder
                )
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    isGenerating = false,
                    error = e.message
                )
            }
        }
    }

    fun clearExport() {
        _state.value = _state.value.copy(generatedFilePath = null, error = null)
    }
}
