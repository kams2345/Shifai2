import Foundation

/// iOS Dependency Container — lightweight service locator.
/// Initializes database, repositories, and provides shared instances.
/// Mirrors Android AppContainer.kt.
@MainActor
final class AppContainer {

    static let shared = AppContainer()

    // ─── Data Layer ───

    let databaseManager = DatabaseManager.shared

    lazy var cycleRepository: CycleRepository = {
        guard let dbQueue = databaseManager.dbQueue else {
            fatalError("Database not initialized")
        }
        return CycleRepository(dbQueue: dbQueue)
    }()

    lazy var insightsRepository: InsightsRepository = {
        guard let dbQueue = databaseManager.dbQueue else {
            fatalError("Database not initialized")
        }
        return InsightsRepository(dbQueue: dbQueue)
    }()

    // ─── Services ───

    let supabaseClient = SupabaseClient.shared
    let analyticsTracker = AnalyticsTracker.shared
    let notificationManager = NotificationManager.shared

    lazy var syncManager: SyncManager = {
        SyncManager(cycleRepo: cycleRepository, supabaseClient: supabaseClient)
    }()

    // ─── ViewModel Factories ───

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel()
    }

    func makeTrackingViewModel() -> CycleTrackingViewModel {
        CycleTrackingViewModel()
    }

    func makeInsightsViewModel() -> InsightsViewModel {
        InsightsViewModel()
    }

    func makeExportViewModel() -> ExportViewModel {
        ExportViewModel()
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel()
    }

    private init() {}
}
