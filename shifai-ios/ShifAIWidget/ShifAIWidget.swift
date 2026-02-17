import WidgetKit
import SwiftUI

// MARK: - ShifAI Widget Bundle
// Spike S0-2: Widget with privacy blur mechanism

@main
struct ShifAIWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShifAICycleWidget()
        ShifAIQuickLogWidget()
        if #available(iOSApplicationExtension 16.1, *) {
            ShifAILockScreenWidget()
        }
    }
}

// MARK: - Timeline Provider

struct ShifAITimelineProvider: TimelineProvider {
    typealias Entry = ShifAICycleEntry

    func placeholder(in context: Context) -> ShifAICycleEntry {
        ShifAICycleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ShifAICycleEntry) -> Void) {
        completion(ShifAICycleEntry.preview)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShifAICycleEntry>) -> Void) {
        // Read from App Group shared database (read-only)
        let entry = loadCurrentCycleData()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func loadCurrentCycleData() -> ShifAICycleEntry {
        // S5-6: Read from App Group shared container (local data only)
        let provider = WidgetDataProvider.shared
        let data = provider.readWidgetData()
        return ShifAICycleEntry(
            date: Date(),
            cycleDay: data.cycleDay,
            phase: data.phase,
            phaseEmoji: data.phaseEmoji,
            energyForecast: data.energyForecast,
            nextPeriodDays: data.nextPeriodDays,
            isPrivacyMode: provider.isPrivacyModeEnabled
        )
    }
}

// MARK: - Timeline Entry

struct ShifAICycleEntry: TimelineEntry {
    let date: Date
    let cycleDay: Int
    let phase: String
    let phaseEmoji: String
    let energyForecast: Int // 1-10
    let nextPeriodDays: Int?
    let isPrivacyMode: Bool

    static let placeholder = ShifAICycleEntry(
        date: Date(),
        cycleDay: 12,
        phase: "Folliculaire",
        phaseEmoji: "🌱",
        energyForecast: 7,
        nextPeriodDays: 16,
        isPrivacyMode: false
    )

    static let preview = placeholder
}

// MARK: - Cycle Widget (Small + Medium + Large)

struct ShifAICycleWidget: Widget {
    let kind = "ShifAICycleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShifAITimelineProvider()) { entry in
            ShifAICycleWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0D0B1A")
                }
        }
        .configurationDisplayName("Mon Cycle")
        .description("Jour du cycle, phase, et météo intérieure")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Views

struct ShifAICycleWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ShifAICycleEntry

    var body: some View {
        ZStack {
            // Privacy Mode: Gaussian blur overlay
            if entry.isPrivacyMode {
                privacyBlurView
            } else {
                switch family {
                case .systemSmall:
                    smallWidgetView
                case .systemMedium:
                    mediumWidgetView
                case .systemLarge:
                    largeWidgetView
                @unknown default:
                    smallWidgetView
                }
            }
        }
    }

    // MARK: - Privacy Blur (Spike S0-2 Core)

    /// When privacy mode is active, all health data is hidden
    /// behind a Gaussian blur with a "Tap to reveal" prompt
    private var privacyBlurView: some View {
        ZStack {
            // Blurred background (simulated health data)
            VStack {
                Text("J\(entry.cycleDay)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text(entry.phase)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .blur(radius: 20) // Heavy Gaussian blur

            // Privacy overlay
            VStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "7C5CFC"))

                Text("ShifAI")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))

                Text("Tap to open")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }

    // MARK: - Small Widget

    private var smallWidgetView: some View {
        VStack(spacing: 4) {
            Text("J\(entry.cycleDay)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(entry.phase)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "A78BFA"))

            Spacer()

            // Energy weather icon
            HStack(spacing: 4) {
                Image(systemName: weatherIcon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "FBBF24"))

                Text(energyLabel)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(12)
    }

    // MARK: - Medium Widget

    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Left: Cycle day + phase
            VStack(alignment: .leading, spacing: 4) {
                Text("J\(entry.cycleDay)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(entry.phase)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "A78BFA"))

                if let days = entry.nextPeriodDays {
                    Text("~\(days)j avant règles")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // Right: Energy forecast + quick log
            VStack(spacing: 8) {
                // Energy
                VStack(spacing: 2) {
                    Image(systemName: weatherIcon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "FBBF24"))
                    Text(energyLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }

                // Quick log buttons
                HStack(spacing: 12) {
                    quickLogButton(emoji: "😊", label: "Mood")
                    quickLogButton(emoji: "⚡", label: "Energie")
                }
            }
        }
        .padding(16)
    }

    // MARK: - Large Widget

    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("J\(entry.cycleDay)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(entry.phase)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "A78BFA"))
                }
                Spacer()
                VStack(spacing: 2) {
                    Image(systemName: weatherIcon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "FBBF24"))
                    Text(energyLabel)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Divider()
                .background(.white.opacity(0.15))

            // Quick stats
            if let days = entry.nextPeriodDays {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(hex: "EF4444"))
                    Text("Prochaines règles dans ~\(days) jours")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            // Quick log row
            HStack(spacing: 12) {
                quickLogButton(emoji: "😊", label: "Mood")
                quickLogButton(emoji: "⚡", label: "Énergie")
                quickLogButton(emoji: "💤", label: "Sommeil")
                quickLogButton(emoji: "🔴", label: "Douleur")
            }
        }
        .padding(16)
    }

    // MARK: - Quick Log Button

    private func quickLogButton(emoji: String, label: String) -> some View {
        Link(destination: URL(string: "shifai://quicklog/\(label.lowercased())")!) {
            VStack(spacing: 2) {
                Text(emoji)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(minWidth: 44, minHeight: 44) // WCAG touch target
        }
    }

    // MARK: - Helpers

    private var weatherIcon: String {
        switch entry.energyForecast {
        case 1...3: return "cloud.rain.fill"
        case 4...5: return "cloud.fill"
        case 6...7: return "cloud.sun.fill"
        case 8...10: return "sun.max.fill"
        default: return "cloud.fill"
        }
    }

    private var energyLabel: String {
        switch entry.energyForecast {
        case 1...3: return "Basse"
        case 4...5: return "Moyenne"
        case 6...7: return "Haute"
        case 8...10: return "Max"
        default: return "—"
        }
    }
}

// MARK: - Quick Log Widget (Medium only)

struct ShifAIQuickLogWidget: Widget {
    let kind = "ShifAIQuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShifAITimelineProvider()) { entry in
            ShifAIQuickLogWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0D0B1A")
                }
        }
        .configurationDisplayName("Quick Log")
        .description("Log rapide depuis l'écran d'accueil")
        .supportedFamilies([.systemMedium])
    }
}

struct ShifAIQuickLogWidgetView: View {
    let entry: ShifAICycleEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Quick Log")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "A78BFA"))
                Spacer()
                Text("J\(entry.cycleDay)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            HStack(spacing: 16) {
                ForEach(["😊", "⚡", "💤", "😤", "🔴"], id: \.self) { emoji in
                    Link(destination: URL(string: "shifai://quicklog/\(emoji)")!) {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - Lock Screen Widget

@available(iOSApplicationExtension 16.1, *)
struct ShifAILockScreenWidget: Widget {
    let kind = "ShifAILockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShifAITimelineProvider()) { entry in
            ShifAILockScreenView(entry: entry)
        }
        .configurationDisplayName("Cycle Day")
        .description("Jour du cycle sur l'écran de verrouillage")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ShifAILockScreenView: View {
    @Environment(\.widgetFamily) var family
    let entry: ShifAICycleEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("J\(entry.cycleDay)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(entry.phaseEmoji)
                        .font(.system(size: 10))
                }
            }

        case .accessoryInline:
            Text("J\(entry.cycleDay) \(entry.phaseEmoji) \(entry.phase)")

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("J\(entry.cycleDay) · \(entry.phase)")
                    .font(.system(size: 13, weight: .bold))
                if let days = entry.nextPeriodDays {
                    Text("~\(days)j avant règles")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

        @unknown default:
            Text("J\(entry.cycleDay)")
        }
    }
}

// MARK: - Color Extension (for Widget target)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
