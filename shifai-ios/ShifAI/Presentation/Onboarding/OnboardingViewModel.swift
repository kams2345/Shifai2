import Foundation

// MARK: - Onboarding ViewModel
// S3-1 to S3-5: Manages onboarding state, profile setup, and completion

final class OnboardingViewModel: ObservableObject {

    // S3-1: Welcome
    @Published var cycleDescription: String = ""

    // S3-2: Disclaimer
    @Published var disclaimerAccepted: Bool = false

    // S3-4: Profile Setup
    @Published var ageRange: String? = nil
    @Published var cycleLength: String? = nil
    @Published var selectedConditions: Set<String> = []
    @Published var trackedSymptoms: Set<String> = []

    // S3-5: Body Map
    @Published var markedZones: Set<BodyZone> = []
    @Published var hasMarkedBodyMap: Bool = false

    // MARK: - Condition-based Symptom Preselection

    var preselectedSymptoms: [String] {
        var symptoms = ["Crampes", "Fatigue", "Migraine", "Ballonnement", "Anxiété", "Insomnie"]

        if selectedConditions.contains("SOPK") {
            symptoms += ["Acné", "Chute de cheveux", "Cycle irrégulier", "Envies alimentaires"]
        }
        if selectedConditions.contains("Endométriose") {
            symptoms += ["Douleur pelvienne", "Mal de dos", "Nausée", "Diarrhée"]
        }

        return Array(Set(symptoms)).sorted()
    }

    // MARK: - Actions

    func toggleCondition(_ condition: String) {
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            // "Aucune" and "Je ne sais pas" are exclusive
            if condition == "Aucune" || condition == "Je ne sais pas" {
                selectedConditions = [condition]
            } else {
                selectedConditions.remove("Aucune")
                selectedConditions.remove("Je ne sais pas")
                selectedConditions.insert(condition)
            }
        }

        // Re-set tracked symptoms from preselection
        trackedSymptoms = Set(preselectedSymptoms)
    }

    func toggleTrackedSymptom(_ symptom: String) {
        if trackedSymptoms.contains(symptom) {
            trackedSymptoms.remove(symptom)
        } else {
            trackedSymptoms.insert(symptom)
        }
    }

    func toggleBodyZone(_ zone: BodyZone) {
        if markedZones.contains(zone) {
            markedZones.remove(zone)
        } else {
            markedZones.insert(zone)
        }
        hasMarkedBodyMap = !markedZones.isEmpty
    }

    // MARK: - Persistence

    func saveProfile() {
        let profile = UserProfile(
            id: "default",
            age: ageRangeToInt(ageRange),
            averageCycleLength: cycleLengthToInt(cycleLength),
            conditions: Array(selectedConditions),
            trackedSymptoms: Array(trackedSymptoms),
            locale: "fr",
            cycleDescription: cycleDescription,
            createdAt: Date(),
            updatedAt: Date()
        )

        // TODO: Save via UserProfileRepository when available
        UserDefaults.standard.set(true, forKey: "profileSetupComplete")
        print("Profile saved: \(profile)")
    }

    func completeOnboarding() {
        // Save body map data
        if !markedZones.isEmpty {
            let symptomRepo = SymptomRepository()
            let today = Date()
            for zone in markedZones {
                let log = SymptomLog(
                    id: UUID().uuidString,
                    date: today,
                    type: .pelvicPain,
                    intensity: 5,
                    bodyZone: zone,
                    painType: .cramping,
                    notes: "onboarding_first_log",
                    createdAt: today
                )
                try? symptomRepo.save(log)
            }
        }

        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(Date(), forKey: "onboardingDate")

        // Schedule Quick Win J1 insight for immediate delivery
        QuickWinEngine.shared.scheduleJ1Insight()
    }

    // MARK: - Helpers

    private func ageRangeToInt(_ range: String?) -> Int? {
        switch range {
        case "18-24": return 21
        case "25-30": return 27
        case "31-35": return 33
        case "36-40": return 38
        case "41-45": return 43
        case "45+": return 48
        default: return nil
        }
    }

    private func cycleLengthToInt(_ length: String?) -> Int? {
        switch length {
        case "< 21 jours": return 19
        case "21-25": return 23
        case "26-30": return 28
        case "31-35": return 33
        case "35+": return 38
        default: return nil
        }
    }
}
