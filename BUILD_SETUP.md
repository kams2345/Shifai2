# Build Setup — ShifAI

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Xcode | 15.2+ | Mac App Store |
| Android Studio | Hedgehog+ | developer.android.com |
| Node.js | 20 LTS | `brew install node` |
| Supabase CLI | 1.x | `brew install supabase/tap/supabase` |
| Swift | 5.9+ | Bundled with Xcode |
| Kotlin | 1.9+ | Bundled with Android Studio |

## iOS

```bash
# 1. Install dependencies
cd shifai-ios
swift package resolve

# 2. Open in Xcode
open ShifAI.xcodeproj

# 3. Set signing team
# Xcode → Signing & Capabilities → Team → Select your team

# 4. Build & Run
# Select iPhone 15 Pro simulator → ⌘R
```

**Required capabilities:**
- App Groups: `group.com.shifai.shared`
- Background Modes: Background fetch, Background processing
- Face ID: Privacy — Face ID Usage Description

## Android

```bash
# 1. Open in Android Studio
cd shifai-android
# File → Open → select shifai-android directory

# 2. Create local.properties
echo "SUPABASE_URL=https://your-project.supabase.co" >> local.properties
echo "SUPABASE_ANON_KEY=your-anon-key" >> local.properties
echo "PLAUSIBLE_DOMAIN=your-domain" >> local.properties

# 3. Sync Gradle
# Android Studio → File → Sync Project with Gradle Files

# 4. Run
# Select emulator → ▶ Run
```

**Required permissions (AndroidManifest.xml):**
- `INTERNET`
- `USE_BIOMETRIC`
- `RECEIVE_BOOT_COMPLETED` (background sync)
- `POST_NOTIFICATIONS` (Android 13+)

## Backend

```bash
# 1. Start local Supabase
cd shifai-backend
supabase start

# 2. Apply migrations
supabase db reset

# 3. Run edge functions locally
supabase functions serve

# 4. Run tests
cd supabase/functions && deno test --allow-all
```

## Environment Variables

| Variable | Where | Purpose |
|----------|-------|---------|
| `SUPABASE_URL` | iOS/Android/Backend | Project URL |
| `SUPABASE_ANON_KEY` | iOS/Android | Public API key |
| `SUPABASE_SERVICE_ROLE_KEY` | Backend only | Admin access |
| `PLAUSIBLE_DOMAIN` | iOS/Android | Analytics domain |
| `ENCRYPTION_KEY` | Generated on device | Never transmitted |

## Running Tests

```bash
# iOS
xcodebuild test -scheme ShifAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Android
cd shifai-android && ./gradlew test

# Backend
cd shifai-backend/supabase/functions && deno test --allow-all
```
