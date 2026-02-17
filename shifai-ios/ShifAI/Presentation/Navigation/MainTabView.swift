import SwiftUI

/// Main Tab View — bottom tab navigation for the 4 primary screens.
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Tableau de bord", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppState.MainTab.dashboard)

            CycleTrackingView()
                .tabItem {
                    Label("Suivi", systemImage: "plus.circle.fill")
                }
                .tag(AppState.MainTab.tracking)

            InsightsTabView()
                .tabItem {
                    Label("Analyses", systemImage: "brain.head.profile")
                }
                .tag(AppState.MainTab.insights)

            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gearshape.fill")
                }
                .tag(AppState.MainTab.settings)
        }
        .tint(Color("AccentColor"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
