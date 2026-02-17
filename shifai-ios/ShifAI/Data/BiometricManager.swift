import LocalAuthentication

/// Biometric Manager — Face ID / Touch ID gate for app launch.
/// Privacy feature: requires biometric unlock when enabled.
final class BiometricManager {

    enum BiometricType {
        case faceID, touchID, none
    }

    enum AuthResult {
        case success
        case failed(String)
        case notAvailable
        case notEnrolled
    }

    static let shared = BiometricManager()

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometric_lock") }
        set { UserDefaults.standard.set(newValue, forKey: "biometric_lock") }
    }

    private init() {}

    // MARK: - Availability

    var availableType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .none
        }
    }

    var isAvailable: Bool { availableType != .none }

    var biometricName: String {
        switch availableType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Biométrie"
        }
    }

    // MARK: - Authentication

    func authenticate(reason: String = "Déverrouiller ShifAI") async -> AuthResult {
        let context = LAContext()
        context.localizedCancelTitle = "Annuler"
        context.localizedFallbackTitle = "Utiliser le code"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotAvailable: return .notAvailable
                case .biometryNotEnrolled: return .notEnrolled
                default: return .failed(laError.localizedDescription)
                }
            }
            return .notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success ? .success : .failed("Échec de l'authentification")
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
