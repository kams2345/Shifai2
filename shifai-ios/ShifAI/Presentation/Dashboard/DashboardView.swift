import SwiftUI

// MARK: - Dashboard View (Full Implementation)
// S2-8: Météo Intérieure, quick-log, cycle phase, insights, navigation

struct DashboardView: View {
    @StateObject private var viewModel = DashboardFullViewModel()
    @State private var showDailyLog = false
    @State private var showSymptoms = false
    @State private var showBodyMap = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Météo Intérieure Card
                    meteoCard

                    // Today's summary
                    todaySummaryRow

                    // Quick-log buttons
                    quickLogRow

                    // Latest insight
                    if let insight = viewModel.latestInsight {
                        insightCard(insight)
                    }

                    // Prediction card
                    if let prediction = viewModel.latestPrediction {
                        predictionCard(prediction)
                    }
                }
                .padding(16)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationTitle("ShifAI")
            .refreshable { viewModel.refresh() }
            .sheet(isPresented: $showDailyLog) { DailyLogView() }
            .sheet(isPresented: $showSymptoms) { SymptomLoggingView() }
            .sheet(isPresented: $showBodyMap) { BodyMapView() }
            .onAppear { viewModel.loadData() }
        }
    }

    // MARK: - Météo Intérieure

    private var meteoCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Météo Intérieure")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))

                    Text("Jour \(viewModel.cycleDay)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(viewModel.phase.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.phase.color)
                }

                Spacer()

                // Energy forecast
                VStack(spacing: 4) {
                    Text(viewModel.phase.emoji)
                        .font(.system(size: 44))

                    if let energy = viewModel.energyForecast {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                            Text("\(energy)/10")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(energyForecastColor(energy))
                    }
                }
            }

            // Cycle progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [viewModel.phase.color, viewModel.phase.color.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * viewModel.cycleProgress, height: 6)
                }
            }
            .frame(height: 6)

            // Days remaining
            if let daysLeft = viewModel.daysUntilPeriod {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Text("~\(daysLeft) jours avant prochaines règles")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }
            }
        }
        .padding(20)
        .modifier(GlassCardModifier())
    }

    // MARK: - Today's Summary

    private var todaySummaryRow: some View {
        HStack(spacing: 12) {
            summaryPill(
                emoji: viewModel.todayMoodEmoji ?? "—",
                label: "Humeur"
            )
            summaryPill(
                emoji: viewModel.todayEnergy != nil ? "⚡\(viewModel.todayEnergy!)" : "—",
                label: "Énergie"
            )
            summaryPill(
                emoji: viewModel.todaySleep != nil ? "🌙\(viewModel.todaySleep!)h" : "—",
                label: "Sommeil"
            )
            summaryPill(
                emoji: viewModel.todayStressEmoji ?? "—",
                label: "Stress"
            )
        }
    }

    private func summaryPill(emoji: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 16))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }

    // MARK: - Quick Log Buttons

    private var quickLogRow: some View {
        HStack(spacing: 10) {
            quickLogButton(icon: "pencil.and.list.clipboard", label: "Log du jour", color: "7C5CFC") {
                showDailyLog = true
            }
            quickLogButton(icon: "stethoscope", label: "Symptômes", color: "F59E0B") {
                showSymptoms = true
            }
            quickLogButton(icon: "figure.stand", label: "Body Map", color: "EF4444") {
                showBodyMap = true
            }
        }
    }

    private func quickLogButton(icon: String, label: String, color: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: color).opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: color).opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Insight Card

    private func insightCard(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(insight.type.color)
                    .frame(width: 8, height: 8)
                Text(insight.type.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(insight.type.color)
                Spacer()
                if !insight.isRead {
                    Text("Nouveau")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "7C5CFC"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Color(hex: "7C5CFC").opacity(0.15))
                        )
                }
            }

            Text(insight.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Text(insight.body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2)
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Prediction Card

    private func predictionCard(_ prediction: Prediction) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "A78BFA"))
                Text("Prédiction")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "A78BFA"))
                Spacer()
                Text("Fiabilité: \(Int(prediction.confidence * 100))%")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }

            Text(prediction.predictedDate.formatted(.dateTime.day().month(.wide)))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("±\(prediction.confidenceRange) jours")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))

            if let reasoning = prediction.reasoning {
                Text(reasoning)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Helpers

    private func energyForecastColor(_ energy: Int) -> Color {
        switch energy {
        case 1...3: return Color(hex: "EF4444")
        case 4...5: return Color(hex: "FBBF24")
        case 6...7: return Color(hex: "34D399")
        case 8...10: return Color(hex: "22D3EE")
        default: return .gray
        }
    }
}

// MARK: - InsightType Extensions

extension InsightType {
    var color: Color {
        switch self {
        case .quickWin: return Color(hex: "34D399")
        case .pattern: return Color(hex: "3B82F6")
        case .prediction: return Color(hex: "A78BFA")
        case .recommendation: return Color(hex: "F59E0B")
        case .education: return Color(hex: "22D3EE")
        }
    }

    var label: String {
        switch self {
        case .quickWin: return "Quick Win"
        case .pattern: return "Pattern"
        case .prediction: return "Prédiction"
        case .recommendation: return "Conseil"
        case .education: return "Info"
        }
    }
}

// MARK: - Dashboard Full ViewModel

final class DashboardFullViewModel: ObservableObject {
    @Published var cycleDay: Int = 1
    @Published var phase: CyclePhase = .unknown
    @Published var cycleProgress: CGFloat = 0
    @Published var daysUntilPeriod: Int? = nil
    @Published var energyForecast: Int? = nil

    @Published var todayMoodEmoji: String? = nil
    @Published var todayEnergy: Int? = nil
    @Published var todaySleep: Int? = nil
    @Published var todayStressEmoji: String? = nil

    @Published var latestInsight: Insight? = nil
    @Published var latestPrediction: Prediction? = nil

    private let cycleRepo: CycleRepositoryProtocol
    private let symptomRepo: SymptomRepositoryProtocol
    private let insightRepo: InsightRepositoryProtocol
    private let predictionRepo: PredictionRepositoryProtocol
    private let ruleEngine: RuleEngine

    init(
        cycleRepo: CycleRepositoryProtocol = CycleRepository(),
        symptomRepo: SymptomRepositoryProtocol = SymptomRepository(),
        insightRepo: InsightRepositoryProtocol = InsightRepository(),
        predictionRepo: PredictionRepositoryProtocol = PredictionRepository(),
        ruleEngine: RuleEngine = RuleEngine()
    ) {
        self.cycleRepo = cycleRepo
        self.symptomRepo = symptomRepo
        self.insightRepo = insightRepo
        self.predictionRepo = predictionRepo
        self.ruleEngine = ruleEngine
    }

    func loadData() {
        loadCycleState()
        loadTodayLogs()
        loadInsights()
    }

    func refresh() {
        loadData()
    }

    private func loadCycleState() {
        let entries = (try? cycleRepo.fetchLast(count: 90)) ?? []
        guard let lastEntry = entries.first else { return }

        cycleDay = Calendar.current.dateComponents([.day], from: lastEntry.date, to: Date()).day! + lastEntry.cycleDay

        // Detect phase
        let avgLength = 28 // Use rule engine for better calc
        if cycleDay <= 5 { phase = .menstrual }
        else if cycleDay <= (avgLength / 2 - 2) { phase = .follicular }
        else if cycleDay <= (avgLength / 2 + 2) { phase = .ovulatory }
        else if cycleDay <= avgLength { phase = .luteal }
        else { phase = .unknown }

        cycleProgress = min(CGFloat(cycleDay) / CGFloat(avgLength), 1.0)

        let remaining = avgLength - cycleDay
        daysUntilPeriod = remaining > 0 ? remaining : nil

        // Energy forecast from rule engine
        energyForecast = ruleEngine.predictEnergy(cycleDay: cycleDay, phase: phase)
    }

    private func loadTodayLogs() {
        let today = Date()
        let logs = (try? symptomRepo.fetchForDate(today)) ?? []

        // Parse mood, energy, sleep, stress from log notes
        for log in logs {
            if let notes = log.notes {
                if notes.hasPrefix("mood:") {
                    todayMoodEmoji = moodLabelToEmoji(String(notes.dropFirst(5)))
                }
                if notes.hasPrefix("energy:") {
                    todayEnergy = Int(notes.dropFirst(7))
                }
                if notes.hasPrefix("sleep:") {
                    // Parse "sleep:7h30m quality:3"
                    if let hIndex = notes.firstIndex(of: "h") {
                        let hourStr = String(notes[notes.index(notes.startIndex, offsetBy: 6)..<hIndex])
                        todaySleep = Int(hourStr)
                    }
                }
                if notes.hasPrefix("stress:") {
                    let level = Int(notes.dropFirst(7)) ?? 3
                    todayStressEmoji = ["😌", "🙂", "😐", "😰", "🤯"][min(level - 1, 4)]
                }
            }
        }
    }

    private func loadInsights() {
        latestInsight = (try? insightRepo.fetchRecent(limit: 1))?.first
        latestPrediction = try? predictionRepo.fetchLatest()
    }

    private func moodLabelToEmoji(_ label: String) -> String {
        switch label {
        case "Super": return "😄"
        case "Bien": return "😊"
        case "Neutre": return "😐"
        case "Triste": return "😔"
        case "Mal": return "😢"
        case "En colère": return "😤"
        case "Anxieuse": return "😰"
        default: return "😐"
        }
    }
}
