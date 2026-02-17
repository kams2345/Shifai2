import Foundation
import GRDB

/// Insights Repository — manages insight CRUD and feedback for iOS.
/// Offline-first, mirrors Android InsightsRepository.kt.
final class InsightsRepository {

    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    // MARK: - Observe

    func observeAll() -> DatabasePublishers.Value<[InsightRecord]> {
        ValueObservation
            .tracking { db in
                try InsightRecord
                    .order(Column("createdAt").desc)
                    .fetchAll(db)
            }
            .publisher(in: dbQueue, scheduling: .immediate)
    }

    // MARK: - Read

    func getUnread() async throws -> [InsightRecord] {
        try await dbQueue.read { db in
            try InsightRecord
                .filter(Column("isRead") == false)
                .order(Column("createdAt").desc)
                .fetchAll(db)
        }
    }

    func unreadCount() async throws -> Int {
        try await dbQueue.read { db in
            try InsightRecord
                .filter(Column("isRead") == false)
                .fetchCount(db)
        }
    }

    // MARK: - Write

    func save(_ insight: InsightRecord) async throws {
        var toSave = insight
        toSave.isSynced = false
        try await dbQueue.write { db in
            try toSave.save(db)
        }
    }

    func markRead(_ id: String) async throws {
        try await dbQueue.write { db in
            try InsightRecord
                .filter(Column("id") == id)
                .updateAll(db, Column("isRead").set(to: true))
        }
    }

    func submitFeedback(_ id: String, feedback: String) async throws {
        try await dbQueue.write { db in
            try InsightRecord
                .filter(Column("id") == id)
                .updateAll(db, Column("feedback").set(to: feedback))
        }
    }

    // MARK: - Sync

    func getUnsynced() async throws -> [InsightRecord] {
        try await dbQueue.read { db in
            try InsightRecord
                .filter(Column("isSynced") == false)
                .fetchAll(db)
        }
    }

    // MARK: - Cleanup

    func deleteAll() async throws {
        try await dbQueue.write { db in
            try InsightRecord.deleteAll(db)
        }
    }
}

// MARK: - GRDB Record

struct InsightRecord: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: String
    var type: String
    var title: String
    var body: String
    var confidence: Double
    var isRead: Bool
    var feedback: String?
    var source: String
    var isSynced: Bool
    var createdAt: Date

    static let databaseTableName = "insights"

    init(
        id: String = UUID().uuidString,
        type: String,
        title: String,
        body: String,
        confidence: Double = 0,
        isRead: Bool = false,
        feedback: String? = nil,
        source: String = "rule_based",
        isSynced: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.confidence = max(0, min(1, confidence))
        self.isRead = isRead
        self.feedback = feedback
        self.source = source
        self.isSynced = isSynced
        self.createdAt = createdAt
    }
}
