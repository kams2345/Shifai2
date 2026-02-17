package com.shifai.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.layout.*
import androidx.glance.text.*
import java.time.LocalDate

// MARK: - ShifAI Cycle Widget (Glance API)
// Spike S0-2: Android widget with privacy blur mechanism

class ShifAICycleWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = loadCycleData(context)

        provideContent {
            ShifAICycleContent(data)
        }
    }

    private fun loadCycleData(context: Context): CycleWidgetData {
        // S5-6: Read from SharedPreferences (main app writes on each log)
        val prefs = context.getSharedPreferences("shifai_widget_data", Context.MODE_PRIVATE)
        return CycleWidgetData(
            cycleDay = prefs.getInt("cycle_day", 0),
            phase = prefs.getString("phase", "—") ?: "—",
            phaseEmoji = prefs.getString("phase_emoji", "❓") ?: "❓",
            energyForecast = prefs.getInt("energy_forecast", 5),
            nextPeriodDays = if (prefs.contains("next_period_days")) prefs.getInt("next_period_days", 0) else null,
            isPrivacyMode = prefs.getBoolean("privacy_mode", false)
        )
    }
}

data class CycleWidgetData(
    val cycleDay: Int,
    val phase: String,
    val phaseEmoji: String,
    val energyForecast: Int,
    val nextPeriodDays: Int?,
    val isPrivacyMode: Boolean
)

// ─── Widget Content ───

@Composable
fun ShifAICycleContent(data: CycleWidgetData) {
    val size = LocalSize.current
    val background = Color(0xFF0D0B1A)
    val accent = Color(0xFF7C5CFC)
    val accentLight = Color(0xFFA78BFA)
    val textSecondary = Color(0xB3FFFFFF) // 70% white

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(background)
            .padding(16.dp)
    ) {
        if (data.isPrivacyMode) {
            // ─── Privacy Mode (S0-2) ───
            // Glance doesn't support Gaussian blur, so we use an opaque overlay
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "🔒",
                    style = TextStyle(fontSize = 28.sp)
                )
                Spacer(modifier = GlanceModifier.height(8.dp))
                Text(
                    text = "ShifAI",
                    style = TextStyle(
                        color = ColorProvider(accentLight),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium
                    )
                )
                Text(
                    text = "Tap to open",
                    style = TextStyle(
                        color = ColorProvider(Color(0x66FFFFFF)),
                        fontSize = 11.sp
                    )
                )
            }
        } else {
            // ─── Normal Mode ───
            Column(
                modifier = GlanceModifier.fillMaxSize()
            ) {
                // Cycle day
                Text(
                    text = "J${data.cycleDay}",
                    style = TextStyle(
                        color = ColorProvider(Color.White),
                        fontSize = 36.sp,
                        fontWeight = FontWeight.Bold
                    )
                )

                // Phase
                Text(
                    text = data.phase,
                    style = TextStyle(
                        color = ColorProvider(accentLight),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium
                    )
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                // Energy forecast
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = weatherEmoji(data.energyForecast),
                        style = TextStyle(fontSize = 16.sp)
                    )
                    Spacer(modifier = GlanceModifier.width(4.dp))
                    Text(
                        text = energyLabel(data.energyForecast),
                        style = TextStyle(
                            color = ColorProvider(textSecondary),
                            fontSize = 12.sp
                        )
                    )
                }

                // Next period
                data.nextPeriodDays?.let { days ->
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    Text(
                        text = "~${days}j avant règles",
                        style = TextStyle(
                            color = ColorProvider(Color(0x80FFFFFF)),
                            fontSize = 11.sp
                        )
                    )
                }
            }
        }
    }
}

// ─── Quick Log Widget ───

class ShifAIQuickLogWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            QuickLogContent()
        }
    }
}

@Composable
fun QuickLogContent() {
    val background = Color(0xFF0D0B1A)
    val accent = Color(0xFFA78BFA)
    val emojis = listOf("😊", "⚡", "💤", "😤", "🔴")
    val labels = listOf("Mood", "Énergie", "Sommeil", "Stress", "Douleur")

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(background)
            .padding(16.dp)
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Quick Log",
                style = TextStyle(
                    color = ColorProvider(accent),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium
                )
            )
        }

        Spacer(modifier = GlanceModifier.height(12.dp))

        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            emojis.forEachIndexed { index, emoji ->
                Column(
                    modifier = GlanceModifier
                        .padding(horizontal = 8.dp)
                        .clickable(
                            actionStartActivity<DeepLinkActivity>(
                                actionParametersOf(
                                    ActionParameters.Key<String>("type") to labels[index].lowercase()
                                )
                            )
                        ),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = emoji,
                        style = TextStyle(fontSize = 24.sp)
                    )
                    Text(
                        text = labels[index],
                        style = TextStyle(
                            color = ColorProvider(Color(0x80FFFFFF)),
                            fontSize = 10.sp
                        )
                    )
                }
            }
        }
    }
}

// ─── Deep Link Handler ───

class DeepLinkActivity : android.app.Activity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Forward to main app with quick-log deeplink
        val type = intent?.extras?.getString("type") ?: "mood"
        val deepLink = Intent(Intent.ACTION_VIEW, Uri.parse("shifai://quicklog/$type"))
        deepLink.setPackage(packageName)
        startActivity(deepLink)
        finish()
    }
}

// ─── Widget Receivers ───

class ShifAICycleWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = ShifAICycleWidget()
}

class ShifAIQuickLogWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = ShifAIQuickLogWidget()
}

// ─── Helpers ───

private fun weatherEmoji(forecast: Int) = when (forecast) {
    in 1..3 -> "🌧️"
    in 4..5 -> "☁️"
    in 6..7 -> "⛅"
    in 8..10 -> "☀️"
    else -> "☁️"
}

private fun energyLabel(forecast: Int) = when (forecast) {
    in 1..3 -> "Basse"
    in 4..5 -> "Moyenne"
    in 6..7 -> "Haute"
    in 8..10 -> "Max"
    else -> "—"
}
