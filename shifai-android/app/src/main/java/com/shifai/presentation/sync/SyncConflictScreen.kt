package com.shifai.presentation.sync

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shifai.data.sync.SyncEngine

private val Purple = Color(0xFF7C5CFC)
private val Lavender = Color(0xFFA78BFA)
private val Blue = Color(0xFF60A5FA)
private val Green = Color(0xFF34D399)
private val Amber = Color(0xFFF59E0B)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

@Composable
fun SyncConflictScreen(
    localVersion: Int,
    serverVersion: Int,
    onDismiss: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BgDark)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(40.dp))

        // Warning icon
        Icon(
            Icons.Default.Warning, null,
            tint = Amber, modifier = Modifier.size(48.dp)
        )
        Spacer(Modifier.height(12.dp))

        Text(
            "Conflit de synchronisation",
            fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White
        )
        Text(
            "Les données sur cet appareil diffèrent de celles sur le serveur.",
            fontSize = 13.sp, color = Color.White.copy(alpha = 0.5f),
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
        )

        Spacer(Modifier.height(20.dp))

        // Version comparison
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            VersionCard("Cet appareil", "v$localVersion", Icons.Default.PhoneAndroid, Blue)
            Text("vs", color = Color.White.copy(alpha = 0.3f), fontWeight = FontWeight.SemiBold)
            VersionCard("Serveur", "v$serverVersion", Icons.Default.Cloud, Lavender)
        }

        Spacer(Modifier.height(32.dp))

        // Resolution options
        ResolutionButton(
            title = "Garder les données locales",
            subtitle = "Les données serveur seront écrasées",
            icon = Icons.Default.PhoneAndroid, color = Blue
        ) {
            SyncEngine.getInstance(null).push()
            onDismiss()
        }

        Spacer(Modifier.height(10.dp))

        ResolutionButton(
            title = "Garder les données du serveur",
            subtitle = "Les données locales seront remplacées",
            icon = Icons.Default.Cloud, color = Lavender
        ) {
            SyncEngine.getInstance(null).pull()
            onDismiss()
        }

        Spacer(Modifier.height(10.dp))

        ResolutionButton(
            title = "Fusionner les deux",
            subtitle = "Les entrées les plus récentes conservées",
            icon = Icons.Default.MergeType, color = Green
        ) {
            SyncEngine.getInstance(null).sync()
            onDismiss()
        }

        Spacer(Modifier.weight(1f))

        // Auto-resolve notice
        Text(
            "Sans action sous 24h, les données les plus récentes seront gardées automatiquement.",
            fontSize = 11.sp, color = Color.White.copy(alpha = 0.25f),
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(12.dp))

        TextButton(onClick = onDismiss) {
            Text("Plus tard", color = Lavender)
        }
    }
}

@Composable
private fun VersionCard(label: String, version: String, icon: ImageVector, color: Color) {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(icon, null, tint = color, modifier = Modifier.size(28.dp))
            Spacer(Modifier.height(6.dp))
            Text(label, fontSize = 12.sp, color = Color.White.copy(alpha = 0.6f))
            Text(version, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = color)
        }
    }
}

@Composable
private fun ResolutionButton(
    title: String, subtitle: String,
    icon: ImageVector, color: Color,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon, null, tint = color,
                modifier = Modifier
                    .size(36.dp)
                    .background(color.copy(alpha = 0.12f), RoundedCornerShape(10.dp))
                    .padding(6.dp)
            )
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(title, fontWeight = FontWeight.Medium, color = Color.White, fontSize = 14.sp)
                Text(subtitle, fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
            }
            Icon(Icons.Default.ChevronRight, null, tint = Color.White.copy(alpha = 0.2f))
        }
    }
}
