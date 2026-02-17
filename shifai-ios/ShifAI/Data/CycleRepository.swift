import Foundation
import GRDB

/// Cycle Repository — offline-first data layer for iOS.
/// Single source of truth: write to GRDB first, sync to Supabase later.
/// Mirrors Android CycleRepository.kt for cross-platform parity.
final class CycleRepository {

    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    // MARK: - Observe

    func observeEntries() -> DatabasePublishers.Value<[CycleEntry]> {
        ValueObservation
            .tracking { db in
                try CycleEntry
                    .order(Column("date").desc)
                    .fetchAll(db)
            }
            .publisher(in: dbQueue, scheduling: .immediate)
    }

    // MARK: - Read

    func getEntryByDate(_ date: Date) async throws -> CycleEntry? {
        try await dbQueue.read { db in
            try CycleEntry
                .filter(Column("date") == date)
                .fetchOne(db)
        }
    }

    func getRecentEntries(count: Int = 30) async throws -> [CycleEntry] {
        try await dbQueue.read { db in
            try CycleEntry
                .order(Column("date").desc)
                .limit(count)
                .fetchAll(db)
        }
    }

    func getDateRange(from start: Date, to end: Date) async throws -> [CycleEntry] {
        try await dbQueue.read { db in
            try CycleEntry
                .filter(Column("date") >= start && Column("date") <= end)
                .order(Column("date").asc)
                .fetchAll(db)
        }
    }

    func getSymptomsForEntry(_ entryId: String) async throws -> [SymptomLog] {
        try await dbQueue.read { db in
            try SymptomLog
                .filter(Column("cycleEntryId") == entryId)
                .fetchAll(db)
        }
    }

    // MARK: - Write

    func saveEntry(_ entry: CycleEntry) async throws {
        var toSave = entry
        toSave.isSynced = false
        try await dbQueue.write { db in
            try toSave.save(db)
        }
    }

    func saveSymptom(_ symptom: SymptomLog) async throws {
        var toSave = symptom
        toSave.isSynced = false
        try await dbQueue.write { db in
            try toSave.save(db)
        }
    }

    func deleteSymptom(_ symptom: SymptomLog) async throws {
        _ = try await dbQueue.write { db in
            try symptom.delete(db)
        }
    }

    // MARK: - Sync

    func getUnsyncedEntries() async throws -> [CycleEntry] {
        try await dbQueue.read { db in
            try CycleEntry
                .filter(Column("isSynced") == false)
                .fetchAll(db)
        }
    }

    func getUnsyncedSymptoms() async throws -> [SymptomLog] {
        try await dbQueue.read { db in
            try SymptomLog
                .filter(Column("isSynced") == false)
                .fetchAll(db)
        }
    }

    func markEntriesSynced(_ ids: [String]) async throws {
        try await dbQueue.write { db in
            try CycleEntry
                .filter(ids.contains(Column("id")))
                .updateAll(db, Column("isSynced").set(to: true))
        }
    }

    // MARK: - Stats

    func entryCount() async throws -> Int {
        try await dbQueue.read { db in
            try CycleEntry.fetchCount(db)
        }
    }

    // MARK: - Danger Zone

    func deleteAllData() async throws {
        try await dbQueue.write { db in
            try CycleEntry.deleteAll(db)
            try SymptomLog.deleteAll(db)
        }
    }
}
