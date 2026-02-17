import UIKit

/// Haptic Feedback Manager — provides tactile feedback for key interactions.
/// Centralizes all haptic patterns for consistency.
enum HapticFeedback {

    // MARK: - Standard Patterns

    /// Light tap — tab switch, toggle
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium tap — save, confirm
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy tap — delete, important action
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// Success — save completed, sync done
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning — approaching limit, quiet hours
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Error — validation failed, sync error
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Selection changed — slider, picker
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - App-Specific Patterns

    /// Daily log saved successfully
    static func dailyLogSaved() {
        success()
    }

    /// Symptom added to body map
    static func symptomAdded() {
        medium()
    }

    /// Flow slider changed
    static func sliderChanged() {
        selection()
    }

    /// Account deletion confirmed
    static func destructiveAction() {
        heavy()
    }

    /// Biometric unlock success
    static func biometricSuccess() {
        success()
    }
}
