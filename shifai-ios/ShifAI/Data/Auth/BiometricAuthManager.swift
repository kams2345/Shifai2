import SwiftUI
import LocalAuthentication

// MARK: - Biometric Authentication Manager
// S1-8: Face ID / Touch ID with PIN fallback

final class BiometricAuthManager: ObservableObject {

    // MARK: - Published State

    @Published var isLocked: Bool = true
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    @Published var failedAttempts: Int = 0
    @Published var isLockedOut: Bool = false

    // MARK: - Configuration

    struct Config {
        static let maxFailedAttempts = 5
        static let lockoutDuration: TimeInterval = 15 * 60 // 15 min
        static let defaultAutoLockTimeout: TimeInterval = 5 * 60 // 5 min
        static let pinLength = 4...6
    }

    // MARK: - Private State

    private let context = LAContext()
    private var lockoutTimer: Timer?
    private var autoLockTimer: Timer?
    private var lastActivityDate = Date()

    static let shared = BiometricAuthManager()

    // MARK: - Biometric Capability

    enum BiometricType {
        case faceID
        case touchID
        case none
    }

    var biometricType: BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .faceID // Treat like Face ID UX
        @unknown default: return .none
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "lock.fill"
        }
    }

    var biometricLabel: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Code PIN"
        }
    }

    var isBiometricAvailable: Bool {
        biometricType != .none
    }

    // MARK: - Authentication

    /// Authenticate using biometrics (Face ID / Touch ID)
    @MainActor
    func authenticateWithBiometrics() async -> Bool {
        guard !isLockedOut else {
            authError = "Trop de tentatives. Réessaie dans 15 min."
            return false
        }

        guard isBiometricAvailable else {
            authError = "Biométrie non disponible"
            return false
        }

        isAuthenticating = true
        authError = nil

        let context = LAContext()
        context.localizedCancelTitle = "Utiliser le code PIN"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Déverrouille ShifAI pour accéder à tes données"
            )

            if success {
                onAuthSuccess()
                return true
            } else {
                onAuthFailure()
                return false
            }
        } catch let error as LAError {
            isAuthenticating = false

            switch error.code {
            case .userCancel:
                authError = nil // User chose PIN fallback
            case .userFallback:
                authError = nil // User wants PIN
            case .biometryLockout:
                authError = "Biométrie verrouillée. Utilise le code PIN."
            case .biometryNotEnrolled:
                authError = "Configure \(biometricLabel) dans Réglages"
            default:
                onAuthFailure()
            }
            return false
        } catch {
            isAuthenticating = false
            onAuthFailure()
            return false
        }
    }

    /// Authenticate using PIN code
    @MainActor
    func authenticateWithPIN(_ pin: String) -> Bool {
        guard !isLockedOut else {
            authError = "Trop de tentatives. Réessaie dans 15 min."
            return false
        }

        // Retrieve stored PIN hash from Keychain
        guard let storedHash = KeychainManager.shared.retrieveKey(.masterKey) else {
            authError = "Aucun code PIN configuré"
            return false
        }

        // Hash the entered PIN and compare
        let enteredHash = hashPIN(pin)
        if enteredHash == storedHash {
            onAuthSuccess()
            return true
        } else {
            onAuthFailure()
            return false
        }
    }

    /// Set up a new PIN
    func setupPIN(_ pin: String) throws {
        guard Config.pinLength.contains(pin.count) else {
            throw BiometricError.invalidPINLength
        }

        let pinHash = hashPIN(pin)
        try KeychainManager.shared.storeKey(pinHash, for: .masterKey)
    }

    // MARK: - Auto-Lock

    /// Called on user activity to reset auto-lock timer
    func resetAutoLockTimer() {
        lastActivityDate = Date()
        autoLockTimer?.invalidate()

        let timeout = UserDefaults.standard.double(forKey: "autoLockTimeout")
        let effectiveTimeout = timeout > 0 ? timeout : Config.defaultAutoLockTimeout

        autoLockTimer = Timer.scheduledTimer(withTimeInterval: effectiveTimeout, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.lock()
            }
        }
    }

    /// Lock the app
    func lock() {
        isLocked = true
        autoLockTimer?.invalidate()
    }

    // MARK: - Private Helpers

    private func onAuthSuccess() {
        isLocked = false
        isAuthenticating = false
        failedAttempts = 0
        authError = nil
        resetAutoLockTimer()
    }

    private func onAuthFailure() {
        isAuthenticating = false
        failedAttempts += 1

        if failedAttempts >= Config.maxFailedAttempts {
            isLockedOut = true
            authError = "Trop de tentatives. Verrouillé pour 15 min."

            lockoutTimer = Timer.scheduledTimer(withTimeInterval: Config.lockoutDuration, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isLockedOut = false
                    self?.failedAttempts = 0
                    self?.authError = nil
                }
            }
        } else {
            let remaining = Config.maxFailedAttempts - failedAttempts
            authError = "Identifiant incorrect. \(remaining) tentative\(remaining > 1 ? "s" : "") restante\(remaining > 1 ? "s" : "")."
        }
    }

    private func hashPIN(_ pin: String) -> Data {
        let pinData = pin.data(using: .utf8)!
        // Use the same PBKDF2 as encryption for PIN hashing
        let salt = "shifai-pin-salt-v1".data(using: .utf8)! // Fixed salt for PIN (not for encryption!)
        return (try? EncryptionManager.shared.deriveMasterKey(from: pinData, salt: salt)) ?? Data()
    }

    // MARK: - Errors

    enum BiometricError: LocalizedError {
        case invalidPINLength
        case biometryUnavailable

        var errorDescription: String? {
            switch self {
            case .invalidPINLength: return "Le code PIN doit contenir 4 à 6 chiffres"
            case .biometryUnavailable: return "Biométrie non disponible"
            }
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenView: View {
    @ObservedObject var authManager: BiometricAuthManager
    @State private var pinInput = ""
    @State private var showPINEntry = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D0B1A").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App Icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "7C5CFC"))

                Text("ShifAI")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Auth Button or PIN Entry
                if showPINEntry {
                    pinEntryView
                } else {
                    biometricButton
                }

                // Error Message
                if let error = authManager.authError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "EF4444"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Toggle between biometric and PIN
                if !showPINEntry && authManager.isBiometricAvailable {
                    Button("Utiliser le code PIN") {
                        withAnimation { showPINEntry = true }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "A78BFA"))
                } else if showPINEntry {
                    Button("Utiliser \(authManager.biometricLabel)") {
                        withAnimation { showPINEntry = false }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "A78BFA"))
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            if authManager.isBiometricAvailable && !showPINEntry {
                Task {
                    await authManager.authenticateWithBiometrics()
                }
            }
        }
    }

    // MARK: - Biometric Button

    private var biometricButton: some View {
        Button {
            Task {
                await authManager.authenticateWithBiometrics()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: authManager.biometricIcon)
                    .font(.system(size: 22))
                Text("Déverrouiller avec \(authManager.biometricLabel)")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "7C5CFC").opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "7C5CFC").opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .disabled(authManager.isAuthenticating || authManager.isLockedOut)
        .opacity(authManager.isLockedOut ? 0.5 : 1)
    }

    // MARK: - PIN Entry

    private var pinEntryView: some View {
        VStack(spacing: 16) {
            // PIN dots
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < pinInput.count ?
                              Color(hex: "7C5CFC") :
                              Color.white.opacity(0.2))
                        .frame(width: 14, height: 14)
                }
            }

            // Number pad
            VStack(spacing: 12) {
                ForEach(0..<3) { row in
                    HStack(spacing: 20) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            numberButton(number)
                        }
                    }
                }
                HStack(spacing: 20) {
                    Color.clear.frame(width: 60, height: 48)
                    numberButton(0)
                    backspaceButton
                }
            }
        }
    }

    private func numberButton(_ number: Int) -> some View {
        Button {
            guard pinInput.count < 6 else { return }
            pinInput += "\(number)"

            if pinInput.count >= 4 {
                // Try auth after minimum PIN length
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if authManager.authenticateWithPIN(pinInput) {
                        // Success
                    } else if pinInput.count >= 6 {
                        pinInput = "" // Reset after max length failure
                    }
                }
            }
        } label: {
            Text("\(number)")
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 60, height: 48)
        }
    }

    private var backspaceButton: some View {
        Button {
            if !pinInput.isEmpty {
                pinInput.removeLast()
            }
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 60, height: 48)
        }
    }
}
