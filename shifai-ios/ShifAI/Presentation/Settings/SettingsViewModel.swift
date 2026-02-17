import Foundation
import SwiftUI

/// Settings ViewModel — sync, notifications, privacy, account.
/// Mirrors Android SettingsViewModel.kt.
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Sync

    @Published var isSyncEnabled = false
    @Published var lastSyncTime: Date?
    @Published var isSyncing = false

    func toggleSync() {
        isSyncEnabled.toggle()
        // TODO: enable/disable sync engine
    }

    // MARK: - Notifications

    @Published var notifPredictions = true
    @Published var notifRecommendations = true
    @Published var notifQuickWins = true
    @Published var notifEducational = true

    func toggleNotifPredictions() { notifPredictions.toggle() }
    func toggleNotifRecommendations() { notifRecommendations.toggle() }
    func toggleNotifQuickWins() { notifQuickWins.toggle() }
    func toggleNotifEducational() { notifEducational.toggle() }

    // MARK: - Privacy

    @Published var isBiometricEnabled = false
    @Published var isWidgetPrivacy = false
    @Published var isAnalyticsConsent = false

    func toggleBiometric() {
        isBiometricEnabled.toggle()
        // TODO: configure biometric auth
    }

    func toggleWidgetPrivacy() {
        isWidgetPrivacy.toggle()
        // TODO: update WidgetDataProvider
    }

    func toggleAnalyticsConsent() {
        isAnalyticsConsent.toggle()
        // TODO: update AnalyticsTracker
    }

    // MARK: - Account

    @Published var showDeleteDialog = false

    func showDeleteConfirmation() { showDeleteDialog = true }
    func dismissDeleteConfirmation() { showDeleteDialog = false }

    func deleteAccount() async {
        // TODO: call SupabaseClient.deleteAccount()
        // Then clear local data
    }

    // MARK: - Export

    func exportCSV() async -> Data? {
        let header = "Date,Jour,Phase,Flux,Humeur,Énergie,Sommeil,Stress"
        // TODO: fetch entries from repository, format CSV
        return header.data(using: .utf8)
    }

    // MARK: - Formatting

    func formatLastSync() -> String? {
        guard let date = lastSyncTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
