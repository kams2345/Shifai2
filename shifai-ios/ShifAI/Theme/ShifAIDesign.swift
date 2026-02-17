import SwiftUI

/// ShifAI Design System — dark glassmorphism theme.
/// Mirrors Android ShifAITheme.kt for cross-platform parity.
enum ShifAIDesign {

    // MARK: - Background

    static let backgroundPrimary = Color(hex: 0x0F0B1E)
    static let backgroundSecondary = Color(hex: 0x1A1432)
    static let backgroundCard = Color(hex: 0x211B3A)
    static let backgroundGlass = Color(hex: 0x7C5CFC).opacity(0.2)

    // MARK: - Brand

    static let brandPrimary = Color(hex: 0x7C5CFC)
    static let brandSecondary = Color(hex: 0xE040FB)
    static let brandGradient = LinearGradient(
        colors: [brandPrimary, brandSecondary],
        startPoint: .leading, endPoint: .trailing
    )

    // MARK: - Phase Colors

    static let phaseMenstrual = Color(hex: 0xEF5350)
    static let phaseFollicular = Color(hex: 0x66BB6A)
    static let phaseOvulatory = Color(hex: 0xFFA726)
    static let phaseLuteal = Color(hex: 0x42A5F5)

    static func phaseColor(_ phase: CyclePhase) -> Color {
        switch phase {
        case .menstrual: return phaseMenstrual
        case .follicular: return phaseFollicular
        case .ovulatory: return phaseOvulatory
        case .luteal: return phaseLuteal
        case .unknown: return brandPrimary
        }
    }

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)

    // MARK: - Semantic

    static let success = Color(hex: 0x4CAF50)
    static let warning = Color(hex: 0xFF9800)
    static let error = Color(hex: 0xF44336)

    // MARK: - Flow Colors

    static let flowColors: [Color] = [
        .clear,                    // 0: none
        Color(hex: 0xFFCDD2),     // 1: light
        Color(hex: 0xEF9A9A),     // 2: medium
        Color(hex: 0xEF5350),     // 3: heavy
        Color(hex: 0xB71C1C)      // 4: very heavy
    ]

    // MARK: - Symptom Intensity

    static func symptomColor(_ intensity: Int) -> Color {
        switch intensity {
        case 1...3: return Color(hex: 0x66BB6A)   // Mild
        case 4...6: return Color(hex: 0xFFA726)   // Moderate
        default:    return Color(hex: 0xF44336)    // Severe
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }

    // MARK: - Typography

    enum Type {
        static let h1: CGFloat = 28
        static let h2: CGFloat = 22
        static let h3: CGFloat = 18
        static let body: CGFloat = 16
        static let bodySmall: CGFloat = 14
        static let caption: CGFloat = 12
        static let label: CGFloat = 11
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
