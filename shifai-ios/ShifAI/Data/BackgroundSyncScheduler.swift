import BackgroundTasks

/// Background Sync Scheduler — BGTaskScheduler wrapper for periodic sync.
/// Mirrors Android SyncWorker.kt (WorkManager every 6 hours).
final class BackgroundSyncScheduler {

    static let shared = BackgroundSyncScheduler()
    static let taskIdentifier = "com.shifai.sync"

    private init() {}

    // MARK: - Registration

    func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            self.handleSync(task: task as! BGProcessingTask)
        }
    }

    // MARK: - Scheduling

    func scheduleNextSync() {
        let request = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60) // 6 hours

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[BackgroundSync] Schedule failed: \(error)")
        }
    }

    func cancelSync() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)
    }

    // MARK: - Execution

    private func handleSync(task: BGProcessingTask) {
        // Schedule next sync before starting
        scheduleNextSync()

        let syncTask = Task {
            let syncManager = await AppContainer.shared.syncManager
            let result = await syncManager.sync()

            switch result {
            case .success(let report):
                print("[BackgroundSync] pushed=\(report.pushed), pulled=\(report.pulled)")
                task.setTaskCompleted(success: true)
            case .failure(let error):
                print("[BackgroundSync] failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            syncTask.cancel()
        }
    }
}
