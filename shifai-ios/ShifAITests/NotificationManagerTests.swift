import XCTest
@testable import ShifAI

final class NotificationManagerTests: XCTestCase {

    // ─── Categories ───

    func testFourCategoriesExist() {
        let categories = NotificationManager.Category.allCases
        XCTAssertEqual(categories.count, 4)
    }

    func testPredictionsCategory() {
        XCTAssertEqual(NotificationManager.Category.predictions.rawValue, "predictions")
    }

    func testRecommendationsCategory() {
        XCTAssertEqual(NotificationManager.Category.recommendations.rawValue, "recommendations")
    }

    func testQuickWinsCategory() {
        XCTAssertEqual(NotificationManager.Category.quickWins.rawValue, "quick_wins")
    }

    func testEducationalCategory() {
        XCTAssertEqual(NotificationManager.Category.educational.rawValue, "educational")
    }

    // ─── French Titles ───

    func testPredictionsTitleFrench() {
        XCTAssertEqual(NotificationManager.Category.predictions.title, "Prédictions de cycle")
    }

    func testRecommendationsTitleFrench() {
        XCTAssertEqual(NotificationManager.Category.recommendations.title, "Recommandations")
    }

    // ─── Quiet Hours ───

    func testMidnightIsQuietHours() {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 0
        comps.minute = 30
        let midnight = calendar.date(from: comps)!
        XCTAssertTrue(NotificationManager.shared.isInQuietHours(midnight))
    }

    func testNoonIsNotQuietHours() {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 12
        comps.minute = 0
        let noon = calendar.date(from: comps)!
        XCTAssertFalse(NotificationManager.shared.isInQuietHours(noon))
    }

    func test11PMIsQuietHours() {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 23
        comps.minute = 0
        let lateNight = calendar.date(from: comps)!
        XCTAssertTrue(NotificationManager.shared.isInQuietHours(lateNight))
    }
}
