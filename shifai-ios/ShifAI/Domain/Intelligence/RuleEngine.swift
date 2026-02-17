import Foundation

// MARK: - Rule Engine (Phase 1 Intelligence)
// Heuristic-based predictions for days 1-13

final class RuleEngine {

    // MARK: - Cycle Prediction

    /// Predict next period start date based on cycle history
    /// Uses weighted average of last 3 cycles (most recent = highest weight)
    func predictNextPeriod(from cycleEntries: [CycleEntry]) -> Prediction? {
        let cycleLengths = calculateCycleLengths(from: cycleEntries)
        guard cycleLengths.count >= 2 else { return nil }

        let lastCycles = Array(cycleLengths.suffix(3))
        let weights: [Double] = lastCycles.count == 3 ? [0.5, 0.3, 0.2] : [0.6, 0.4]
        let weightedAvg = zip(lastCycles, weights).reduce(0.0) { $0 + Double($1.0) * $1.1 }
        let predictedCycleLength = Int(round(weightedAvg))

        // Confidence based on cycle regularity
        let stdDev = standardDeviation(cycleLengths.map { Double($0) })
        let confidence = max(0.3, min(0.85, 1.0 - (stdDev / 10.0)))

        guard let lastPeriodStart = findLastPeriodStart(from: cycleEntries) else { return nil }

        let predictedDate = Calendar.current.date(
            byAdding: .day, value: predictedCycleLength, to: lastPeriodStart
        )

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return Prediction(
            id: UUID().uuidString,
            type: .periodStart,
            predictedDate: predictedDate.map { formatter.string(from: $0) },
            predictedValue: nil,
            confidence: confidence,
            actualDate: nil,
            actualValue: nil,
            accuracyScore: nil,
            modelVersion: "rule_engine_v1",
            createdAt: Date()
        )
    }

    // MARK: - Pattern Detection

    /// Detect simple correlations between tracked data points
    func detectPatterns(symptoms: [SymptomLog], cycles: [CycleEntry]) -> [Insight] {
        var insights: [Insight] = []

        // Pattern: Energy by cycle phase
        if let energyPhaseInsight = detectEnergyPhasePattern(symptoms: symptoms, cycles: cycles) {
            insights.append(energyPhaseInsight)
        }

        // Pattern: Sleep-energy correlation
        if let sleepEnergyInsight = detectSleepEnergyCorrelation(symptoms: symptoms) {
            insights.append(sleepEnergyInsight)
        }

        // Pattern: Stress-pain correlation
        if let stressPainInsight = detectStressPainCorrelation(symptoms: symptoms) {
            insights.append(stressPainInsight)
        }

        return insights
    }

    // MARK: - Quick Wins

    /// Generate Day 1 Quick Win: benchmark sleep vs average
    func generateQuickWinDay1(symptoms: [SymptomLog]) -> Insight? {
        let sleepLogs = symptoms.filter { $0.symptomType == .sleep }
        guard !sleepLogs.isEmpty else { return nil }

        let avgSleep = Double(sleepLogs.map(\.value).reduce(0, +)) / Double(sleepLogs.count)
        let benchmarkAvg = 7.0 // Average for women 25-35

        let comparison = avgSleep >= benchmarkAvg ? "meilleur" : "en dessous de"
        let percentage = abs(Int(((avgSleep - benchmarkAvg) / benchmarkAvg) * 100))

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return Insight(
            id: UUID().uuidString,
            date: formatter.string(from: Date()),
            type: .quickWin,
            title: "Ton sommeil est \(percentage)% \(comparison) la moyenne 🎉",
            body: "La moyenne de sommeil recommandée est de \(benchmarkAvg)h. Tu es à ~\(String(format: "%.1f", avgSleep))h.",
            confidence: 0.9,
            reasoning: "Basé sur tes \(sleepLogs.count) entrées de sommeil, comparé aux recommandations pour ta tranche d'âge.",
            source: .ruleBased
        )
    }

    /// Generate Day 3 Quick Win: mini-pattern detection
    func generateQuickWinDay3(symptoms: [SymptomLog]) -> Insight? {
        let energyLogs = symptoms.filter { $0.symptomType == .energy }.sorted { $0.date < $1.date }
        guard energyLogs.count >= 3 else { return nil }

        let trend = energyLogs.last!.value - energyLogs.first!.value
        let trendText = trend > 0 ? "augmenté" : (trend < 0 ? "diminué" : "resté stable")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return Insight(
            id: UUID().uuidString,
            date: formatter.string(from: Date()),
            type: .quickWin,
            title: "Ton énergie a \(trendText) ces 3 jours 📈",
            body: "Ton corps suit un rythme. Continue à logger pour découvrir tes patterns !",
            confidence: 0.7,
            reasoning: "Basé sur tes 3 dernières entrées d'énergie: \(energyLogs.map { String($0.value) }.joined(separator: " → "))",
            source: .ruleBased
        )
    }

    // MARK: - Private Helpers

    private func calculateCycleLengths(from entries: [CycleEntry]) -> [Int] {
        let periodStarts = entries
            .filter { ($0.flowIntensity ?? 0) > 0 }
            .sorted { $0.date < $1.date }

        // Group consecutive period days into cycle starts
        var cycleStarts: [String] = []
        var lastDate: String?

        for entry in periodStarts {
            if let last = lastDate {
                // If more than 3 days gap, it's a new cycle
                if daysBetween(last, entry.date) > 3 {
                    cycleStarts.append(entry.date)
                }
            } else {
                cycleStarts.append(entry.date)
            }
            lastDate = entry.date
        }

        // Calculate lengths between consecutive starts
        var lengths: [Int] = []
        for i in 1..<cycleStarts.count {
            if let days = daysBetween(cycleStarts[i-1], cycleStarts[i]) as Int? {
                lengths.append(days)
            }
        }
        return lengths
    }

    private func findLastPeriodStart(from entries: [CycleEntry]) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return entries
            .filter { ($0.flowIntensity ?? 0) > 0 }
            .sorted { $0.date > $1.date }
            .first
            .flatMap { formatter.date(from: $0.date) }
    }

    private func daysBetween(_ dateStr1: String, _ dateStr2: String) -> Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        guard let d1 = formatter.date(from: dateStr1),
              let d2 = formatter.date(from: dateStr2) else { return 0 }
        return Calendar.current.dateComponents([.day], from: d1, to: d2).day ?? 0
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }

    private func detectEnergyPhasePattern(symptoms: [SymptomLog], cycles: [CycleEntry]) -> Insight? {
        // TODO: Correlate energy values with cycle phases
        return nil
    }

    private func detectSleepEnergyCorrelation(symptoms: [SymptomLog]) -> Insight? {
        // TODO: Check if high sleep → high energy next day
        return nil
    }

    private func detectStressPainCorrelation(symptoms: [SymptomLog]) -> Insight? {
        // TODO: Check if high stress → high pain
        return nil
    }
}
