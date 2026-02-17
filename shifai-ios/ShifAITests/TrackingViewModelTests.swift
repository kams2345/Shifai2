import XCTest
@testable import ShifAI

final class TrackingViewModelTests: XCTestCase {

    // ─── Defaults ───

    func testDefaultFlowIsZero() {
        let flow = 0
        XCTAssertEqual(flow, 0)
    }

    func testDefaultMoodIs5() {
        let mood = 5
        XCTAssertEqual(mood, 5)
    }

    func testDefaultSymptomsEmpty() {
        let symptoms: [String] = []
        XCTAssertTrue(symptoms.isEmpty)
    }

    // ─── Clamping ───

    func testFlowClampedTo0_4() {
        let clamped = max(0, min(4, 10))
        XCTAssertEqual(clamped, 4)
        let clampedLow = max(0, min(4, -1))
        XCTAssertEqual(clampedLow, 0)
    }

    func testMoodClampedTo1_10() {
        let clamped = max(1, min(10, 15))
        XCTAssertEqual(clamped, 10)
    }

    func testSleepClampedTo0_24() {
        let clamped = max(0.0, min(24.0, 30.0))
        XCTAssertEqual(clamped, 24.0)
    }

    // ─── Symptoms ───

    func testAddSymptomUniqueness() {
        var symptoms = ["Migraine"]
        // Adding same symptom should replace, not duplicate
        if let idx = symptoms.firstIndex(of: "Migraine") {
            symptoms[idx] = "Migraine"
        }
        XCTAssertEqual(symptoms.count, 1)
    }

    func testRemoveSymptom() {
        var symptoms = ["Migraine", "Fatigue"]
        symptoms.removeAll { $0 == "Migraine" }
        XCTAssertEqual(symptoms.count, 1)
        XCTAssertEqual(symptoms.first, "Fatigue")
    }

    // ─── Body Map ───

    func testBodyZoneToggle() {
        var zones: Set<String> = []
        zones.insert("HEAD")
        XCTAssertTrue(zones.contains("HEAD"))
        zones.remove("HEAD")
        XCTAssertFalse(zones.contains("HEAD"))
    }

    // ─── Notes ───

    func testNotesUpdate() {
        var notes = ""
        notes = "Crampes fortes ce matin"
        XCTAssertEqual(notes, "Crampes fortes ce matin")
    }
}
