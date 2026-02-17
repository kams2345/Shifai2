import Foundation
import SwiftUI

/// Insights ViewModel — patterns, predictions, recommendations.
/// Mirrors Android InsightsViewModel.kt.
@MainActor
final class InsightsViewModel: ObservableObject {

    enum Filter: String, CaseIterable, Identifiable {
        case all = "Tout"
        case predictions = "Prédictions"
        case correlations = "Corrélations"
        case recommendations = "Conseils"

        var id: String { rawValue }
    }

    enum Feedback: String, CaseIterable {
        case accurate = "Précis"
        case early = "Trop tôt"
        case late = "Trop tard"
        case wrong = "Incorrect"
    }

    struct Insight: Identifiable {
        let id: String
        let type: String
        let title: String
        let body: String
        let confidence: Double
        var isRead: Bool
        let source: String
        var feedback: Feedback?
    }

    @Published var filter: Filter = .all
    @Published var insights: [Insight] = []
    @Published var mlStatus: String = "rule_based"
    @Published var isLoading = false

    var filteredInsights: [Insight] {
        guard filter != .all else { return insights }
        return insights.filter { $0.type == filter.rawValue.lowercased() }
    }

    var unreadCount: Int {
        insights.filter { !$0.isRead }.count
    }

    func markAsRead(_ id: String) {
        if let index = insights.firstIndex(where: { $0.id == id }) {
            insights[index].isRead = true
        }
    }

    func submitFeedback(_ id: String, feedback: Feedback) {
        if let index = insights.firstIndex(where: { $0.id == id }) {
            insights[index].feedback = feedback
            // TODO: persist to repository
        }
    }

    func formatConfidence(_ value: Double) -> String {
        "\(Int(value * 100)) %"
    }

    func loadInsights() async {
        isLoading = true
        defer { isLoading = false }
        // TODO: fetch from repository
    }
}
