import SwiftUI

// MARK: - Insights Tab View
// S4-6: Insights list with cards, S4-7: Predictions, S4-8: Recommendations

struct InsightsTabView: View {
    @StateObject private var viewModel = InsightsTabViewModel()
    @State private var selectedInsight: Insight? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Predictions section (S4-7)
                    if viewModel.periodPrediction != nil || viewModel.ovulationPrediction != nil {
                        predictionsSection
                    }

                    // Insights list (S4-6)
                    insightsSection

                    // Recommendations (S4-8)
                    if !viewModel.recommendations.isEmpty {
                        recommendationsSection
                    }
                }
                .padding(16)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationTitle("Insights")
            .refreshable { viewModel.refresh() }
            .onAppear { viewModel.loadData() }
            .sheet(item: $selectedInsight) { insight in
                InsightDetailView(insight: insight)
            }
        }
    }

    // MARK: - S4-7: Predictions Section

    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(hex: "A78BFA"))
                Text("Prédictions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            if let period = viewModel.periodPrediction {
                predictionCard(
                    icon: "drop.fill",
                    iconColor: "EF4444",
                    title: "Prochaines règles",
                    date: period.predictedDate,
                    confidence: period.confidence,
                    range: period.confidenceRange,
                    reasoning: period.reasoning,
                    feedback: viewModel.periodFeedback,
                    onFeedback: { viewModel.submitFeedback(predictionId: period.id, feedback: $0) }
                )
            }

            if let ovulation = viewModel.ovulationPrediction {
                predictionCard(
                    icon: "sun.max.fill",
                    iconColor: "F59E0B",
                    title: "Fenêtre d'ovulation",
                    date: ovulation.predictedDate,
                    confidence: ovulation.confidence,
                    range: ovulation.confidenceRange,
                    reasoning: ovulation.reasoning,
                    feedback: nil,
                    onFeedback: nil
                )
            }

            // S4-7: Timeline (mini cycle bar)
            cycleTimeline
        }
    }

    // MARK: - Prediction Card

    private func predictionCard(
        icon: String, iconColor: String, title: String, date: Date,
        confidence: Double, range: Int, reasoning: String?,
        feedback: InsightFeedback?, onFeedback: ((InsightFeedback) -> Void)?
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: iconColor))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("Fiabilité: \(Int(confidence * 100))%")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(date.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("±\(range)j")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }

            if let reasoning = reasoning {
                Text(reasoning)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(2)
            }

            // S4-5: Prediction Feedback
            if let onFeedback = onFeedback {
                Divider().background(.white.opacity(0.08))

                HStack(spacing: 12) {
                    Text("Précis ?")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()

                    feedbackButton("👍", label: "Oui", isSelected: feedback == .accurate) {
                        onFeedback(.accurate)
                    }
                    feedbackButton("👎", label: "Non", isSelected: feedback == .inaccurate) {
                        onFeedback(.inaccurate)
                    }
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    private func feedbackButton(_ emoji: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isSelected ?
                               Color(hex: "7C5CFC").opacity(0.3) :
                               Color.white.opacity(0.04))
            )
        }
    }

    // MARK: - S4-7: Cycle Timeline

    private var cycleTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "timeline.selection")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                Text("Timeline du cycle")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }

            GeometryReader { geo in
                let w = geo.size.width
                let progress = viewModel.cycleProgress

                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 24)

                    // Phase segments
                    HStack(spacing: 0) {
                        // Menstrual (J1-5)
                        Rectangle()
                            .fill(Color(hex: "EF4444").opacity(0.4))
                            .frame(width: w * 0.18, height: 24)

                        // Follicular (J6-12)
                        Rectangle()
                            .fill(Color(hex: "34D399").opacity(0.3))
                            .frame(width: w * 0.25, height: 24)

                        // Ovulatory (J13-16)
                        Rectangle()
                            .fill(Color(hex: "F59E0B").opacity(0.4))
                            .frame(width: w * 0.14, height: 24)

                        // Luteal (J17-28)
                        Rectangle()
                            .fill(Color(hex: "A78BFA").opacity(0.3))
                            .frame(width: w * 0.43, height: 24)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Current position marker
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                        .offset(x: w * progress - 5)

                    // Period prediction marker
                    if let _ = viewModel.periodPrediction {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "EF4444"))
                            .offset(x: w * 0.95)
                    }
                }
            }
            .frame(height: 24)

            // Labels
            HStack {
                Text("J1")
                Spacer()
                Text("Ovulation")
                Spacer()
                Text("J\(viewModel.cycleLength)")
            }
            .font(.system(size: 10))
            .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .modifier(GlassCardModifier())
    }

    // MARK: - S4-6: Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "FBBF24"))
                Text("Insights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if viewModel.unreadCount > 0 {
                    Text("\(viewModel.unreadCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color(hex: "7C5CFC")))
                }
            }

            ForEach(viewModel.insights) { insight in
                insightCard(insight)
                    .onTapGesture { selectedInsight = insight }
            }

            if viewModel.insights.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("🔍")
                            .font(.system(size: 32))
                        Text("Continue de logger pour débloquer tes premiers insights")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()
                }
                .padding(.vertical, 24)
            }
        }
    }

    private func insightCard(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(insight.type.color)
                    .frame(width: 8, height: 8)
                Text(insight.type.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(insight.type.color)
                Spacer()
                if !insight.isRead {
                    Text("Nouveau")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "7C5CFC"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(hex: "7C5CFC").opacity(0.15)))
                }
                if let conf = insight.confidence {
                    Text("\(Int(conf * 100))%")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Text(insight.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text(insight.body)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.55))
                .lineLimit(2)
        }
        .padding(14)
        .modifier(GlassCardModifier())
    }

    // MARK: - S4-8: Recommendations Section

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundColor(Color(hex: "F59E0B"))
                Text("Recommandations")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            ForEach(viewModel.recommendations) { rec in
                recommendationCard(rec)
            }
        }
    }

    private func recommendationCard(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            Text(insight.body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button {
                    viewModel.followRecommendation(insight.id)
                } label: {
                    Text("✅ Oui, ajusté")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color(hex: "34D399").opacity(0.3)))
                }

                Button {
                    viewModel.skipRecommendation(insight.id)
                } label: {
                    Text("Pas cette fois")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.04)))
                }
            }
        }
        .padding(14)
        .modifier(GlassCardModifier())
    }
}

// MARK: - Insight Detail View

struct InsightDetailView: View {
    let insight: Insight
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Type badge
                    HStack {
                        Circle().fill(insight.type.color).frame(width: 10, height: 10)
                        Text(insight.type.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(insight.type.color)
                    }

                    // Title
                    Text(insight.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    // Body
                    Text(insight.body)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))

                    if let confidence = insight.confidence {
                        Divider().background(.white.opacity(0.1))
                        HStack {
                            Text("Fiabilité")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("\(Int(confidence * 100))%")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "A78BFA"))
                        }
                    }

                    // Reasoning (S4-2 Explainable AI)
                    if let reasoning = insight.reasoning {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("Comment ShifAI a déduit ça")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            Text(reasoning)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                        )
                    }
                }
                .padding(16)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(Color(hex: "A78BFA"))
                }
            }
        }
    }
}

// MARK: - Insights Tab ViewModel

final class InsightsTabViewModel: ObservableObject {
    @Published var insights: [Insight] = []
    @Published var recommendations: [Insight] = []
    @Published var periodPrediction: Prediction? = nil
    @Published var ovulationPrediction: Prediction? = nil
    @Published var periodFeedback: InsightFeedback? = nil
    @Published var cycleProgress: CGFloat = 0.5
    @Published var cycleLength: Int = 28
    @Published var unreadCount: Int = 0

    private let mlEngine = MLEngine.shared
    private let insightRepo: InsightRepositoryProtocol
    private let predictionRepo: PredictionRepositoryProtocol

    init(
        insightRepo: InsightRepositoryProtocol = InsightRepository(),
        predictionRepo: PredictionRepositoryProtocol = PredictionRepository()
    ) {
        self.insightRepo = insightRepo
        self.predictionRepo = predictionRepo
    }

    func loadData() {
        // Load fresh predictions from engine
        mlEngine.loadModelIfReady()
        let result = mlEngine.predict()

        periodPrediction = result.periodPrediction
        ovulationPrediction = result.ovulationPrediction

        // Save new predictions
        if let p = result.periodPrediction { try? predictionRepo.save(p) }
        if let o = result.ovulationPrediction { try? predictionRepo.save(o) }

        // Save new insights
        for insight in result.insights {
            try? insightRepo.save(insight)
        }

        // Load all insights
        let allInsights = (try? insightRepo.fetchRecent(limit: 20)) ?? []
        insights = allInsights.filter { $0.type != .recommendation }
        recommendations = allInsights.filter { $0.type == .recommendation }
        unreadCount = allInsights.filter { !$0.isRead }.count
    }

    func refresh() {
        loadData()
    }

    // S4-5: Prediction Feedback
    func submitFeedback(predictionId: String, feedback: InsightFeedback) {
        periodFeedback = feedback
        // TODO: Update prediction in repo with feedback
    }

    // S4-8: Recommendation tracking
    func followRecommendation(_ id: String) {
        // TODO: Track recommendation_followed event
        removeRecommendation(id)
    }

    func skipRecommendation(_ id: String) {
        removeRecommendation(id)
    }

    private func removeRecommendation(_ id: String) {
        recommendations.removeAll { $0.id == id }
    }
}
