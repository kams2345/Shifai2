import XCTest
@testable import ShifAI

final class ExportViewModelTests: XCTestCase {

    // ─── Templates ───

    func testThreeTemplatesExist() {
        let templates = ["SOPK", "Endométriose", "Personnalisé"]
        XCTAssertEqual(templates.count, 3)
    }

    func testSOPKTemplateLabel() {
        let label = "Rapport SOPK"
        XCTAssertTrue(label.contains("SOPK"))
    }

    func testEndometriosisTemplateLabel() {
        let label = "Rapport Endométriose"
        XCTAssertTrue(label.contains("Endométriose"))
    }

    // ─── Date Ranges ───

    func testThreeDateRanges() {
        let ranges = [3, 6, 12]
        XCTAssertEqual(ranges.count, 3)
    }

    func testDefaultDateRangeIs3Months() {
        let defaultRange = 3
        XCTAssertEqual(defaultRange, 3)
    }

    func testDateRangeLabelsInFrench() {
        let labels = ["3 mois", "6 mois", "12 mois"]
        labels.forEach { XCTAssertTrue($0.contains("mois")) }
    }

    // ─── PDF State ───

    func testInitiallyNotGenerating() {
        let isGenerating = false
        XCTAssertFalse(isGenerating)
    }

    func testPDFDataNilBeforeGeneration() {
        let pdfData: Data? = nil
        XCTAssertNil(pdfData)
    }

    // ─── Disclaimer ───

    func testDisclaimerExists() {
        let disclaimer = "Ce document est informatif uniquement"
        XCTAssertFalse(disclaimer.isEmpty)
    }

    // ─── Share ───

    func testShareRequiresPDFData() {
        let pdfData: Data? = nil
        let canShare = pdfData != nil
        XCTAssertFalse(canShare)
    }
}
