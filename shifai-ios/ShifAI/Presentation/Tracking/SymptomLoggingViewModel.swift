import Foundation

// MARK: - Symptom Logging ViewModel
// S2-2: Manages symptom selection, intensity, and persistence

final class SymptomLoggingViewModel: ObservableObject {

    @Published var selectedSymptoms: [SymptomType: Int] = [:] // type → intensity
    @Published var searchText: String = ""
    @Published var frequentSymptoms: [SymptomType] = []

    private let symptomRepo: SymptomRepositoryProtocol

    init(symptomRepo: SymptomRepositoryProtocol = SymptomRepository()) {
        self.symptomRepo = symptomRepo
    }

    func loadFrequents() {
        let frequent = (try? symptomRepo.fetchMostFrequent(limit: 8)) ?? []
        frequentSymptoms = frequent.map { $0.0 }
    }

    func toggleSymptom(_ type: SymptomType) {
        if selectedSymptoms.keys.contains(type) {
            selectedSymptoms.removeValue(forKey: type)
        } else {
            selectedSymptoms[type] = 5 // Default intensity
        }
    }

    func filteredSymptoms(for category: SymptomCategory) -> [SymptomType] {
        let symptoms = category.symptoms
        if searchText.isEmpty { return symptoms }
        return symptoms.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    func selectedInCategory(_ category: SymptomCategory) -> [SymptomType] {
        category.symptoms.filter { selectedSymptoms.keys.contains($0) }
    }

    func saveAll() {
        let today = Date()
        for (type, intensity) in selectedSymptoms {
            let log = SymptomLog(
                id: UUID().uuidString,
                date: today,
                type: type,
                intensity: intensity,
                bodyZone: nil,
                painType: nil,
                notes: nil,
                createdAt: today
            )
            try? symptomRepo.save(log)
        }
    }
}
