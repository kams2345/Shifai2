import SwiftUI

// MARK: - Cycle Tracking View
// S2-1: Log period start/end, flow intensity, phase detection, history

struct CycleTrackingView: View {
    @StateObject private var viewModel = CycleTrackingViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Cycle Header
                currentCycleCard

                // Log Period Section
                periodLogSection

                // Flow Intensity
                if viewModel.isOnPeriod {
                    flowIntensitySection
                }

                // Cervical Mucus (optional)
                cervicalMucusSection

                // Notes
                notesSection

                // History
                recentHistorySection
            }
            .padding(16)
        }
        .background(ShifAIColors.background.ignoresSafeArea())
        .navigationTitle("Suivi Cycle")
        .onAppear { viewModel.loadData() }
    }

    // MARK: - Current Cycle Card

    private var currentCycleCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Jour \(viewModel.currentCycleDay)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(viewModel.currentPhase.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.currentPhase.color)
                }

                Spacer()

                // Phase icon
                VStack(spacing: 4) {
                    Text(viewModel.currentPhase.emoji)
                        .font(.system(size: 36))

                    if let daysUntilPeriod = viewModel.daysUntilNextPeriod {
                        Text("~\(daysUntilPeriod)j")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            // Cycle length info
            if let avgLength = viewModel.averageCycleLength {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Cycle moyen: \(avgLength) jours")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
            }
        }
        .padding(20)
        .modifier(GlassCardModifier())
    }

    // MARK: - Period Log

    private var periodLogSection: some View {
        VStack(spacing: 12) {
            Text("Règles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                // Start period button
                Button {
                    withAnimation { viewModel.togglePeriod() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isOnPeriod ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20))
                        Text(viewModel.isOnPeriod ? "Fin des règles" : "Début des règles")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.isOnPeriod ?
                                  Color(hex: "EF4444").opacity(0.3) :
                                  Color(hex: "7C5CFC").opacity(0.3))
                    )
                }

                Spacer()

                // Date picker
                DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color(hex: "A78BFA"))
                    .colorScheme(.dark)
            }
        }
    }

    // MARK: - Flow Intensity

    private var flowIntensitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Intensité du flux")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        viewModel.flowIntensity = level
                    } label: {
                        VStack(spacing: 4) {
                            // Drop icon sized by intensity
                            Image(systemName: "drop.fill")
                                .font(.system(size: CGFloat(10 + level * 3)))
                                .foregroundColor(viewModel.flowIntensity == level ?
                                                 Color(hex: "EF4444") :
                                                 .white.opacity(0.3))

                            Text("\(level)")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.flowIntensity == level ?
                                      Color(hex: "EF4444").opacity(0.15) :
                                      Color.clear)
                        )
                    }
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Cervical Mucus

    private var cervicalMucusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Glaire cervicale")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(CervicalMucus.allCases, id: \.self) { type in
                    Button {
                        viewModel.cervicalMucus = type
                    } label: {
                        Text(type.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(viewModel.cervicalMucus == type ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.cervicalMucus == type ?
                                          Color(hex: "7C5CFC").opacity(0.4) :
                                          Color.white.opacity(0.08))
                            )
                    }
                }
            }
        }
        .padding(16)
        .modifier(GlassCardModifier())
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            TextField("Observations du jour...", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(3...6)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                )
        }
    }

    // MARK: - History

    private var recentHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Historique récent")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                NavigationLink("Tout voir") {
                    TrackingCalendarView()
                }
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "A78BFA"))
            }

            ForEach(viewModel.recentEntries, id: \.id) { entry in
                HStack(spacing: 12) {
                    // Date
                    VStack(spacing: 2) {
                        Text(entry.date.formatted(.dateTime.day()))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(entry.date.formatted(.dateTime.month(.abbreviated)))
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                    .frame(width: 44)

                    // Phase indicator
                    Circle()
                        .fill(entry.phase.color)
                        .frame(width: 8, height: 8)

                    // Details
                    VStack(alignment: .leading, spacing: 2) {
                        Text("J\(entry.cycleDay) · \(entry.phase.displayName)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)

                        if let flow = entry.flowIntensity {
                            HStack(spacing: 2) {
                                ForEach(0..<flow, id: \.self) { _ in
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(Color(hex: "EF4444"))
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.04))
                )
            }
        }
    }
}

// MARK: - Save Button

extension CycleTrackingView {
    private var saveButton: some View {
        Button {
            viewModel.saveEntry()
        } label: {
            Text("Enregistrer")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "7C5CFC"))
                )
        }
    }
}
