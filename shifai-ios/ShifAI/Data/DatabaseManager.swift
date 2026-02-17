import Foundation
import GRDB

/// Database Manager — creates, encrypts, and migrates GRDB database.
/// Uses SQLCipher for AES-256 encryption with key from Keychain.
final class DatabaseManager {

    static let shared = DatabaseManager()

    private(set) var dbQueue: DatabaseQueue?

    private init() {}

    // MARK: - Setup

    func setup() throws {
        let path = databasePath()
        let passphrase = try EncryptionManager.shared.getDatabaseKey()

        var config = Configuration()
        config.prepareDatabase { db in
            try db.usePassphrase(passphrase)
        }
        config.foreignKeysEnabled = true

        let dbQueue = try DatabaseQueue(path: path, configuration: config)
        try migrator.migrate(dbQueue)
        self.dbQueue = dbQueue
    }

    /// In-memory database for testing (no encryption).
    func setupForTesting() throws {
        let dbQueue = try DatabaseQueue(configuration: Configuration())
        try migrator.migrate(dbQueue)
        self.dbQueue = dbQueue
    }

    // MARK: - Migrations

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // v1: Initial schema
        migrator.registerMigration("v1_initial") { db in
            try db.create(table: "cycle_entries") { t in
                t.column("id", .text).primaryKey()
                t.column("date", .date).notNull().unique()
                t.column("cycleDay", .integer).notNull()
                t.column("phase", .text).notNull().defaults(to: "unknown")
                t.column("flowIntensity", .integer).defaults(to: 0)
                t.column("moodScore", .integer).defaults(to: 5)
                t.column("energyScore", .integer).defaults(to: 5)
                t.column("sleepHours", .double).defaults(to: 0)
                t.column("stressLevel", .integer).defaults(to: 5)
                t.column("notes", .text).defaults(to: "")
                t.column("isSynced", .boolean).defaults(to: false)
                t.column("updatedAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }

            try db.create(table: "symptom_logs") { t in
                t.column("id", .text).primaryKey()
                t.column("cycleEntryId", .text).notNull()
                    .references("cycle_entries", onDelete: .cascade)
                t.column("category", .text).notNull()
                t.column("symptomType", .text).notNull()
                t.column("intensity", .integer).notNull()
                t.column("bodyZone", .text)
                t.column("isSynced", .boolean).defaults(to: false)
                t.column("createdAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }

            try db.create(table: "insights") { t in
                t.column("id", .text).primaryKey()
                t.column("type", .text).notNull()
                t.column("title", .text).notNull()
                t.column("body", .text).notNull()
                t.column("confidence", .double).defaults(to: 0)
                t.column("isRead", .boolean).defaults(to: false)
                t.column("feedback", .text)
                t.column("source", .text).defaults(to: "rule_based")
                t.column("isSynced", .boolean).defaults(to: false)
                t.column("createdAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }

            try db.create(table: "predictions") { t in
                t.column("id", .text).primaryKey()
                t.column("type", .text).notNull()
                t.column("predictedDate", .date).notNull()
                t.column("confidence", .double).defaults(to: 0)
                t.column("actualDate", .date)
                t.column("source", .text).defaults(to: "rule_based")
                t.column("isSynced", .boolean).defaults(to: false)
                t.column("createdAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }

            // Indexes
            try db.create(index: "idx_cycle_date", on: "cycle_entries", columns: ["date"])
            try db.create(index: "idx_symptom_entry", on: "symptom_logs", columns: ["cycleEntryId"])
            try db.create(index: "idx_insight_created", on: "insights", columns: ["createdAt"])
            try db.create(index: "idx_prediction_date", on: "predictions", columns: ["predictedDate"])
        }

        return migrator
    }

    // MARK: - Path

    private func databasePath() -> String {
        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.shifai.shared")!
            .appendingPathComponent("shifai.db")
        return url.path
    }
}
