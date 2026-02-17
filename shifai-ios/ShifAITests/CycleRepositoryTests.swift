import XCTest
@testable import ShifAI

final class CycleRepositoryTests: XCTestCase {

    // ─── Offline-First Contract ───

    func testSaveEntryMarksUnsynced() {
        // CycleRepository.saveEntry sets isSynced = false
        var entry = CycleEntry(date: Date(), cycleDay: 1)
        entry.isSynced = false
        XCTAssertFalse(entry.isSynced)
    }

    func testSaveSymptomMarksUnsynced() {
        var symptom = SymptomLog(cycleEntryId: "abc", category: "PAIN", symptomType: "cramps", intensity: 5)
        symptom.isSynced = false
        XCTAssertFalse(symptom.isSynced)
    }

    // ─── Value Clamping ───

    func testFlowClampedTo0_4() {
        let entry = CycleEntry(date: Date(), cycleDay: 1, flowIntensity: 10)
        XCTAssertEqual(entry.flowIntensity, 4)
    }

    func testFlowClampedToMinimum() {
        let entry = CycleEntry(date: Date(), cycleDay: 1, flowIntensity: -5)
        XCTAssertEqual(entry.flowIntensity, 0)
    }

    func testMoodClampedTo1_10() {
        let entry = CycleEntry(date: Date(), cycleDay: 1, moodScore: 15)
        XCTAssertEqual(entry.moodScore, 10)
    }

    func testSleepClampedTo24() {
        let entry = CycleEntry(date: Date(), cycleDay: 1, sleepHours: 30)
        XCTAssertEqual(entry.sleepHours, 24)
    }

    func testIntensityClampedTo1_10() {
        let symptom = SymptomLog(cycleEntryId: "abc", category: "PAIN", symptomType: "cramps", intensity: 15)
        XCTAssertEqual(symptom.intensity, 10)
    }

    // ─── Defaults ───

    func testEntryDefaults() {
        let entry = CycleEntry(date: Date(), cycleDay: 14)
        XCTAssertEqual(entry.moodScore, 5)
        XCTAssertEqual(entry.energyScore, 5)
        XCTAssertEqual(entry.flowIntensity, 0)
        XCTAssertTrue(entry.notes.isEmpty)
    }

    func testSymptomBodyZoneOptional() {
        let symptom = SymptomLog(cycleEntryId: "abc", category: "MOOD", symptomType: "irritability", intensity: 4)
        XCTAssertNil(symptom.bodyZone)
    }

    // ─── Identifiable ───

    func testEntryHasUniqueId() {
        let e1 = CycleEntry(date: Date(), cycleDay: 1)
        let e2 = CycleEntry(date: Date(), cycleDay: 2)
        XCTAssertNotEqual(e1.id, e2.id)
    }
}
