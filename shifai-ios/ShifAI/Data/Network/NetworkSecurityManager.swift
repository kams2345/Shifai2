import Foundation

// MARK: - Network Security Manager
// S1-10: Certificate Pinning + TLS 1.3 enforcement

/// Manages network security including certificate pinning for Supabase EU
final class NetworkSecurityManager: NSObject {

    static let shared = NetworkSecurityManager()

    // MARK: - Pin Configuration

    // SHA-256 hashes of Supabase EU intermediate CA certificates
    // Generated via: openssl x509 -inform PEM -in cert.pem -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64
    private let pinnedCertificateHashes: [String] = [
        // Primary pin: Let's Encrypt ISRG Root X1
        "C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=",
        // Backup pin: Let's Encrypt E5
        "JSD78f+VKHRmLJNQIi/G29qMjTlp6fQBXnKESj2bTWo="
    ]

    // MARK: - Pinned URLSession

    /// Creates a URLSession with certificate pinning enabled
    lazy var pinnedSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.tlsMaximumSupportedProtocolVersion = .TLSv13
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true

        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    // MARK: - Validation

    /// Validates that a host is an allowed Supabase EU endpoint
    func isAllowedHost(_ host: String) -> Bool {
        let allowedHosts = [
            AppConfig.Supabase.baseURL
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "/", with: ""),
            "supabase.co",
            "supabase.in"
        ]
        return allowedHosts.contains(where: { host.hasSuffix($0) })
    }
}

// MARK: - URLSession Delegate (Certificate Pinning)

extension NetworkSecurityManager: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let host = challenge.protectionSpace.host

        // Only pin Supabase EU connections
        guard isAllowedHost(host) else {
            // Non-Supabase connections: use default validation
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Validate server certificate chain
        let policies = [SecPolicyCreateSSL(true, host as CFString)]
        SecTrustSetPolicies(serverTrust, policies as CFArray)

        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            // Certificate validation failed — reject connection
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract and verify certificate pin
        let certificateCount = SecTrustGetCertificateCount(serverTrust)

        for index in 0..<certificateCount {
            guard let certificate = SecTrustCopyCertificateChain(serverTrust)?[index] else {
                continue
            }

            let cert = certificate as! SecCertificate

            // Get public key and hash it
            guard let publicKey = SecCertificateCopyKey(cert),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
                continue
            }

            let hash = sha256Base64(of: publicKeyData)

            if pinnedCertificateHashes.contains(hash) {
                // Pin matches — allow connection
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }

        // No pin matched — reject connection (fail-close)
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    /// SHA-256 hash of data, returned as base64
    private func sha256Base64(of data: Data) -> String {
        let hash = EncryptionManager.shared.sha256Hash(of: data)
        // Convert hex string to Data then to base64 for pin comparison
        guard let hashData = Data(hexString: hash) else { return "" }
        return hashData.base64EncodedString()
    }
}

// MARK: - Data Extension for Hex Parsing

extension Data {
    init?(hexString: String) {
        let hex = hexString.dropFirst(hexString.hasPrefix("0x") ? 2 : 0)
        guard hex.count % 2 == 0 else { return nil }

        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex

        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }

        self = data
    }
}
