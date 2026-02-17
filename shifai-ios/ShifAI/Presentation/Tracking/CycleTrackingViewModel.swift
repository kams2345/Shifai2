import Foundation
import Combine

// MARK: - Cycle Tracking ViewModel
// S2-1: Manages cycle state, period logging, phase detection

final class CycleTrackingViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentCycleDay: Int = 1
    @Published var currentPhase: CyclePhase = .unknown
    @Published var isOnPeriod: Bool = false
    @Published var flowIntensity: Int = 0
    @Published var cervicalMucus: CervicalMucus? = nil
    @Published var notes: String = ""
    @Published var selectedDate: Date = Date()
    @Published var daysUntilNextPeriod: Int? = nil
    @Published var averageCycleLength: Int? = nil
    @Published var recentEntries: [CycleEntry] = []

    // MARK: - Dependencies

    private let cycleRepo: CycleRepositoryProtocol
    private let ruleEngine: RuleEngine

    init(
        cycleRepo: CycleRepositoryProtocol = CycleRepository(),
        ruleEngine: RuleEngine = RuleEngine()
    ) {
        self.cycleRepo = cycleRepo
        self.ruleEngine = ruleEngine
    }

    // MARK: - Data Loading

    func loadData() {
        loadCurrentCycle()
        loadRecentEntries()
        computePredictions()
    }

    private func loadCurrentCycle() {
        // Fetch today's entry
        if let entry = try? cycleRepo.fetchCurrent() {
            currentCycleDay = entry.cycleDay
            currentPhase = entry.phase
            isOnPeriod = entry.flowIntensity != nil && entry.flowIntensity! > 0
            flowIntensity = entry.flowIntensity ?? 0
            cervicalMucus = entry.cervicalMucus
            notes = entry.notes ?? ""
        } else {
            // Calculate from last period
            let lastEntries = (try? cycleRepo.fetchLast(count: 90)) ?? []
            if let lastPeriodStart = lastEntries.first(where: { ($0.flowIntensity ?? 0) > 0 }) {
                currentCycleDay = cycleRepo.calculateCurrentCycleDay(from: lastPeriodStart.date)
                currentPhase = detectPhase(cycleDay: currentCycleDay)
            }
        }
    }

    private func loadRecentEntries() {
        recentEntries = (try? cycleRepo.fetchLast(count: 14)) ?? []
    }

    private func computePredictions() {
        let entries = (try? cycleRepo.fetchLast(count: 90)) ?? []
        guard entries.count >= 2 else { return }

        // Calculate average cycle length
        let cycleLengths = extractCycleLengths(from: entries)
        if !cycleLengths.isEmpty {
            averageCycleLength = cycleLengths.reduce(0, +) / cycleLengths.count
        }

        // Days until next period
        if let avgLength = averageCycleLength {
            let remaining = avgLength - currentCycleDay
            daysUntilNextPeriod = remaining > 0 ? remaining : nil
        }
    }

    // MARK: - Actions

    func togglePeriod() {
        isOnPeriod.toggle()
        if isOnPeriod {
            flowIntensity = 3 // Default medium
            currentCycleDay = 1
            currentPhase = .menstrual
        } else {
            flowIntensity = 0
        }
        saveEntry()
    }

    func saveEntry() {
        let entry = CycleEntry(
            id: UUID().uuidString,
            date: Calendar.current.startOfDay(for: selectedDate),
            cycleDay: currentCycleDay,
            phase: currentPhase,
            flowIntensity: flowIntensity > 0 ? flowIntensity : nil,
            cervicalMucus: cervicalMucus,
            basalTemp: nil,
            notes: notes.isEmpty ? nil : notes,
            createdAt: Date(),
            updatedAt: Date()
        )

        try? cycleRepo.save(entry)
        loadRecentEntries()
    }

    // MARK: - Phase Detection

    func detectPhase(cycleDay: Int, cycleLength: Int = 28) -> CyclePhase {
        let adjustedLength = averageCycleLength ?? cycleLength

        if cycleDay <= 5 { return .menstrual }
        if cycleDay <= (adjustedLength / 2 - 2) { return .follicular }
        if cycleDay <= (adjustedLength / 2 + 2) { return .ovulatory }
        if cycleDay <= adjustedLength { return .luteal }
        return .unknown
    }

    // MARK: - Cycle Length Extraction

    private func extractCycleLengths(from entries: [CycleEntry]) -> [Int] {
        // Find period start dates (cycle_day == 1 or flow > 0 after no flow)
        let periodStarts = entries
            .filter { $0.cycleDay == 1 || ($0.flowIntensity ?? 0) > 0 }
            .map { $0.date }
            .sorted()

        guard periodStarts.count >= 2 else { return [] }

        var lengths: [Int] = []
        for i in 1..<periodStarts.count {
            let days = Calendar.current.dateComponents([.day], from: periodStarts[i-1], to: periodStarts[i]).day ?? 0
            if days >= 18 && days <= 60 { // Valid cycle range
                lengths.append(days)
            }
        }
        return lengths
    }
}

// MARK: - CyclePhase Extensions

extension CyclePhase {
    var displayName: String {
        switch self {
        case .menstrual: return "Menstruelle"
        case .follicular: return "Folliculaire"
        case .ovulatory: return "Ovulatoire"
        case .luteal: return "Lutéale"
        case .unknown: return "—"
        }
    }

    var emoji: String {
        switch self {
        case .menstrual: return "🔴"
        case .follicular: return "🌱"
        case .ovulatory: return "🌸"
        case .luteal: return "🌙"
        case .unknown: return "❓"
        }
    }

    var color: Color {
        switch self {
        case .menstrual: return Color(hex: "EF4444")
        case .follicular: return Color(hex: "34D399")
        case .ovulatory: return Color(hex: "F59E0B")
        case .luteal: return Color(hex: "A78BFA")
        case .unknown: return .gray
        }
    }
}

extension CervicalMucus {
    var displayName: String {
        switch self {
        case .dry: return "Sec"
        case .sticky: return "Collant"
        case .creamy: return "Crémeux"
        case .watery: return "Aqueux"
        case .eggWhite: return "Blanc d'œuf"
        }
    }
}
