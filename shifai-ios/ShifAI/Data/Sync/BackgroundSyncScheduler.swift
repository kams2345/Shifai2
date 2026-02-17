import Foundation
import BackgroundTasks

// MARK: - Background Sync Scheduler (S7-4 + S7-5)
// iOS: BGAppRefreshTask + BGProcessingTask
// Interval: 6-12h, battery budget <5% day
// Manual sync trigger from Settings

final class BackgroundSyncScheduler {

    static let shared = BackgroundSyncScheduler()

    // Task identifiers (must match Info.plist BGTaskSchedulerPermittedIdentifiers)
    static let refreshTaskId = "com.shifai.sync.refresh"
    static let processingTaskId = "com.shifai.sync.processing"

    // MARK: - Registration (call from AppDelegate.didFinishLaunching)

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskId,
            using: nil
        ) { task in
            self.handleRefreshTask(task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.processingTaskId,
            using: nil
        ) { task in
            self.handleProcessingTask(task as! BGProcessingTask)
        }
    }

    // MARK: - Schedule

    func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 3600) // 6h minimum

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[Sync] Failed to schedule refresh: \(error)")
        }
    }

    func scheduleProcessing() {
        let request = BGProcessingTaskRequest(identifier: Self.processingTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 3600) // 12h
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false  // Don't require charging

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[Sync] Failed to schedule processing: \(error)")
        }
    }

    // MARK: - Task Handlers

    private func handleRefreshTask(_ task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleRefresh()

        guard SyncEngine.shared.isEnabled else {
            task.setTaskCompleted(success: true)
            return
        }

        let syncTask = Task {
            do {
                try await SyncEngine.shared.sync()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        // Expiration handler
        task.expirationHandler = {
            syncTask.cancel()
        }
    }

    private func handleProcessingTask(_ task: BGProcessingTask) {
        // Schedule next processing
        scheduleProcessing()

        guard SyncEngine.shared.isEnabled else {
            task.setTaskCompleted(success: true)
            return
        }

        let syncTask = Task {
            do {
                try await SyncEngine.shared.sync()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            syncTask.cancel()
        }
    }

    // MARK: - S7-5: Manual Sync Trigger

    /// Call from Settings → "Synchroniser maintenant" button
    func triggerManualSync() async -> SyncResult {
        guard SyncEngine.shared.isEnabled else {
            return SyncResult(success: false, message: "Sync désactivée")
        }

        do {
            try await SyncEngine.shared.sync()
            return SyncResult(
                success: true,
                message: "Synchronisé — \(formattedDate(Date()))"
            )
        } catch {
            return SyncResult(
                success: false,
                message: "Erreur: \(error.localizedDescription)"
            )
        }
    }

    struct SyncResult {
        let success: Bool
        let message: String
    }

    // MARK: - Helpers

    func lastSyncDescription() -> String {
        guard let lastSync = SyncEngine.shared.lastSyncDate else {
            return "Jamais synchronisé"
        }

        let interval = Date().timeIntervalSince(lastSync)
        if interval < 60 { return "Il y a quelques secondes" }
        if interval < 3600 { return "Il y a \(Int(interval / 60)) min" }
        if interval < 86400 { return "Il y a \(Int(interval / 3600))h" }
        return "Dernière sync: \(formattedDate(lastSync))"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
