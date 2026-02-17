import SwiftUI

/// Biometric Lock View — shown when biometric lock is enabled.
/// Auto-prompts for Face ID / Touch ID on appear.
struct BiometricLockView: View {
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.accent)

            Text("ShifAI est verrouillé")
                .font(.title2.bold())

            Text("Authentifiez-vous pour accéder à vos données")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Déverrouiller") {
                Task {
                    let result = await BiometricManager.shared.authenticate()
                    if case .success = result {
                        onUnlock()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .task {
            let result = await BiometricManager.shared.authenticate()
            if case .success = result {
                onUnlock()
            }
        }
    }
}
