import Foundation
import CryptoKit
import CommonCrypto

// MARK: - Encryption Manager
// AES-256-GCM encryption for sync data, PBKDF2 key derivation
// Spike S0-1: IMPLEMENTED — zero-knowledge architecture

/// Manages all encryption operations following zero-knowledge architecture
final class EncryptionManager {

    static let shared = EncryptionManager()

    // MARK: - Errors

    enum EncryptionError: Error, LocalizedError {
        case keyDerivationFailed
        case encryptionFailed
        case decryptionFailed
        case invalidData
        case keychainAccessFailed
        case saltGenerationFailed
        case invalidKeyLength

        var errorDescription: String? {
            switch self {
            case .keyDerivationFailed: return "Échec de la dérivation de clé"
            case .encryptionFailed: return "Échec du chiffrement"
            case .decryptionFailed: return "Échec du déchiffrement"
            case .invalidData: return "Données invalides"
            case .keychainAccessFailed: return "Accès Keychain échoué"
            case .saltGenerationFailed: return "Génération du sel échouée"
            case .invalidKeyLength: return "Longueur de clé invalide"
            }
        }
    }

    // MARK: - Key Management

    /// Derive master key from user PIN/biometric-bound secret using PBKDF2
    /// - Parameters:
    ///   - password: User's PIN or biometric-derived secret
    ///   - salt: Random salt (stored in Keychain)
    /// - Returns: Derived key (256-bit / 32 bytes)
    func deriveMasterKey(from password: Data, salt: Data) throws -> Data {
        let iterations = AppConfig.Encryption.pbkdf2Iterations
        let keyLength = AppConfig.Encryption.keyLength / 8 // 256 bits → 32 bytes

        var derivedKey = Data(count: keyLength)

        let result = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            password.withUnsafeBytes { passwordBytes in
                salt.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        password.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        keyLength
                    )
                }
            }
        }

        guard result == kCCSuccess else {
            throw EncryptionError.keyDerivationFailed
        }

        return derivedKey
    }

    /// Generate cryptographically secure random salt
    func generateSalt() throws -> Data {
        var salt = Data(count: AppConfig.Encryption.saltLength)
        let result = salt.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, AppConfig.Encryption.saltLength, buffer.baseAddress!)
        }
        guard result == errSecSuccess else {
            throw EncryptionError.saltGenerationFailed
        }
        return salt
    }

    /// Generate a random 256-bit key
    func generateRandomKey() throws -> Data {
        var key = Data(count: 32) // 256 bits
        let result = key.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, 32, buffer.baseAddress!)
        }
        guard result == errSecSuccess else {
            throw EncryptionError.saltGenerationFailed
        }
        return key
    }

    // MARK: - Encryption / Decryption

    /// Encrypt data using AES-256-GCM
    /// - Parameters:
    ///   - data: Plaintext data to encrypt
    ///   - key: 256-bit encryption key (32 bytes)
    /// - Returns: Encrypted data: nonce (12) + ciphertext + tag (16)
    func encrypt(_ data: Data, with key: Data) throws -> Data {
        guard key.count == 32 else {
            throw EncryptionError.invalidKeyLength
        }

        let symmetricKey = SymmetricKey(data: key)

        guard let sealedBox = try? AES.GCM.seal(data, using: symmetricKey) else {
            throw EncryptionError.encryptionFailed
        }

        // Combined: nonce (12 bytes) + ciphertext + tag (16 bytes)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }

        return combined
    }

    /// Decrypt data using AES-256-GCM
    /// - Parameters:
    ///   - encryptedData: Combined nonce (12) + ciphertext + tag (16)
    ///   - key: 256-bit encryption key (32 bytes)
    /// - Returns: Decrypted plaintext data
    func decrypt(_ encryptedData: Data, with key: Data) throws -> Data {
        guard key.count == 32 else {
            throw EncryptionError.invalidKeyLength
        }

        guard encryptedData.count > 28 else { // 12 nonce + 16 tag minimum
            throw EncryptionError.invalidData
        }

        let symmetricKey = SymmetricKey(data: key)

        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData) else {
            throw EncryptionError.invalidData
        }

        guard let decryptedData = try? AES.GCM.open(sealedBox, using: symmetricKey) else {
            throw EncryptionError.decryptionFailed
        }

        return decryptedData
    }

    // MARK: - Sync Blob

    /// Encrypt full dataset for cloud sync (zero-knowledge)
    func encryptForSync(_ jsonData: Data, syncKey: Data) throws -> (blob: Data, checksum: String) {
        let encrypted = try encrypt(jsonData, with: syncKey)
        let checksum = sha256Hash(of: encrypted)
        return (encrypted, checksum)
    }

    /// Decrypt blob received from cloud sync
    func decryptFromSync(_ blob: Data, syncKey: Data, expectedChecksum: String) throws -> Data {
        let actualChecksum = sha256Hash(of: blob)
        guard actualChecksum == expectedChecksum else {
            throw EncryptionError.invalidData
        }
        return try decrypt(blob, with: syncKey)
    }

    // MARK: - Hashing

    /// SHA-256 hash for integrity verification
    func sha256Hash(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
