package com.shifai.presentation.onboarding

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shifai.R

private val Purple = Color(0xFF7C5CFC)
private val Pink = Color(0xFFEC4899)
private val Lavender = Color(0xFFA78BFA)
private val Green = Color(0xFF34D399)
private val BgDark = Color(0xFF0F0B1E)

@Composable
fun OnboardingScreen(onComplete: () -> Unit) {
    var currentPage by remember { mutableIntStateOf(0) }
    var cycleLength by remember { mutableIntStateOf(28) }
    var selectedCondition by remember { mutableStateOf("none") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(BgDark, Color(0xFF1A0A2E))))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Skip button
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                if (currentPage < 4) {
                    TextButton(onClick = onComplete) {
                        Text(stringResource(R.string.onboarding_skip), color = Color.White.copy(alpha = 0.4f))
                    }
                }
            }

            Spacer(Modifier.weight(0.3f))

            // Pages
            AnimatedContent(targetState = currentPage, label = "onboarding") { page ->
                when (page) {
                    0 -> WelcomePage()
                    1 -> PrivacyPage()
                    2 -> SetupPage(cycleLength, { cycleLength = it }, selectedCondition, { selectedCondition = it })
                    3 -> QuickWinPage()
                    4 -> ReadyPage()
                }
            }

            Spacer(Modifier.weight(0.5f))

            // Progress dots
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                repeat(5) { i ->
                    Box(
                        modifier = Modifier
                            .size(if (i == currentPage) 24.dp else 8.dp, 8.dp)
                            .clip(CircleShape)
                            .background(if (i == currentPage) Purple else Color.White.copy(alpha = 0.2f))
                    )
                }
            }

            Spacer(Modifier.height(24.dp))

            // CTA button
            Button(
                onClick = {
                    if (currentPage < 4) currentPage++ else onComplete()
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Purple)
            ) {
                Text(
                    if (currentPage < 4) stringResource(R.string.onboarding_next)
                    else stringResource(R.string.onboarding_done),
                    fontSize = 16.sp, fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
private fun WelcomePage() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("🌸", fontSize = 64.sp)
        Spacer(Modifier.height(20.dp))
        Text(
            stringResource(R.string.onboarding_welcome_title),
            fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(8.dp))
        Text(
            stringResource(R.string.onboarding_welcome_subtitle),
            fontSize = 16.sp, color = Lavender,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun PrivacyPage() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("🔒", fontSize: 54.sp)
        Spacer(Modifier.height(20.dp))
        Text(
            stringResource(R.string.onboarding_privacy_title),
            fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(24.dp))

        listOf(
            "🔒" to stringResource(R.string.onboarding_privacy_encryption),
            "🇪🇺" to stringResource(R.string.onboarding_privacy_eu),
            "✅" to stringResource(R.string.onboarding_privacy_trackers)
        ).forEach { (emoji, text) ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .background(Color.White.copy(alpha = 0.05f), RoundedCornerShape(12.dp))
                    .padding(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(emoji, fontSize = 20.sp)
                Spacer(Modifier.width(12.dp))
                Text(text, color = Color.White, fontWeight = FontWeight.Medium)
            }
        }
    }
}

@Composable
private fun SetupPage(
    cycleLength: Int, onCycleLengthChange: (Int) -> Unit,
    condition: String, onConditionChange: (String) -> Unit
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("⚙️", fontSize = 48.sp)
        Spacer(Modifier.height(16.dp))
        Text(
            stringResource(R.string.onboarding_setup_title),
            fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White
        )
        Spacer(Modifier.height(24.dp))

        Text(stringResource(R.string.onboarding_setup_cycle_length),
            fontSize = 14.sp, color = Lavender)
        Spacer(Modifier.height(8.dp))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = { if (cycleLength > 20) onCycleLengthChange(cycleLength - 1) }) {
                Icon(Icons.Default.Remove, null, tint = Color.White)
            }
            Text("$cycleLength jours", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Purple)
            IconButton(onClick = { if (cycleLength < 45) onCycleLengthChange(cycleLength + 1) }) {
                Icon(Icons.Default.Add, null, tint = Color.White)
            }
        }

        Spacer(Modifier.height(20.dp))
        Text(stringResource(R.string.onboarding_setup_conditions),
            fontSize = 14.sp, color = Lavender)
        Spacer(Modifier.height(8.dp))

        listOf(
            "sopk" to stringResource(R.string.onboarding_setup_sopk),
            "endometriosis" to stringResource(R.string.onboarding_setup_endometriosis),
            "none" to stringResource(R.string.onboarding_setup_none)
        ).forEach { (key, label) ->
            FilterChip(
                selected = condition == key,
                onClick = { onConditionChange(key) },
                label = { Text(label) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 3.dp),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = Purple,
                    selectedLabelColor = Color.White
                )
            )
        }
    }
}

@Composable
private fun QuickWinPage() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("🎯", fontSize = 54.sp)
        Spacer(Modifier.height(20.dp))
        Text(
            stringResource(R.string.onboarding_quickwin_title),
            fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White
        )
        Spacer(Modifier.height(12.dp))
        Text(
            "Commence par un premier log :\nComment te sens-tu aujourd'hui ?",
            fontSize = 14.sp, color = Color.White.copy(alpha = 0.6f),
            textAlign = TextAlign.Center, lineHeight = 20.sp
        )
        Spacer(Modifier.height(24.dp))

        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            listOf("😊" to "Bien", "😐" to "Neutre", "😔" to "Pas top", "😩" to "Difficile")
                .forEach { (emoji, label) ->
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(emoji, fontSize = 32.sp)
                        Text(label, fontSize = 11.sp, color = Color.White.copy(alpha = 0.5f))
                    }
                }
        }
    }
}

@Composable
private fun ReadyPage() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("🚀", fontSize = 64.sp)
        Spacer(Modifier.height(20.dp))
        Text(
            stringResource(R.string.onboarding_ready_title),
            fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White
        )
        Spacer(Modifier.height(12.dp))
        Text(
            "ShifAI va apprendre de ton cycle.\nPlus tu logues, plus c'est précis.",
            fontSize = 14.sp, color = Color.White.copy(alpha = 0.6f),
            textAlign = TextAlign.Center, lineHeight = 20.sp
        )
    }
}
