package com.shifai.presentation.export

import android.content.Intent
import android.graphics.pdf.PdfDocument
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import com.shifai.R
import com.shifai.domain.export.MedicalExportEngine
import java.io.File

private val Purple = Color(0xFF7C5CFC)
private val Pink = Color(0xFFEC4899)
private val Lavender = Color(0xFFA78BFA)
private val Green = Color(0xFF34D399)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

@Composable
fun ExportPreviewScreen(
    onBack: () -> Unit = {}
) {
    val context = LocalContext.current
    var selectedTemplate by remember { mutableStateOf(MedicalExportEngine.ExportTemplate.SOPK) }
    var dateRangeMonths by remember { mutableIntStateOf(3) }
    var isGenerating by remember { mutableStateOf(false) }
    var pdfFile by remember { mutableStateOf<File?>(null) }
    var showShareSheet by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BgDark)
            .padding(16.dp)
    ) {
        // ─── Header ───
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                stringResource(R.string.export_title),
                fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White
            )
        }

        Spacer(Modifier.height(20.dp))

        // ─── Template Selector ───
        Text(
            "MODÈLE", fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
            color = Lavender, letterSpacing = 1.sp
        )
        Spacer(Modifier.height(8.dp))

        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            TemplateCard(
                name = stringResource(R.string.export_template_sopk),
                emoji = "🩺",
                description = "Cycles irréguliers, symptômes androgéniques",
                selected = selectedTemplate == MedicalExportEngine.ExportTemplate.SOPK,
                color = Purple
            ) { selectedTemplate = MedicalExportEngine.ExportTemplate.SOPK }

            TemplateCard(
                name = stringResource(R.string.export_template_endometriosis),
                emoji = "💜",
                description = "Douleur chronique, localisation, intensité",
                selected = selectedTemplate == MedicalExportEngine.ExportTemplate.ENDOMETRIOSIS,
                color = Pink
            ) { selectedTemplate = MedicalExportEngine.ExportTemplate.ENDOMETRIOSIS }

            TemplateCard(
                name = stringResource(R.string.export_template_custom),
                emoji = "✏️",
                description = "Sélection libre des sections",
                selected = selectedTemplate == MedicalExportEngine.ExportTemplate.CUSTOM,
                color = Lavender
            ) { selectedTemplate = MedicalExportEngine.ExportTemplate.CUSTOM }
        }

        Spacer(Modifier.height(24.dp))

        // ─── Date Range ───
        Text(
            stringResource(R.string.export_date_range).uppercase(),
            fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
            color = Lavender, letterSpacing = 1.sp
        )
        Spacer(Modifier.height(8.dp))

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(3, 6, 12).forEach { months ->
                FilterChip(
                    selected = dateRangeMonths == months,
                    onClick = { dateRangeMonths = months },
                    label = { Text("$months mois") },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = Purple,
                        selectedLabelColor = Color.White,
                        labelColor = Color.White.copy(alpha = 0.6f)
                    )
                )
            }
        }

        Spacer(Modifier.height(24.dp))

        // ─── Disclaimer ───
        Card(
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0x15F59E0B))
        ) {
            Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.Top) {
                Text("⚠️", fontSize = 16.sp)
                Spacer(Modifier.width(8.dp))
                Text(
                    stringResource(R.string.export_disclaimer),
                    fontSize = 12.sp, color = Color(0xFFF59E0B).copy(alpha = 0.8f)
                )
            }
        }

        Spacer(Modifier.weight(1f))

        // ─── Actions ───
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Generate
            Button(
                onClick = {
                    isGenerating = true
                    // Generate PDF
                    val engine = MedicalExportEngine()
                    val config = MedicalExportEngine.ExportConfig.defaultConfig(selectedTemplate)
                    val pdf = engine.generatePDF(config)
                    // Save to cache
                    val file = File(context.cacheDir, "shifai_export.pdf")
                    file.writeBytes(pdf)
                    pdfFile = file
                    isGenerating = false
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = Purple),
                enabled = !isGenerating
            ) {
                if (isGenerating) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        strokeWidth = 2.dp, color = Color.White
                    )
                } else {
                    Icon(Icons.Default.PictureAsPdf, null, modifier = Modifier.size(18.dp))
                }
                Spacer(Modifier.width(8.dp))
                Text(stringResource(R.string.export_generate))
            }

            // Share
            if (pdfFile != null) {
                Button(
                    onClick = {
                        pdfFile?.let { file ->
                            val uri = FileProvider.getUriForFile(
                                context, "${context.packageName}.fileprovider", file
                            )
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "application/pdf"
                                putExtra(Intent.EXTRA_STREAM, uri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            context.startActivity(Intent.createChooser(intent, "Partager le PDF"))
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Green)
                ) {
                    Icon(Icons.Default.Share, null, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(stringResource(R.string.export_share))
                }
            }
        }
    }
}

@Composable
private fun TemplateCard(
    name: String,
    emoji: String,
    description: String,
    selected: Boolean,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (selected) color.copy(alpha = 0.15f) else CardBg
        ),
        border = if (selected) CardDefaults.outlinedCardBorder().copy(
            width = 1.5.dp,
            brush = androidx.compose.ui.graphics.SolidColor(color)
        ) else null,
        modifier = Modifier.width(140.dp)
    ) {
        Column(modifier = Modifier.padding(14.dp)) {
            Text(emoji, fontSize = 24.sp)
            Spacer(Modifier.height(6.dp))
            Text(name, fontWeight = FontWeight.SemiBold, color = Color.White, fontSize = 14.sp)
            Text(description, fontSize = 10.sp, color = Color.White.copy(alpha = 0.4f),
                lineHeight = 13.sp)
        }
    }
}
