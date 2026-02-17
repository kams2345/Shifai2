# ShifAI — Developer Handoff & Code Review Guide

**Date :** 17 février 2026  
**Projet :** ShifAI — Application de suivi de cycle menstruel (iOS + Android + Backend)  
**Statut :** MVP complet, prêt pour revue technique et compilation

---

## 📋 Résumé du projet

ShifAI est une application mobile de suivi de cycle menstruel avec prédictions IA, conçue pour le marché francophone africain. L'application est **100% en français**, **offline-first** avec synchronisation chiffrée, et conforme **RGPD**.

### Chiffres clés

| Métrique | Valeur |
|----------|--------|
| Fichiers totaux | 293 |
| Lignes de code | ~31 600 |
| Tests unitaires | ~906 |
| Composants cross-platform | 28 |
| Edge Functions backend | 5 |
| Sprints de développement | 48 |

---

## 🏗️ Architecture

```
shifai-ios/          → App iOS (Swift 5.9+, SwiftUI, GRDB, SQLCipher)
shifai-android/      → App Android (Kotlin, Jetpack Compose, Room, SQLCipher)
shifai-backend/      → Backend Supabase (PostgreSQL, Edge Functions Deno)
.github/             → CI/CD (GitHub Actions)
```

### Stack technique

| Couche | iOS | Android | Backend |
|--------|-----|---------|---------|
| UI | SwiftUI | Jetpack Compose | — |
| State | @MainActor + @Published | StateFlow + ViewModel | — |
| DB locale | GRDB + SQLCipher | Room + SQLCipher | PostgreSQL |
| Réseau | URLSession | HttpURLConnection | Supabase |
| Auth | LAContext (Face ID) | BiometricPrompt | RLS + JWT |
| Sync | BGTaskScheduler | WorkManager | Edge Functions |
| Chiffrement | CryptoKit (AES-256-GCM) | Android Keystore | pgcrypto |
| Santé | HealthKit | Health Connect | — |

### Pattern architectural

```
Presentation (Views + ViewModels)
       ↓
Data (Repositories + Managers)
       ↓
Domain (Engines: ML, Rules, Patterns)
       ↓
Infrastructure (Analytics, Crash, Perf)
```

---

## 🔍 Ce qu'il faut vérifier

### 1. Compilation (PRIORITAIRE)

**iOS :**
```bash
cd shifai-ios
open ShifAI.xcodeproj
# → Build (⌘B) sur iPhone 15 Pro Simulator
# → Résoudre les imports manquants (GRDB, SQLCipher via SPM)
# → Configurer Signing & Capabilities
```

**Android :**
```bash
cd shifai-android
# → Ouvrir dans Android Studio
# → File → Sync Project with Gradle Files
# → Build → Make Project
# → Résoudre les dépendances dans build.gradle
```

**Backend :**
```bash
cd shifai-backend
supabase start        # Démarrer Supabase local
supabase db reset     # Appliquer les migrations
supabase functions serve  # Tester les Edge Functions
```

### 2. Architecture & code quality

- [ ] **Cohérence** : Vérifier que les 28 composants cross-platform ont la même logique
- [ ] **Imports** : Tous les fichiers importent les bons modules
- [ ] **Types** : Pas de `Any` ou `as!` forcés (iOS), pas de `!!` (Android)
- [ ] **Null safety** : Optionals bien gérés côté iOS, nullability côté Kotlin
- [ ] **Concurrence** : `@MainActor` correct sur les ViewModels iOS, `StateFlow` sur Android
- [ ] **Mémoire** : Pas de retain cycles (iOS `[weak self]`), pas de leaks Android

### 3. Sécurité (CRITIQUE)

- [ ] **Chiffrement au repos** : SQLCipher configuré correctement (AES-256)
- [ ] **Zero PII dans les logs** : `CrashReporter` ne log jamais de données personnelles
- [ ] **RLS Supabase** : Row Level Security activé sur toutes les tables
- [ ] **Clés API** : Jamais hardcodées, toujours depuis config/env
- [ ] **Certificate pinning** : `NetworkSecurityManager` implémenté
- [ ] **Biométrie** : Face ID / Touch ID ne stocke pas de credentials en clair

### 4. Tests

**Exécuter les tests :**
```bash
# iOS
xcodebuild test -scheme ShifAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Android
cd shifai-android && ./gradlew test

# Backend
cd shifai-backend/supabase/functions && deno test --allow-all
```

- [ ] Tous les tests passent (41 fichiers iOS, 43 Android, 2 Backend)
- [ ] Couverture de code > 60%
- [ ] Tests critiques : `EncryptionManagerTests`, `SyncManagerTests`, `DatabaseManagerTests`

### 5. Fonctionnalités à tester manuellement

| Flux | Description | Points d'attention |
|------|-------------|-------------------|
| Onboarding | 6 goals, cycle/period length | Clamping (21-45 / 2-10) |
| Daily tracking | Flow, mood, energy, sleep, stress | Validation des plages |
| Body map | Sélection zones corporelles | Touch target sizes |
| Insights | Cartes IA avec feedback | Français correct |
| Export CSV | Téléchargement des données | Format dates françaises |
| Export PDF | Rapport médical | Mise en page |
| Sync | Push/pull chiffrés | Gestion conflits |
| Share link | Lien médecin temporaire (72h) | Expiration |
| Offline | Utilisation sans réseau | Aucune erreur |
| Biométrie | Face ID / empreinte | Fallback mot de passe |
| Notifications | 4 catégories, heures calmes | Pas entre 22h-7h |

---

## 📁 Structure du projet

### iOS (128 fichiers)

```
ShifAI/
├── App/              → ShifAIApp, AppState, AppConfig, AppContainer
├── Data/
│   ├── Models/       → CycleEntry, SymptomLog, InsightRecord, etc.
│   ├── Local/        → DatabaseManager, Repositories, Keychain
│   ├── Network/      → SupabaseClient, NetworkSecurityManager
│   ├── Sync/         → SyncEngine, BackgroundSyncScheduler
│   ├── Auth/         → BiometricAuthManager
│   ├── Encryption/   → EncryptionManager (AES-256-GCM)
│   ├── Export/       → CSVExporter, PDF template
│   └── Widget/       → WidgetDataProvider
├── Domain/
│   ├── Intelligence/ → MLEngine, RuleEngine, PatternDetection, QuickWin
│   ├── Export/       → MedicalExportEngine
│   └── Models/       → Domain models
├── Presentation/
│   ├── Dashboard/    → DashboardView + ViewModel
│   ├── Tracking/     → CycleTracking, BodyMap, DailyLog, SymptomLogging
│   ├── Insights/     → InsightsTabView + ViewModel
│   ├── Settings/     → SettingsView + ViewModel
│   ├── Export/       → ExportPreviewView + ViewModel
│   ├── Onboarding/   → OnboardingView + ViewModel
│   ├── Navigation/   → MainTabView (4 onglets)
│   └── Auth/         → BiometricLockView
└── ShifAITests/      → 41 fichiers de tests (~411 cas)
```

### Android (130 fichiers)

```
app/src/main/java/com/shifai/
├── app/              → ShifAIApplication, AppState
├── data/
│   ├── local/        → AppDatabase, Room Entities, DAOs
│   ├── repository/   → CycleRepository, InsightsRepository, Predictions
│   ├── sync/         → SyncManager, SyncWorker, BackgroundSync
│   ├── encryption/   → EncryptionManager
│   ├── monitoring/   → CrashReporter, PerformanceMonitor
│   ├── network/      → SupabaseClient, NetworkReachability
│   ├── health/       → HealthConnectManager
│   └── cache/        → ImageCache
├── domain/           → Miroir iOS (intelligence, export, models)
├── presentation/     → Compose Screens + ViewModels
│   ├── dashboard/    → DashboardScreen + ViewModel
│   ├── tracking/     → TrackingScreen + ViewModels
│   ├── insights/     → InsightsScreen + ViewModel
│   ├── settings/     → SettingsScreen + ViewModel
│   ├── navigation/   → ShifAINavigation, DeepLinkRouter
│   └── theme/        → ShifAITheme (Material3)
└── di/               → AppContainer (DI manuelle)

app/src/test/         → 43 fichiers de tests (~432 cas)
```

### Backend (16 fichiers)

```
shifai-backend/
├── supabase/
│   ├── migrations/   → 4 migrations SQL
│   └── functions/
│       ├── sync-data/           → Sync chiffré batch
│       ├── generate-share-link/ → Liens temporaires médecin
│       ├── delete-account/      → Suppression RGPD
│       ├── cleanup-expired/     → Cron maintenance
│       └── tests/               → Tests Deno
└── scripts/                     → Scripts utilitaires
```

---

## 📖 Documentation disponible

| Document | Contenu |
|----------|---------|
| `README.md` | Vue d'ensemble du projet |
| `ARCHITECTURE.md` | Architecture technique détaillée |
| `SECURITY.md` | Politique de sécurité et chiffrement |
| `COMPLIANCE.md` | Conformité RGPD |
| `API_REFERENCE.md` | Documentation API REST + Edge Functions |
| `BUILD_SETUP.md` | Guide d'installation pour développeurs |
| `MIGRATION.md` | Schéma de versioning de la base de données |
| `TESTING_STRATEGY.md` | Stratégie de test complète |
| `PERFORMANCE_BUDGET.md` | Budgets de performance par opération |
| `DEPLOYMENT.md` | Guide de déploiement CI/CD |
| `STORE_METADATA.md` | Descriptions App Store / Play Store (français) |
| `PRIVACY_POLICY.md` | Politique de confidentialité |
| `CHANGELOG.md` | Historique des changements |

---

## ⚠️ Points d'attention pour le développeur

### Éléments potentiellement à ajuster

1. **Dépendances SPM (iOS)** : Le `Package.swift` doit référencer GRDB, SQLCipher-Swift. Vérifier les versions.
2. **build.gradle (Android)** : Les dépendances Room, Compose, Health Connect, SQLCipher doivent être dans le bon fichier gradle.
3. **Supabase project** : Il faut créer un projet sur supabase.com et récupérer l'URL + clés.
4. **Feature Flags** : 3 flags sont désactivés par défaut (`ml_predictions`, `body_map_v2`, `analytics_v2`) — c'est intentionnel pour un lancement progressif.
5. **HealthKit / Health Connect** : Optionnel dans l'onboarding, nécessite des permissions spécifiques.
6. **AppConfig.plist / local.properties** : Ces fichiers contiennent les clés API et ne doivent PAS être commités dans git.

### Ordre de revue recommandé

1. **Compiler** les deux apps (iOS puis Android)
2. **Lancer les tests** unitaires
3. **Tester** le flux Onboarding → Dashboard → Tracking
4. **Vérifier** la sécurité (chiffrement, RLS, logs)
5. **Tester** la sync (offline → online)
6. **Valider** l'export (CSV + PDF)

---

## 📞 Contact

Pour toute question sur l'architecture ou les choix techniques, consulter les documents `ARCHITECTURE.md` et `SECURITY.md` dans le repo.
