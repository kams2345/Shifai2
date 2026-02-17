import XCTest
@testable import ShifAI

// MARK: - Encryption Manager Tests
// Spike S0-1: Validates the full encryption round-trip

final class EncryptionManagerTests: XCTestCase {

    let sut = EncryptionManager()

    // MARK: - Salt Generation

    func testGenerateSalt_ReturnsCorrectLength() throws {
        let salt = try sut.generateSalt()
        XCTAssertEqual(salt.count, 32, "Salt should be 32 bytes")
    }

    func testGenerateSalt_ReturnsUniqueSalts() throws {
        let salt1 = try sut.generateSalt()
        let salt2 = try sut.generateSalt()
        XCTAssertNotEqual(salt1, salt2, "Each salt should be unique")
    }

    // MARK: - Key Derivation (PBKDF2)

    func testDeriveMasterKey_ReturnsCorrectLength() throws {
        let password = "test-pin-1234".data(using: .utf8)!
        let salt = try sut.generateSalt()

        let key = try sut.deriveMasterKey(from: password, salt: salt)
        XCTAssertEqual(key.count, 32, "Derived key should be 32 bytes (256 bits)")
    }

    func testDeriveMasterKey_SameInputProducesSameKey() throws {
        let password = "consistent-pin".data(using: .utf8)!
        let salt = try sut.generateSalt()

        let key1 = try sut.deriveMasterKey(from: password, salt: salt)
        let key2 = try sut.deriveMasterKey(from: password, salt: salt)
        XCTAssertEqual(key1, key2, "Same password + same salt → same key")
    }

    func testDeriveMasterKey_DifferentSaltProducesDifferentKey() throws {
        let password = "same-pin".data(using: .utf8)!
        let salt1 = try sut.generateSalt()
        let salt2 = try sut.generateSalt()

        let key1 = try sut.deriveMasterKey(from: password, salt: salt1)
        let key2 = try sut.deriveMasterKey(from: password, salt: salt2)
        XCTAssertNotEqual(key1, key2, "Different salt → different key")
    }

    func testDeriveMasterKey_DifferentPasswordProducesDifferentKey() throws {
        let salt = try sut.generateSalt()

        let key1 = try sut.deriveMasterKey(from: "pin-1234".data(using: .utf8)!, salt: salt)
        let key2 = try sut.deriveMasterKey(from: "pin-5678".data(using: .utf8)!, salt: salt)
        XCTAssertNotEqual(key1, key2, "Different password → different key")
    }

    // MARK: - AES-256-GCM Encrypt/Decrypt

    func testEncryptDecrypt_RoundTrip_SmallData() throws {
        let key = try sut.generateRandomKey()
        let plaintext = "Hello ShifAI 🌙".data(using: .utf8)!

        let encrypted = try sut.encrypt(plaintext, with: key)
        let decrypted = try sut.decrypt(encrypted, with: key)

        XCTAssertEqual(decrypted, plaintext, "Decrypted data must match original")
    }

    func testEncryptDecrypt_RoundTrip_LargeData() throws {
        // Simulate ~5MB of cycle data (realistic sync blob)
        let key = try sut.generateRandomKey()
        let largePayload = Data(repeating: 0xAB, count: 5 * 1024 * 1024)

        let encrypted = try sut.encrypt(largePayload, with: key)
        let decrypted = try sut.decrypt(encrypted, with: key)

        XCTAssertEqual(decrypted, largePayload, "Large data round-trip must work")
    }

    func testEncryptDecrypt_RoundTrip_JSONPayload() throws {
        let key = try sut.generateRandomKey()

        // Simulate real cycle entry JSON
        let cycleData: [String: Any] = [
            "id": "uuid-123",
            "date": "2026-02-10",
            "flowIntensity": 3,
            "phase": "follicular",
            "symptoms": [
                ["type": "mood", "value": 7],
                ["type": "energy", "value": 6],
                ["type": "pain", "value": 4, "bodyZone": "uterus"]
            ]
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: cycleData)

        let encrypted = try sut.encrypt(jsonData, with: key)
        let decrypted = try sut.decrypt(encrypted, with: key)

        let decoded = try JSONSerialization.jsonObject(with: decrypted) as! [String: Any]
        XCTAssertEqual(decoded["id"] as? String, "uuid-123")
        XCTAssertEqual(decoded["phase"] as? String, "follicular")
    }

    func testEncrypt_ProducesDifferentCiphertextEachTime() throws {
        let key = try sut.generateRandomKey()
        let plaintext = "Same plaintext".data(using: .utf8)!

        let encrypted1 = try sut.encrypt(plaintext, with: key)
        let encrypted2 = try sut.encrypt(plaintext, with: key)

        XCTAssertNotEqual(encrypted1, encrypted2, "GCM nonce makes each encryption unique")
    }

    func testEncrypt_OutputIncludesNonceAndTag() throws {
        let key = try sut.generateRandomKey()
        let plaintext = "Test".data(using: .utf8)!

        let encrypted = try sut.encrypt(plaintext, with: key)

        // Output = nonce (12) + ciphertext (4) + tag (16) = 32
        XCTAssertEqual(encrypted.count, 12 + plaintext.count + 16)
    }

    func testDecrypt_FailsWithWrongKey() throws {
        let key1 = try sut.generateRandomKey()
        let key2 = try sut.generateRandomKey()
        let plaintext = "Secret data".data(using: .utf8)!

        let encrypted = try sut.encrypt(plaintext, with: key1)

        XCTAssertThrowsError(try sut.decrypt(encrypted, with: key2)) { error in
            XCTAssertTrue(error is EncryptionManager.EncryptionError)
        }
    }

    func testDecrypt_FailsWithTamperedData() throws {
        let key = try sut.generateRandomKey()
        let plaintext = "Tamper-proof data".data(using: .utf8)!

        var encrypted = try sut.encrypt(plaintext, with: key)

        // Tamper with last byte (GCM tag)
        encrypted[encrypted.count - 1] ^= 0xFF

        XCTAssertThrowsError(try sut.decrypt(encrypted, with: key)) { error in
            XCTAssertTrue(error is EncryptionManager.EncryptionError)
        }
    }

    func testDecrypt_FailsWithTruncatedData() throws {
        let key = try sut.generateRandomKey()

        // Data too short (less than nonce + tag)
        let shortData = Data(repeating: 0x00, count: 20)
        XCTAssertThrowsError(try sut.decrypt(shortData, with: key))
    }

    func testEncrypt_FailsWithInvalidKeyLength() throws {
        let shortKey = Data(count: 16) // 128 bits instead of 256
        let plaintext = "Test".data(using: .utf8)!

        XCTAssertThrowsError(try sut.encrypt(plaintext, with: shortKey)) { error in
            guard let encError = error as? EncryptionManager.EncryptionError else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(encError, .invalidKeyLength)
        }
    }

    // MARK: - SHA-256 Hashing

    func testSHA256Hash_ProducesConsistentHash() {
        let data = "test data".data(using: .utf8)!

        let hash1 = sut.sha256Hash(of: data)
        let hash2 = sut.sha256Hash(of: data)

        XCTAssertEqual(hash1, hash2)
        XCTAssertEqual(hash1.count, 64, "SHA-256 hex = 64 chars")
    }

    func testSHA256Hash_DifferentDataProducesDifferentHash() {
        let hash1 = sut.sha256Hash(of: "data1".data(using: .utf8)!)
        let hash2 = sut.sha256Hash(of: "data2".data(using: .utf8)!)

        XCTAssertNotEqual(hash1, hash2)
    }

    // MARK: - Sync Blob Round-Trip

    func testSyncBlobRoundTrip() throws {
        let syncKey = try sut.generateRandomKey()

        // Simulate full cycle dataset
        let dataset = """
        {"cycles":[{"date":"2026-01-15","flow":3},{"date":"2026-02-12","flow":4}],
         "symptoms":[{"type":"mood","value":7},{"type":"energy","value":5}],
         "profile":{"conditions":["sopk"],"locale":"fr"}}
        """.data(using: .utf8)!

        // Encrypt for sync
        let (blob, checksum) = try sut.encryptForSync(dataset, syncKey: syncKey)

        // Verify blob is not plaintext
        XCTAssertNotEqual(blob, dataset)
        XCTAssertFalse(checksum.isEmpty)

        // Decrypt from sync
        let decrypted = try sut.decryptFromSync(blob, syncKey: syncKey, expectedChecksum: checksum)
        XCTAssertEqual(decrypted, dataset, "Sync round-trip must preserve data")
    }

    func testSyncBlobDecrypt_FailsWithWrongChecksum() throws {
        let syncKey = try sut.generateRandomKey()
        let data = "test".data(using: .utf8)!

        let (blob, _) = try sut.encryptForSync(data, syncKey: syncKey)

        XCTAssertThrowsError(
            try sut.decryptFromSync(blob, syncKey: syncKey, expectedChecksum: "wrong-checksum")
        )
    }

    // MARK: - Full PBKDF2 → AES-GCM Pipeline

    func testFullPipeline_PINToEncryptDecrypt() throws {
        // 1. User sets PIN
        let pin = "1234".data(using: .utf8)!
        let salt = try sut.generateSalt()

        // 2. Derive master key
        let masterKey = try sut.deriveMasterKey(from: pin, salt: salt)
        XCTAssertEqual(masterKey.count, 32)

        // 3. Encrypt health data
        let healthData = """
        {"date":"2026-02-10","symptoms":[{"type":"pain","value":7,"zone":"uterus"}]}
        """.data(using: .utf8)!

        let encrypted = try sut.encrypt(healthData, with: masterKey)

        // 4. Later: user enters same PIN → same key → decrypt
        let sameKey = try sut.deriveMasterKey(from: pin, salt: salt)
        let decrypted = try sut.decrypt(encrypted, with: sameKey)

        XCTAssertEqual(decrypted, healthData, "Full pipeline: PIN → PBKDF2 → AES-GCM → decrypt")
    }

    // MARK: - Performance

    func testPerformance_EncryptDecrypt1MB() throws {
        let key = try sut.generateRandomKey()
        let data = Data(repeating: 0x42, count: 1_024 * 1_024)

        measure {
            do {
                let encrypted = try sut.encrypt(data, with: key)
                _ = try sut.decrypt(encrypted, with: key)
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
    }

    func testPerformance_PBKDF2KeyDerivation() throws {
        let password = "test-pin".data(using: .utf8)!
        let salt = try sut.generateSalt()

        measure {
            _ = try? sut.deriveMasterKey(from: password, salt: salt)
        }
    }
}
