import Foundation

// MARK: - Pattern Detection Engine
// S4-1: Cycle length analysis, correlation detection, ovulation window estimation
// S4-2: Explainable AI — human-readable reasoning for every insight

final class PatternDetectionEngine {

    private let cycleRepo: CycleRepositoryProtocol
    private let symptomRepo: SymptomRepositoryProtocol

    init(
        cycleRepo: CycleRepositoryProtocol = CycleRepository(),
        symptomRepo: SymptomRepositoryProtocol = SymptomRepository()
    ) {
        self.cycleRepo = cycleRepo
        self.symptomRepo = symptomRepo
    }

    // MARK: - S4-1: Cycle Length Analysis

    struct CycleLengthAnalysis {
        let average: Double
        let stdDeviation: Double
        let trend: CycleTrend
        let lengths: [Int]
        let isRegular: Bool           // std dev < 3 days
    }

    enum CycleTrend: String {
        case shortening, lengthening, stable, insufficient
    }

    func analyzeCycleLengths() -> CycleLengthAnalysis? {
        guard let entries = try? cycleRepo.fetchLast(count: 365) else { return nil }

        // Detect cycle boundaries (where cycleDay resets to 1)
        var lengths: [Int] = []
        var currentLength = 0

        for (i, entry) in entries.enumerated() {
            if entry.cycleDay == 1 && i > 0 {
                if currentLength > 0 { lengths.append(currentLength) }
                currentLength = 1
            } else {
                currentLength += 1
            }
        }

        guard lengths.count >= 2 else {
            return CycleLengthAnalysis(average: 28, stdDeviation: 0, trend: .insufficient,
                                       lengths: lengths, isRegular: false)
        }

        let avg = Double(lengths.reduce(0, +)) / Double(lengths.count)
        let variance = lengths.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(lengths.count)
        let stdDev = sqrt(variance)

        // Trend: compare first half vs second half
        let midpoint = lengths.count / 2
        let firstHalfAvg = Double(lengths[..<midpoint].reduce(0, +)) / Double(midpoint)
        let secondHalfAvg = Double(lengths[midpoint...].reduce(0, +)) / Double(lengths.count - midpoint)

        let trend: CycleTrend
        if abs(firstHalfAvg - secondHalfAvg) < 1.5 {
            trend = .stable
        } else if secondHalfAvg < firstHalfAvg {
            trend = .shortening
        } else {
            trend = .lengthening
        }

        return CycleLengthAnalysis(
            average: avg, stdDeviation: stdDev, trend: trend,
            lengths: lengths, isRegular: stdDev < 3.0
        )
    }

    // MARK: - S4-1: Correlation Detection

    struct Correlation {
        let factor1: String
        let factor2: String
        let strength: Double           // -1.0 to 1.0
        let direction: CorrelationDirection
        let sampleSize: Int

        var isSignificant: Bool { abs(strength) > 0.3 && sampleSize >= 7 }
    }

    enum CorrelationDirection: String {
        case positive, negative, none
    }

    func detectCorrelations() -> [Correlation] {
        guard let symptoms = try? symptomRepo.fetchLast(count: 90) else { return [] }

        var correlations: [Correlation] = []

        // Group logs by date
        let cal = Calendar.current
        let byDate = Dictionary(grouping: symptoms) { cal.startOfDay(for: $0.date) }

        // Stress ↔ Pain
        let stressPain = computeCorrelation(
            logs: byDate,
            factor1Notes: "stress:",
            factor2Type: .cramps,
            label1: "Stress",
            label2: "Crampes"
        )
        if let c = stressPain { correlations.append(c) }

        // Sleep ↔ Energy
        let sleepEnergy = computeCorrelation(
            logs: byDate,
            factor1Notes: "sleep:",
            factor2Notes: "energy:",
            label1: "Sommeil",
            label2: "Énergie"
        )
        if let c = sleepEnergy { correlations.append(c) }

        // Cycle phase ↔ Mood
        let phaseMood = computePhaseMoodCorrelation(logs: byDate)
        correlations.append(contentsOf: phaseMood)

        return correlations.filter { $0.isSignificant }
    }

    private func computeCorrelation(
        logs: [Date: [SymptomLog]],
        factor1Notes: String? = nil,
        factor1Type: SymptomType? = nil,
        factor2Notes: String? = nil,
        factor2Type: SymptomType? = nil,
        label1: String,
        label2: String
    ) -> Correlation? {
        var pairs: [(Double, Double)] = []

        for (_, dayLogs) in logs {
            var val1: Double? = nil
            var val2: Double? = nil

            for log in dayLogs {
                if let notes = factor1Notes, let logNotes = log.notes, logNotes.hasPrefix(notes) {
                    val1 = Double(logNotes.replacingOccurrences(of: notes, with: "")) ?? Double(log.intensity)
                }
                if let type = factor1Type, log.type == type {
                    val1 = Double(log.intensity)
                }
                if let notes = factor2Notes, let logNotes = log.notes, logNotes.hasPrefix(notes) {
                    val2 = Double(logNotes.replacingOccurrences(of: notes, with: "")) ?? Double(log.intensity)
                }
                if let type = factor2Type, log.type == type {
                    val2 = Double(log.intensity)
                }
            }

            if let v1 = val1, let v2 = val2 {
                pairs.append((v1, v2))
            }
        }

        guard pairs.count >= 5 else { return nil }

        let r = pearsonR(pairs)
        let direction: CorrelationDirection = r > 0.1 ? .positive : r < -0.1 ? .negative : .none

        return Correlation(factor1: label1, factor2: label2,
                          strength: r, direction: direction, sampleSize: pairs.count)
    }

    private func computePhaseMoodCorrelation(logs: [Date: [SymptomLog]]) -> [Correlation] {
        // Phase-mood correlations are detected via cycle entries + mood logs
        // Simplified: detect dominant moods per phase
        return []
    }

    // MARK: - S4-1: Period Prediction (Weighted Average)

    func predictNextPeriod() -> Prediction? {
        guard let analysis = analyzeCycleLengths(),
              analysis.lengths.count >= 2 else { return nil }

        // Weighted average: more recent cycles weight more
        let weights: [Double] = analysis.lengths.enumerated().map { (i, _) in
            Double(i + 1) // Linear weighting: 1, 2, 3...
        }
        let totalWeight = weights.reduce(0, +)
        let weightedAvg = zip(analysis.lengths, weights).map { Double($0) * $1 }.reduce(0, +) / totalWeight

        // Last period start
        guard let entries = try? cycleRepo.fetchLast(count: 60),
              let lastPeriodStart = entries.first(where: { $0.cycleDay == 1 }) else { return nil }

        let predictedDate = Calendar.current.date(byAdding: .day, value: Int(weightedAvg), to: lastPeriodStart.date)!

        // Confidence: higher for regular cycles
        let confidence = min(0.85, max(0.35, 1.0 - (analysis.stdDeviation / 10.0)))
        let range = max(1, Int(analysis.stdDeviation.rounded()))

        // S4-2: Explainable reasoning
        let reasoning = buildPeriodReasoning(analysis: analysis, weightedAvg: weightedAvg, confidence: confidence)

        return Prediction(
            type: .periodStart,
            predictedDate: predictedDate,
            confidence: confidence,
            confidenceRange: range,
            reasoning: reasoning
        )
    }

    // MARK: - S4-1: Ovulation Window Estimation

    func estimateOvulationWindow() -> Prediction? {
        guard let analysis = analyzeCycleLengths(),
              analysis.lengths.count >= 2 else { return nil }

        guard let entries = try? cycleRepo.fetchLast(count: 60),
              let lastPeriodStart = entries.first(where: { $0.cycleDay == 1 }) else { return nil }

        // Ovulation: approximately 14 days before next period
        let ovulationDay = Int(analysis.average) - 14
        let ovulationDate = Calendar.current.date(byAdding: .day, value: ovulationDay, to: lastPeriodStart.date)!

        let confidence = min(0.70, max(0.25, 1.0 - (analysis.stdDeviation / 12.0)))

        let reasoning = "Estimation basée sur \(analysis.lengths.count) cycles (moy: \(String(format: "%.1f", analysis.average))j). " +
            "L'ovulation survient en moyenne 14j avant les prochaines règles. " +
            "Fiabilité limitée — confirme avec température basale ou tests LH."

        return Prediction(
            type: .ovulation,
            predictedDate: ovulationDate,
            confidence: confidence,
            confidenceRange: max(2, Int(analysis.stdDeviation)),
            reasoning: reasoning
        )
    }

    // MARK: - S4-2: Insight Generation with Reasoning

    func generateInsights() -> [Insight] {
        var insights: [Insight] = []

        // Cycle regularity insight
        if let analysis = analyzeCycleLengths(), analysis.lengths.count >= 3 {
            let regularity = analysis.isRegular ? "régulier" : "irrégulier"
            let trendText: String
            switch analysis.trend {
            case .shortening: trendText = "tend à raccourcir"
            case .lengthening: trendText = "tend à s'allonger"
            case .stable: trendText = "est stable"
            case .insufficient: trendText = "données insuffisantes"
            }

            insights.append(Insight(
                type: .pattern,
                title: "Pattern de cycle détecté",
                body: "Ton cycle est \(regularity) (\(String(format: "%.0f", analysis.average))j en moyenne, ±\(String(format: "%.1f", analysis.stdDeviation))j) et \(trendText).",
                confidence: min(0.8, Double(analysis.lengths.count) / 12.0),
                reasoning: "Analyse de \(analysis.lengths.count) cycles. Longueurs: \(analysis.lengths.map(String.init).joined(separator: ", "))j. " +
                    "Écart-type: \(String(format: "%.1f", analysis.stdDeviation))j (\(regularity))."
            ))
        }

        // Correlations
        let correlations = detectCorrelations()
        for corr in correlations {
            let directionText = corr.direction == .positive ? "augmente avec" : "diminue quand"
            insights.append(Insight(
                type: .pattern,
                title: "Corrélation: \(corr.factor1) ↔ \(corr.factor2)",
                body: "Ton \(corr.factor2) \(directionText) ton \(corr.factor1). Force: \(Int(abs(corr.strength) * 100))%.",
                confidence: abs(corr.strength),
                reasoning: "Corrélation de Pearson r=\(String(format: "%.2f", corr.strength)) sur \(corr.sampleSize) jours. " +
                    "Seuil de significativité: |r| > 0.3."
            ))
        }

        // Energy prediction
        if let energyInsight = predictEnergyFromPhase() {
            insights.append(energyInsight)
        }

        return insights
    }

    private func predictEnergyFromPhase() -> Insight? {
        guard let entries = try? cycleRepo.fetchLast(count: 30),
              let lastEntry = entries.first else { return nil }

        let cycleDay = Calendar.current.dateComponents([.day], from: lastEntry.date, to: Date()).day! + lastEntry.cycleDay
        let analysis = analyzeCycleLengths()
        let avgLen = analysis?.average ?? 28

        let phase: CyclePhase
        let energyForecast: String
        let recommendation: String

        if cycleDay <= 5 {
            phase = .menstrual
            energyForecast = "basse (3-4/10)"
            recommendation = "Prévois journées douces. Yoga, marche, hydratation."
        } else if Double(cycleDay) <= avgLen / 2 - 2 {
            phase = .follicular
            energyForecast = "montante (6-8/10)"
            recommendation = "Bon moment pour les projets ambitieux et le sport intense."
        } else if Double(cycleDay) <= avgLen / 2 + 2 {
            phase = .ovulatory
            energyForecast = "au pic (8-9/10)"
            recommendation = "Profite de ce boost — présentations, défis sportifs, social."
        } else {
            phase = .luteal
            energyForecast = "en baisse (4-6/10)"
            recommendation = "Transition en douceur. Activités calmes, bonne alimentation."
        }

        return Insight(
            type: .recommendation,
            title: "Énergie prévue: \(energyForecast)",
            body: "\(phase.emoji) Phase \(phase.displayName) (J\(cycleDay)). \(recommendation)",
            confidence: 0.55,
            reasoning: "Prévision basée sur ta phase de cycle actuelle (J\(cycleDay)/\(Int(avgLen))). " +
                "Les niveaux d'énergie suivent généralement les fluctuations hormonales du cycle menstruel."
        )
    }

    // MARK: - S4-2: Explainable Reasoning Builder

    private func buildPeriodReasoning(analysis: CycleLengthAnalysis, weightedAvg: Double, confidence: Double) -> String {
        var parts: [String] = []

        parts.append("Moyenne pondérée de \(analysis.lengths.count) cycles: \(String(format: "%.1f", weightedAvg))j")
        parts.append("Écart-type: \(String(format: "%.1f", analysis.stdDeviation))j")

        if analysis.isRegular {
            parts.append("Cycle régulier → haute fiabilité")
        } else {
            parts.append("Cycle irrégulier → fiabilité réduite")
        }

        switch analysis.trend {
        case .shortening: parts.append("Tendance: cycles qui raccourcissent")
        case .lengthening: parts.append("Tendance: cycles qui s'allongent")
        case .stable: parts.append("Tendance: stable")
        case .insufficient: break
        }

        parts.append("Fiabilité: \(Int(confidence * 100))%")

        return parts.joined(separator: ". ") + "."
    }

    // MARK: - Pearson Correlation

    private func pearsonR(_ pairs: [(Double, Double)]) -> Double {
        let n = Double(pairs.count)
        let sumX = pairs.map(\.0).reduce(0, +)
        let sumY = pairs.map(\.1).reduce(0, +)
        let sumXY = pairs.map { $0.0 * $0.1 }.reduce(0, +)
        let sumX2 = pairs.map { $0.0 * $0.0 }.reduce(0, +)
        let sumY2 = pairs.map { $0.1 * $0.1 }.reduce(0, +)

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        guard denominator > 0 else { return 0 }
        return numerator / denominator
    }
}
