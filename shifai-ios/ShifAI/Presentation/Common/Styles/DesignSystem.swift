import SwiftUI

// MARK: - ShifAI Design System

/// Palette de couleurs ShifAI — Dark mode, purple/indigo, no pink
enum ShifAIColors {
    // Primary palette
    static let accent = Color(hex: "7C5CFC")           // Vibrant purple
    static let accentLight = Color(hex: "A78BFA")       // Light purple
    static let accentDark = Color(hex: "5B3FD6")        // Deep purple

    // Background
    static let background = Color(hex: "0D0B1A")        // Near-black indigo
    static let backgroundSecondary = Color(hex: "161430") // Slightly lighter
    static let cardBackground = Color(hex: "1E1B3A")    // Card surface

    // Glass effect
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)

    // Semantic colors
    static let success = Color(hex: "34D399")           // Green
    static let warning = Color(hex: "FBBF24")           // Amber
    static let error = Color(hex: "F87171")             // Red (no pink)
    static let info = Color(hex: "60A5FA")              // Blue

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)

    // Insight card accents
    static let quickWin = Color(hex: "34D399")          // Green
    static let pattern = Color(hex: "60A5FA")           // Blue
    static let prediction = Color(hex: "A78BFA")        // Purple
    static let recommendation = Color(hex: "FB923C")    // Orange

    // Pain heatmap gradient
    static let painLow = Color(hex: "34D399")           // Green
    static let painMedium = Color(hex: "FBBF24")        // Yellow
    static let painHigh = Color(hex: "F87171")          // Red

    // Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, Color(hex: "1A1040"), backgroundSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentLight, accent, accentDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Cycle phase colors
    static let menstrual = Color(hex: "EF4444")         // Red
    static let follicular = Color(hex: "3B82F6")        // Blue
    static let ovulatory = Color(hex: "F59E0B")         // Amber
    static let luteal = Color(hex: "8B5CF6")            // Purple
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

enum ShifAITypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)

    // Special
    static let cycleDay = Font.system(size: 48, weight: .bold, design: .rounded)
    static let metricValue = Font.system(size: 32, weight: .bold, design: .rounded)
}

// MARK: - Spacing & Layout

enum ShifAISpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // Card
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8

    // Touch targets (WCAG: min 44pt)
    static let minTouchTarget: CGFloat = 44
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = ShifAISpacing.cardCornerRadius

    func body(content: Content) -> some View {
        content
            .padding(ShifAISpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(ShifAIColors.glassBackground)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(ShifAIColors.glassBorder, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = ShifAISpacing.cardCornerRadius) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
