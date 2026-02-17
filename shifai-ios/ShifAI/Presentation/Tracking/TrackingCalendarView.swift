import SwiftUI

// MARK: - Tracking Calendar View
// S2-9: Monthly calendar with color-coded dots, day detail on tap

struct TrackingCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Month navigation
                monthHeader

                // Day-of-week labels
                dayOfWeekHeader

                // Calendar grid
                calendarGrid

                // Legend
                legendSection

                // Selected day detail
                if let selected = viewModel.selectedDate {
                    dayDetailSection(selected)
                }
            }
            .padding(16)
        }
        .background(ShifAIColors.background.ignoresSafeArea())
        .navigationTitle("Calendrier")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadMonth() }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                viewModel.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "A78BFA"))
            }

            Spacer()

            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button {
                viewModel.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "A78BFA"))
            }
        }
    }

    // MARK: - Day of Week Header

    private var dayOfWeekHeader: some View {
        let days = ["L", "M", "M", "J", "V", "S", "D"]
        return HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                Text(days[index])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let weeks = viewModel.weeksInMonth()

        return VStack(spacing: 4) {
            ForEach(weeks, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { day in
                        if let day = day {
                            dayCell(day)
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 52)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(_ date: Date) -> some View {
        let data = viewModel.dayData[Calendar.current.startOfDay(for: date)]
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = viewModel.selectedDate == Calendar.current.startOfDay(for: date)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedDate = Calendar.current.startOfDay(for: date)
            }
        } label: {
            VStack(spacing: 3) {
                // Day number
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundColor(isToday ? Color(hex: "7C5CFC") : .white)

                // Dots row
                HStack(spacing: 2) {
                    if data?.hasFlow == true {
                        Circle().fill(Color(hex: "EF4444")).frame(width: 5, height: 5)
                    }
                    if data?.hasSymptoms == true {
                        Circle().fill(Color(hex: "F59E0B")).frame(width: 5, height: 5)
                    }
                    if data?.hasMood == true {
                        Circle().fill(Color(hex: "A78BFA")).frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: "7C5CFC").opacity(0.2) :
                          isToday ? Color.white.opacity(0.04) : Color.clear)
            )
        }
    }

    // MARK: - Legend

    private var legendSection: some View {
        HStack(spacing: 16) {
            legendItem(color: Color(hex: "EF4444"), label: "Règles")
            legendItem(color: Color(hex: "F59E0B"), label: "Symptômes")
            legendItem(color: Color(hex: "A78BFA"), label: "Humeur")
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Day Detail

    private func dayDetailSection(_ date: Date) -> some View {
        let data = viewModel.dayData[date]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            if let data = data {
                // Cycle info
                if let cycleDay = data.cycleDay, let phase = data.phase {
                    HStack(spacing: 8) {
                        Text("J\(cycleDay)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(phase.displayName)
                            .font(.system(size: 13))
                            .foregroundColor(phase.color)
                        if let flow = data.flowIntensity {
                            HStack(spacing: 1) {
                                ForEach(0..<flow, id: \.self) { _ in
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(Color(hex: "EF4444"))
                                }
                            }
                        }
                    }
                }

                // Symptoms
                if !data.symptoms.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(data.symptoms, id: \.self) { type in
                            Text(type.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.06))
                                )
                        }
                    }
                }

                // Notes
                if let notes = data.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                Text("Aucune donnée pour ce jour")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Calendar ViewModel

final class CalendarViewModel: ObservableObject {
    struct DayInfo: Hashable {
        let cycleDay: Int?
        let phase: CyclePhase?
        let flowIntensity: Int?
        let hasFlow: Bool
        let hasSymptoms: Bool
        let hasMood: Bool
        let symptoms: [SymptomType]
        let notes: String?
    }

    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date? = nil
    @Published var dayData: [Date: DayInfo] = [:]

    private let cycleRepo: CycleRepositoryProtocol
    private let symptomRepo: SymptomRepositoryProtocol

    init(
        cycleRepo: CycleRepositoryProtocol = CycleRepository(),
        symptomRepo: SymptomRepositoryProtocol = SymptomRepository()
    ) {
        self.cycleRepo = cycleRepo
        self.symptomRepo = symptomRepo
    }

    func loadMonth() {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth)),
              let lastOfMonth = cal.date(byAdding: .day, value: range.count - 1, to: firstOfMonth) else { return }

        // Load cycle entries
        let entries = (try? cycleRepo.fetchByDateRange(from: firstOfMonth, to: lastOfMonth)) ?? []
        let symptoms = (try? symptomRepo.fetchByDateRange(from: firstOfMonth, to: lastOfMonth)) ?? []

        var data: [Date: DayInfo] = [:]

        for entry in entries {
            let dateKey = cal.startOfDay(for: entry.date)
            let daySymptoms = symptoms.filter { cal.isDate($0.date, inSameDayAs: entry.date) }

            data[dateKey] = DayInfo(
                cycleDay: entry.cycleDay,
                phase: entry.phase,
                flowIntensity: entry.flowIntensity,
                hasFlow: (entry.flowIntensity ?? 0) > 0,
                hasSymptoms: !daySymptoms.isEmpty,
                hasMood: daySymptoms.contains(where: { $0.notes?.hasPrefix("mood:") == true }),
                symptoms: daySymptoms.map { $0.type },
                notes: entry.notes
            )
        }

        // Add symptom-only days
        for sym in symptoms {
            let dateKey = cal.startOfDay(for: sym.date)
            if data[dateKey] == nil {
                let daySymptoms = symptoms.filter { cal.isDate($0.date, inSameDayAs: sym.date) }
                data[dateKey] = DayInfo(
                    cycleDay: nil, phase: nil, flowIntensity: nil,
                    hasFlow: false,
                    hasSymptoms: true,
                    hasMood: daySymptoms.contains(where: { $0.notes?.hasPrefix("mood:") == true }),
                    symptoms: daySymptoms.map { $0.type },
                    notes: nil
                )
            }
        }

        dayData = data
    }

    func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        loadMonth()
    }

    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        loadMonth()
    }

    func weeksInMonth() -> [[Date?]] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        // Monday = 2 in Calendar, adjust for Monday-start weeks
        let firstWeekday = (cal.component(.weekday, from: firstOfMonth) + 5) % 7

        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            let date = cal.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            currentWeek.append(date)

            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        // Pad last week
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }

        return weeks
    }
}

// MARK: - Flow Layout (for symptom chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
