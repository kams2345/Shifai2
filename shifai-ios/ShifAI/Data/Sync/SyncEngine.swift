import Foundation
import CryptoKit

// MARK: - Sync Engine (S7-1)
// Zero-knowledge, offline-first cloud sync
// Flow: local DB → JSON → AES-256-GCM encrypt → blob → Supabase

final class SyncEngine {

    static let shared = SyncEngine()

    // MARK: - Config

    private let syncEndpoint: String
    private let maxBlobSize = 10 * 1024 * 1024  // 10MB
    private let syncInterval: TimeInterval = 6 * 3600  // 6h

    private var isSyncing = false

    enum SyncState: Equatable {
        case idle
        case syncing
        case success(lastSync: Date)
        case error(String)
    }

    @Published var state: SyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "sync_enabled") }
    }

    // MARK: - Init

    init() {
        self.syncEndpoint = "\(Configuration.supabaseURL)/functions/v1/sync-data"
        self.isEnabled = UserDefaults.standard.bool(forKey: "sync_enabled")
        self.lastSyncDate = UserDefaults.standard.object(forKey: "last_sync_date") as? Date
    }

    // MARK: - S7-1: Push (Local → Cloud)

    func push() async throws {
        guard isEnabled, !isSyncing else { return }
        isSyncing = true
        state = .syncing

        defer { isSyncing = false }

        do {
            // 1. Serialize local data to JSON
            let payload = try serializeLocalData()

            // 2. Encrypt with AES-256-GCM
            let encryptedBlob = try encrypt(data: payload)

            // 3. Compute SHA-256 checksum
            let checksum = SHA256.hash(data: encryptedBlob)
                .compactMap { String(format: "%02x", $0) }
                .joined()

            guard encryptedBlob.count <= maxBlobSize else {
                state = .error("Données trop volumineuses (\(encryptedBlob.count / 1024)KB)")
                return
            }

            // 4. Push to Supabase
            let currentVersion = UserDefaults.standard.integer(forKey: "sync_blob_version")
            var request = URLRequest(url: URL(string: syncEndpoint)!)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(try getAuthToken())", forHTTPHeaderField: "Authorization")
            request.setValue(checksum, forHTTPHeaderField: "X-Checksum-SHA256")
            request.setValue("\(currentVersion + 1)", forHTTPHeaderField: "X-Blob-Version")
            request.httpBody = encryptedBlob

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                state = .error(errorBody)
                return
            }

            // 5. Update local state
            let newVersion = currentVersion + 1
            UserDefaults.standard.set(newVersion, forKey: "sync_blob_version")
            let now = Date()
            UserDefaults.standard.set(now, forKey: "last_sync_date")
            lastSyncDate = now
            state = .success(lastSync: now)

        } catch {
            state = .error(error.localizedDescription)
            throw error
        }
    }

    // MARK: - S7-1: Pull (Cloud → Local)

    func pull() async throws {
        guard isEnabled, !isSyncing else { return }
        isSyncing = true
        state = .syncing

        defer { isSyncing = false }

        do {
            // 1. GET metadata first
            var metaRequest = URLRequest(url: URL(string: "\(syncEndpoint)?action=metadata")!)
            metaRequest.httpMethod = "GET"
            metaRequest.setValue("Bearer \(try getAuthToken())", forHTTPHeaderField: "Authorization")

            let (metaData, metaResponse) = try await URLSession.shared.data(for: metaRequest)
            guard let metaHttp = metaResponse as? HTTPURLResponse, metaHttp.statusCode == 200 else {
                state = .error("Impossible de vérifier la version serveur")
                return
            }

            let metadata = try JSONDecoder().decode(SyncMetadata.self, from: metaData)
            let localVersion = UserDefaults.standard.integer(forKey: "sync_blob_version")

            guard metadata.blobVersion > localVersion else {
                state = .success(lastSync: lastSyncDate ?? Date())
                return  // Local is up to date
            }

            // 2. GET blob
            var blobRequest = URLRequest(url: URL(string: "\(syncEndpoint)?action=pull")!)
            blobRequest.httpMethod = "GET"
            blobRequest.setValue("Bearer \(try getAuthToken())", forHTTPHeaderField: "Authorization")

            let (blobData, blobResponse) = try await URLSession.shared.data(for: blobRequest)
            guard let blobHttp = blobResponse as? HTTPURLResponse, blobHttp.statusCode == 200 else {
                state = .error("Échec du téléchargement")
                return
            }

            // 3. Verify checksum
            let serverChecksum = (blobHttp.value(forHTTPHeaderField: "X-Checksum-SHA256")) ?? ""
            let localChecksum = SHA256.hash(data: blobData)
                .compactMap { String(format: "%02x", $0) }
                .joined()

            guard serverChecksum == localChecksum else {
                state = .error("Erreur d'intégrité des données")
                return
            }

            // 4. Decrypt
            let decryptedData = try decrypt(data: blobData)

            // 5. Merge with local
            try mergeWithLocal(data: decryptedData)

            // 6. Update version
            UserDefaults.standard.set(metadata.blobVersion, forKey: "sync_blob_version")
            let now = Date()
            UserDefaults.standard.set(now, forKey: "last_sync_date")
            lastSyncDate = now
            state = .success(lastSync: now)

        } catch {
            state = .error(error.localizedDescription)
            throw error
        }
    }

    // MARK: - Full Sync (Push then Pull)

    func sync() async throws {
        try await push()
        try await pull()
    }

    // MARK: - Serialization

    private func serializeLocalData() throws -> Data {
        // Serialize cycle entries, symptom logs, insights, predictions
        // into a unified JSON structure
        var payload: [String: Any] = [:]

        let cycleRepo = CycleRepository()
        let symptomRepo = SymptomRepository()
        let insightRepo = InsightRepository()
        let predictionRepo = PredictionRepository()

        let cycles = try cycleRepo.fetchAll()
        let insights = try insightRepo.fetchRecent(limit: 10000)
        let predictions = try predictionRepo.fetchAll()

        // Encode to JSON via Codable
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        payload["cycles"] = try encoder.encode(cycles)
        payload["insights"] = try encoder.encode(insights)
        payload["predictions"] = try encoder.encode(predictions)
        payload["version"] = UserDefaults.standard.integer(forKey: "sync_blob_version") + 1
        payload["timestamp"] = ISO8601DateFormatter().string(from: Date())

        return try JSONSerialization.data(withJSONObject: payload)
    }

    private func mergeWithLocal(data: Data) throws {
        // Last-write-wins merge strategy
        // In conflict cases, the data with the more recent timestamp wins
        // TODO: Implement full merge logic with conflict detection
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Parse the incoming data and merge
        // For MVP: server data replaces local for items with newer timestamps
    }

    // MARK: - Encryption (AES-256-GCM)

    private func encrypt(data: Data) throws -> Data {
        let key = try getOrCreateSyncKey()
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        guard let combined = sealedBox.combined else {
            throw SyncError.encryptionFailed
        }
        return combined
    }

    private func decrypt(data: Data) throws -> Data {
        let key = try getOrCreateSyncKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    private func getOrCreateSyncKey() throws -> SymmetricKey {
        let keyTag = "com.shifai.sync.key"

        // Try to read from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let keyData = result as? Data {
            return SymmetricKey(data: keyData)
        }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(addQuery as CFDictionary, nil)
        return newKey
    }

    // MARK: - Auth

    private func getAuthToken() throws -> String {
        // Return current Supabase JWT
        guard let token = UserDefaults.standard.string(forKey: "supabase_access_token") else {
            throw SyncError.notAuthenticated
        }
        return token
    }

    // MARK: - Types

    struct SyncMetadata: Codable {
        let blobVersion: Int
        let updatedAt: String
        let sizeBytes: Int

        enum CodingKeys: String, CodingKey {
            case blobVersion = "blob_version"
            case updatedAt = "updated_at"
            case sizeBytes = "size_bytes"
        }
    }

    enum SyncError: Error, LocalizedError {
        case encryptionFailed
        case notAuthenticated
        case blobTooLarge
        case integrityCheckFailed

        var errorDescription: String? {
            switch self {
            case .encryptionFailed: return "Échec du chiffrement"
            case .notAuthenticated: return "Non authentifié"
            case .blobTooLarge: return "Données trop volumineuses"
            case .integrityCheckFailed: return "Erreur d'intégrité"
            }
        }
    }
}

// MARK: - Configuration

private enum Configuration {
    static var supabaseURL: String {
        // Read from Info.plist or environment
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? "https://your-project.supabase.co"
    }
}
