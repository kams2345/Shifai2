package com.shifai.presentation.tracking

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
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
private val Amber = Color(0xFFF59E0B)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

data class SymptomItem(val name: String, val emoji: String, val id: String)

val symptoms = listOf(
    SymptomItem("Crampes", "🔴", "cramps"),
    SymptomItem("Maux de tête", "🤕", "headache"),
    SymptomItem("Fatigue", "😴", "fatigue"),
    SymptomItem("Ballonnements", "🫧", "bloating"),
    SymptomItem("Nausées", "🤢", "nausea"),
    SymptomItem("Mal de dos", "💫", "backpain"),
    SymptomItem("Seins sensibles", "🩹", "breast_tenderness"),
    SymptomItem("Acné", "🔵", "acne"),
    SymptomItem("Insomnie", "🌙", "insomnia"),
    SymptomItem("Vertiges", "💫", "dizziness"),
    SymptomItem("Anxiété", "😰", "anxiety"),
    SymptomItem("Irritabilité", "😤", "irritability"),
    SymptomItem("Envies alimentaires", "🍫", "cravings"),
    SymptomItem("Douleurs pelviennes", "🩸", "pelvic_pain"),
    SymptomItem("Migraine", "⚡", "migraine"),
    SymptomItem("Constipation", "💨", "constipation"),
    SymptomItem("Douleurs articulaires", "🦴", "joint_pain"),
    SymptomItem("Changements d'humeur", "🎭", "mood_swings"),
    SymptomItem("Bouffées de chaleur", "🥵", "hot_flashes"),
    SymptomItem("Diarrhée", "💧", "diarrhea")
)

@Composable
fun TrackingScreen() {
    var flowIntensity by remember { mutableIntStateOf(0) }
    var moodValue by remember { mutableFloatStateOf(0.5f) }
    var energyValue by remember { mutableFloatStateOf(0.5f) }
    var sleepHours by remember { mutableFloatStateOf(7f) }
    var stressValue by remember { mutableFloatStateOf(0.3f) }
    var selectedSymptoms by remember { mutableStateOf(setOf<String>()) }
    var notes by remember { mutableStateOf("") }
    var isSaved by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BgDark)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        // Header
        item {
            Text(
                stringResource(R.string.tracking_title),
                fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color.White
            )
        }

        // ─── Flow Intensity ───
        item {
            SectionCard(stringResource(R.string.tracking_flow)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    listOf(
                        0 to stringResource(R.string.tracking_flow_none),
                        1 to stringResource(R.string.tracking_flow_light),
                        2 to stringResource(R.string.tracking_flow_medium),
                        3 to stringResource(R.string.tracking_flow_heavy)
                    ).forEach { (value, label) ->
                        FilterChip(
                            selected = flowIntensity == value,
                            onClick = { flowIntensity = value },
                            label = { Text(label, fontSize = 12.sp) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = Pink,
                                selectedLabelColor = Color.White
                            )
                        )
                    }
                }
            }
        }

        // ─── Mood & Energy Sliders ───
        item {
            SectionCard("Bien-être") {
                SliderRow(stringResource(R.string.tracking_mood), "😢", "😊", moodValue) { moodValue = it }
                SliderRow(stringResource(R.string.tracking_energy), "🔋", "⚡", energyValue) { energyValue = it }
                SliderRow(stringResource(R.string.tracking_sleep), "🌙", "☀️", sleepHours / 12f) { sleepHours = it * 12f }
                SliderRow(stringResource(R.string.tracking_stress), "😌", "😰", stressValue) { stressValue = it }

                Spacer(Modifier.height(4.dp))
                Text(
                    "Sommeil: ${String.format("%.1f", sleepHours)}h",
                    fontSize = 12.sp, color = Lavender
                )
            }
        }

        // ─── Symptoms Grid ───
        item {
            SectionCard(stringResource(R.string.tracking_symptoms)) {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(4),
                    modifier = Modifier.height(280.dp),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    items(symptoms) { symptom ->
                        val isSelected = symptom.id in selectedSymptoms
                        Column(
                            modifier = Modifier
                                .clip(RoundedCornerShape(10.dp))
                                .background(
                                    if (isSelected) Purple.copy(alpha = 0.2f)
                                    else Color.White.copy(alpha = 0.03f)
                                )
                                .clickable {
                                    selectedSymptoms = if (isSelected) {
                                        selectedSymptoms - symptom.id
                                    } else {
                                        selectedSymptoms + symptom.id
                                    }
                                }
                                .padding(8.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(symptom.emoji, fontSize = 20.sp)
                            Text(
                                symptom.name,
                                fontSize = 9.sp, color = Color.White.copy(alpha = 0.7f),
                                maxLines = 2, lineHeight = 11.sp
                            )
                        }
                    }
                }
            }
        }

        // ─── Notes ───
        item {
            SectionCard(stringResource(R.string.tracking_notes)) {
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(80.dp),
                    placeholder = { Text("Notes libres...", color = Color.White.copy(alpha = 0.3f)) },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = Purple,
                        unfocusedBorderColor = Color.White.copy(alpha = 0.1f),
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
            }
        }

        // ─── Save Button ───
        item {
            Button(
                onClick = {
                    // TODO: Save to repository
                    isSaved = true
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isSaved) Green else Purple
                )
            ) {
                if (isSaved) {
                    Icon(Icons.Default.Check, null)
                    Spacer(Modifier.width(8.dp))
                    Text(stringResource(R.string.tracking_saved))
                } else {
                    Icon(Icons.Default.Save, null)
                    Spacer(Modifier.width(8.dp))
                    Text(stringResource(R.string.tracking_save), fontWeight = FontWeight.SemiBold)
                }
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

// ─── Components ───

@Composable
private fun SectionCard(title: String, content: @Composable ColumnScope.() -> Unit) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                title.uppercase(), fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
                color = Lavender, letterSpacing = 1.sp
            )
            Spacer(Modifier.height(10.dp))
            content()
        }
    }
}

@Composable
private fun SliderRow(
    label: String, leftEmoji: String, rightEmoji: String,
    value: Float, onValueChange: (Float) -> Unit
) {
    Column(modifier = Modifier.padding(vertical = 4.dp)) {
        Text(label, fontSize = 13.sp, color = Color.White)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(leftEmoji, fontSize = 14.sp)
            Slider(
                value = value, onValueChange = onValueChange,
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 8.dp),
                colors = SliderDefaults.colors(
                    thumbColor = Purple,
                    activeTrackColor = Purple
                )
            )
            Text(rightEmoji, fontSize = 14.sp)
        }
    }
}
