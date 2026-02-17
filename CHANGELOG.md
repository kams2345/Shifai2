# Changelog

All notable changes to ShifAI will be documented in this file.

## [1.0.0-beta.1] — 2026-02-12

### 🎉 First Beta Release

#### Core Tracking
- Cycle day tracking with 4 phases (menstrual, follicular, ovulatory, luteal)
- Flow intensity (5 levels)
- 29 symptom types across 6 categories
- Body map with 5 pain zones
- Mood, energy, sleep, and stress sliders (1-10)
- Daily notes

#### Intelligence Engine
- Pattern detection (symptom correlations, phase patterns)
- ML predictions via on-device TF Lite (iOS: Core ML)
- Auto-transition from rule-based to ML after 3 complete cycles
- Quick wins (5 milestones + 10 educational drip tips)
- Personalized recommendations

#### Medical Export
- PDF reports (SOPK, Endometriosis, Custom)
- 3/6/12 month date ranges
- Secure sharing via temporary links (24h expiry)

#### Privacy & Security
- AES-256-GCM encryption for all data
- SQLCipher encrypted database
- Biometric authentication (Face ID / fingerprint)
- Zero-knowledge backend (server cannot read data)
- Certificate pinning
- EU-only data hosting
- GDPR-compliant with full data export/deletion

#### Widgets
- iOS: WidgetKit (small, medium, large + lock screen)
- Android: Glance widget
- Privacy mode for widgets
- Cycle day, phase, and energy forecast display

#### Sync
- End-to-end encrypted cross-device sync
- Offline-first with automatic reconciliation
- Conflict resolution UI (keep local / keep remote / merge)

#### Notifications
- Smart prediction notifications
- Quiet hours (22:00-07:00)
- Max 1 notification per day
- Auto-stop after 3 consecutive ignores
- Per-category toggle

#### Platform Support
- iOS 17+ (SwiftUI)
- Android 8+ (Jetpack Compose)
- Supabase backend (EU region)

---

### Technical Stats
- **154 files** across iOS, Android, and backend
- **22,233 lines of code**
- **301 unit tests**
- **20 symptom types** tracked
- **4 Edge Functions** (sync, share, delete, cleanup)
- **2 SQL migrations** applied
