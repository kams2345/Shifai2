import Foundation

// MARK: - Quick Win Engine
// S3-6 (J1 Benchmark) + S3-7 (J3 Mini-Pattern) + S3-8 (Educational Drip J4-J13)

final class QuickWinEngine {

    static let shared = QuickWinEngine()

    private let insightRepo: InsightRepositoryProtocol
    private let symptomRepo: SymptomRepositoryProtocol
    private let cycleRepo: CycleRepositoryProtocol

    init(
        insightRepo: InsightRepositoryProtocol = InsightRepository(),
        symptomRepo: SymptomRepositoryProtocol = SymptomRepository(),
        cycleRepo: CycleRepositoryProtocol = CycleRepository()
    ) {
        self.insightRepo = insightRepo
        self.symptomRepo = symptomRepo
        self.cycleRepo = cycleRepo
    }

    // MARK: - Daily Check

    /// Called daily (e.g. from AppDelegate or on Dashboard load) to generate time-based insights
    func checkAndGenerateInsights() {
        guard let onboardingDate = UserDefaults.standard.object(forKey: "onboardingDate") as? Date else { return }

        let daysSinceOnboarding = Calendar.current.dateComponents([.day], from: onboardingDate, to: Date()).day ?? 0

        switch daysSinceOnboarding {
        case 0:
            scheduleJ1Insight()
        case 2:
            generateJ3MiniPattern()
        case 3...12:
            deliverEducationalTip(day: daysSinceOnboarding)
        default:
            break // After J13, ML insights take over
        }
    }

    // MARK: - S3-6: Quick Win J1 — Benchmark Instantané

    func scheduleJ1Insight() {
        // Benchmark: sleep vs average women same age
        let benchmarkInsight = Insight(
            id: "qw-j1-benchmark-\(UUID().uuidString.prefix(8))",
            type: .quickWin,
            title: "Ton premier aperçu 🎉",
            body: "Les femmes de ta tranche d'âge dorment en moyenne 7h12. Tu verras bientôt comment ton sommeil influence tes cycles.",
            reasoning: "Benchmark basé sur les données OMS pour les femmes 25-35 ans. Source: Sleep Foundation 2024.",
            confidence: nil,
            isRead: false,
            createdAt: Date()
        )
        try? insightRepo.save(benchmarkInsight)

        // Educational: how cycles work
        let educationalInsight = Insight(
            id: "qw-j1-edu-\(UUID().uuidString.prefix(8))",
            type: .education,
            title: "Comprendre ton cycle en 4 phases",
            body: "🔴 Menstruelle (J1-5): repos et récupération\n🌱 Folliculaire (J6-12): énergie montante\n🌸 Ovulatoire (J13-15): pic d'énergie\n🌙 Lutéale (J16-28): transition et ralentissement",
            reasoning: "Éducation de base sur le cycle menstruel. Durées approximatives pour un cycle de 28 jours.",
            confidence: nil,
            isRead: false,
            createdAt: Date()
        )
        try? insightRepo.save(educationalInsight)
    }

    // MARK: - S3-7: Quick Win J3 — Mini-Pattern

    func generateJ3MiniPattern() {
        // Fetch last 3 days of data
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let symptoms = (try? symptomRepo.fetchByDateRange(from: threeDaysAgo, to: Date())) ?? []
        let entries = (try? cycleRepo.fetchByDateRange(from: threeDaysAgo, to: Date())) ?? []

        guard !symptoms.isEmpty || !entries.isEmpty else {
            // Fallback if no data
            let noDataInsight = Insight(
                id: "qw-j3-nodata-\(UUID().uuidString.prefix(8))",
                type: .quickWin,
                title: "Continue comme ça ! 💪",
                body: "3 jours déjà ! Plus tu logges, plus ShifAI pourra détecter tes patterns uniques.",
                reasoning: nil,
                confidence: nil,
                isRead: false,
                createdAt: Date()
            )
            try? insightRepo.save(noDataInsight)
            return
        }

        // Analyze energy pattern
        let energyLogs = symptoms.filter { $0.notes?.hasPrefix("energy:") == true }
        if energyLogs.count >= 2 {
            let energyValues = energyLogs.compactMap { log -> Int? in
                guard let notes = log.notes else { return nil }
                return Int(notes.replacingOccurrences(of: "energy:", with: ""))
            }
            let avgEnergy = energyValues.reduce(0, +) / max(energyValues.count, 1)

            let trend = energyValues.count >= 2 ?
                (energyValues.last! > energyValues.first! ? "montante" : "descendante") : "stable"

            let patternInsight = Insight(
                id: "qw-j3-pattern-\(UUID().uuidString.prefix(8))",
                type: .quickWin,
                title: "Ton énergie suit un pattern ! ⚡",
                body: "En 3 jours, ton énergie est \(trend) (moyenne: \(avgEnergy)/10). Ton corps a une logique — continue de logger pour la comprendre.",
                reasoning: "Basé sur \(energyValues.count) mesures d'énergie sur 3 jours. Tendance: \(trend).",
                confidence: 0.45,
                isRead: false,
                createdAt: Date()
            )
            try? insightRepo.save(patternInsight)
        }

        // Analyze symptom frequency
        let symptomTypes = symptoms.map { $0.type }
        let typeCounts = Dictionary(grouping: symptomTypes, by: { $0 }).mapValues { $0.count }
        if let mostFrequent = typeCounts.max(by: { $0.value < $1.value }), mostFrequent.value >= 2 {
            let freqInsight = Insight(
                id: "qw-j3-freq-\(UUID().uuidString.prefix(8))",
                type: .pattern,
                title: "Symptôme récurrent détecté",
                body: "\(mostFrequent.key.displayName) apparaît \(mostFrequent.value)x en 3 jours. On va observer si c'est lié à ta phase de cycle.",
                reasoning: "Fréquence détectée: \(mostFrequent.key.displayName) × \(mostFrequent.value) sur 3 jours.",
                confidence: 0.35,
                isRead: false,
                createdAt: Date()
            )
            try? insightRepo.save(freqInsight)
        }

        // Encouragement
        let encouragement = Insight(
            id: "qw-j3-encourage-\(UUID().uuidString.prefix(8))",
            type: .quickWin,
            title: "Continue encore quelques jours ! 🌟",
            body: "Les insights deviennent de plus en plus précis avec le temps. À J7, on pourra commencer à identifier tes premières corrélations.",
            reasoning: nil,
            confidence: nil,
            isRead: false,
            createdAt: Date()
        )
        try? insightRepo.save(encouragement)
    }

    // MARK: - S3-8: Educational Drip J4-J13

    func deliverEducationalTip(day: Int) {
        let tipIndex = day - 3 // J4 = index 1, J13 = index 10
        guard tipIndex >= 1, tipIndex <= educationalTips.count else { return }

        // Check if already delivered today
        let todayKey = "edu_tip_delivered_\(day)"
        guard !UserDefaults.standard.bool(forKey: todayKey) else { return }

        let tip = educationalTips[tipIndex - 1]

        let insight = Insight(
            id: "edu-j\(day + 1)-\(UUID().uuidString.prefix(8))",
            type: .education,
            title: tip.title,
            body: tip.body,
            reasoning: tip.source,
            confidence: nil,
            isRead: false,
            createdAt: Date()
        )
        try? insightRepo.save(insight)
        UserDefaults.standard.set(true, forKey: todayKey)
    }

    // MARK: - Educational Content (10 tips)

    struct EducationalTip {
        let title: String
        let body: String
        let source: String?
    }

    private let educationalTips: [EducationalTip] = [
        // J4
        EducationalTip(
            title: "Phase menstruelle : le repos a du sens 🔴",
            body: "Pendant tes règles, le taux de progestérone et d'œstrogène chute. C'est normal de ressentir de la fatigue. Écouter ton corps pendant cette phase, c'est pas de la faiblesse — c'est de l'intelligence biologique.",
            source: "Source: ACOG — Understanding the Menstrual Cycle"
        ),
        // J5
        EducationalTip(
            title: "Stress et cycles : une connexion puissante 🧠",
            body: "Le cortisol (hormone du stress) peut retarder l'ovulation et allonger ton cycle. Si ton cycle est irrégulier, le stress chronique pourrait être un facteur. ShifAI va traquer cette corrélation pour toi.",
            source: "Source: Harvard Health — Stress and the Menstrual Cycle"
        ),
        // J6
        EducationalTip(
            title: "Sommeil et hormones : un duo critique 😴",
            body: "La mélatonine influence directement la production de GnRH, l'hormone qui régule ton cycle. Un sommeil perturbé peut affecter tes règles, ton humeur et ton énergie. Vise 7-8h régulières.",
            source: "Source: Sleep Foundation — Menstrual Cycle and Sleep"
        ),
        // J7
        EducationalTip(
            title: "Phase folliculaire : ton énergie remonte 🌱",
            body: "Après les règles, les œstrogènes augmentent progressivement. C'est souvent le moment où tu te sens le plus dynamique et concentrée. Profites-en pour les tâches qui demandent de l'énergie !",
            source: "Source: Clue — Follicular Phase Explained"
        ),
        // J8
        EducationalTip(
            title: "SOPK : comprendre les bases 💜",
            body: "Le Syndrome des Ovaires Polykystiques touche 1 femme sur 10. Il est causé par un excès d'androgènes et une résistance à l'insuline. Cycles irréguliers, acné, fatigue — ce ne sont pas des caprices, c'est de la biologie.",
            source: "Source: WHO — Polycystic Ovary Syndrome Fact Sheet"
        ),
        // J9
        EducationalTip(
            title: "Nutrition et cycle : ce que disent les études 🥗",
            body: "Les aliments anti-inflammatoires (oméga-3, légumes verts, curcuma) peuvent aider à réduire les douleurs menstruelles. En phase lutéale, ton corps consomme ~100-300 calories de plus par jour — c'est normal d'avoir plus faim.",
            source: "Source: British Journal of Nutrition"
        ),
        // J10
        EducationalTip(
            title: "Exercice et cycle : adapter son activité 🏃‍♀️",
            body: "Phase folliculaire → sessions intenses (HIIT, cardio). Phase lutéale → yoga, marche, pilates. Ce n'est pas un dogme, mais écouter ton énergie peut optimiser tes performances et réduire les blessures.",
            source: "Source: British Journal of Sports Medicine"
        ),
        // J11
        EducationalTip(
            title: "Endométriose : 7 ans pour un diagnostic ⏳",
            body: "En moyenne, il faut 7 ans pour diagnostiquer l'endométriose. Le suivi régulier de tes douleurs (localisation, intensité, timing) est l'un des meilleurs outils pour accélérer le diagnostic avec ton médecin.",
            source: "Source: Endometriosis UK — Diagnostic Delay Study"
        ),
        // J12
        EducationalTip(
            title: "Ta phase ovulatoire : pic d'énergie 🌸",
            body: "Autour de l'ovulation (milieu de cycle), un pic d'œstrogène et de LH peut te donner un boost d'énergie et de confiance. C'est un bon moment pour les présentations, les discussions importantes, ou les défis sportifs.",
            source: "Source: Healthline — Ovulation Symptoms"
        ),
        // J13
        EducationalTip(
            title: "Tu es unique, et c'est le point 🌈",
            body: "Chaque corps est différent. Les \"normes\" sont des moyennes, pas des règles. ShifAI apprend TON rythme unique. À partir de maintenant, les insights seront de plus en plus personnalisés basés sur TES données.",
            source: nil
        ),
    ]
}
