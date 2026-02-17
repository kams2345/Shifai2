import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.requiresBiometric {
                BiometricLockView()
            } else if !appState.isOnboardingComplete {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Tab Navigation

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case tracking = "Tracking"
        case insights = "Insights"
        case export = "Export"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .tracking: return "plus.circle.fill"
            case .insights: return "lightbulb.fill"
            case .export: return "doc.text.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            CycleTrackingView()
                .tabItem {
                    Label(Tab.tracking.rawValue, systemImage: Tab.tracking.icon)
                }
                .tag(Tab.tracking)

            InsightsView()
                .tabItem {
                    Label(Tab.insights.rawValue, systemImage: Tab.insights.icon)
                }
                .tag(Tab.insights)

            ExportFlowView()
                .tabItem {
                    Label(Tab.export.rawValue, systemImage: Tab.export.icon)
                }
                .tag(Tab.export)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(ShifAIColors.accent)
    }
}

// MARK: - Biometric Lock Placeholder

struct BiometricLockView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundColor(ShifAIColors.accent)

            Text("Déverrouille ShifAI")
                .font(.title2)
                .fontWeight(.semibold)

            Button("Déverrouiller") {
                // TODO: Implement biometric auth via LocalAuthentication
                appState.requiresBiometric = false
            }
            .buttonStyle(.borderedProminent)
            .tint(ShifAIColors.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ShifAIColors.backgroundGradient)
    }
}
