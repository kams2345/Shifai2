import XCTest
@testable import ShifAI

final class ShifAIDesignTests: XCTestCase {

    // ─── Phase Colors ───

    func testAllPhasesHaveColors() {
        let phases: [CyclePhase] = [.menstrual, .follicular, .ovulatory, .luteal, .unknown]
        phases.forEach { phase in
            let _ = ShifAIDesign.phaseColor(phase) // Should not crash
        }
    }

    func testPhaseColorsAreDistinct() {
        let colors = [
            ShifAIDesign.phaseMenstrual,
            ShifAIDesign.phaseFollicular,
            ShifAIDesign.phaseOvulatory,
            ShifAIDesign.phaseLuteal
        ]
        // All should be different (compare descriptions as Color equality is tricky)
        let descriptions = colors.map { "\($0)" }
        XCTAssertEqual(Set(descriptions).count, 4)
    }

    // ─── Flow Colors ───

    func testFlowColorsHas5Levels() {
        XCTAssertEqual(ShifAIDesign.flowColors.count, 5)
    }

    // ─── Symptom Colors ───

    func testMildSymptomColor() {
        let mild = ShifAIDesign.symptomColor(2)
        let severe = ShifAIDesign.symptomColor(9)
        XCTAssertNotEqual("\(mild)", "\(severe)")
    }

    // ─── Spacing ───

    func testSpacingScaleIncreasing() {
        XCTAssertTrue(ShifAIDesign.Spacing.xs < ShifAIDesign.Spacing.sm)
        XCTAssertTrue(ShifAIDesign.Spacing.sm < ShifAIDesign.Spacing.md)
        XCTAssertTrue(ShifAIDesign.Spacing.md < ShifAIDesign.Spacing.lg)
        XCTAssertTrue(ShifAIDesign.Spacing.lg < ShifAIDesign.Spacing.xl)
    }

    // ─── Radius ───

    func testRadiusPillIsLarge() {
        XCTAssertTrue(ShifAIDesign.Radius.pill > 100)
    }

    // ─── Typography ───

    func testTypeScaleIncreasing() {
        XCTAssertTrue(ShifAIDesign.Type.label < ShifAIDesign.Type.caption)
        XCTAssertTrue(ShifAIDesign.Type.caption < ShifAIDesign.Type.bodySmall)
        XCTAssertTrue(ShifAIDesign.Type.body < ShifAIDesign.Type.h3)
        XCTAssertTrue(ShifAIDesign.Type.h3 < ShifAIDesign.Type.h1)
    }

    // ─── Hex Color ───

    func testHexColorExtension() {
        let white = Color(hex: 0xFFFFFF)
        let black = Color(hex: 0x000000)
        XCTAssertNotEqual("\(white)", "\(black)")
    }
}
