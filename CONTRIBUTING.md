# Contributing to ShifAI

## Getting Started

### Prerequisites
- **iOS**: Xcode 15+, Swift 5.9+
- **Android**: Android Studio Hedgehog+, JDK 17, Gradle 8.6
- **Backend**: Deno 1.40+, Supabase CLI 1.100+

### Setup

```bash
# Clone
git clone https://github.com/shifai/shifai.git
cd shifai

# iOS
open shifai-ios/ShifAI.xcodeproj

# Android
cd shifai-android && ./gradlew build

# Backend
cd shifai-backend && supabase start
supabase db reset  # Runs migrations + seed data
```

## Architecture

```
shifai-ios/         SwiftUI + GRDB + CryptoKit
shifai-android/     Compose + Room + Keystore
shifai-backend/     Supabase (PostgreSQL + Edge Functions)
.github/            CI/CD workflows
```

### Layer Rules

| Layer | Can depend on | Cannot depend on |
|-------|--------------|-----------------|
| Presentation (ViewModels) | Domain, Data | — |
| Domain (Engines) | Models only | Presentation, Data |
| Data (Repos, Network) | Domain models | Presentation |
| Infrastructure | Nothing | — |

## Code Style

### Swift
- **SwiftLint** rules in `.swiftlint.yml`
- Prefer `struct` over `class` for value types
- Use `@MainActor` for UI-bound code
- Use `actor` for thread-safe shared state

### Kotlin
- **ktlint** enforced via Gradle
- Prefer `data class` for models
- Use `sealed class` for closed hierarchies
- Use `StateFlow` for UI state

### Both Platforms
- All strings in French (primary language)
- All UI accessible (WCAG 2.1 AA)
- No hardcoded values — use `AppConfig`
- All errors via `ShifAIError` types

## Testing

```bash
# iOS (92+ tests)
cd shifai-ios && fastlane test

# Android (254+ tests)
cd shifai-android && ./gradlew testDebugUnitTest

# Backend (13 tests)
cd shifai-backend && deno test supabase/functions/tests/
```

### Test Guidelines
- Unit tests for all Engines, ViewModels, and Data classes
- Test file naming: `[Class]Tests.swift` / `[Class]Test.kt`
- No mocking frameworks — use pure logic tests
- Test French strings where applicable

## Privacy & Security

> **CRITICAL**: ShifAI processes health data. Every PR must follow these rules.

1. **No PII in logs** — ever
2. **No plaintext health data** in network requests
3. **No third-party analytics SDKs** — Plausible only
4. **No new permissions** without team review
5. **Encryption before sync** — always client-side
6. **RLS policies required** for any new table

## Pull Request Process

1. Create feature branch from `main`
2. Follow commit convention: `feat:`, `fix:`, `test:`, `docs:`
3. All tests must pass
4. Security review for any data/network changes
5. French strings required for UI changes
6. Accessibility labels for new interactive elements

## File Naming

| Platform | Production | Tests |
|----------|-----------|-------|
| iOS | `PascalCase.swift` | `PascalCaseTests.swift` |
| Android | `PascalCase.kt` | `PascalCaseTest.kt` |
| Backend | `kebab-case/index.ts` | `*_test.ts` |
