import SwiftUI

@main
struct ShifAIApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        appState.handleAppBecameActive()
                    case .inactive:
                        appState.handleAppBecameInactive()
                    case .background:
                        appState.handleAppEnteredBackground()
                    @unknown default:
                        break
                    }
                }
        }
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isOnboardingComplete = false
    @Published var requiresBiometric = false

    private var lastActiveDate: Date?
    private let autoLockTimeout: TimeInterval = 300 // 5 min default

    func handleAppBecameActive() {
        if let lastActive = lastActiveDate,
           Date().timeIntervalSince(lastActive) > autoLockTimeout {
            requiresBiometric = true
        }
    }

    func handleAppBecameInactive() {
        lastActiveDate = Date()
    }

    func handleAppEnteredBackground() {
        lastActiveDate = Date()
    }
}
