import HealthKit

/// HealthKit Manager — reads cycle data from Apple Health.
/// Write-only for ShifAI-generated data, read for imported cycle data.
final class HealthKitManager {

    static let shared = HealthKitManager()

    private let store = HKHealthStore()

    private let readTypes: Set<HKSampleType> = [
        HKCategoryType(.menstrualFlow),
        HKCategoryType(.ovulationTestResult),
        HKQuantityType(.bodyTemperature),
        HKQuantityType(.heartRate),
    ]

    private let writeTypes: Set<HKSampleType> = [
        HKCategoryType(.menstrualFlow),
    ]

    private init() {}

    // MARK: - Authorization

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    // MARK: - Read Menstrual Data

    func fetchMenstrualFlow(startDate: Date, endDate: Date) async throws -> [HKCategorySample] {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKCategoryType(.menstrualFlow),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
                }
            }
            store.execute(query)
        }
    }

    // MARK: - Write Period Data

    func saveMenstrualFlow(date: Date, flow: Int) async throws {
        guard isAvailable else { return }

        let hkFlow: HKCategoryValueMenstrualFlow = switch flow {
        case 1: .light
        case 2: .medium
        case 3: .heavy
        default: .unspecified
        }

        let sample = HKCategorySample(
            type: HKCategoryType(.menstrualFlow),
            value: hkFlow.rawValue,
            start: date,
            end: date
        )

        try await store.save(sample)
    }

    // MARK: - Sync Import

    func importCycleData(into repository: CycleRepository) async throws {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let samples = try await fetchMenstrualFlow(startDate: sixMonthsAgo, endDate: Date())

        for sample in samples {
            let flow = sample.value
            try await repository.importFromHealthKit(
                date: sample.startDate,
                flowIntensity: flow
            )
        }
    }
}
