import Foundation

// MARK: - Database Manager
// SQLCipher encrypted database via GRDB.swift

/// Manages the local encrypted SQLite database
final class DatabaseManager {

    // MARK: - Errors

    enum DatabaseError: Error, LocalizedError {
        case notInitialized
        case migrationFailed(String)
        case queryFailed(String)
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .notInitialized: return "Base de données non initialisée"
            case .migrationFailed(let msg): return "Migration échouée: \(msg)"
            case .queryFailed(let msg): return "Requête échouée: \(msg)"
            case .writeFailed(let msg): return "Écriture échouée: \(msg)"
            }
        }
    }

    // MARK: - Properties

    static let shared = DatabaseManager()
    private var isInitialized = false

    // Database file path (inside container, NOT shared)
    var databasePath: String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("shifai_encrypted.db").path
    }

    // Shared database path (for Widget Extension — App Group)
    var sharedDatabasePath: String {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.shifai.shared"
        ) else {
            return databasePath // Fallback
        }
        return containerURL.appendingPathComponent("shifai_shared.db").path
    }

    private init() {}

    // MARK: - Initialization

    /// Initialize encrypted database with derived key
    /// - Parameter dbKey: AES-256 key derived from master key
    func initialize(with dbKey: Data) throws {
        // TODO: Initialize GRDB.swift DatabasePool with SQLCipher
        // - Open database at databasePath
        // - Set SQLCipher key: PRAGMA key = x'...'
        // - Set PRAGMA cipher_page_size = 4096
        // - Run migrations
        // - Set isInitialized = true

        try runMigrations()
        isInitialized = true
    }

    // MARK: - Migrations

    private func runMigrations() throws {
        // Migration v1: Initial schema
        try migrateV1()
    }

    private func migrateV1() throws {
        // TODO: Execute via GRDB migrator
        let sql = """
        CREATE TABLE IF NOT EXISTS user_profile (
            id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL,
            onboarding_completed INTEGER NOT NULL DEFAULT 0,
            cycle_type TEXT NOT NULL DEFAULT 'unknown',
            conditions TEXT NOT NULL DEFAULT '[]',
            preferences TEXT NOT NULL DEFAULT '{}'
        );

        CREATE TABLE IF NOT EXISTS cycle_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            flow_intensity INTEGER,
            cycle_day INTEGER,
            phase TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'pending'
        );

        CREATE TABLE IF NOT EXISTS symptom_logs (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            symptom_type TEXT NOT NULL,
            value INTEGER NOT NULL,
            notes TEXT,
            body_zone TEXT,
            pain_type TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'pending'
        );

        CREATE TABLE IF NOT EXISTS insights (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            confidence REAL,
            reasoning TEXT,
            source TEXT NOT NULL DEFAULT 'rule_based',
            user_feedback TEXT,
            created_at INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS predictions (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            predicted_date TEXT,
            predicted_value INTEGER,
            confidence REAL NOT NULL,
            actual_date TEXT,
            actual_value INTEGER,
            accuracy_score REAL,
            model_version TEXT NOT NULL,
            created_at INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS sync_log (
            id TEXT PRIMARY KEY,
            sync_type TEXT NOT NULL,
            started_at INTEGER NOT NULL,
            completed_at INTEGER,
            records_pushed INTEGER DEFAULT 0,
            records_pulled INTEGER DEFAULT 0,
            conflicts INTEGER DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'pending'
        );

        -- Indexes for performance
        CREATE INDEX IF NOT EXISTS idx_cycle_entries_date ON cycle_entries(date);
        CREATE INDEX IF NOT EXISTS idx_symptom_logs_date ON symptom_logs(date);
        CREATE INDEX IF NOT EXISTS idx_insights_date ON insights(date);
        CREATE INDEX IF NOT EXISTS idx_predictions_type ON predictions(type);
        """
        // TODO: Execute SQL via GRDB
        _ = sql
    }

    // MARK: - Wipe (Account Deletion — GDPR)

    /// Delete all local data (GDPR Art. 17)
    func wipeDatabase() throws {
        isInitialized = false
        try? FileManager.default.removeItem(atPath: databasePath)
        try? FileManager.default.removeItem(atPath: sharedDatabasePath)
    }
}
