# Analytics Events — ShifAI
## Privacy-Safe Event Tracking (Plausible.io)

> **Zero PII guarantee**: No user identifiers, no health data, no device fingerprints.

## Events

| Event | When Fired | Properties |
|-------|-----------|------------|
| `app_launched` | App foreground | `platform`, `version` |
| `onboarding_started` | First screen shown | `platform` |
| `onboarding_completed` | Last step done | `cycle_length_bucket` (short/normal/long) |
| `onboarding_skipped` | Skip button tapped | `step_number` |
| `tracking_saved` | Daily log saved | `symptom_count_bucket` (0/1-3/4+) |
| `tracking_edited` | Existing log edited | — |
| `insight_viewed` | Insight card tapped | `insight_type` |
| `insight_feedback` | Feedback submitted | `feedback_type` (accurate/early/late/wrong) |
| `export_generated` | PDF created | `template`, `date_range` |
| `export_shared` | Share sheet opened | `method` (link/file) |
| `sync_enabled` | Sync toggled on | — |
| `sync_completed` | Sync finished | `conflict_count_bucket` (0/1/2+) |
| `sync_failed` | Sync error | `error_category` |
| `notification_received` | Push delivered | `notification_type` |
| `notification_tapped` | Push opened app | `notification_type` |
| `notification_disabled` | Category toggled off | `category` |
| `settings_biometric` | Biometric toggled | `enabled` |
| `settings_privacy` | Widget privacy toggled | `enabled` |
| `delete_account` | Account deleted | — |
| `error_occurred` | Unhandled error | `error_code` |
| `ml_transition` | Switched to ML mode | `cycle_count` |
| `widget_tapped` | Widget opened app | `widget_size` |

## Property Buckets (Privacy-Safe)

Instead of exact values, we bucket sensitive counts:

| Property | Buckets | Rationale |
|----------|---------|-----------|
| `cycle_length_bucket` | short (<25), normal (25-35), long (>35) | No exact cycle length |
| `symptom_count_bucket` | 0, 1-3, 4+ | No exact symptom count |
| `conflict_count_bucket` | 0, 1, 2+ | No exact conflict count |

## What We **Don't** Track

- ❌ User identifiers (no user_id, email, device_id)
- ❌ Health data (no symptoms, phases, flow, mood values)
- ❌ Location or IP (Plausible anonymizes by default)
- ❌ Session duration or screen time
- ❌ Specific dates or timestamps of health events
- ❌ Body map zones
- ❌ Notes content

## Implementation

| Platform | File | Method |
|----------|------|--------|
| iOS | `AnalyticsTracker.swift` | `URLSession` POST to Plausible |
| Android | `AnalyticsTracker.kt` | `HttpURLConnection` POST to Plausible |

### Consent Flow
1. Analytics **disabled** by default
2. User enables in Settings → "Analytique anonyme"
3. Stored in `AppConfig` / `SharedPreferences`
4. All tracking calls check consent before sending
