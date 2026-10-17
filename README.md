# ShifAI 🌙

**Rappel intelligent** — privacy-first, AI-powered, offline-ready.

[![iOS](https://img.shields.io/badge/iOS-17%2B-blue)](shifai-ios/)
[![Android](https://img.shields.io/badge/Android-API%2029%2B-green)](shifai-android/)
[![Tests](https://img.shields.io/badge/tests-906-brightgreen)](.github/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-proprietary-red)](LICENSE)

## Status

| Composant | Statut | Détails |
|-----------|--------|--------|
| 📱 iOS | ✅ Code complet | 128 fichiers, ~411 tests |
| 🤖 Android | ✅ Code complet | 130 fichiers, ~432 tests |
| ☁️ Backend | ✅ Code complet | 5 Edge Functions, ~23 tests |
| 📦 CI/CD | ⏳ Config requise | Workflows prêts, secrets à ajouter |
| 🚀 Production | ⏳ Build requis | Compilation + tests à valider |

## Architecture

```
shifai-ios/          SwiftUI · GRDB · CryptoKit · WidgetKit
shifai-android/      Compose · Room · Keystore · Glance
shifai-backend/      Supabase · PostgreSQL · Deno Edge Functions
.github/             CI/CD · Issue Templates · CODEOWNERS
```

### Layer Diagram

```mermaid
graph TD
    A[UI Layer] --> B[ViewModels]
    B --> C[Domain Engines]
    B --> D[Repository]
    C --> E[Models]
    D --> F[Local DB]
    D --> G[Supabase Client]
    F --> H[SQLCipher / GRDB]
    G --> I[Edge Functions]
    G --> J[PostgreSQL + RLS]
```

## Features

| Feature | Description |
|---------|-------------|
| 📊 **Smart Tracking** | Flow, mood, energy, sleep, stress, 29 symptom types, body map |
| 🤖 **AI Predictions** | Rule-based → ML transition after 6 cycles (CoreML / TFLite) |
| 💡 **Pattern Insights** | Correlations, trends, personalized quick wins |
| 📄 **Medical Export** | PDF reports (SOPK, Endométriose, Custom) + CSV |
| 🔒 **Zero-Knowledge** | AES-256-GCM E2E encryption, data unreadable on server |
| ☁️ **E2E Sync** | Offline-first with encrypted cloud backup |
| 📱 **Widgets** | iOS WidgetKit + Android Glance with privacy mode |
| 🔔 **Smart Alerts** | Phase predictions, quiet hours, per-category control |
| ♿ **Accessible** | WCAG 2.1 AA, French semantic labels |
| 🇫🇷 **French-First** | Full French UI (150+ strings per platform) |

## Quick Start

### Prerequisites
- **iOS**: Xcode 15+, Swift 5.9+
- **Android**: Android Studio Hedgehog+, JDK 17
- **Backend**: Deno 1.40+, Supabase CLI

### Setup

```bash
git clone https://github.com/kams2345/Shifai2.git && cd Shifai2

# Backend
cd shifai-backend && supabase start && supabase db reset

# iOS
open shifai-ios/ShifAI.xcodeproj
# Set SUPABASE_URL and SUPABASE_ANON_KEY in Config.xcconfig

# Android
cd shifai-android && ./gradlew assembleDebug
# Set values in local.properties
```

### Run Tests

```bash
# iOS (~411 tests)
xcodebuild test -scheme ShifAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Android (~432 tests)
cd shifai-android && ./gradlew test

# Backend (~23 tests)
cd shifai-backend/supabase/functions && deno test --allow-all
```

## Security & Privacy

> ShifAI processes **health data** (GDPR Article 9). Security is not optional.

- 🔐 **AES-256-GCM** encryption at rest (SQLCipher) and in transit (TLS 1.3)
- 🔑 **Keychain / Keystore** for cryptographic keys
- 📌 **Certificate pinning** for API calls
- 🚫 **Zero third-party trackers** — Plausible analytics only (consent-based)
- 🏛️ **EU-only hosting** (aws-eu-central-1)
- 📋 **DPIA** completed (RGPD Art. 35)

See [SECURITY_AUDIT.md](SECURITY_AUDIT.md) for the full 50+ item checklist.

## Documentation

| Document | Purpose |
|----------|---------|
| [BUILD_SETUP.md](BUILD_SETUP.md) | Setup reproductible (commandes exactes, env vars) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Architecture technique détaillée |
| [DEV_HANDOFF.md](DEV_HANDOFF.md) | Guide de revue pour développeurs |
| [API_REFERENCE.md](API_REFERENCE.md) | Documentation API REST + Edge Functions |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Architecture rules, code style, PR process |
| [ANALYTICS_EVENTS.md](ANALYTICS_EVENTS.md) | 22 privacy-safe events |
| [PRIVACY_POLICY.md](PRIVACY_POLICY.md) | Politique de confidentialité RGPD (français) |
| [TERMS_OF_SERVICE.md](TERMS_OF_SERVICE.md) | Conditions d'utilisation App Store / Play Store |
| [DPIA.md](DPIA.md) | Data Protection Impact Assessment |
| [SECURITY_AUDIT.md](SECURITY_AUDIT.md) | Pre-launch security checklist |
| [MIGRATION.md](MIGRATION.md) | Schema de versioning base de données |
| [PERFORMANCE_BUDGET.md](PERFORMANCE_BUDGET.md) | Budgets de performance par opération |
| [CHANGELOG.md](CHANGELOG.md) | Release notes |

## License

Proprietary. All rights reserved.
