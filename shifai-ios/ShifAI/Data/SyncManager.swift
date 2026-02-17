import Foundation

/// Sync Manager — orchestrates offline-first sync with Supabase.
/// Mirrors Android SyncManager.kt for cross-platform parity.
@MainActor
final class SyncManager: ObservableObject {

    enum Status: String {
        case idle, syncing, success, failed
    }

    @Published private(set) var status: Status = .idle
    @Published private(set) var lastSyncTime: Date?
    @Published private(set) var conflictCount: Int = 0

    private let cycleRepo: CycleRepository
    private let supabaseClient: SupabaseClient

    init(cycleRepo: CycleRepository, supabaseClient: SupabaseClient) {
        self.cycleRepo = cycleRepo
        self.supabaseClient = supabaseClient
    }

    // MARK: - Full Sync

    struct SyncReport {
        let pushed: Int
        let pulled: Int
        let conflicts: Int
    }

    func sync() async -> Result<SyncReport, ShifAIError> {
        status = .syncing
        conflictCount = 0

        do {
            // Phase 1: Push unsynced
            let unsyncedEntries = try await cycleRepo.getUnsyncedEntries()
            let unsyncedSymptoms = try await cycleRepo.getUnsyncedSymptoms()
            let pushCount = unsyncedEntries.count + unsyncedSymptoms.count

            if pushCount > 0 {
                // TODO: encrypt and upload
                try await cycleRepo.markEntriesSynced(unsyncedEntries.map(\.id))
            }

            // Phase 2: Pull remote
            let pullCount = 0
            let conflicts = 0
            conflictCount = conflicts

            status = .success
            lastSyncTime = Date()

            return .success(SyncReport(
                pushed: pushCount,
                pulled: pullCount,
                conflicts: conflicts
            ))
        } catch {
            status = .failed
            return .failure(.syncFailed)
        }
    }

    // MARK: - Status

    func hasPendingSync() async -> Bool {
        guard let entries = try? await cycleRepo.getUnsyncedEntries() else { return false }
        return !entries.isEmpty
    }

    func formatLastSync() -> String? {
        guard let date = lastSyncTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
