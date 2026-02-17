import Foundation
import GRDB

/// Prediction Record — GRDB record for local storage.
/// Mirrors PredictionEntity.kt (Room) and backend predictions table.
struct PredictionRecord: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: String
    var type: String
    var predictedDate: Date
    var confidence: Double
    var actualDate: Date?
    var source: String
    var isSynced: Bool
    var createdAt: Date

    static let databaseTableName = "predictions"

    init(
        id: String = UUID().uuidString,
        type: String,
        predictedDate: Date,
        confidence: Double = 0,
        actualDate: Date? = nil,
        source: String = "rule_based",
        isSynced: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.predictedDate = predictedDate
        self.confidence = max(0, min(1, confidence))
        self.actualDate = actualDate
        self.source = source
        self.isSynced = isSynced
        self.createdAt = createdAt
    }

    /// Calculate prediction accuracy (days off) when verified.
    var accuracyDays: Int? {
        guard let actual = actualDate else { return nil }
        return Calendar.current.dateComponents([.day], from: predictedDate, to: actual).day
    }
}
