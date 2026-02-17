# Testing Strategy — ShifAI

## Overview

~906 tests across 3 platforms. Focus on data integrity, encryption, and sync correctness.

## Test Distribution

| Platform | Test Files | Cases | Runner |
|----------|-----------|-------|--------|
| iOS | 41 | ~411 | XCTest |
| Android | 43 | ~432 | JUnit 4 |
| Backend | 2 | ~23 | Deno.test |

## Test Categories

### Unit Tests (majority)

| Category | iOS | Android | Examples |
|----------|-----|---------|----------|
| ViewModels | 7 files | 7 files | State transitions, data loading, validation |
| Repositories | 3 files | 3 files | CRUD, queries, aggregation |
| Domain Engines | 4 files | 4 files | Rules, patterns, predictions, ML fallback |
| Data Managers | 6 files | 6 files | Encryption, sync, biometric, export |
| Models | 5 files | 5 files | Encoding, decoding, validation, defaults |
| Infrastructure | 5 files | 5 files | Feature flags, dates, analytics, crash, perf |
| Accessibility | 1 file | 1 file | French label verification |
| Health | 1 file | 1 file | Flow mapping, import range, permissions |
| Cache | 1 file | 1 file | Memory + disk cache operations |
| Network | 1 file | 1 file | Connection types, sync decisions |

### Integration Tests (backend)

- Edge function request/response validation
- Cleanup logic (expired links, orphans, conflicts)
- Batch deletion and timestamp format

## Running Tests

```bash
# iOS (all tests)
xcodebuild test -scheme ShifAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Android (all tests)
cd shifai-android && ./gradlew test

# Backend (all tests)
cd shifai-backend/supabase/functions && deno test --allow-all

# Android single file
./gradlew test --tests "com.shifai.data.encryption.EncryptionManagerTest"
```

## Critical Test Areas

Tests that **must pass** before any release:

1. **EncryptionManagerTests** — AES-256-GCM encrypt/decrypt roundtrip
2. **DatabaseManagerTests** — SQLCipher operations, migration integrity
3. **SyncManagerTests** — Conflict resolution, offline queue
4. **BiometricManagerTests** — Auth flow, fallback handling
5. **CSVExporterTests** — Data export correctness
6. **CrashReporterTests** — Zero-PII verification

## Coverage Targets

| Layer | Target | Priority |
|-------|--------|----------|
| Domain Engines | 80%+ | High |
| Data Layer | 70%+ | High |
| ViewModels | 60%+ | Medium |
| Presentation | 40%+ | Low |
