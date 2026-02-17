import Foundation
import SwiftUI

/// Deep Link Router — handles shifai:// URL scheme.
/// Registered in Info.plist CFBundleURLSchemes.
final class DeepLinkRouter: ObservableObject {

    enum Destination: Equatable {
        case dashboard
        case tracking
        case insights
        case export
        case settings
        case syncConflict
        case onboarding
        case unknown
    }

    @Published var activeDestination: Destination?

    /// Parse incoming deep link URL and route.
    /// Supported URLs:
    /// - shifai://dashboard
    /// - shifai://tracking
    /// - shifai://insights
    /// - shifai://export
    /// - shifai://settings
    /// - shifai://sync/conflict
    /// - shifai://auth/callback?token=xxx
    func handle(_ url: URL) {
        guard url.scheme == "shifai" else { return }

        let host = url.host ?? ""
        let path = url.path

        switch host {
        case "dashboard":
            activeDestination = .dashboard
        case "tracking":
            activeDestination = .tracking
        case "insights":
            activeDestination = .insights
        case "export":
            activeDestination = .export
        case "settings":
            activeDestination = .settings
        case "sync":
            if path == "/conflict" {
                activeDestination = .syncConflict
            }
        case "auth":
            handleAuthCallback(url)
        case "app":
            activeDestination = .dashboard // Default landing
        default:
            activeDestination = .unknown
        }
    }

    /// Handle OAuth callback from Supabase Auth
    private func handleAuthCallback(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let token = components.queryItems?.first(where: { $0.name == "token" })?.value else {
            return
        }
        // Store token and navigate
        Task {
            await SupabaseClient.shared.setAccessToken(token)
        }
        activeDestination = .dashboard
    }

    func clearDestination() {
        activeDestination = nil
    }
}
