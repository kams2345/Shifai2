import SwiftUI

// MARK: - Body Map View
// S2-3: Interactive body map with 5 tappable zones, pain type + intensity

struct BodyMapView: View {
    @StateObject private var viewModel = BodyMapViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                ShifAIColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Instructions
                    Text("Touche les zones de douleur")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))

                    // Body Map Canvas
                    bodyMapCanvas
                        .frame(height: 400)

                    // Selected zone details
                    if let zone = viewModel.selectedZone {
                        zoneDetailCard(zone)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Body Map")
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

    // MARK: - Body Map Canvas

    private var bodyMapCanvas: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Body silhouette (simplified outline)
                bodyOutline(width: w, height: h)

                // Interactive zones
                zoneButton(.uterus, x: w * 0.5, y: h * 0.55, size: 60)
                zoneButton(.leftOvary, x: w * 0.35, y: h * 0.50, size: 44)
                zoneButton(.rightOvary, x: w * 0.65, y: h * 0.50, size: 44)
                zoneButton(.lowerBack, x: w * 0.5, y: h * 0.45, size: 56)
                zoneButton(.thighs, x: w * 0.5, y: h * 0.72, size: 52)
            }
        }
    }

    // MARK: - Body Outline

    private func bodyOutline(width: Float? = nil, height: Float? = nil) -> some View {
        // Simplified female torso outline using SF Symbols + shapes
        ZStack {
            // Torso outline
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                .frame(width: 160, height: 300)

            // Head
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                .frame(width: 50, height: 50)
                .offset(y: -190)

            // Legs
            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                .frame(width: 30, height: 120)
                .offset(x: -30, y: 190)

            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                .frame(width: 30, height: 120)
                .offset(x: 30, y: 190)
        }
    }

    // MARK: - Zone Button

    private func zoneButton(_ zone: BodyZone, x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        let isSelected = viewModel.selectedZone == zone
        let hasData = viewModel.zoneData[zone] != nil
        let intensity = viewModel.zoneData[zone]?.intensity ?? 0

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedZone = zone
            }
        } label: {
            ZStack {
                // Heatmap circle (intensity-based)
                Circle()
                    .fill(heatmapColor(intensity: intensity).opacity(hasData ? 0.5 : 0.08))
                    .frame(width: size, height: size)

                // Pulsing border if selected
                if isSelected {
                    Circle()
                        .stroke(Color(hex: "7C5CFC"), lineWidth: 2)
                        .frame(width: size + 4, height: size + 4)
                }

                // Zone label
                Text(zone.shortName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .position(x: x, y: y)
    }

    // MARK: - Zone Detail Card

    private func zoneDetailCard(_ zone: BodyZone) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(zone.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            // Pain type picker
            Text("Type de douleur")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(PainType.allCases, id: \.self) { painType in
                    let isSelected = viewModel.zoneData[zone]?.painType == painType

                    Button {
                        viewModel.setPainType(painType, for: zone)
                    } label: {
                        VStack(spacing: 4) {
                            Text(painType.emoji)
                                .font(.system(size: 20))
                            Text(painType.displayName)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ?
                                      Color(hex: "7C5CFC").opacity(0.3) :
                                      Color.white.opacity(0.04))
                        )
                    }
                }
            }

            // Intensity slider (1-10)
            HStack {
                Text("Intensité")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))

                Slider(
                    value: Binding(
                        get: { Double(viewModel.zoneData[zone]?.intensity ?? 5) },
                        set: { viewModel.setIntensity(Int($0), for: zone) }
                    ),
                    in: 1...10,
                    step: 1
                )
                .tint(heatmapColor(intensity: viewModel.zoneData[zone]?.intensity ?? 5))

                Text("\(viewModel.zoneData[zone]?.intensity ?? 5)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 28)
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Heatmap Color

    private func heatmapColor(intensity: Int) -> Color {
        switch intensity {
        case 1...3: return Color(hex: "FBBF24") // Yellow
        case 4...6: return Color(hex: "F97316") // Orange
        case 7...8: return Color(hex: "EF4444") // Red
        case 9...10: return Color(hex: "DC2626") // Deep red
        default: return Color.white.opacity(0.2)
        }
    }
}

// MARK: - Body Map ViewModel

final class BodyMapViewModel: ObservableObject {

    struct ZoneEntry {
        var painType: PainType
        var intensity: Int
        var notes: String?
    }

    @Published var selectedZone: BodyZone? = nil
    @Published var zoneData: [BodyZone: ZoneEntry] = [:]

    private let symptomRepo: SymptomRepositoryProtocol

    init(symptomRepo: SymptomRepositoryProtocol = SymptomRepository()) {
        self.symptomRepo = symptomRepo
    }

    func setPainType(_ type: PainType, for zone: BodyZone) {
        if zoneData[zone] != nil {
            zoneData[zone]?.painType = type
        } else {
            zoneData[zone] = ZoneEntry(painType: type, intensity: 5)
        }
    }

    func setIntensity(_ intensity: Int, for zone: BodyZone) {
        if zoneData[zone] != nil {
            zoneData[zone]?.intensity = intensity
        } else {
            zoneData[zone] = ZoneEntry(painType: .cramping, intensity: intensity)
        }
    }

    func saveAll() {
        let today = Date()
        for (zone, entry) in zoneData {
            let log = SymptomLog(
                id: UUID().uuidString,
                date: today,
                type: .pelvicPain,
                intensity: entry.intensity,
                bodyZone: zone,
                painType: entry.painType,
                notes: entry.notes,
                createdAt: today
            )
            try? symptomRepo.save(log)
        }
    }
}

// MARK: - Extensions

extension BodyZone {
    var displayName: String {
        switch self {
        case .uterus: return "Utérus"
        case .leftOvary: return "Ovaire gauche"
        case .rightOvary: return "Ovaire droit"
        case .lowerBack: return "Bas du dos"
        case .thighs: return "Cuisses"
        }
    }

    var shortName: String {
        switch self {
        case .uterus: return "Utérus"
        case .leftOvary: return "OG"
        case .rightOvary: return "OD"
        case .lowerBack: return "Dos"
        case .thighs: return "Cuisses"
        }
    }
}

extension PainType {
    var displayName: String {
        switch self {
        case .cramping: return "Crampes"
        case .burning: return "Brûlure"
        case .pressure: return "Pression"
        case .sharp: return "Aiguë"
        case .other: return "Autre"
        }
    }

    var emoji: String {
        switch self {
        case .cramping: return "🤜"
        case .burning: return "🔥"
        case .pressure: return "⬇️"
        case .sharp: return "⚡"
        case .other: return "➕"
        }
    }
}
