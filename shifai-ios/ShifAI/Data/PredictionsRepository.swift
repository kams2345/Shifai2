import Foundation
import GRDB

/// Predictions Repository — manages prediction CRUD and verification.
/// Offline-first, mirrors Android pattern.
final class PredictionsRepository {

    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    // MARK: - Observe

    func observeUpcoming() -> DatabasePublishers.Value<[PredictionRecord]> {
        ValueObservation
            .tracking { db in
                try PredictionRecord
                    .filter(Column("predictedDate") >= Date())
                    .order(Column("predictedDate").asc)
                    .fetchAll(db)
            }
            .publisher(in: dbQueue, scheduling: .immediate)
    }

    // MARK: - Read

    func getNextPrediction(type: String) async throws -> PredictionRecord? {
        try await dbQueue.read { db in
            try PredictionRecord
                .filter(Column("type") == type)
                .filter(Column("predictedDate") >= Date())
                .order(Column("predictedDate").asc)
                .fetchOne(db)
        }
    }

    func getVerified(limit: Int = 10) async throws -> [PredictionRecord] {
        try await dbQueue.read { db in
            try PredictionRecord
                .filter(Column("actualDate") != nil)
                .order(Column("predictedDate").desc)
                .limit(limit)
                .fetchAll(db)
        }
    }

    // MARK: - Write

    func save(_ prediction: PredictionRecord) async throws {
        var toSave = prediction
        toSave.isSynced = false
        try await dbQueue.write { db in
            try toSave.save(db)
        }
    }

    func verify(_ id: String, actualDate: Date) async throws {
        try await dbQueue.write { db in
            try PredictionRecord
                .filter(Column("id") == id)
                .updateAll(db,
                    Column("actualDate").set(to: actualDate),
                    Column("isSynced").set(to: false)
                )
        }
    }

    // MARK: - Sync

    func getUnsynced() async throws -> [PredictionRecord] {
        try await dbQueue.read { db in
            try PredictionRecord
                .filter(Column("isSynced") == false)
                .fetchAll(db)
        }
    }

    // MARK: - Analytics

    func averageAccuracy(type: String) async throws -> Double? {
        try await dbQueue.read { db in
            let verified = try PredictionRecord
                .filter(Column("type") == type)
                .filter(Column("actualDate") != nil)
                .fetchAll(db)

            guard !verified.isEmpty else { return nil }
            let totalDays = verified.compactMap(\.accuracyDays).map { abs($0) }
            return Double(totalDays.reduce(0, +)) / Double(totalDays.count)
        }
    }
}
