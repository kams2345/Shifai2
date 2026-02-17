import Foundation

// MARK: - Dashboard ViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var cycleDay: Int = 12
    @Published var currentPhase: CyclePhase = .follicular
    @Published var energyPrediction: Int? = 7
    @Published var energyConfidence: Double? = 0.72
    @Published var latestInsight: Insight?

    private let ruleEngine = RuleEngine()

    var energyPredictionText: String {
        switch energyPrediction ?? 5 {
        case 1...3: return "Énergie basse prévue"
        case 4...5: return "Énergie moyenne prévue"
        case 6...7: return "Énergie haute prévue"
        case 8...10: return "Énergie au max ! 🔥"
        default: return "Énergie indéterminée"
        }
    }

    init() {
        // TODO: Load actual data from repository
        loadMockData()
    }

    func quickLog(_ item: QuickLogItem) {
        // TODO: Present quick-log sheet for the selected item
    }

    func refreshInsights() {
        // TODO: Regenerate insights from rule engine
    }

    private func loadMockData() {
        latestInsight = Insight(
            date: "2026-02-10",
            type: .pattern,
            title: "Ton énergie augmente J10-J14 depuis 3 cycles",
            body: "Ce pattern est typique de la phase folliculaire. Profites-en !",
            confidence: 0.68,
            reasoning: "Basé sur: sommeil stable, stress bas, jour du cycle",
            source: .ruleBased
        )
    }
}
