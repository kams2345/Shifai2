# Deployment — ShifAI

## CI/CD Pipeline

GitHub Actions workflow: `.github/workflows/ci.yml`

### Pipeline Stages

```
Push to main
    ├── iOS Build + Test (Xcode 15, iPhone 15 Pro Simulator)
    ├── Android Build + Test (Gradle, JDK 17)
    └── Backend Test (Deno)
         ↓
    Tag vX.Y.Z
         ↓
    ├── iOS → TestFlight (Fastlane)
    └── Android → Play Console (Internal Testing)
```

## Required Secrets (GitHub)

| Secret | Purpose |
|--------|---------|
| `APPLE_DEVELOPER_TEAM_ID` | iOS signing |
| `MATCH_PASSWORD` | Fastlane Match certificates |
| `SUPABASE_URL` | Backend URL |
| `SUPABASE_ANON_KEY` | Public API key |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions admin |
| `KEYSTORE_FILE` | Android signing keystore (base64) |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |

## iOS Deployment

### TestFlight

```bash
# Using Fastlane
cd shifai-ios
bundle exec fastlane beta
```

### App Store

```bash
bundle exec fastlane release
```

### Requirements
- Apple Developer account ($99/year)
- App ID with HealthKit, BackgroundModes, AppGroups
- Provisioning profiles (managed by Fastlane Match)

## Android Deployment

### Internal Testing

```bash
cd shifai-android
./gradlew bundleRelease
# Upload AAB to Play Console → Internal Testing track
```

### Production

```bash
./gradlew bundleRelease
# Play Console → Production track (after internal testing)
```

### Requirements
- Google Play Developer account ($25 one-time)
- Signed release keystore
- Data Safety form completed

## Backend Deployment

### Supabase (Production)

```bash
cd shifai-backend

# Deploy Edge Functions
supabase functions deploy sync-data
supabase functions deploy generate-share-link
supabase functions deploy delete-account
supabase functions deploy cleanup-expired
supabase functions deploy cleanup-expired-exports

# Apply migrations
supabase db push
```

### Cron Jobs

Set up in Supabase Dashboard → Database → Extensions → pg_cron:

```sql
-- Cleanup expired share links every hour
SELECT cron.schedule('cleanup-expired', '0 * * * *',
  $$SELECT net.http_post(
    'https://your-project.supabase.co/functions/v1/cleanup-expired',
    '{}', 'application/json',
    ARRAY[http_header('Authorization', 'Bearer ' || current_setting('app.service_role_key'))]
  )$$
);
```

## Environment Setup

| Environment | Supabase | Purpose |
|-------------|----------|---------|
| Local | `supabase start` | Development |
| Staging | Separate project | Pre-release testing |
| Production | Main project | Live users |
