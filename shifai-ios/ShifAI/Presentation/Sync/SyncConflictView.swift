import SwiftUI

// MARK: - Sync Conflict Resolution UI (S7-6)
// Shows when server has a different version than local
// User chooses: keep local, keep server, or merge

struct SyncConflictView: View {
    @StateObject private var viewModel: SyncConflictViewModel
    @Environment(\.dismiss) private var dismiss

    init(localVersion: Int, serverVersion: Int) {
        _viewModel = StateObject(wrappedValue: SyncConflictViewModel(
            localVersion: localVersion,
            serverVersion: serverVersion
        ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "F59E0B"))

                    Text("Conflit de synchronisation")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Les données sur cet appareil diffèrent de celles sur le serveur.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Comparison cards
                HStack(spacing: 12) {
                    conflictCard(
                        title: "Cet appareil",
                        version: viewModel.localVersion,
                        icon: "iphone",
                        color: Color(hex: "60A5FA"),
                        date: viewModel.localDate
                    )

                    Text("vs")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))

                    conflictCard(
                        title: "Serveur",
                        version: viewModel.serverVersion,
                        icon: "cloud.fill",
                        color: Color(hex: "A78BFA"),
                        date: viewModel.serverDate
                    )
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 32)

                // Resolution options
                VStack(spacing: 12) {
                    resolutionButton(
                        title: "Garder les données de cet appareil",
                        subtitle: "Les données serveur seront écrasées",
                        icon: "iphone.gen3",
                        color: Color(hex: "60A5FA")
                    ) {
                        Task { await viewModel.resolveKeepLocal() }
                        dismiss()
                    }

                    resolutionButton(
                        title: "Garder les données du serveur",
                        subtitle: "Les données locales seront remplacées",
                        icon: "cloud.fill",
                        color: Color(hex: "A78BFA")
                    ) {
                        Task { await viewModel.resolveKeepServer() }
                        dismiss()
                    }

                    resolutionButton(
                        title: "Fusionner les deux",
                        subtitle: "Les entrées les plus récentes sont conservées",
                        icon: "arrow.triangle.merge",
                        color: Color(hex: "34D399")
                    ) {
                        Task { await viewModel.resolveMerge() }
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Auto-resolve notice
                Text("Sans action sous 24h, les données les plus récentes seront gardées automatiquement.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Plus tard") { dismiss() }
                        .foregroundColor(Color(hex: "A78BFA"))
                }
            }
        }
    }

    // MARK: - Components

    private func conflictCard(title: String, version: Int, icon: String, color: Color, date: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Text("v\(version)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)

            Text(date)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func resolutionButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
        }
    }
}

// MARK: - ViewModel

final class SyncConflictViewModel: ObservableObject {
    let localVersion: Int
    let serverVersion: Int
    let localDate: String
    let serverDate: String

    init(localVersion: Int, serverVersion: Int) {
        self.localVersion = localVersion
        self.serverVersion = serverVersion

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")

        self.localDate = formatter.string(from: SyncEngine.shared.lastSyncDate ?? Date())
        self.serverDate = "Serveur" // Will be set from metadata
    }

    func resolveKeepLocal() async {
        // Force push local data to server (overwrites server)
        try? await SyncEngine.shared.push()
    }

    func resolveKeepServer() async {
        // Force pull server data (overwrites local)
        try? await SyncEngine.shared.pull()
    }

    func resolveMerge() async {
        // Merge: last-write-wins per entry
        try? await SyncEngine.shared.sync()
    }
}
