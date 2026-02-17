import SwiftUI

// MARK: - Accessibility Modifiers (S10-2)
// VoiceOver, Dynamic Type, WCAG 2.1 AA, min 44×44pt, Reduce Motion

extension View {

    // MARK: - Touch Target (min 44×44)

    func accessibleTapTarget() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }

    // MARK: - VoiceOver Labels

    func voiceOverLabel(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }

    // MARK: - Reduce Motion

    func animateIfAllowed(_ animation: Animation?, value: some Equatable) -> some View {
        self.modifier(ReduceMotionAnimationModifier(animation: animation, value: value))
    }

    // MARK: - Dynamic Type Scaling

    func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: size, weight: weight))
            .dynamicTypeSize(...DynamicTypeSize.accessibility3) // Support 100-200%
    }

    // MARK: - High Contrast Support

    func adaptiveBackground(_ lightColor: Color, darkColor: Color) -> some View {
        self.modifier(AdaptiveBackgroundModifier(lightColor: lightColor, darkColor: darkColor))
    }
}

// MARK: - Reduce Motion Modifier

struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

// MARK: - Adaptive Background

struct AdaptiveBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let lightColor: Color
    let darkColor: Color

    func body(content: Content) -> some View {
        content.background(colorScheme == .dark ? darkColor : lightColor)
    }
}

// MARK: - Accessibility IDs (for UI testing)

enum AccessibilityID {
    // Onboarding
    static let onboardingNext = "onboarding_next_button"
    static let onboardingSkip = "onboarding_skip_button"
    static let onboardingComplete = "onboarding_complete_button"

    // Dashboard
    static let dashboardCycleDay = "dashboard_cycle_day"
    static let dashboardPhase = "dashboard_phase"
    static let dashboardQuickLog = "dashboard_quick_log_button"

    // Tracking
    static let trackingFlowPicker = "tracking_flow_picker"
    static let trackingMoodSlider = "tracking_mood_slider"
    static let trackingEnergySlider = "tracking_energy_slider"
    static let trackingBodyMap = "tracking_body_map"
    static let trackingSave = "tracking_save_button"

    // Insights
    static let insightsList = "insights_list"
    static let insightsPredictionCard = "insights_prediction_card"
    static let insightsFeedbackButton = "insights_feedback_button"

    // Export
    static let exportTemplateSelector = "export_template_selector"
    static let exportDateRange = "export_date_range"
    static let exportShareButton = "export_share_button"
    static let exportPDFView = "export_pdf_view"

    // Settings
    static let settingsSyncToggle = "settings_sync_toggle"
    static let settingsManualSync = "settings_manual_sync_button"
    static let settingsBiometricToggle = "settings_biometric_toggle"
    static let settingsDeleteAccount = "settings_delete_account_button"
    static let settingsExportCSV = "settings_export_csv_button"
}

// MARK: - WCAG Color Contrast Helpers

struct WCAGContrast {
    /// Minimum contrast ratio for normal text (< 18pt)
    static let normalTextAA: CGFloat = 4.5
    /// Minimum contrast ratio for large text (>= 18pt or 14pt bold)
    static let largeTextAA: CGFloat = 3.0

    /// Calculate relative luminance
    static func luminance(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
        func adjust(_ v: CGFloat) -> CGFloat {
            v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * adjust(r) + 0.7152 * adjust(g) + 0.0722 * adjust(b)
    }

    /// Calculate contrast ratio between two luminance values
    static func contrastRatio(_ l1: CGFloat, _ l2: CGFloat) -> CGFloat {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
}
