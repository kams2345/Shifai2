import SwiftUI

// MARK: - Complete Onboarding Flow
// S3-1 through S3-5: 5-step onboarding with progress, animations, data collection

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep = 0

    var body: some View {
        ZStack {
            ShifAIColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar

                // Content
                TabView(selection: $currentStep) {
                    welcomeScreen.tag(0)
                    disclaimerScreen.tag(1)
                    privacyScreen.tag(2)
                    profileSetupScreen.tag(3)
                    firstActionScreen.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<5) { step in
                Capsule()
                    .fill(step <= currentStep ?
                          Color(hex: "7C5CFC") :
                          Color.white.opacity(0.1))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - S3-1: Accueil Empathique

    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            // Shield icon
            Image(systemName: "shield.checkered")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "7C5CFC"), Color(hex: "A78BFA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: 12) {
                Text("Ton corps a un rythme unique.")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("ShifAI apprend le tien.")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color(hex: "A78BFA"))
            }

            // "Décris ton cycle en 3 mots"
            VStack(alignment: .leading, spacing: 8) {
                Text("Décris ton cycle en 3 mots")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))

                TextField("Ex: irrégulier, douloureux, imprévisible", text: $viewModel.cycleDescription)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "7C5CFC").opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 24)

            // Validation stat
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "A78BFA"))
                Text("40% des femmes ont des cycles irréguliers. Tu n'es pas seule.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton { currentStep = 1 }
        }
    }

    // MARK: - S3-2: Disclaimer Légal

    private var disclaimerScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "stethoscope")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "FBBF24"))

            VStack(spacing: 16) {
                Text("Information importante")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    disclaimerRow(icon: "info.circle.fill", color: "FBBF24",
                                 text: "ShifAI est un outil d'information, PAS un dispositif médical.")

                    disclaimerRow(icon: "cross.case.fill", color: "EF4444",
                                 text: "Consulte toujours ton médecin pour diagnostic et traitement.")

                    disclaimerRow(icon: "checkmark.shield.fill", color: "34D399",
                                 text: "Les prédictions sont basées sur tes données et peuvent varier.")
                }
                .padding(.horizontal, 24)
            }

            // Checkbox
            Button {
                withAnimation { viewModel.disclaimerAccepted.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.disclaimerAccepted ?
                          "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundColor(viewModel.disclaimerAccepted ?
                                         Color(hex: "7C5CFC") : .white.opacity(0.3))

                    Text("J'ai compris et j'accepte")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 24)

            // Links
            HStack(spacing: 24) {
                Button("Politique de confidentialité") { }
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "A78BFA"))
                Button("CGU") { }
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "A78BFA"))
            }

            Spacer()

            nextButton(disabled: !viewModel.disclaimerAccepted) { currentStep = 2 }
        }
    }

    // MARK: - S3-3: Privacy Promise

    private var privacyScreen: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "34D399"), Color(hex: "22D3EE")],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            Text("Tes données restent sur\nTON téléphone.")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                privacyBadge(emoji: "🔒", title: "Chiffré AES-256",
                             subtitle: "Même nous ne pouvons pas lire tes données")
                privacyBadge(emoji: "🇪🇺", title: "Serveurs EU",
                             subtitle: "Hébergement exclusivement européen")
                privacyBadge(emoji: "0️⃣", title: "Zéro trackers",
                             subtitle: "Aucun analytics tiers, aucune pub")
            }
            .padding(.horizontal, 24)

            Button("En savoir plus →") { }
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "A78BFA"))

            Spacer()

            nextButton { currentStep = 3 }
        }
    }

    // MARK: - S3-4: Setup Profil

    private var profileSetupScreen: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Parlons de toi")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Tu peux modifier à tout moment.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 20)

                // Age range
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Tranche d'âge")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(["18-24", "25-30", "31-35", "36-40", "41-45", "45+"], id: \.self) { range in
                            selectionChip(range, isSelected: viewModel.ageRange == range) {
                                viewModel.ageRange = range
                            }
                        }
                    }
                }

                // Cycle length
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Durée estimée du cycle")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(["< 21 jours", "21-25", "26-30", "31-35", "35+", "Je ne sais pas"], id: \.self) { option in
                            selectionChip(option, isSelected: viewModel.cycleLength == option) {
                                viewModel.cycleLength = option
                            }
                        }
                    }
                }

                // Known conditions
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Conditions connues")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(["SOPK", "Endométriose", "Aucune", "Je ne sais pas"], id: \.self) { condition in
                            selectionChip(condition, isSelected: viewModel.selectedConditions.contains(condition)) {
                                viewModel.toggleCondition(condition)
                            }
                        }
                    }
                }

                // Symptoms to track
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Symptômes à suivre (préselection)")

                    let preselected = viewModel.preselectedSymptoms
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(preselected, id: \.self) { symptom in
                            selectionChip(symptom, isSelected: viewModel.trackedSymptoms.contains(symptom)) {
                                viewModel.toggleTrackedSymptom(symptom)
                            }
                        }
                    }
                }

                nextButton { currentStep = 4; viewModel.saveProfile() }
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - S3-5: Première Action — Body Map

    private var firstActionScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.stand")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "A78BFA"))

            VStack(spacing: 8) {
                Text("Première observation")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Marque les zones de douleur actuelles sur la Body Map")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            // Inline simplified body map
            miniBodyMap

            Text("Merci ! Je vais observer ce pattern. 🔍")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "34D399"))
                .opacity(viewModel.hasMarkedBodyMap ? 1 : 0)

            Spacer()

            // Complete onboarding
            Button {
                viewModel.completeOnboarding()
            } label: {
                Text("Commencer →")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "7C5CFC"), Color(hex: "6D28D9")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Mini Body Map

    private var miniBodyMap: some View {
        HStack(spacing: 16) {
            ForEach(BodyZone.allCases, id: \.self) { zone in
                Button {
                    viewModel.toggleBodyZone(zone)
                } label: {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.markedZones.contains(zone) ?
                                  Color(hex: "EF4444").opacity(0.5) :
                                  Color.white.opacity(0.08))
                            .frame(width: 44, height: 44)
                            .overlay(
                                viewModel.markedZones.contains(zone) ?
                                Circle()
                                    .stroke(Color(hex: "EF4444"), lineWidth: 2) :
                                nil
                            )

                        Text(zone.shortName)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }

    // MARK: - Shared Components

    private func nextButton(disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text("Continuer")
                    .font(.system(size: 16, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "7C5CFC").opacity(disabled ? 0.3 : 1))
            )
        }
        .disabled(disabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private func disclaimerRow(icon: String, color: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: color))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private func privacyBadge(emoji: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white.opacity(0.6))
    }

    private func selectionChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ?
                              Color(hex: "7C5CFC").opacity(0.4) :
                              Color.white.opacity(0.06))
                        .overlay(
                            isSelected ?
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "7C5CFC").opacity(0.5), lineWidth: 1) :
                            nil
                        )
                )
        }
    }
}

// MARK: - BodyZone CaseIterable

extension BodyZone: CaseIterable {
    public static var allCases: [BodyZone] = [.uterus, .leftOvary, .rightOvary, .lowerBack, .thighs]
}

// MARK: - PainType CaseIterable

extension PainType: CaseIterable {
    public static var allCases: [PainType] = [.cramping, .burning, .pressure, .sharp, .other]
}
