package com.shifai.presentation.util

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Haptic Feedback — tactile feedback for key interactions.
 * Mirrors iOS HapticFeedback.swift.
 */
object HapticFeedback {

    // ─── Standard Patterns ───

    /** Light tap — tab switch, toggle */
    fun light(context: Context) = vibrate(context, 20, 80)

    /** Medium tap — save, confirm */
    fun medium(context: Context) = vibrate(context, 40, 128)

    /** Heavy tap — delete, important action */
    fun heavy(context: Context) = vibrate(context, 60, 200)

    /** Success — save completed, sync done */
    fun success(context: Context) = vibrate(context, 30, 100)

    /** Warning — approaching limit */
    fun warning(context: Context) = vibrate(context, 50, 150)

    /** Error — validation failed */
    fun error(context: Context) = vibrate(context, 70, 200)

    /** Selection changed — slider, picker */
    fun selection(context: Context) = vibrate(context, 10, 60)

    // ─── App-Specific Patterns ───

    fun dailyLogSaved(context: Context) = success(context)
    fun symptomAdded(context: Context) = medium(context)
    fun sliderChanged(context: Context) = selection(context)
    fun destructiveAction(context: Context) = heavy(context)
    fun biometricSuccess(context: Context) = success(context)

    // ─── Implementation ───

    private fun vibrate(context: Context, durationMs: Long, amplitude: Int) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vm.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, amplitude))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }
}
