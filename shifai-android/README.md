# ShifAI Android

Application native Android pour le suivi de cycles féminins personnalisé, avec intelligence artificielle on-device et architecture privacy-first.

## Stack Technique

- **Language:** Kotlin 2.0+
- **UI:** Jetpack Compose + Views (Body Map canvas)
- **Architecture:** Clean Architecture (Presentation → Domain → Data)
- **Database:** Room + SQLCipher (AES-256 encrypted)
- **ML:** TensorFlow Lite (Phase 2)
- **Auth:** Supabase Auth + AndroidKeyStore (TEE hardware-backed)
- **Widgets:** Glance API (Material You)
- **CI/CD:** GitHub Actions + Fastlane → Play Console Internal Track

## Configuration

1. Copier `local.properties.example` → `local.properties`
2. Ajouter `SUPABASE_URL=...` et `SUPABASE_ANON_KEY=...`
3. Ouvrir dans Android Studio Hedgehog+
4. Build target: SDK 26+ (Android 8.0)

## Architecture

```
app/src/main/java/com/shifai/
├── presentation/     # Compose UI, ViewModels, Navigation
├── domain/           # Models, UseCases, Intelligence Engine
└── data/             # Room+SQLCipher, KeyStore, Encryption, API
```

## Parité avec iOS

Ce projet miroir la structure iOS (`shifai-ios/`). Les modèles de domaine, le Rule Engine, et les interfaces d'encryption sont identiques pour assurer la cohérence entre plateformes.
