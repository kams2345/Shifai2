import SwiftUI

// MARK: - Symptom Logging View
// S2-2: 30+ symptoms, categories, intensity, quick-select

struct SymptomLoggingView: View {
    @StateObject private var viewModel = SymptomLoggingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search
                    searchBar

                    // Quick select (frecents)
                    if !viewModel.frequentSymptoms.isEmpty {
                        quickSelectSection
                    }

                    // Categories
                    ForEach(SymptomCategory.allCases, id: \.self) { category in
                        categorySection(category)
                    }
                }
                .padding(16)
            }
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationTitle("Symptômes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") { viewModel.saveAll(); dismiss() }
                        .foregroundColor(Color(hex: "7C5CFC"))
                        .disabled(viewModel.selectedSymptoms.isEmpty)
                }
            }
            .onAppear { viewModel.loadFrequents() }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.4))
            TextField("Rechercher un symptôme...", text: $viewModel.searchText)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Quick Select

    private var quickSelectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fréquents")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                ForEach(viewModel.frequentSymptoms, id: \.self) { type in
                    symptomChip(type, isQuickSelect: true)
                }
            }
        }
    }

    // MARK: - Category Section

    private func categorySection(_ category: SymptomCategory) -> some View {
        let symptoms = viewModel.filteredSymptoms(for: category)
        guard !symptoms.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(category.emoji)
                    Text(category.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(symptoms, id: \.self) { type in
                        symptomChip(type)
                    }
                }

                // Intensity slider for selected symptoms in this category
                ForEach(viewModel.selectedInCategory(category), id: \.self) { type in
                    intensitySlider(for: type)
                }
            }
            .padding(16)
            .modifier(GlassCardModifier())
        )
    }

    // MARK: - Symptom Chip

    private func symptomChip(_ type: SymptomType, isQuickSelect: Bool = false) -> some View {
        let isSelected = viewModel.selectedSymptoms.keys.contains(type)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.toggleSymptom(type)
            }
        } label: {
            Text(type.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ?
                              Color(hex: "7C5CFC").opacity(0.5) :
                              Color.white.opacity(0.06))
                )
        }
    }

    // MARK: - Intensity Slider

    private func intensitySlider(for type: SymptomType) -> some View {
        let intensity = Binding(
            get: { viewModel.selectedSymptoms[type] ?? 5 },
            set: { viewModel.selectedSymptoms[type] = $0 }
        )

        return HStack(spacing: 12) {
            Text(type.displayName)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)

            Slider(value: .init(
                get: { Double(intensity.wrappedValue) },
                set: { intensity.wrappedValue = Int($0) }
            ), in: 1...10, step: 1)
            .tint(Color(hex: "7C5CFC"))

            Text("\(intensity.wrappedValue)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "A78BFA"))
                .frame(width: 24)
        }
    }
}

// MARK: - Symptom Category

enum SymptomCategory: String, CaseIterable {
    case pain = "pain"
    case digestive = "digestive"
    case emotional = "emotional"
    case physical = "physical"
    case hormonal = "hormonal"
    case other = "other"

    var displayName: String {
        switch self {
        case .pain: return "Douleur"
        case .digestive: return "Digestif"
        case .emotional: return "Émotionnel"
        case .physical: return "Physique"
        case .hormonal: return "Hormonal"
        case .other: return "Autre"
        }
    }

    var emoji: String {
        switch self {
        case .pain: return "🔴"
        case .digestive: return "🫄"
        case .emotional: return "💭"
        case .physical: return "🤕"
        case .hormonal: return "⚡"
        case .other: return "📝"
        }
    }

    var symptoms: [SymptomType] {
        switch self {
        case .pain:
            return [.cramps, .headache, .backPain, .breastTenderness, .jointPain, .pelvicPain]
        case .digestive:
            return [.bloating, .nausea, .constipation, .diarrhea, .cravings, .appetiteLoss]
        case .emotional:
            return [.anxious, .irritable, .sad, .moodSwings, .brainFog, .crying]
        case .physical:
            return [.fatigue, .insomnia, .hotFlashes, .dizziness, .acne, .hairLoss]
        case .hormonal:
            return [.spotting, .heavyFlow, .irregularCycle, .nightSweats]
        case .other:
            return [.other]
        }
    }
}

// MARK: - SymptomType Display

extension SymptomType {
    var displayName: String {
        switch self {
        case .cramps: return "Crampes"
        case .headache: return "Migraine"
        case .backPain: return "Mal de dos"
        case .breastTenderness: return "Seins sensibles"
        case .jointPain: return "Douleurs articulaires"
        case .pelvicPain: return "Douleur pelvienne"
        case .bloating: return "Ballonnement"
        case .nausea: return "Nausée"
        case .constipation: return "Constipation"
        case .diarrhea: return "Diarrhée"
        case .cravings: return "Envies alimentaires"
        case .appetiteLoss: return "Perte d'appétit"
        case .anxious: return "Anxiété"
        case .irritable: return "Irritabilité"
        case .sad: return "Tristesse"
        case .moodSwings: return "Sautes d'humeur"
        case .brainFog: return "Brouillard mental"
        case .crying: return "Envie de pleurer"
        case .fatigue: return "Fatigue"
        case .insomnia: return "Insomnie"
        case .hotFlashes: return "Bouffées de chaleur"
        case .dizziness: return "Vertiges"
        case .acne: return "Acné"
        case .hairLoss: return "Chute de cheveux"
        case .spotting: return "Spotting"
        case .heavyFlow: return "Flux abondant"
        case .irregularCycle: return "Cycle irrégulier"
        case .nightSweats: return "Sueurs nocturnes"
        case .other: return "Autre"
        }
    }

    var category: SymptomCategory {
        for cat in SymptomCategory.allCases {
            if cat.symptoms.contains(self) { return cat }
        }
        return .other
    }
}
