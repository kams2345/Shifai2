import XCTest
@testable import ShifAI

final class EncryptionManagerTests: XCTestCase {

    var manager: EncryptionManager!

    override func setUp() {
        manager = EncryptionManager()
    }

    // MARK: - AES-256-GCM Encryption

    func testEncryptDecrypt_RoundTrip_ReturnsOriginal() throws {
        let original = "Cycle day 14, mood: happy, energy: 8/10"
        let data = Data(original.utf8)

        let encrypted = try manager.encrypt(data: data)
        XCTAssertNotEqual(encrypted, data, "Encrypted should differ from plaintext")

        let decrypted = try manager.decrypt(data: encrypted)
        let result = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(result, original, "Decrypted should match original")
    }

    func testEncryptDecrypt_EmptyData_Works() throws {
        let data = Data()
        let encrypted = try manager.encrypt(data: data)
        let decrypted = try manager.decrypt(data: encrypted)
        XCTAssertEqual(decrypted, data)
    }

    func testEncryptDecrypt_LargeData_Works() throws {
        // Simulate a full dataset blob (~100KB)
        let largeData = Data(repeating: 0xAB, count: 100_000)
        let encrypted = try manager.encrypt(data: largeData)

        XCTAssertGreaterThan(encrypted.count, largeData.count, "Encrypted should be larger (IV + tag)")

        let decrypted = try manager.decrypt(data: encrypted)
        XCTAssertEqual(decrypted, largeData)
    }

    func testEncrypt_ProducesDifferentCiphertext_EachTime() throws {
        let data = Data("same plaintext".utf8)
        let encrypted1 = try manager.encrypt(data: data)
        let encrypted2 = try manager.encrypt(data: data)

        XCTAssertNotEqual(encrypted1, encrypted2, "Each encryption should use unique IV")
    }

    func testDecrypt_TamperedData_ThrowsError() {
        let data = Data("sensitive health data".utf8)

        do {
            var encrypted = try manager.encrypt(data: data)
            // Tamper with ciphertext
            encrypted[12] ^= 0xFF

            _ = try manager.decrypt(data: encrypted)
            XCTFail("Should throw on tampered data")
        } catch {
            // Expected: authentication tag verification fails
            XCTAssertNotNil(error, "Tampered data should throw")
        }
    }

    // MARK: - Key Derivation

    func testDeriveKey_SameInput_SameOutput() throws {
        let password = "user-passphrase"
        let salt = Data("fixed-salt-for-test".utf8)

        let key1 = try manager.deriveKey(from: password, salt: salt)
        let key2 = try manager.deriveKey(from: password, salt: salt)

        XCTAssertEqual(key1, key2, "Same password + salt should derive same key")
    }

    func testDeriveKey_DifferentSalt_DifferentOutput() throws {
        let password = "user-passphrase"

        let key1 = try manager.deriveKey(from: password, salt: Data("salt-1".utf8))
        let key2 = try manager.deriveKey(from: password, salt: Data("salt-2".utf8))

        XCTAssertNotEqual(key1, key2, "Different salts should produce different keys")
    }

    // MARK: - Checksum

    func testChecksum_Deterministic() {
        let data = Data("cycle data blob".utf8)
        let hash1 = manager.sha256Checksum(data: data)
        let hash2 = manager.sha256Checksum(data: data)

        XCTAssertEqual(hash1, hash2, "SHA-256 should be deterministic")
        XCTAssertEqual(hash1.count, 64, "SHA-256 hex should be 64 chars")
    }
}
