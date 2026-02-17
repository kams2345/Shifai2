package com.shifai.presentation.theme

import androidx.compose.ui.graphics.Color

/**
 * ShifAI Design System — dark glassmorphism theme.
 * All colors, typography scales, and spacing in one place.
 */
object ShifAITheme {

    // ─── Background ───
    val backgroundPrimary = Color(0xFF0F0B1E)
    val backgroundSecondary = Color(0xFF1A1432)
    val backgroundCard = Color(0xFF211B3A)
    val backgroundGlass = Color(0x337C5CFC)     // 20% opacity

    // ─── Brand ───
    val brandPrimary = Color(0xFF7C5CFC)         // Purple
    val brandSecondary = Color(0xFFE040FB)        // Magenta
    val brandGradientStart = Color(0xFF7C5CFC)
    val brandGradientEnd = Color(0xFFE040FB)

    // ─── Phase Colors ───
    val phaseMenstrual = Color(0xFFEF5350)        // Red
    val phaseFollicular = Color(0xFF66BB6A)       // Green
    val phaseOvulatory = Color(0xFFFFA726)        // Orange
    val phaseLuteal = Color(0xFF42A5F5)           // Blue

    // ─── Text ───
    val textPrimary = Color(0xFFFFFFFF)
    val textSecondary = Color(0xB3FFFFFF)         // 70% white
    val textTertiary = Color(0x80FFFFFF)          // 50% white
    val textAccent = Color(0xFF7C5CFC)

    // ─── Semantic ───
    val success = Color(0xFF4CAF50)
    val warning = Color(0xFFFF9800)
    val error = Color(0xFFF44336)
    val info = Color(0xFF2196F3)

    // ─── Chart ───
    val chartLine = Color(0xFF7C5CFC)
    val chartFill = Color(0x337C5CFC)
    val chartGrid = Color(0x1AFFFFFF)

    // ─── Spacing ───
    object Spacing {
        const val xs = 4
        const val sm = 8
        const val md = 16
        const val lg = 24
        const val xl = 32
        const val xxl = 48
    }

    // ─── Corner Radius ───
    object Radius {
        const val sm = 8
        const val md = 12
        const val lg = 16
        const val xl = 24
        const val pill = 999
    }

    // ─── Typography Scale ───
    object Type {
        const val h1 = 28
        const val h2 = 22
        const val h3 = 18
        const val body = 16
        const val bodySmall = 14
        const val caption = 12
        const val label = 11
    }

    // ─── Elevation ───
    object Elevation {
        const val card = 4
        const val modal = 8
        const val toast = 12
    }

    // ─── Flow Intensity Colors ───
    val flowColors = listOf(
        Color(0x00FFFFFF),   // 0: none
        Color(0xFFFFCDD2),   // 1: light
        Color(0xFFEF9A9A),   // 2: medium
        Color(0xFFEF5350),   // 3: heavy
        Color(0xFFB71C1C)    // 4: very heavy
    )

    // ─── Symptom Intensity Gradient ───
    fun symptomColor(intensity: Int): Color = when {
        intensity <= 3 -> Color(0xFF66BB6A)   // Green (mild)
        intensity <= 6 -> Color(0xFFFFA726)   // Orange (moderate)
        else -> Color(0xFFF44336)             // Red (severe)
    }
}
