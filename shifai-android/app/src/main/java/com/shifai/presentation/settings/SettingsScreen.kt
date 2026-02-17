package com.shifai.presentation.settings

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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shifai.R
import com.shifai.domain.notifications.NotificationEngine

// Colors
private val Purple = Color(0xFF7C5CFC)
private val Pink = Color(0xFFEC4899)
private val Lavender = Color(0xFFA78BFA)
private val Green = Color(0xFF34D399)
private val Blue = Color(0xFF60A5FA)
private val Amber = Color(0xFFF59E0B)
private val BgDark = Color(0xFF0F0B1E)
private val CardBg = Color(0x0AFFFFFF)

@Composable
fun SettingsScreen(
    onNavigateToProfile: () -> Unit = {},
    onNavigateToExport: () -> Unit = {},
    onNavigateToPrivacyPolicy: () -> Unit = {},
    onNavigateToTerms: () -> Unit = {},
) {
    var syncEnabled by remember { mutableStateOf(false) }
    var isSyncing by remember { mutableStateOf(false) }
    var biometricEnabled by remember { mutableStateOf(false) }
    var autoLockMinutes by remember { mutableIntStateOf(5) }
    var widgetPrivacy by remember { mutableStateOf(false) }
    var dailyReminder by remember { mutableStateOf(true) }
    var showDeleteDialog by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BgDark)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        // ─── Header ───
        item {
            Text(
                stringResource(R.string.settings_title),
                fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        // ─── Profile Card ───
        item {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg),
                onClick = onNavigateToProfile
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(Brush.linearGradient(listOf(Purple, Pink))),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("🌸", fontSize = 20.sp)
                    }
                    Spacer(Modifier.width(14.dp))
                    Column {
                        Text(stringResource(R.string.settings_profile),
                            fontWeight = FontWeight.SemiBold, color = Color.White)
                        Text("Cycle • Symptômes • Conditions",
                            fontSize = 12.sp, color = Color.White.copy(alpha = 0.5f))
                    }
                    Spacer(Modifier.weight(1f))
                    Icon(Icons.Default.ChevronRight, null, tint = Color.White.copy(alpha = 0.3f))
                }
            }
        }

        // ─── Sync ───
        item {
            SectionHeader(stringResource(R.string.settings_sync))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.CloudUpload, null, tint = Green, modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(10.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(stringResource(R.string.settings_sync_cloud), color = Color.White)
                            Text(stringResource(R.string.settings_sync_cloud_description),
                                fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
                        }
                        Switch(checked = syncEnabled, onCheckedChange = { syncEnabled = it },
                            colors = SwitchDefaults.colors(checkedTrackColor = Purple))
                    }

                    if (syncEnabled) {
                        Spacer(Modifier.height(12.dp))
                        Button(
                            onClick = { isSyncing = true },
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                            contentPadding = PaddingValues(0.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Sync, null, tint = Blue, modifier = Modifier.size(18.dp))
                                Spacer(Modifier.width(8.dp))
                                Text(stringResource(R.string.settings_sync_now), color = Color.White)
                                Spacer(Modifier.weight(1f))
                                if (isSyncing) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(16.dp),
                                        strokeWidth = 2.dp, color = Lavender
                                    )
                                } else {
                                    Text(stringResource(R.string.settings_sync_never),
                                        fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
                                }
                            }
                        }
                    }
                }
            }
        }

        // ─── Notifications ───
        item {
            SectionHeader(stringResource(R.string.settings_notifications))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    NotificationEngine.Category.values().forEach { cat ->
                        var enabled by remember { mutableStateOf(true) }
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(vertical = 6.dp)
                        ) {
                            Text(cat.displayName, color = Color.White, modifier = Modifier.weight(1f))
                            Text("${cat.defaultHour}h", fontSize = 12.sp,
                                color = Color.White.copy(alpha = 0.3f))
                            Spacer(Modifier.width(8.dp))
                            Switch(checked = enabled, onCheckedChange = { enabled = it },
                                colors = SwitchDefaults.colors(checkedTrackColor = Purple))
                        }
                    }

                    HorizontalDivider(color = Color.White.copy(alpha = 0.06f))
                    Spacer(Modifier.height(8.dp))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.NotificationsActive, null, tint = Amber, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(10.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(stringResource(R.string.settings_daily_reminder), color = Color.White)
                            Text(stringResource(R.string.settings_daily_reminder_description),
                                fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
                        }
                        Switch(checked = dailyReminder, onCheckedChange = { dailyReminder = it },
                            colors = SwitchDefaults.colors(checkedTrackColor = Purple))
                    }
                }
            }
        }

        // ─── Privacy & Security ───
        item {
            SectionHeader(stringResource(R.string.settings_privacy))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    SettingsToggle(
                        label = stringResource(R.string.settings_privacy_biometric),
                        icon = Icons.Default.Fingerprint,
                        checked = biometricEnabled,
                        onCheckedChange = { biometricEnabled = it }
                    )

                    SettingsToggle(
                        label = stringResource(R.string.settings_privacy_widget),
                        subtitle = stringResource(R.string.settings_privacy_widget_description),
                        icon = Icons.Default.VisibilityOff, iconTint = Pink,
                        checked = widgetPrivacy,
                        onCheckedChange = { widgetPrivacy = it }
                    )

                    Spacer(Modifier.height(8.dp))

                    // Privacy badges
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        PrivacyBadge("🔒", "AES-256")
                        PrivacyBadge("🇪🇺", "Serveurs EU")
                        PrivacyBadge("✅", "0 trackers")
                    }
                }
            }
        }

        // ─── Data ───
        item {
            SectionHeader(stringResource(R.string.settings_data))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    SettingsRow(stringResource(R.string.settings_export_csv), Icons.Default.Download) { }
                    SettingsRow(stringResource(R.string.settings_export_pdf), Icons.Default.PictureAsPdf) {
                        onNavigateToExport()
                    }
                    TextButton(onClick = { showDeleteDialog = true }) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Delete, null, tint = Color.Red, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(8.dp))
                            Text(stringResource(R.string.settings_delete_account), color = Color.Red)
                        }
                    }
                }
            }
        }

        // ─── About ───
        item {
            SectionHeader(stringResource(R.string.settings_about))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBg)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    InfoRow(stringResource(R.string.settings_version), "1.0.0")
                    SettingsRow(stringResource(R.string.settings_privacy_policy), Icons.Default.Shield) {
                        onNavigateToPrivacyPolicy()
                    }
                    SettingsRow(stringResource(R.string.settings_terms), Icons.Default.Description) {
                        onNavigateToTerms()
                    }
                    SettingsRow(stringResource(R.string.settings_bug_report), Icons.Default.BugReport) { }
                }
            }
        }
    }

    // Delete dialog
    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text(stringResource(R.string.settings_delete_title)) },
            text = { Text(stringResource(R.string.settings_delete_message)) },
            confirmButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text(stringResource(R.string.settings_delete_confirm), color = Color.Red)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text(stringResource(R.string.common_cancel))
                }
            }
        )
    }
}

// ─── Reusable Components ───

@Composable
private fun SectionHeader(title: String) {
    Text(
        title.uppercase(),
        fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
        color = Lavender, letterSpacing = 1.sp,
        modifier = Modifier.padding(top = 16.dp, bottom = 6.dp)
    )
}

@Composable
private fun SettingsToggle(
    label: String,
    subtitle: String? = null,
    icon: ImageVector,
    iconTint: Color = Color.White,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 6.dp)
    ) {
        Icon(icon, null, tint = iconTint, modifier = Modifier.size(20.dp))
        Spacer(Modifier.width(10.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(label, color = Color.White)
            if (subtitle != null) {
                Text(subtitle, fontSize = 11.sp, color = Color.White.copy(alpha = 0.4f))
            }
        }
        Switch(
            checked = checked, onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(checkedTrackColor = Purple)
        )
    }
}

@Composable
private fun SettingsRow(label: String, icon: ImageVector, onClick: () -> Unit) {
    TextButton(onClick = onClick, modifier = Modifier.fillMaxWidth()) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, null, tint = Color.White, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(10.dp))
            Text(label, color = Color.White)
            Spacer(Modifier.weight(1f))
            Icon(Icons.Default.ChevronRight, null, tint = Color.White.copy(alpha = 0.2f))
        }
    }
}

@Composable
private fun InfoRow(label: String, value: String) {
    Row(modifier = Modifier.padding(vertical = 6.dp)) {
        Text(label, color = Color.White)
        Spacer(Modifier.weight(1f))
        Text(value, fontSize = 13.sp, color = Color.White.copy(alpha = 0.4f))
    }
}

@Composable
private fun PrivacyBadge(icon: String, text: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(icon, fontSize = 16.sp)
        Text(text, fontSize = 9.sp, color = Color.White.copy(alpha = 0.4f))
    }
}
