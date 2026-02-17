import Foundation
import Security

// MARK: - Keychain Manager
// Secure key storage using iOS Keychain (Secure Enclave backed)

final class KeychainManager {

    enum KeychainError: Error {
        case saveFailed(OSStatus)
        case readFailed(OSStatus)
        case deleteFailed(OSStatus)
        case notFound
        case invalidData
    }

    // MARK: - Key Identifiers

    private enum KeyIdentifier: String {
        case masterKey = "com.shifai.keys.master"
        case dbKey = "com.shifai.keys.database"
        case syncKey = "com.shifai.keys.sync"
        case exportKey = "com.shifai.keys.export"
        case salt = "com.shifai.keys.salt"
    }

    // MARK: - Generic Operations

    /// Save data to Keychain with Secure Enclave protection
    func save(_ data: Data, for key: String) throws {
        // Delete existing if present
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.shifai.keychain"
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Save new
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.shifai.keychain",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    /// Read data from Keychain
    func read(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.shifai.keychain",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.readFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        return data
    }

    /// Delete data from Keychain
    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.shifai.keychain"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Convenience Methods

    func saveMasterKey(_ key: Data) throws { try save(key, for: KeyIdentifier.masterKey.rawValue) }
    func readMasterKey() throws -> Data { try read(for: KeyIdentifier.masterKey.rawValue) }

    func saveSalt(_ salt: Data) throws { try save(salt, for: KeyIdentifier.salt.rawValue) }
    func readSalt() throws -> Data { try read(for: KeyIdentifier.salt.rawValue) }

    func saveSyncKey(_ key: Data) throws { try save(key, for: KeyIdentifier.syncKey.rawValue) }
    func readSyncKey() throws -> Data { try read(for: KeyIdentifier.syncKey.rawValue) }

    /// Wipe all ShifAI keys (account deletion)
    func deleteAllKeys() throws {
        for identifier in [KeyIdentifier.masterKey, .dbKey, .syncKey, .exportKey, .salt] {
            try delete(for: identifier.rawValue)
        }
    }
}
