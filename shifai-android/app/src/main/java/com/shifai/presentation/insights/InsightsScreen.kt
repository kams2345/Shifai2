package com.shifai.presentation.insights

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shifai.R

private val Purple = Color(0xFF7C5CFC)
private val Pink = Color(0xFFEC4899)
private val Lavender = Color(0xFFA78BFA)
private val Green = Color(0xFF34D399)
private val Blue = Color(0xFF60A5FA)
private val Amber = Color(0xFFF59E0B)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

data class InsightItem(
    val icon: String,
    val title: String,
    val body: String,
    val confidence: Int,
    val type: String,  // prediction, correlation, recommendation
    val color: Color
)

@Composable
fun InsightsScreen() {
    // TODO: Wire to ViewModel
    val dataPoints = 42
    val insights = listOf(
        InsightItem("🔮", "Prochaines règles", "Estimées dans 12-14 jours (28 mars - 30 mars)", 78, "prediction", Purple),
        InsightItem("🌡️", "Ovulation", "Fenêtre probable dans 5-7 jours", 72, "prediction", Pink),
        InsightItem("🔗", "Corrélation découverte", "Maux de tête ↔ Sommeil < 7h en phase lutéale (corrélation 0.74)", 85, "correlation", Blue),
        InsightItem("🔗", "Corrélation", "Énergie basse ↔ Stress élevé + Phase lutéale", 68, "correlation", Blue),
        InsightItem("💡", "Recommandation", "Phase folliculaire : c'est le bon moment pour les séances sportives intenses", 90, "recommendation", Green),
        InsightItem("💡", "Recommandation", "Essaie d'augmenter ton sommeil de 30min en phase lutéale", 82, "recommendation", Green),
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BgDark)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        // ─── Header ───
        item {
            Text(
                stringResource(R.string.insights_title),
                fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color.White
            )
            Spacer(Modifier.height(4.dp))
            Text(
                "Basé sur $dataPoints jours de données",
                fontSize = 12.sp, color = Lavender
            )
        }

        // ─── Filters ───
        item {
            var selectedFilter by remember { mutableStateOf("all") }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "all" to "Tout",
                    "prediction" to stringResource(R.string.insights_predictions),
                    "correlation" to stringResource(R.string.insights_correlations),
                    "recommendation" to stringResource(R.string.insights_recommendations)
                ).forEach { (key, label) ->
                    FilterChip(
                        selected = selectedFilter == key,
                        onClick = { selectedFilter = key },
                        label = { Text(label, fontSize = 12.sp) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Purple,
                            selectedLabelColor = Color.White,
                            labelColor = Color.White.copy(alpha = 0.5f)
                        )
                    )
                }
            }
        }

        // ─── Insight Cards ───
        items(insights) { insight ->
            InsightCard(insight)
        }

        // ─── ML Status ───
        item {
            Card(
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0x08FFFFFF))
            ) {
                Row(
                    modifier = Modifier.padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("🧠", fontSize = 16.sp)
                    Spacer(Modifier.width(10.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Moteur ML actif", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = Green)
                        Text("$dataPoints jours analysés • Modèle v1.0",
                            fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

@Composable
private fun InsightCard(insight: InsightItem) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(insight.icon, fontSize = 20.sp)
                Spacer(Modifier.width(10.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(insight.title, fontWeight = FontWeight.SemiBold, color = Color.White)
                    Text(
                        when (insight.type) {
                            "prediction" -> "Prédiction"
                            "correlation" -> "Corrélation"
                            else -> "Recommandation"
                        },
                        fontSize = 10.sp, color = insight.color
                    )
                }
                // Confidence badge
                Box(
                    modifier = Modifier
                        .background(insight.color.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text("${insight.confidence}%", fontSize = 12.sp,
                        fontWeight = FontWeight.Bold, color = insight.color)
                }
            }

            Spacer(Modifier.height(10.dp))

            Text(
                insight.body,
                fontSize = 13.sp, color = Color.White.copy(alpha = 0.7f),
                lineHeight = 18.sp
            )

            // Feedback buttons for predictions
            if (insight.type == "prediction") {
                Spacer(Modifier.height(10.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    listOf(
                        stringResource(R.string.insights_feedback_accurate),
                        stringResource(R.string.insights_feedback_early),
                        stringResource(R.string.insights_feedback_late),
                        stringResource(R.string.insights_feedback_wrong)
                    ).forEach { label ->
                        AssistChip(
                            onClick = { /* TODO: send feedback */ },
                            label = { Text(label, fontSize = 10.sp) },
                            colors = AssistChipDefaults.assistChipColors(
                                labelColor = Color.White.copy(alpha = 0.6f)
                            ),
                            border = AssistChipDefaults.assistChipBorder(
                                borderColor = Color.White.copy(alpha = 0.1f)
                            )
                        )
                    }
                }
            }
        }
    }
}
