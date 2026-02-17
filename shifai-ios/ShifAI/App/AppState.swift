import SwiftUI

/// App State — central observable state for the app lifecycle.
/// Manages tab selection, onboarding completion, and biometric lock.
@MainActor
final class AppState: ObservableObject {

    enum MainTab: String, CaseIterable {
        case dashboard = "dashboard"
        case tracking = "tracking"
        case insights = "insights"
        case settings = "settings"
    }

    enum LaunchState {
        case loading
        case onboarding
        case biometricLock
        case authenticated
    }

    @Published var selectedTab: MainTab = .dashboard
    @Published var launchState: LaunchState = .loading

    @AppStorage("onboarding_completed") var hasCompletedOnboarding = false
    @AppStorage("biometric_lock") var isBiometricEnabled = false

    init() {
        determineLaunchState()
    }

    // MARK: - Launch Flow

    func determineLaunchState() {
        if !hasCompletedOnboarding {
            launchState = .onboarding
        } else if isBiometricEnabled {
            launchState = .biometricLock
        } else {
            launchState = .authenticated
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        determineLaunchState()
    }

    func unlockWithBiometrics() {
        launchState = .authenticated
    }

    // MARK: - Tab Management

    func switchToTab(_ tab: MainTab) {
        selectedTab = tab
    }

    func resetToHome() {
        selectedTab = .dashboard
    }
}
