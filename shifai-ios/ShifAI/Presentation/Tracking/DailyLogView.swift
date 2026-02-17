import SwiftUI

// MARK: - Daily Log View
// S2-4 to S2-7: Mood, Energy, Sleep, Stress — all in one quick-log view

struct DailyLogView: View {
    @StateObject private var viewModel = DailyLogViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Date header
                    dateHeader

                    // Mood (S2-4)
                    moodSection

                    // Energy (S2-5)
                    energySection

                    // Sleep (S2-6)
                    sleepSection

                    // Stress (S2-7)
                    stressSection

                    // Quick actions
                    quickActionButtons

                    Spacer(minLength: 20)
                }
                .padding(16)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationTitle("Log du jour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        viewModel.saveAll()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "7C5CFC"))
                }
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Text(viewModel.date.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            if viewModel.currentCycleDay > 0 {
                Text("J\(viewModel.currentCycleDay)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "A78BFA"))
            }
        }
    }

    // MARK: - Mood (S2-4)

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Humeur", icon: "face.smiling")

            HStack(spacing: 0) {
                ForEach(Array(viewModel.moodOptions.enumerated()), id: \.offset) { index, mood in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedMood = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: viewModel.selectedMood == index ? 36 : 28))

                            Text(mood.label)
                                .font(.system(size: 10))
                                .foregroundColor(viewModel.selectedMood == index ?
                                                 .white : .white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedMood == index ?
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "7C5CFC").opacity(0.2)) :
                            nil
                        )
                    }
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Energy (S2-5)

    private var energySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Énergie", icon: "bolt.fill")

            HStack(spacing: 4) {
                Text("⚡")
                    .font(.system(size: 14))
                    .opacity(0.5)

                Slider(value: $viewModel.energy, in: 1...10, step: 1)
                    .tint(energyColor)

                Text("🔥")
                    .font(.system(size: 14))
            }

            HStack {
                Text(energyLabel)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(Int(viewModel.energy))/10")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(energyColor)
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Sleep (S2-6)

    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Sommeil", icon: "moon.fill")

            // Duration
            HStack {
                Text("Durée")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()

                HStack(spacing: 4) {
                    Picker("Hours", selection: $viewModel.sleepHours) {
                        ForEach(0...14, id: \.self) { h in
                            Text("\(h)h").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 80)

                    Picker("Minutes", selection: $viewModel.sleepMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text("\(m)m").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 80)
                }
                .colorScheme(.dark)
            }

            Divider().background(.white.opacity(0.1))

            // Quality
            HStack {
                Text("Qualité")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            viewModel.sleepQuality = star
                        } label: {
                            Image(systemName: star <= viewModel.sleepQuality ? "star.fill" : "star")
                                .font(.system(size: 20))
                                .foregroundColor(star <= viewModel.sleepQuality ?
                                                 Color(hex: "FBBF24") : .white.opacity(0.2))
                        }
                    }
                }
            }

            // Benchmark
            if viewModel.sleepHours > 0 {
                let totalHours = Double(viewModel.sleepHours) + Double(viewModel.sleepMinutes) / 60.0
                let benchmark = totalHours >= 7.0

                HStack(spacing: 6) {
                    Image(systemName: benchmark ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(benchmark ? Color(hex: "34D399") : Color(hex: "FBBF24"))
                    Text(benchmark ?
                         "Au-dessus de la recommandation (7h)" :
                         "En dessous de la recommandation (7h)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Stress (S2-7)

    private var stressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Stress", icon: "waveform.path.ecg")

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        withAnimation { viewModel.stress = level }
                    } label: {
                        VStack(spacing: 4) {
                            Text(stressEmoji(level))
                                .font(.system(size: viewModel.stress == level ? 32 : 24))

                            Text(stressLabel(level))
                                .font(.system(size: 10))
                                .foregroundColor(viewModel.stress == level ?
                                                 .white : .white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.stress == level ?
                            RoundedRectangle(cornerRadius: 10)
                                .fill(stressColor(level).opacity(0.2)) :
                            nil
                        )
                    }
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Quick Actions

    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            NavigationLink {
                SymptomLoggingView()
            } label: {
                quickActionCard(emoji: "🩺", label: "Symptômes")
            }

            NavigationLink {
                BodyMapView()
            } label: {
                quickActionCard(emoji: "🫀", label: "Body Map")
            }
        }
    }

    private func quickActionCard(emoji: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 28))
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "A78BFA"))
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private var energyColor: Color {
        switch Int(viewModel.energy) {
        case 1...3: return Color(hex: "EF4444")
        case 4...5: return Color(hex: "FBBF24")
        case 6...7: return Color(hex: "34D399")
        case 8...10: return Color(hex: "22D3EE")
        default: return .gray
        }
    }

    private var energyLabel: String {
        switch Int(viewModel.energy) {
        case 1...2: return "Épuisée"
        case 3...4: return "Faible"
        case 5...6: return "Moyenne"
        case 7...8: return "Bonne"
        case 9...10: return "Au top !"
        default: return "—"
        }
    }

    private func stressEmoji(_ level: Int) -> String {
        ["😌", "🙂", "😐", "😰", "🤯"][level - 1]
    }

    private func stressLabel(_ level: Int) -> String {
        ["Zen", "Calme", "Moyen", "Stressée", "Élevé"][level - 1]
    }

    private func stressColor(_ level: Int) -> Color {
        switch level {
        case 1...2: return Color(hex: "34D399")
        case 3: return Color(hex: "FBBF24")
        case 4...5: return Color(hex: "EF4444")
        default: return .gray
        }
    }
}

// MARK: - Daily Log ViewModel

final class DailyLogViewModel: ObservableObject {

    struct MoodOption {
        let emoji: String
        let label: String
    }

    let moodOptions: [MoodOption] = [
        MoodOption(emoji: "😄", label: "Super"),
        MoodOption(emoji: "😊", label: "Bien"),
        MoodOption(emoji: "😐", label: "Neutre"),
        MoodOption(emoji: "😔", label: "Triste"),
        MoodOption(emoji: "😢", label: "Mal"),
        MoodOption(emoji: "😤", label: "En colère"),
        MoodOption(emoji: "😰", label: "Anxieuse"),
    ]

    @Published var date = Date()
    @Published var currentCycleDay: Int = 0

    // Mood (S2-4)
    @Published var selectedMood: Int? = nil

    // Energy (S2-5)
    @Published var energy: Double = 5

    // Sleep (S2-6)
    @Published var sleepHours: Int = 7
    @Published var sleepMinutes: Int = 30
    @Published var sleepQuality: Int = 3

    // Stress (S2-7)
    @Published var stress: Int = 3

    // Notes
    @Published var notes: String = ""

    private let symptomRepo: SymptomRepositoryProtocol

    init(symptomRepo: SymptomRepositoryProtocol = SymptomRepository()) {
        self.symptomRepo = symptomRepo
    }

    func saveAll() {
        let today = Date()

        // Save mood as symptom log
        if let moodIndex = selectedMood {
            let moodLog = SymptomLog(
                id: UUID().uuidString, date: today,
                type: .moodSwings, intensity: moodIndex + 1,
                bodyZone: nil, painType: nil,
                notes: "mood:\(moodOptions[moodIndex].label)",
                createdAt: today
            )
            try? symptomRepo.save(moodLog)
        }

        // Save energy
        let energyLog = SymptomLog(
            id: UUID().uuidString, date: today,
            type: .fatigue, intensity: 10 - Int(energy), // Inverse: low energy = high fatigue
            bodyZone: nil, painType: nil,
            notes: "energy:\(Int(energy))",
            createdAt: today
        )
        try? symptomRepo.save(energyLog)

        // Save sleep
        let sleepLog = SymptomLog(
            id: UUID().uuidString, date: today,
            type: .insomnia, intensity: 5 - sleepQuality, // Inverse scale
            bodyZone: nil, painType: nil,
            notes: "sleep:\(sleepHours)h\(sleepMinutes)m quality:\(sleepQuality)",
            createdAt: today
        )
        try? symptomRepo.save(sleepLog)

        // Save stress
        let stressLog = SymptomLog(
            id: UUID().uuidString, date: today,
            type: .anxious, intensity: stress * 2, // Scale 1-5 → 2-10
            bodyZone: nil, painType: nil,
            notes: "stress:\(stress)",
            createdAt: today
        )
        try? symptomRepo.save(stressLog)
    }
}
