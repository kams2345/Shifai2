import XCTest
@testable import ShifAI

final class ModelsTests: XCTestCase {

    // ─── CycleEntry ───

    func testCycleEntryDefaultSyncIsPending() {
        let entry = CycleEntry(id: "1", date: Date(), cycleDay: 1, phase: .follicular)
        XCTAssertEqual(entry.syncStatus, .pending)
    }

    func testCycleEntryAutoTimestamps() {
        let entry = CycleEntry(id: "1", date: Date(), cycleDay: 5, phase: .luteal)
        XCTAssertNotNil(entry.createdAt)
        XCTAssertNotNil(entry.updatedAt)
    }

    // ─── CyclePhase ───

    func testCyclePhaseHas5Cases() {
        XCTAssertEqual(CyclePhase.allCases.count, 5)
    }

    func testCyclePhaseDisplayNamesAreFrench() {
        XCTAssertEqual(CyclePhase.menstrual.displayName, "Menstruelle")
        XCTAssertEqual(CyclePhase.follicular.displayName, "Folliculaire")
        XCTAssertEqual(CyclePhase.ovulatory.displayName, "Ovulatoire")
        XCTAssertEqual(CyclePhase.luteal.displayName, "Lutéale")
    }

    // ─── SymptomType ───

    func testSymptomTypeCovers29Symptoms() {
        XCTAssertEqual(SymptomType.allCases.count, 29)
    }

    func testSymptomDisplayNamesAreFrench() {
        XCTAssertEqual(SymptomType.cramps.displayName, "Crampes")
        XCTAssertEqual(SymptomType.headache.displayName, "Migraine")
        XCTAssertEqual(SymptomType.bloating.displayName, "Ballonnements")
    }

    // ─── SymptomCategory ───

    func testSymptomCategoryHas6Categories() {
        XCTAssertEqual(SymptomCategory.allCases.count, 6)
    }

    func testCategorySymptomMapping() {
        let painSymptoms = SymptomCategory.pain.symptoms
        XCTAssertTrue(painSymptoms.contains(.cramps))
        XCTAssertTrue(painSymptoms.contains(.headache))
        XCTAssertFalse(painSymptoms.contains(.bloating))
    }

    // ─── BodyZone ───

    func testBodyZoneHas5Zones() {
        XCTAssertEqual(BodyZone.allCases.count, 5)
    }

    // ─── Insight ───

    func testInsightDefaultIsUnread() {
        let insight = Insight(
            id: "1", type: .quickWin,
            title: "Test", body: "Body"
        )
        XCTAssertFalse(insight.isRead)
    }

    func testInsightTypeHas5Types() {
        XCTAssertEqual(InsightType.allCases.count, 5)
    }

    // ─── Prediction ───

    func testPredictionConfidenceRange() {
        let pred = Prediction(
            id: "1", type: .periodStart,
            predictedDate: Date(),
            confidence: 0.87,
            confidenceRange: 2,
            modelVersion: "v1"
        )
        XCTAssertEqual(pred.confidence, 0.87, accuracy: 0.001)
        XCTAssertEqual(pred.confidenceRange, 2)
    }

    func testPredictionTypeHas4Types() {
        XCTAssertEqual(PredictionType.allCases.count, 4)
    }

    // ─── UserProfile ───

    func testUserProfileDefaults() {
        let profile = UserProfile(
            id: "1", conditions: [], trackedSymptoms: [], locale: "fr"
        )
        XCTAssertEqual(profile.locale, "fr")
        XCTAssertTrue(profile.conditions.isEmpty)
    }

    // ─── CervicalMucus ───

    func testCervicalMucusHas5Types() {
        XCTAssertEqual(CervicalMucus.allCases.count, 5)
    }

    func testCervicalMucusDisplayNames() {
        XCTAssertEqual(CervicalMucus.dry.displayName, "Sec")
        XCTAssertEqual(CervicalMucus.eggWhite.displayName, "Blanc d'œuf")
    }
}
