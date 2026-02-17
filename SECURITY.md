# Security — ShifAI

## Threat Model

ShifAI processes **GDPR Article 9** health data. All security measures are mandatory, not optional.

## Encryption

| Layer | Method | Key Storage |
|-------|--------|-------------|
| Database (at rest) | SQLCipher (AES-256) | iOS Keychain / Android Keystore |
| Data fields | AES-256-GCM | Device-generated, never transmitted |
| Network (in transit) | TLS 1.3 | Certificate pinning |
| Server-side | pgcrypto | Supabase managed |
| Backup | Encrypted before sync | Same master key |

## Zero-Knowledge Architecture

1. User data is encrypted **on-device** before any network transmission
2. Encryption key is generated locally and stored in hardware-backed keychain
3. Server stores **only encrypted blobs** — cannot read user data
4. Share links use time-limited tokens (72h) with separate encryption

## Authentication

| Method | iOS | Android |
|--------|-----|---------|
| Biometric | Face ID / Touch ID (LAContext) | Fingerprint / Face (BiometricPrompt) |
| Fallback | Device passcode | Device PIN/pattern |
| Session | JWT (Supabase Auth) | JWT (Supabase Auth) |

## Network Security

- **TLS 1.3** minimum for all API calls
- **Certificate pinning** for `*.supabase.co` domains
- **NetworkSecurityManager** validates server certificates
- No data sent over unencrypted channels

## Data Minimization (GDPR)

- **No PII in logs**: CrashReporter strips all personal data
- **No tracking IDs**: No IDFA, GAID, or advertising identifiers
- **No third-party SDKs**: No Firebase, Facebook, Google Analytics
- **Analytics**: Plausible only (cookie-free, consent-based)
- **Crash reports**: Error codes only, no stack traces with user data

## Access Controls

- **Row Level Security (RLS)** on all Supabase tables
- **Service role key** restricted to backend Edge Functions
- **Anon key** has read-only access scoped to authenticated user's rows
- **Delete cascade**: Account deletion removes all data (GDPR Art. 17)

## Incident Response

1. Security issues: contact **security@shifai.app**
2. Response time: 24 hours for critical, 72 hours for medium
3. User notification: Within 72 hours per GDPR Art. 33/34
