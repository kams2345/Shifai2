import Foundation
import SwiftUI

// MARK: - Domain Models
// Pure data models — zero framework dependencies

// MARK: - CycleEntry

struct CycleEntry: Identifiable, Codable, Equatable {
    let id: String
    let date: Date
    var flowIntensity: Int?              // 1-5, nil if no period
    var cycleDay: Int
    var phase: CyclePhase?
    var cervicalMucus: CervicalMucus?
    var basalTemp: Double?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        flowIntensity: Int? = nil,
        cycleDay: Int = 1,
        phase: CyclePhase? = nil,
        cervicalMucus: CervicalMucus? = nil,
        basalTemp: Double? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.date = date
        self.flowIntensity = flowIntensity
        self.cycleDay = cycleDay
        self.phase = phase
        self.cervicalMucus = cervicalMucus
        self.basalTemp = basalTemp
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

enum CyclePhase: String, Codable, CaseIterable {
    case menstrual
    case follicular
    case ovulatory
    case luteal
    case unknown

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
        case .unknown: return Color.gray
        }
    }
}

// MARK: - SymptomLog

struct SymptomLog: Identifiable, Codable, Equatable {
    let id: String
    let date: Date
    let type: SymptomType
    var intensity: Int                    // 1-10
    var bodyZone: BodyZone?
    var painType: PainType?
    var notes: String?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        type: SymptomType,
        intensity: Int = 5,
        bodyZone: BodyZone? = nil,
        painType: PainType? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.intensity = intensity
        self.bodyZone = bodyZone
        self.painType = painType
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - SymptomType (29 symptoms across 6 categories)

enum SymptomType: String, Codable, CaseIterable {
    // Pain
    case cramps, headache, backPain, breastTenderness, jointPain, pelvicPain
    // Digestive
    case bloating, nausea, constipation, diarrhea, cravings, appetiteLoss
    // Emotional
    case anxious, irritable, sad, moodSwings, brainFog, crying
    // Physical
    case fatigue, insomnia, hotFlashes, dizziness, acne, hairLoss
    // Hormonal
    case spotting, heavyFlow, irregularCycle, nightSweats
    // Other
    case other

    var displayName: String {
        switch self {
        case .cramps: return "Crampes"
        case .headache: return "Migraine"
        case .backPain: return "Mal de dos"
        case .breastTenderness: return "Seins sensibles"
        case .jointPain: return "Douleurs articulaires"
        case .pelvicPain: return "Douleur pelvienne"
        case .bloating: return "Ballonnement"
        case .nausea: return "Nausée"
        case .constipation: return "Constipation"
        case .diarrhea: return "Diarrhée"
        case .cravings: return "Envies alimentaires"
        case .appetiteLoss: return "Perte d'appétit"
        case .anxious: return "Anxiété"
        case .irritable: return "Irritabilité"
        case .sad: return "Tristesse"
        case .moodSwings: return "Sautes d'humeur"
        case .brainFog: return "Brouillard mental"
        case .crying: return "Envie de pleurer"
        case .fatigue: return "Fatigue"
        case .insomnia: return "Insomnie"
        case .hotFlashes: return "Bouffées de chaleur"
        case .dizziness: return "Vertiges"
        case .acne: return "Acné"
        case .hairLoss: return "Chute de cheveux"
        case .spotting: return "Spotting"
        case .heavyFlow: return "Flux abondant"
        case .irregularCycle: return "Cycle irrégulier"
        case .nightSweats: return "Sueurs nocturnes"
        case .other: return "Autre"
        }
    }
}

enum SymptomCategory: String, Codable, CaseIterable {
    case pain = "Douleur"
    case digestive = "Digestif"
    case emotional = "Émotionnel"
    case physical = "Physique"
    case hormonal = "Hormonal"
    case other = "Autre"

    var emoji: String {
        switch self {
        case .pain: return "🔴"
        case .digestive: return "🫄"
        case .emotional: return "💭"
        case .physical: return "🤕"
        case .hormonal: return "⚡"
        case .other: return "📝"
        }
    }

    var symptoms: [SymptomType] {
        switch self {
        case .pain: return [.cramps, .headache, .backPain, .breastTenderness, .jointPain, .pelvicPain]
        case .digestive: return [.bloating, .nausea, .constipation, .diarrhea, .cravings, .appetiteLoss]
        case .emotional: return [.anxious, .irritable, .sad, .moodSwings, .brainFog, .crying]
        case .physical: return [.fatigue, .insomnia, .hotFlashes, .dizziness, .acne, .hairLoss]
        case .hormonal: return [.spotting, .heavyFlow, .irregularCycle, .nightSweats]
        case .other: return [.other]
        }
    }
}

enum BodyZone: String, Codable, CaseIterable {
    case uterus
    case leftOvary = "left_ovary"
    case rightOvary = "right_ovary"
    case lowerBack = "lower_back"
    case thighs

    var displayName: String {
        switch self {
        case .uterus: return "Utérus"
        case .leftOvary: return "Ovaire gauche"
        case .rightOvary: return "Ovaire droit"
        case .lowerBack: return "Bas du dos"
        case .thighs: return "Cuisses"
        }
    }
}

enum PainType: String, Codable {
    case cramping
    case burning
    case pressure
    case sharp
    case other

    var displayName: String {
        switch self {
        case .cramping: return "Crampes"
        case .burning: return "Brûlure"
        case .pressure: return "Pression"
        case .sharp: return "Aiguë"
        case .other: return "Autre"
        }
    }
}

// MARK: - Insight

struct Insight: Identifiable, Codable, Equatable {
    let id: String
    let type: InsightType
    var title: String
    var body: String                      // Markdown
    var confidence: Double?               // 0.0-1.0
    var reasoning: String?                // Explainable AI
    var isRead: Bool
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        type: InsightType,
        title: String,
        body: String,
        confidence: Double? = nil,
        reasoning: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.confidence = confidence
        self.reasoning = reasoning
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

enum InsightType: String, Codable, CaseIterable {
    case quickWin = "quick_win"
    case pattern
    case prediction
    case recommendation
    case education

    var color: Color {
        switch self {
        case .quickWin: return Color(hex: "34D399")
        case .pattern: return Color(hex: "60A5FA")
        case .prediction: return Color(hex: "A78BFA")
        case .recommendation: return Color(hex: "F59E0B")
        case .education: return Color(hex: "EC4899")
        }
    }

    var label: String {
        switch self {
        case .quickWin: return "Quick Win"
        case .pattern: return "Pattern"
        case .prediction: return "Prédiction"
        case .recommendation: return "Recommandation"
        case .education: return "Éducation"
        }
    }
}

enum IntelligenceSource: String, Codable {
    case ruleBased = "rule_based"
    case mlModelV1 = "ml_model_v1"
}

enum InsightFeedback: String, Codable {
    case accurate
    case inaccurate
}

// MARK: - Prediction

struct Prediction: Identifiable, Codable, Equatable {
    let id: String
    let type: PredictionType
    var predictedDate: Date
    var confidence: Double                 // 0.0-1.0
    var confidenceRange: Int               // ± days
    var reasoning: String?
    var actualDate: Date?
    var userFeedback: PredictionFeedback?
    var modelVersion: String
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        type: PredictionType = .periodStart,
        predictedDate: Date = Date(),
        confidence: Double = 0.5,
        confidenceRange: Int = 3,
        reasoning: String? = nil,
        actualDate: Date? = nil,
        userFeedback: PredictionFeedback? = nil,
        modelVersion: String = "rule_v1",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.predictedDate = predictedDate
        self.confidence = confidence
        self.confidenceRange = confidenceRange
        self.reasoning = reasoning
        self.actualDate = actualDate
        self.userFeedback = userFeedback
        self.modelVersion = modelVersion
        self.createdAt = createdAt
    }
}

enum PredictionType: String, Codable, CaseIterable {
    case periodStart = "period_start"
    case ovulation
    case energy
    case mood
}

// MARK: - User Profile

struct UserProfile: Identifiable, Codable, Equatable {
    let id: String
    var age: Int?
    var averageCycleLength: Int?
    var conditions: [String]
    var trackedSymptoms: [String]
    var locale: String
    var cycleDescription: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        age: Int? = nil,
        averageCycleLength: Int? = nil,
        conditions: [String] = [],
        trackedSymptoms: [String] = [],
        locale: String = "fr",
        cycleDescription: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.age = age
        self.averageCycleLength = averageCycleLength
        self.conditions = conditions
        self.trackedSymptoms = trackedSymptoms
        self.locale = locale
        self.cycleDescription = cycleDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct UserPreferences: Codable, Equatable {
    var autoLockSeconds: Int = 300
    var notificationsEnabled: Bool = true
    var cloudSyncEnabled: Bool = false
    var biometricEnabled: Bool = false
    var preferredNotificationHour: Int = 9
    var locale: String = "fr"
}

// MARK: - Sync

enum SyncStatus: String, Codable {
    case pending
    case synced
    case conflict
}

// MARK: - Additional Enums

enum CervicalMucus: String, Codable, CaseIterable {
    case dry
    case sticky
    case creamy
    case watery
    case eggWhite = "egg_white"

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

enum PredictionFeedback: String, Codable {
    case accurate
    case inaccurate
    case skipped
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
    }
}
