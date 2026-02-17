import SwiftUI

// MARK: - Placeholder Views
// Temporary views for tab navigation — will be replaced by full implementations

struct CycleTrackingView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShifAISpacing.lg) {
                    Text("📊")
                        .font(.system(size: 64))
                    Text("Suivi du Cycle")
                        .font(ShifAITypography.title)
                        .foregroundColor(ShifAIColors.textPrimary)
                    Text("Logging cycle, symptômes, Body Map, mood, énergie, sommeil, stress")
                        .font(ShifAITypography.body)
                        .foregroundColor(ShifAIColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(ShifAISpacing.xl)
            }
            .background(ShifAIColors.backgroundGradient)
            .navigationTitle("Tracking")
        }
    }
}

struct InsightsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShifAISpacing.lg) {
                    Text("💡")
                        .font(.system(size: 64))
                    Text("Insights")
                        .font(ShifAITypography.title)
                        .foregroundColor(ShifAIColors.textPrimary)
                    Text("Quick Wins, Patterns, Prédictions, Recommandations")
                        .font(ShifAITypography.body)
                        .foregroundColor(ShifAIColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(ShifAISpacing.xl)
            }
            .background(ShifAIColors.backgroundGradient)
            .navigationTitle("Insights")
        }
    }
}

struct ExportFlowView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShifAISpacing.lg) {
                    Text("📋")
                        .font(.system(size: 64))
                    Text("Export Médical")
                        .font(ShifAITypography.title)
                        .foregroundColor(ShifAIColors.textPrimary)
                    Text("Templates SOPK / Endométriose / Custom\nPDF, email, lien sécurisé 7 jours")
                        .font(ShifAITypography.body)
                        .foregroundColor(ShifAIColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(ShifAISpacing.xl)
            }
            .background(ShifAIColors.backgroundGradient)
            .navigationTitle("Export")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Profil") {
                    Label("Mon profil", systemImage: "person.fill")
                }
                Section("Notifications") {
                    Label("Préférences de notifications", systemImage: "bell.fill")
                }
                Section("Privacy & Sécurité") {
                    Label("Verrouillage biométrique", systemImage: "faceid")
                    Label("Cloud Sync", systemImage: "icloud.fill")
                    Label("Privacy Policy", systemImage: "lock.shield.fill")
                }
                Section("Données") {
                    Label("Exporter mes données (CSV)", systemImage: "square.and.arrow.up")
                    Label("Supprimer mon compte", systemImage: "trash.fill")
                        .foregroundColor(ShifAIColors.error)
                }
                Section("À propos") {
                    Label("Version \(AppConfig.appVersion)", systemImage: "info.circle")
                    Label("Signaler un bug", systemImage: "ladybug.fill")
                }
            }
            .navigationTitle("Réglages")
            .scrollContentBackground(.hidden)
            .background(ShifAIColors.backgroundGradient)
        }
    }
}
