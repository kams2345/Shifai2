import Foundation
import GRDB

/// Cycle Entry — GRDB record for local storage.
/// Mirrors CycleEntryEntity.kt (Room) and backend cycle_entries table.
struct CycleEntry: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: String
    var date: Date
    var cycleDay: Int
    var phase: CyclePhase
    var flowIntensity: Int
    var moodScore: Int
    var energyScore: Int
    var sleepHours: Double
    var stressLevel: Int
    var notes: String
    var isSynced: Bool
    var updatedAt: Date

    static let databaseTableName = "cycle_entries"

    init(
        id: String = UUID().uuidString,
        date: Date,
        cycleDay: Int,
        phase: CyclePhase = .unknown,
        flowIntensity: Int = 0,
        moodScore: Int = 5,
        energyScore: Int = 5,
        sleepHours: Double = 0,
        stressLevel: Int = 5,
        notes: String = "",
        isSynced: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.cycleDay = cycleDay
        self.phase = phase
        self.flowIntensity = min(4, max(0, flowIntensity))
        self.moodScore = min(10, max(1, moodScore))
        self.energyScore = min(10, max(1, energyScore))
        self.sleepHours = min(24.0, max(0, sleepHours))
        self.stressLevel = min(10, max(1, stressLevel))
        self.notes = notes
        self.isSynced = isSynced
        self.updatedAt = updatedAt
    }
}

/// Symptom Log — GRDB record for local storage.
/// Mirrors SymptomLogEntity.kt and backend symptom_logs table.
struct SymptomLog: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: String
    var cycleEntryId: String
    var category: String
    var symptomType: String
    var intensity: Int
    var bodyZone: String?
    var isSynced: Bool
    var createdAt: Date

    static let databaseTableName = "symptom_logs"

    init(
        id: String = UUID().uuidString,
        cycleEntryId: String,
        category: String,
        symptomType: String,
        intensity: Int,
        bodyZone: String? = nil,
        isSynced: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.cycleEntryId = cycleEntryId
        self.category = category
        self.symptomType = symptomType
        self.intensity = min(10, max(1, intensity))
        self.bodyZone = bodyZone
        self.isSynced = isSynced
        self.createdAt = createdAt
    }
}
