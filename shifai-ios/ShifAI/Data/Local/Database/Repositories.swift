import Foundation
import GRDB

// MARK: - Cycle Repository
// Manages all cycle-related database operations via GRDB + SQLCipher

protocol CycleRepositoryProtocol {
    func save(_ entry: CycleEntry) throws
    func update(_ entry: CycleEntry) throws
    func delete(id: String) throws
    func fetchAll() throws -> [CycleEntry]
    func fetchCurrent() throws -> CycleEntry?
    func fetchLast(count: Int) throws -> [CycleEntry]
    func fetchByDateRange(from: Date, to: Date) throws -> [CycleEntry]
    func calculateCurrentCycleDay(from lastPeriodStart: Date) -> Int
}

final class CycleRepository: CycleRepositoryProtocol {

    private let dbManager: DatabaseManager

    init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }

    // MARK: - GRDB Record

    /// GRDB record mapping for CycleEntry
    struct CycleRecord: Codable, FetchableRecord, PersistableRecord {
        static let databaseTableName = "cycle_entries"

        var id: String
        var date: Date
        var cycleDay: Int
        var phase: String
        var flowIntensity: Int?
        var cervicalMucus: String?
        var basalTemp: Double?
        var notes: String?
        var createdAt: Date
        var updatedAt: Date

        // Map from domain model
        init(from entry: CycleEntry) {
            self.id = entry.id
            self.date = entry.date
            self.cycleDay = entry.cycleDay
            self.phase = entry.phase.rawValue
            self.flowIntensity = entry.flowIntensity
            self.cervicalMucus = entry.cervicalMucus?.rawValue
            self.basalTemp = entry.basalTemp
            self.notes = entry.notes
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }

        // Map to domain model
        func toDomain() -> CycleEntry {
            CycleEntry(
                id: id,
                date: date,
                cycleDay: cycleDay,
                phase: CyclePhase(rawValue: phase) ?? .unknown,
                flowIntensity: flowIntensity,
                cervicalMucus: cervicalMucus.flatMap { CervicalMucus(rawValue: $0) },
                basalTemp: basalTemp,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }

    // MARK: - CRUD

    func save(_ entry: CycleEntry) throws {
        try dbManager.dbQueue?.write { db in
            var record = CycleRecord(from: entry)
            record.createdAt = Date()
            record.updatedAt = Date()
            try record.insert(db)
        }
    }

    func update(_ entry: CycleEntry) throws {
        try dbManager.dbQueue?.write { db in
            var record = CycleRecord(from: entry)
            record.updatedAt = Date()
            try record.update(db)
        }
    }

    func delete(id: String) throws {
        try dbManager.dbQueue?.write { db in
            _ = try CycleRecord.deleteOne(db, key: id)
        }
    }

    func fetchAll() throws -> [CycleEntry] {
        try dbManager.dbQueue?.read { db in
            let records = try CycleRecord
                .order(Column("date").desc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchCurrent() throws -> CycleEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return try dbManager.dbQueue?.read { db in
            try CycleRecord
                .filter(Column("date") == today)
                .fetchOne(db)?
                .toDomain()
        }
    }

    func fetchLast(count: Int) throws -> [CycleEntry] {
        try dbManager.dbQueue?.read { db in
            let records = try CycleRecord
                .order(Column("date").desc)
                .limit(count)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchByDateRange(from start: Date, to end: Date) throws -> [CycleEntry] {
        try dbManager.dbQueue?.read { db in
            let records = try CycleRecord
                .filter(Column("date") >= start && Column("date") <= end)
                .order(Column("date").asc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func calculateCurrentCycleDay(from lastPeriodStart: Date) -> Int {
        Calendar.current.dateComponents([.day], from: lastPeriodStart, to: Date()).day! + 1
    }
}

// MARK: - Symptom Repository

protocol SymptomRepositoryProtocol {
    func save(_ log: SymptomLog) throws
    func update(_ log: SymptomLog) throws
    func delete(id: String) throws
    func fetchForDate(_ date: Date) throws -> [SymptomLog]
    func fetchByDateRange(from: Date, to: Date) throws -> [SymptomLog]
    func fetchLast(count: Int) throws -> [SymptomLog]
    func fetchByType(_ type: SymptomType) throws -> [SymptomLog]
    func fetchMostFrequent(limit: Int) throws -> [(SymptomType, Int)]
}

final class SymptomRepository: SymptomRepositoryProtocol {

    private let dbManager: DatabaseManager

    init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }

    struct SymptomRecord: Codable, FetchableRecord, PersistableRecord {
        static let databaseTableName = "symptom_logs"

        var id: String
        var date: Date
        var symptomType: String
        var intensity: Int
        var bodyZone: String?
        var painType: String?
        var notes: String?
        var createdAt: Date

        init(from log: SymptomLog) {
            self.id = log.id
            self.date = log.date
            self.symptomType = log.type.rawValue
            self.intensity = log.intensity
            self.bodyZone = log.bodyZone?.rawValue
            self.painType = log.painType?.rawValue
            self.notes = log.notes
            self.createdAt = log.createdAt
        }

        func toDomain() -> SymptomLog {
            SymptomLog(
                id: id,
                date: date,
                type: SymptomType(rawValue: symptomType) ?? .other,
                intensity: intensity,
                bodyZone: bodyZone.flatMap { BodyZone(rawValue: $0) },
                painType: painType.flatMap { PainType(rawValue: $0) },
                notes: notes,
                createdAt: createdAt
            )
        }
    }

    func save(_ log: SymptomLog) throws {
        try dbManager.dbQueue?.write { db in
            let record = SymptomRecord(from: log)
            try record.insert(db)
        }
    }

    func update(_ log: SymptomLog) throws {
        try dbManager.dbQueue?.write { db in
            let record = SymptomRecord(from: log)
            try record.update(db)
        }
    }

    func delete(id: String) throws {
        try dbManager.dbQueue?.write { db in
            _ = try SymptomRecord.deleteOne(db, key: id)
        }
    }

    func fetchForDate(_ date: Date) throws -> [SymptomLog] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return try dbManager.dbQueue?.read { db in
            let records = try SymptomRecord
                .filter(Column("date") >= startOfDay && Column("date") < endOfDay)
                .order(Column("createdAt").desc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchByDateRange(from start: Date, to end: Date) throws -> [SymptomLog] {
        try dbManager.dbQueue?.read { db in
            let records = try SymptomRecord
                .filter(Column("date") >= start && Column("date") <= end)
                .order(Column("date").asc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchLast(count: Int) throws -> [SymptomLog] {
        try dbManager.dbQueue?.read { db in
            let records = try SymptomRecord
                .order(Column("date").desc)
                .limit(count)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchByType(_ type: SymptomType) throws -> [SymptomLog] {
        try dbManager.dbQueue?.read { db in
            let records = try SymptomRecord
                .filter(Column("symptomType") == type.rawValue)
                .order(Column("date").desc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    /// Returns most frequent symptom types with their counts
    func fetchMostFrequent(limit: Int) throws -> [(SymptomType, Int)] {
        try dbManager.dbQueue?.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT symptom_type, COUNT(*) as count
                FROM symptom_logs
                GROUP BY symptom_type
                ORDER BY count DESC
                LIMIT ?
            """, arguments: [limit])

            return rows.compactMap { row in
                guard let typeString = row["symptom_type"] as? String,
                      let type = SymptomType(rawValue: typeString),
                      let count = row["count"] as? Int else { return nil }
                return (type, count)
            }
        } ?? []
    }
}

// MARK: - Insight Repository

protocol InsightRepositoryProtocol {
    func save(_ insight: Insight) throws
    func fetchRecent(limit: Int) throws -> [Insight]
    func fetchUnread() throws -> [Insight]
    func markAsRead(id: String) throws
}

final class InsightRepository: InsightRepositoryProtocol {

    private let dbManager: DatabaseManager

    init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }

    struct InsightRecord: Codable, FetchableRecord, PersistableRecord {
        static let databaseTableName = "insights"

        var id: String
        var type: String
        var title: String
        var body: String
        var reasoning: String?
        var confidence: Double?
        var isRead: Bool
        var createdAt: Date

        init(from insight: Insight) {
            self.id = insight.id
            self.type = insight.type.rawValue
            self.title = insight.title
            self.body = insight.body
            self.reasoning = insight.reasoning
            self.confidence = insight.confidence
            self.isRead = insight.isRead
            self.createdAt = insight.createdAt
        }

        func toDomain() -> Insight {
            Insight(
                id: id,
                type: InsightType(rawValue: type) ?? .quickWin,
                title: title,
                body: body,
                reasoning: reasoning,
                confidence: confidence,
                isRead: isRead,
                createdAt: createdAt
            )
        }
    }

    func save(_ insight: Insight) throws {
        try dbManager.dbQueue?.write { db in
            let record = InsightRecord(from: insight)
            try record.insert(db)
        }
    }

    func fetchRecent(limit: Int) throws -> [Insight] {
        try dbManager.dbQueue?.read { db in
            let records = try InsightRecord
                .order(Column("createdAt").desc)
                .limit(limit)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func fetchUnread() throws -> [Insight] {
        try dbManager.dbQueue?.read { db in
            let records = try InsightRecord
                .filter(Column("isRead") == false)
                .order(Column("createdAt").desc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func markAsRead(id: String) throws {
        try dbManager.dbQueue?.write { db in
            try db.execute(sql: """
                UPDATE insights SET is_read = 1 WHERE id = ?
            """, arguments: [id])
        }
    }
}

// MARK: - Prediction Repository

protocol PredictionRepositoryProtocol {
    func save(_ prediction: Prediction) throws
    func fetchLatest() throws -> Prediction?
    func fetchAll() throws -> [Prediction]
    func submitFeedback(id: String, feedback: PredictionFeedback) throws
}

final class PredictionRepository: PredictionRepositoryProtocol {

    private let dbManager: DatabaseManager

    init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }

    struct PredictionRecord: Codable, FetchableRecord, PersistableRecord {
        static let databaseTableName = "predictions"

        var id: String
        var type: String
        var predictedDate: Date
        var confidenceRange: Int // days ±
        var confidence: Double
        var reasoning: String?
        var actualDate: Date?
        var userFeedback: String?
        var createdAt: Date

        init(from prediction: Prediction) {
            self.id = prediction.id
            self.type = prediction.type.rawValue
            self.predictedDate = prediction.predictedDate
            self.confidenceRange = prediction.confidenceRange
            self.confidence = prediction.confidence
            self.reasoning = prediction.reasoning
            self.actualDate = prediction.actualDate
            self.userFeedback = prediction.userFeedback?.rawValue
            self.createdAt = prediction.createdAt
        }

        func toDomain() -> Prediction {
            Prediction(
                id: id,
                type: PredictionType(rawValue: type) ?? .periodStart,
                predictedDate: predictedDate,
                confidenceRange: confidenceRange,
                confidence: confidence,
                reasoning: reasoning,
                actualDate: actualDate,
                userFeedback: userFeedback.flatMap { PredictionFeedback(rawValue: $0) },
                createdAt: createdAt
            )
        }
    }

    func save(_ prediction: Prediction) throws {
        try dbManager.dbQueue?.write { db in
            let record = PredictionRecord(from: prediction)
            try record.insert(db)
        }
    }

    func fetchLatest() throws -> Prediction? {
        try dbManager.dbQueue?.read { db in
            try PredictionRecord
                .order(Column("createdAt").desc)
                .fetchOne(db)?
                .toDomain()
        }
    }

    func fetchAll() throws -> [Prediction] {
        try dbManager.dbQueue?.read { db in
            let records = try PredictionRecord
                .order(Column("createdAt").desc)
                .fetchAll(db)
            return records.map { $0.toDomain() }
        } ?? []
    }

    func submitFeedback(id: String, feedback: PredictionFeedback) throws {
        try dbManager.dbQueue?.write { db in
            try db.execute(sql: """
                UPDATE predictions SET user_feedback = ? WHERE id = ?
            """, arguments: [feedback.rawValue, id])
        }
    }
}
