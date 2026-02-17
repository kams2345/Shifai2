import Foundation
import CoreML

// MARK: - ML Engine — iOS (Core ML)
// S4-3: On-device inference, auto-transition Rules→ML at 14+ days data

final class MLEngine {

    static let shared = MLEngine()

    // MARK: - State

    enum EngineMode: String {
        case ruleBased       // < 14 days of data
        case mlPowered       // 14+ days, model loaded
        case fallback        // ML failed, back to rules
    }

    @Published private(set) var mode: EngineMode = .ruleBased
    @Published private(set) var modelVersion: String = "rule_v1"

    private var mlModel: MLModel?
    private let minDaysForML = 14

    private let patternEngine: PatternDetectionEngine
    private let symptomRepo: SymptomRepositoryProtocol

    init(
        patternEngine: PatternDetectionEngine = PatternDetectionEngine(),
        symptomRepo: SymptomRepositoryProtocol = SymptomRepository()
    ) {
        self.patternEngine = patternEngine
        self.symptomRepo = symptomRepo
    }

    // MARK: - Model Loading

    func loadModelIfReady() {
        let daysSinceOnboarding = daysSinceOnboarding()

        guard daysSinceOnboarding >= minDaysForML else {
            mode = .ruleBased
            return
        }

        // Attempt to load Core ML model
        do {
            if let modelURL = Bundle.main.url(forResource: "shifai_cycle_v1", withExtension: "mlmodelc") {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndNeuralEngine
                mlModel = try MLModel(contentsOf: modelURL, configuration: config)
                mode = .mlPowered
                modelVersion = "ml_v1"
                print("[MLEngine] Model loaded successfully")
            } else {
                // Model not yet bundled — use rules
                mode = .ruleBased
                print("[MLEngine] Model not found, staying rule-based")
            }
        } catch {
            mode = .fallback
            print("[MLEngine] Model load failed: \(error). Falling back to rules.")
        }
    }

    // MARK: - Unified Predict API

    /// Returns predictions using the best available engine
    func predict() -> MLPredictionResult {
        switch mode {
        case .mlPowered:
            return predictWithML()
        case .ruleBased, .fallback:
            return predictWithRules()
        }
    }

    // MARK: - Rule-based Predictions

    private func predictWithRules() -> MLPredictionResult {
        let periodPrediction = patternEngine.predictNextPeriod()
        let ovulationPrediction = patternEngine.estimateOvulationWindow()
        let insights = patternEngine.generateInsights()

        return MLPredictionResult(
            periodPrediction: periodPrediction,
            ovulationPrediction: ovulationPrediction,
            energyForecast: patternEngine.predictEnergyFromPhasePublic(),
            insights: insights,
            source: .ruleBased,
            inferenceTimeMs: 0
        )
    }

    // MARK: - ML Predictions (Core ML)

    private func predictWithML() -> MLPredictionResult {
        let startTime = CFAbsoluteTimeGetCurrent()

        guard let model = mlModel else {
            return predictWithRules()
        }

        // Build feature vector from last 14+ days
        let features = buildFeatureVector()

        do {
            let input = try MLDictionaryFeatureProvider(dictionary: features)
            let output = try model.prediction(from: input)

            let inferenceMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

            // Parse output
            let periodDaysOut = output.featureValue(for: "period_days_out")?.int64Value ?? 28
            let ovulationDaysOut = output.featureValue(for: "ovulation_days_out")?.int64Value ?? 14
            let energyPrediction = output.featureValue(for: "energy_next_day")?.doubleValue ?? 5.0
            let confidence = output.featureValue(for: "confidence")?.doubleValue ?? 0.5

            // Build predictions from ML output
            let today = Date()
            let periodDate = Calendar.current.date(byAdding: .day, value: Int(periodDaysOut), to: today)!
            let ovulationDate = Calendar.current.date(byAdding: .day, value: Int(ovulationDaysOut), to: today)!

            let periodPrediction = Prediction(
                type: .periodStart,
                predictedDate: periodDate,
                confidence: confidence,
                confidenceRange: 2,
                reasoning: "Prédiction ML (Core ML \(modelVersion)). Inférence: \(String(format: "%.0f", inferenceMs))ms. " +
                    "Basée sur \(minDaysForML)+ jours de données multi-signaux.",
                modelVersion: modelVersion
            )

            let ovulationPrediction = Prediction(
                type: .ovulation,
                predictedDate: ovulationDate,
                confidence: confidence * 0.85,
                confidenceRange: 3,
                reasoning: "Estimation ML de la fenêtre d'ovulation.",
                modelVersion: modelVersion
            )

            // Combine ML predictions with rule-based insights
            let insights = patternEngine.generateInsights()

            return MLPredictionResult(
                periodPrediction: periodPrediction,
                ovulationPrediction: ovulationPrediction,
                energyForecast: Int(energyPrediction),
                insights: insights,
                source: .mlModelV1,
                inferenceTimeMs: inferenceMs
            )
        } catch {
            print("[MLEngine] Inference error: \(error)")
            mode = .fallback
            return predictWithRules()
        }
    }

    // MARK: - Feature Engineering

    private func buildFeatureVector() -> [String: Any] {
        let logs = (try? symptomRepo.fetchLast(count: 200)) ?? []

        // Aggregate features per day for last 14 days
        var features: [String: Any] = [:]

        for dayOffset in 0..<14 {
            let targetDate = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            let dayLogs = logs.filter { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }

            // Energy
            let energy = dayLogs.first(where: { $0.notes?.hasPrefix("energy:") == true })
            let energyVal = energy.flatMap { log -> Double? in
                guard let notes = log.notes else { return nil }
                return Double(notes.replacingOccurrences(of: "energy:", with: ""))
            } ?? 5.0
            features["energy_d\(dayOffset)"] = energyVal

            // Stress
            let stress = dayLogs.first(where: { $0.notes?.hasPrefix("stress:") == true })
            let stressVal = stress.flatMap { log -> Double? in
                guard let notes = log.notes else { return nil }
                return Double(notes.replacingOccurrences(of: "stress:", with: ""))
            } ?? 3.0
            features["stress_d\(dayOffset)"] = stressVal

            // Sleep
            let sleep = dayLogs.first(where: { $0.notes?.hasPrefix("sleep:") == true })
            features["sleep_d\(dayOffset)"] = sleep != nil ? 1.0 : 0.0

            // Pain count
            let painCount = dayLogs.filter { [.cramps, .headache, .backPain, .pelvicPain].contains($0.type) }.count
            features["pain_d\(dayOffset)"] = Double(painCount)

            // Symptom count
            features["symptom_count_d\(dayOffset)"] = Double(dayLogs.count)
        }

        return features
    }

    // MARK: - Helpers

    private func daysSinceOnboarding() -> Int {
        guard let date = UserDefaults.standard.object(forKey: "onboardingDate") as? Date else { return 0 }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}

// MARK: - Result Types

struct MLPredictionResult {
    let periodPrediction: Prediction?
    let ovulationPrediction: Prediction?
    let energyForecast: Int?
    let insights: [Insight]
    let source: IntelligenceSource
    let inferenceTimeMs: Double
}

// MARK: - PatternDetectionEngine Extension

extension PatternDetectionEngine {
    func predictEnergyFromPhasePublic() -> Int? {
        guard let entries = try? cycleRepo.fetchLast(count: 30),
              let lastEntry = entries.first else { return nil }

        let cycleDay = Calendar.current.dateComponents([.day], from: lastEntry.date, to: Date()).day! + lastEntry.cycleDay

        switch cycleDay {
        case 1...5: return 3
        case 6...12: return 7
        case 13...16: return 9
        case 17...28: return 5
        default: return 5
        }
    }
}
