package com.shifai.presentation.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Purple = Color(0xFF7C5CFC)
private val Pink = Color(0xFFEC4899)
private val Lavender = Color(0xFFA78BFA)
private val Green = Color(0xFF34D399)
private val Blue = Color(0xFF60A5FA)
private val Amber = Color(0xFFF59E0B)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

@Composable
fun DashboardScreen() {
    // TODO: Wire to real ViewModel
    val cycleDay = 14
    val phase = "Ovulatoire"
    val phaseEmoji = "🌸"
    val daysUntilPeriod = 14
    val energyForecast = "Haute"

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
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("Bonjour 👋", fontSize = 14.sp, color = Color.White.copy(alpha = 0.6f))
                    Text("ShifAI", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(Brush.linearGradient(listOf(Purple, Pink))),
                    contentAlignment = Alignment.Center
                ) {
                    Text("🌸", fontSize = 18.sp)
                }
            }
        }

        // ─── Cycle Day Ring ───
        item {
            Card(
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Cycle day circle
                    Box(
                        modifier = Modifier
                            .size(120.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.radialGradient(
                                    listOf(Purple.copy(alpha = 0.3f), Color.Transparent)
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("Jour", fontSize = 12.sp, color = Color.White.copy(alpha = 0.5f))
                            Text("$cycleDay", fontSize = 36.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }

                    Spacer(Modifier.height(12.dp))

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(phaseEmoji, fontSize = 16.sp)
                        Text("Phase $phase", fontWeight = FontWeight.SemiBold, color = Lavender)
                    }

                    Spacer(Modifier.height(4.dp))
                    Text("Prochaines règles dans ~$daysUntilPeriod jours",
                        fontSize = 12.sp, color = Color.White.copy(alpha = 0.4f))
                }
            }
        }

        // ─── Energy Forecast ───
        item {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(Amber.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("⚡", fontSize = 20.sp)
                    }
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Énergie prévue", fontSize = 12.sp, color = Color.White.copy(alpha = 0.5f))
                        Text(energyForecast, fontWeight = FontWeight.SemiBold, color = Color.White)
                    }
                    Icon(Icons.Default.ChevronRight, null, tint = Color.White.copy(alpha = 0.2f))
                }
            }
        }

        // ─── Quick Log CTA ───
        item {
            Button(
                onClick = { /* TODO: navigate to tracking */ },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Purple
                )
            ) {
                Icon(Icons.Default.Add, null, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Text("Log rapide", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            }
        }

        // ─── Quick Stats ───
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                StatCard("Symptômes", "3", "aujourd'hui", Blue, Modifier.weight(1f))
                StatCard("Sommeil", "7.5h", "la nuit dernière", Purple, Modifier.weight(1f))
                StatCard("Humeur", "😊", "maintenant", Green, Modifier.weight(1f))
            }
        }

        // ─── Insights Preview ───
        item {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("💡", fontSize = 16.sp)
                        Spacer(Modifier.width(8.dp))
                        Text("Insight du jour", fontWeight = FontWeight.SemiBold, color = Lavender)
                    }
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "Tes maux de tête apparaissent souvent en phase lutéale quand ton sommeil est < 7h.",
                        fontSize = 13.sp, color = Color.White.copy(alpha = 0.7f),
                        lineHeight = 18.sp
                    )
                }
            }
        }
    }
}

@Composable
private fun StatCard(label: String, value: String, sub: String, color: Color, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg)
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(value, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = color)
            Text(label, fontSize = 11.sp, color = Color.White.copy(alpha = 0.6f))
            Text(sub, fontSize = 9.sp, color = Color.White.copy(alpha = 0.3f))
        }
    }
}
