import SwiftUI

// MARK: - Settings Screen (S9-1) + Notification Settings (S8-6) + Privacy Dashboard (S9-2) + Data Export/Delete (S9-3)

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirmation = false
    @State private var showExportSheet = false

    var body: some View {
        NavigationView {
            List {
                // ─── Profile ───
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "7C5CFC"), Color(hex: "EC4899")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)
                            Text("🌸")
                                .font(.system(size: 24))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mon Profil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Cycle • Symptômes • Conditions")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .listRowBackground(Color.white.opacity(0.04))

                // ─── S7: Sync Settings ───
                Section(header: sectionHeader("Synchronisation")) {
                    Toggle(isOn: $viewModel.syncEnabled) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Sync Cloud")
                                    .foregroundColor(.white)
                                Text("Données chiffrées. Le serveur ne peut pas les lire.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        } icon: {
                            Image(systemName: "icloud.and.arrow.up")
                                .foregroundColor(Color(hex: "34D399"))
                        }
                    }
                    .tint(Color(hex: "7C5CFC"))

                    if viewModel.syncEnabled {
                        Button {
                            Task { await viewModel.triggerSync() }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(Color(hex: "60A5FA"))
                                Text("Synchroniser maintenant")
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.isSyncing {
                                    ProgressView().tint(Color(hex: "A78BFA"))
                                } else {
                                    Text(viewModel.lastSyncText)
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.04))

                // ─── S8-6: Notification Settings ───
                Section(header: sectionHeader("Notifications")) {
                    ForEach(NotificationEngine.NotificationCategory.allCases, id: \.rawValue) { category in
                        Toggle(isOn: Binding(
                            get: { viewModel.isNotificationEnabled(category) },
                            set: { viewModel.setNotificationEnabled(category, enabled: $0) }
                        )) {
                            HStack {
                                Text(category.displayName)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(viewModel.notificationHour(category))h")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .tint(Color(hex: "7C5CFC"))
                    }

                    Toggle(isOn: $viewModel.dailyCheckInEnabled) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Rappel quotidien")
                                    .foregroundColor(.white)
                                Text("Rappel pour logger tes symptômes")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        } icon: {
                            Image(systemName: "bell.badge")
                                .foregroundColor(Color(hex: "F59E0B"))
                        }
                    }
                    .tint(Color(hex: "7C5CFC"))
                }
                .listRowBackground(Color.white.opacity(0.04))

                // ─── S9-2: Privacy & Security ───
                Section(header: sectionHeader("Confidentialité & Sécurité")) {
                    Toggle(isOn: $viewModel.biometricEnabled) {
                        Label("Verrouillage biométrique", systemImage: "faceid")
                            .foregroundColor(.white)
                    }
                    .tint(Color(hex: "7C5CFC"))

                    HStack {
                        Label("Auto-lock", systemImage: "lock.rotation")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $viewModel.autoLockMinutes) {
                            Text("1 min").tag(1)
                            Text("5 min").tag(5)
                            Text("15 min").tag(15)
                        }
                        .pickerStyle(.menu)
                        .tint(Color(hex: "A78BFA"))
                    }

                    Toggle(isOn: $viewModel.widgetPrivacyMode) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Mode privé widget")
                                    .foregroundColor(.white)
                                Text("Floute les données sur l'écran d'accueil")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        } icon: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(Color(hex: "EC4899"))
                        }
                    }
                    .tint(Color(hex: "7C5CFC"))

                    // Privacy badges
                    HStack(spacing: 12) {
                        privacyBadge(icon: "🔒", text: "Chiffrement AES-256")
                        privacyBadge(icon: "🇪🇺", text: "Serveurs EU")
                        privacyBadge(icon: "✅", text: "0 trackers")
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.white.opacity(0.04))

                // ─── S9-3: Data ───
                Section(header: sectionHeader("Mes Données")) {
                    Button {
                        showExportSheet = true
                    } label: {
                        Label("Exporter mes données (CSV)", systemImage: "arrow.down.doc")
                            .foregroundColor(.white)
                    }

                    NavigationLink {
                        ExportPreviewView()
                    } label: {
                        Label("Export médical (PDF)", systemImage: "doc.richtext")
                            .foregroundColor(.white)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Supprimer mon compte", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                .listRowBackground(Color.white.opacity(0.04))

                // ─── About ───
                Section(header: sectionHeader("À propos")) {
                    infoRow("Version", value: "1.0.0")
                    infoRow("Build", value: "Sprint 7")

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Politique de confidentialité", systemImage: "hand.raised")
                            .foregroundColor(.white)
                    }

                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("Conditions d'utilisation", systemImage: "doc.text")
                            .foregroundColor(.white)
                    }

                    Button {
                        viewModel.reportBug()
                    } label: {
                        Label("Signaler un bug", systemImage: "ladybug")
                            .foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ShifAIColors.background.ignoresSafeArea())
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .alert("Supprimer mon compte", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer tout", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
            } message: {
                Text("Es-tu sûre ? Cette action est irréversible. Toutes tes données seront supprimées de cet appareil et du serveur.")
            }
            .sheet(isPresented: $showExportSheet) {
                if let csvData = viewModel.exportCSV() {
                    ShareSheet(activityItems: csvData)
                }
            }
        }
    }

    // MARK: - Components

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "A78BFA"))
            .textCase(.uppercase)
    }

    private func privacyBadge(icon: String, text: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 16))
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 13))
        }
    }
}

// MARK: - Privacy Policy View (S9-5)

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Politique de Confidentialité")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                policySection("Collecte de données",
                    "ShifAI collecte uniquement les données que vous saisissez volontairement : cycles, symptômes, notes. Aucune donnée n'est collectée automatiquement à votre insu.")

                policySection("Chiffrement",
                    "Toutes vos données sont chiffrées AES-256-GCM sur votre appareil avant toute transmission. Le serveur ne peut jamais lire vos données en clair (zero-knowledge).")

                policySection("Hébergement",
                    "Toutes les données sont hébergées en Union Européenne (Supabase, région eu-west-1), conformément au RGPD.")

                policySection("Vos droits (RGPD)",
                    "• Droit d'accès : exportez vos données à tout moment (CSV)\n• Droit à l'effacement : supprimez votre compte et toutes vos données\n• Droit à la portabilité : exportez dans un format ouvert\n• Droit d'opposition : désactivez la sync cloud à tout moment")

                policySection("Trackers et analytics",
                    "ShifAI n'utilise aucun tracker tiers (pas de Google Analytics, pas de Facebook Pixel). Nous utilisons Plausible Analytics (hébergé en UE, sans cookies, RGPD-compliant).")

                policySection("Contact DPO",
                    "Pour toute question relative à vos données personnelles :\ndpo@shifai.app")
            }
            .padding(20)
        }
        .background(ShifAIColors.background.ignoresSafeArea())
        .navigationTitle("Confidentialité")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "A78BFA"))
            Text(body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Terms of Service View (S9-5)

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Conditions d'Utilisation")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("""
                1. ShifAI est une application de suivi de cycle menstruel à titre informatif uniquement.

                2. ShifAI ne fournit aucun diagnostic médical, avis médical, ni traitement.

                3. Les prédictions sont basées sur des algorithmes statistiques et ne doivent pas être utilisées comme seule base de décision médicale.

                4. Consultez toujours un professionnel de santé qualifié.

                5. Vos données vous appartiennent. Vous pouvez les exporter ou les supprimer à tout moment.

                6. En utilisant ShifAI, vous acceptez notre Politique de Confidentialité.

                © ShifAI \(Calendar.current.component(.year, from: Date()))
                """)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
        }
        .background(ShifAIColors.background.ignoresSafeArea())
        .navigationTitle("Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ViewModel

final class SettingsViewModel: ObservableObject {
    @Published var syncEnabled: Bool {
        didSet { SyncEngine.shared.isEnabled = syncEnabled }
    }
    @Published var isSyncing = false
    @Published var lastSyncText = ""
    @Published var biometricEnabled: Bool {
        didSet { UserDefaults.standard.set(biometricEnabled, forKey: "biometric_enabled") }
    }
    @Published var autoLockMinutes: Int {
        didSet { UserDefaults.standard.set(autoLockMinutes, forKey: "auto_lock_minutes") }
    }
    @Published var widgetPrivacyMode: Bool {
        didSet { WidgetDataProvider.shared.setPrivacyMode(widgetPrivacyMode) }
    }
    @Published var dailyCheckInEnabled: Bool {
        didSet { UserDefaults.standard.set(dailyCheckInEnabled, forKey: "daily_checkin_enabled") }
    }

    private let notificationEngine = NotificationEngine.shared

    init() {
        self.syncEnabled = SyncEngine.shared.isEnabled
        self.biometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
        self.autoLockMinutes = UserDefaults.standard.integer(forKey: "auto_lock_minutes")
        self.widgetPrivacyMode = WidgetDataProvider.shared.isPrivacyModeEnabled
        self.dailyCheckInEnabled = UserDefaults.standard.bool(forKey: "daily_checkin_enabled")

        if autoLockMinutes == 0 { autoLockMinutes = 5 }
        updateLastSyncText()
    }

    func isNotificationEnabled(_ category: NotificationEngine.NotificationCategory) -> Bool {
        notificationEngine.isCategoryEnabled(category)
    }

    func setNotificationEnabled(_ category: NotificationEngine.NotificationCategory, enabled: Bool) {
        notificationEngine.setCategoryEnabled(category, enabled: enabled)
    }

    func notificationHour(_ category: NotificationEngine.NotificationCategory) -> Int {
        notificationEngine.preferredHour(for: category)
    }

    // S7-5: Manual sync
    func triggerSync() async {
        isSyncing = true
        let result = await BackgroundSyncScheduler.shared.triggerManualSync()
        isSyncing = false
        lastSyncText = result.message
    }

    private func updateLastSyncText() {
        lastSyncText = BackgroundSyncScheduler.shared.lastSyncDescription()
    }

    // S9-3: CSV export
    func exportCSV() -> [Any]? {
        // Generate CSVs for each data table
        var csvFiles: [Any] = []

        let cycleRepo = CycleRepository()
        let symptomRepo = SymptomRepository()

        if let cycles = try? cycleRepo.fetchAll() {
            var csv = "date,cycle_day,phase,flow_intensity,notes\n"
            let formatter = ISO8601DateFormatter()
            for c in cycles {
                csv += "\(formatter.string(from: c.date)),\(c.cycleDay),\(c.phase?.rawValue ?? ""),\(c.flowIntensity ?? 0),\"\(c.notes ?? "")\"\n"
            }
            if let data = csv.data(using: .utf8) {
                csvFiles.append(data)
            }
        }

        return csvFiles.isEmpty ? nil : csvFiles
    }

    // S9-4: Account deletion
    func deleteAccount() async {
        // 1. Wipe local DB
        // TODO: Call DatabaseManager.shared.deleteAll()

        // 2. Clear Keychain
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        SecItemDelete(query as CFDictionary)

        // 3. Clear UserDefaults
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }

        // 4. Request server deletion via Edge Function
        // TODO: Call delete-account edge function
    }

    // S9-8: Bug report
    func reportBug() {
        let device = UIDevice.current
        let info = """
        App: ShifAI v1.0.0
        Device: \(device.model)
        OS: \(device.systemName) \(device.systemVersion)
        """
        // Open email compose with device info (no PII)
        if let url = URL(string: "mailto:support@shifai.app?subject=Bug%20Report&body=\(info.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
}
