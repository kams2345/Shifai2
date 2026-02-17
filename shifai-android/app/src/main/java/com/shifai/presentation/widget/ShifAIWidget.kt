package com.shifai.presentation.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.shifai.presentation.MainActivity

/**
 * ShifAI Glance Widget — cycle day + phase display.
 * Mirrors iOS WidgetKit widget for cross-platform parity.
 */
class ShifAIWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            ShifAIWidgetContent()
        }
    }
}

class ShifAIWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ShifAIWidget()
}

@Composable
fun ShifAIWidgetContent() {
    val prefs = currentState<androidx.glance.appwidget.GlanceAppWidgetManager>()
    // Read from SharedPreferences (populated by WidgetDataProvider)
    val cycleDay = 14 // TODO: Read from SharedPreferences
    val cycleDayTotal = 28
    val phase = "Ovulatoire"
    val phaseEmoji = "☀️"
    val energy = "Bonne énergie"

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(Color(0xFF0F0B1E)))
            .padding(12.dp)
            .clickable(actionStartActivity<MainActivity>()),
        verticalAlignment = Alignment.Vertical.CenterVertically
    ) {
        // Header
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Horizontal.Start
        ) {
            Text(
                text = "ShifAI",
                style = TextStyle(
                    color = ColorProvider(Color(0xFF7C5CFC)),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }

        Spacer(modifier = GlanceModifier.height(8.dp))

        // Cycle Day
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Horizontal.CenterHorizontally
        ) {
            Text(
                text = "J$cycleDay",
                style = TextStyle(
                    color = ColorProvider(Color.White),
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            Text(
                text = " / $cycleDayTotal",
                style = TextStyle(
                    color = ColorProvider(Color(0x80FFFFFF)),
                    fontSize = 16.sp
                )
            )
        }

        Spacer(modifier = GlanceModifier.height(4.dp))

        // Phase
        Text(
            text = "$phaseEmoji $phase",
            style = TextStyle(
                color = ColorProvider(Color(0xCCFFFFFF)),
                fontSize = 14.sp
            ),
            modifier = GlanceModifier.fillMaxWidth()
        )

        Spacer(modifier = GlanceModifier.height(4.dp))

        // Energy
        Text(
            text = "⚡ $energy",
            style = TextStyle(
                color = ColorProvider(Color(0x99FFFFFF)),
                fontSize = 11.sp
            ),
            modifier = GlanceModifier.fillMaxWidth()
        )
    }
}
