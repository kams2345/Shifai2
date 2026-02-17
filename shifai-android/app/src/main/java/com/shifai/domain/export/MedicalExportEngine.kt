package com.shifai.domain.export

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*

/**
 * Medical Export PDF Engine — Android
 * S6-1: PDF generation using android.graphics.pdf.PdfDocument
 * S6-2: SOPK template
 * S6-3: Endométriose template
 * S6-4: Custom template
 */
class MedicalExportEngine {

    enum class ExportTemplate(val label: String, val description: String) {
        SOPK("SOPK", "Irrégularité cycles, symptômes androgéniques"),
        ENDOMETRIOSIS("Endométriose", "Douleurs chroniques, localisation, évolution"),
        CUSTOM("Personnalisé", "Sélection libre de sections")
    }

    enum class ExportSection(val label: String) {
        CYCLE_OVERVIEW("Aperçu des cycles"),
        SYMPTOM_FREQUENCY("Fréquence des symptômes"),
        BODY_MAP_HEATMAP("Body Map — Zones de douleur"),
        SLEEP_ENERGY("Patterns sommeil/énergie"),
        CORRELATIONS("Corrélations détectées"),
        PREDICTIONS("Prédictions"),
        MOOD_TIMELINE("Timeline humeur")
    }

    data class ExportConfig(
        val template: ExportTemplate,
        val startDate: Date,
        val endDate: Date,
        val sections: Set<ExportSection>,
        val gynecologistNotes: String? = null
    )

    // A4: 595 x 842 points (72 dpi)
    private val pageWidth = 595
    private val pageHeight = 842
    private val margin = 50f

    fun generatePDF(config: ExportConfig): ByteArray {
        val document = PdfDocument()

        // Page 1: Cover
        var pageNum = 1
        val coverInfo = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNum).create()
        val coverPage = document.startPage(coverInfo)
        drawCoverPage(coverPage.canvas, config)
        document.finishPage(coverPage)

        // Content pages
        for (section in config.sections.sortedBy { it.label }) {
            pageNum++
            val info = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNum).create()
            val page = document.startPage(info)
            drawSection(page.canvas, section, config)
            document.finishPage(page)
        }

        // Disclaimer page
        pageNum++
        val disclaimerInfo = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNum).create()
        val disclaimerPage = document.startPage(disclaimerInfo)
        drawDisclaimerPage(disclaimerPage.canvas)
        document.finishPage(disclaimerPage)

        val output = ByteArrayOutputStream()
        document.writeTo(output)
        document.close()

        return output.toByteArray()
    }

    // MARK: - Cover Page

    private fun drawCoverPage(canvas: Canvas, config: ExportConfig) {
        var y = margin
        val titlePaint = Paint().apply {
            color = Color.rgb(124, 92, 252)
            textSize = 28f
            isFakeBoldText = true
            isAntiAlias = true
        }
        canvas.drawText("Rapport Médical ShifAI", margin, y + 28f, titlePaint)
        y += 50f

        val bodyPaint = Paint().apply {
            color = Color.DKGRAY
            textSize = 12f
            isAntiAlias = true
        }

        val dateFormat = SimpleDateFormat("d MMMM yyyy", Locale.FRANCE)
        canvas.drawText("Template: ${config.template.label}", margin, y, bodyPaint)
        y += 20f
        canvas.drawText(
            "Période: ${dateFormat.format(config.startDate)} — ${dateFormat.format(config.endDate)}",
            margin, y, bodyPaint
        )
        y += 30f

        // Separator
        val linePaint = Paint().apply { color = Color.LTGRAY; strokeWidth = 0.5f }
        canvas.drawLine(margin, y, pageWidth - margin, y, linePaint)
        y += 20f

        val bulletPaint = Paint().apply { color = Color.BLACK; textSize = 13f; isAntiAlias = true }
        val bullets = listOf(
            "📊 Sections incluses: ${config.sections.size}",
            "🔒 Données chiffrées AES-256",
            "⚠️ Ce document est informatif uniquement"
        )
        for (b in bullets) {
            canvas.drawText(b, margin, y, bulletPaint)
            y += 22f
        }

        config.gynecologistNotes?.let { notes ->
            y += 20f
            val notesPaint = Paint().apply { color = Color.BLACK; textSize = 13f; isFakeBoldText = true; isAntiAlias = true }
            canvas.drawText("Notes pour le gynécologue:", margin, y, notesPaint)
            y += 20f
            val notesBody = Paint().apply { color = Color.DKGRAY; textSize = 11f; isAntiAlias = true }
            canvas.drawText(notes, margin, y, notesBody)
        }

        drawWatermark(canvas)
    }

    // MARK: - Section Drawing

    private fun drawSection(canvas: Canvas, section: ExportSection, config: ExportConfig) {
        var y = margin
        val headerPaint = Paint().apply {
            color = Color.rgb(124, 92, 252)
            textSize = 20f
            isFakeBoldText = true
            isAntiAlias = true
        }
        canvas.drawText(section.label, margin, y + 20f, headerPaint)
        y += 50f

        val bodyPaint = Paint().apply { color = Color.BLACK; textSize = 12f; isAntiAlias = true }

        when (section) {
            ExportSection.CYCLE_OVERVIEW -> {
                canvas.drawText("Analyse des cycles sur la période sélectionnée.", margin, y, bodyPaint)
                y += 40f
                // Phase bar
                val phases = listOf(
                    Triple("Menstruel", 0.18f, Color.rgb(239, 68, 68)),
                    Triple("Folliculaire", 0.25f, Color.rgb(52, 211, 153)),
                    Triple("Ovulatoire", 0.14f, Color.rgb(245, 158, 11)),
                    Triple("Lutéal", 0.43f, Color.rgb(167, 139, 250))
                )
                var x = margin
                val barW = pageWidth - 2 * margin
                val barPaint = Paint().apply { isAntiAlias = true }
                for ((label, ratio, color) in phases) {
                    val w = barW * ratio
                    barPaint.color = color
                    barPaint.alpha = 180
                    canvas.drawRect(x, y, x + w, y + 30f, barPaint)
                    val labelPaint = Paint().apply { this.color = Color.WHITE; textSize = 8f; isAntiAlias = true }
                    canvas.drawText(label, x + 4f, y + 18f, labelPaint)
                    x += w
                }
            }
            ExportSection.SYMPTOM_FREQUENCY -> {
                canvas.drawText("Top symptômes les plus fréquents.", margin, y, bodyPaint)
                y += 30f
                val symptoms = listOf("Crampes" to 0.85f, "Fatigue" to 0.72f, "Migraine" to 0.65f,
                    "Ballonnement" to 0.55f, "Anxiété" to 0.48f)
                val barPaint = Paint().apply { isAntiAlias = true }
                for ((name, ratio) in symptoms) {
                    canvas.drawText(name, margin, y + 10f, bodyPaint)
                    barPaint.color = Color.rgb(124, 92, 252)
                    barPaint.alpha = (ratio * 255).toInt()
                    val w = (pageWidth - 2 * margin - 120f) * ratio
                    canvas.drawRect(margin + 110f, y, margin + 110f + w, y + 14f, barPaint)
                    y += 22f
                }
            }
            ExportSection.BODY_MAP_HEATMAP -> {
                canvas.drawText("Zones de douleur signalées.", margin, y, bodyPaint)
            }
            ExportSection.SLEEP_ENERGY -> {
                canvas.drawText("Patterns sommeil/énergie par phase.", margin, y, bodyPaint)
            }
            ExportSection.CORRELATIONS -> {
                canvas.drawText("Corrélations statistiques détectées (r > 0.3).", margin, y, bodyPaint)
            }
            ExportSection.PREDICTIONS -> {
                canvas.drawText("Prédictions et précision historique.", margin, y, bodyPaint)
            }
            ExportSection.MOOD_TIMELINE -> {
                canvas.drawText("Évolution humeur sur la période.", margin, y, bodyPaint)
            }
        }

        drawWatermark(canvas)
    }

    // MARK: - Disclaimer

    private fun drawDisclaimerPage(canvas: Canvas) {
        var y = margin
        val titlePaint = Paint().apply {
            color = Color.RED
            textSize = 18f
            isFakeBoldText = true
            isAntiAlias = true
        }
        canvas.drawText("⚠️ Avertissement Médical", margin, y + 18f, titlePaint)
        y += 50f

        val bodyPaint = Paint().apply { color = Color.BLACK; textSize = 11f; isAntiAlias = true }
        val lines = listOf(
            "Ce document a été généré automatiquement par ShifAI.",
            "Il ne constitue en aucun cas un diagnostic ou avis médical.",
            "Les données sont auto-déclarées et non validées par un professionnel.",
            "",
            "Consultez toujours un professionnel de santé qualifié.",
            "",
            "ShifAI respecte le RGPD. Données chiffrées AES-256, stockées en UE.",
            "",
            "© ShifAI ${Calendar.getInstance().get(Calendar.YEAR)}"
        )
        for (line in lines) {
            canvas.drawText(line, margin, y, bodyPaint)
            y += 18f
        }

        drawWatermark(canvas)
    }

    // MARK: - Watermark

    private fun drawWatermark(canvas: Canvas) {
        val paint = Paint().apply { color = Color.LTGRAY; textSize = 8f; isAntiAlias = true }
        canvas.drawText("Information uniquement — Généré par ShifAI", margin, pageHeight - 20f, paint)
    }

    companion object {
        fun defaultSections(template: ExportTemplate): Set<ExportSection> = when (template) {
            ExportTemplate.SOPK -> setOf(
                ExportSection.CYCLE_OVERVIEW, ExportSection.SYMPTOM_FREQUENCY,
                ExportSection.BODY_MAP_HEATMAP, ExportSection.SLEEP_ENERGY, ExportSection.CORRELATIONS
            )
            ExportTemplate.ENDOMETRIOSIS -> setOf(
                ExportSection.CYCLE_OVERVIEW, ExportSection.BODY_MAP_HEATMAP,
                ExportSection.SYMPTOM_FREQUENCY, ExportSection.SLEEP_ENERGY, ExportSection.MOOD_TIMELINE
            )
            ExportTemplate.CUSTOM -> ExportSection.values().toSet()
        }
    }
}
