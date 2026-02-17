# Security Audit Checklist
## ShifAI — Pre-Launch Security Review

### 1. Data Protection
- [ ] AES-256-GCM encryption verified on iOS (CryptoKit)
- [ ] AES-256-GCM encryption verified on Android (Keystore)
- [ ] SQLCipher database encryption verified (both platforms)
- [ ] Encryption keys never leave device
- [ ] Key rotation mechanism tested
- [ ] No plaintext PII in logs
- [ ] No plaintext PII in crash reports

### 2. Network Security
- [ ] TLS 1.3 enforced (ATS on iOS, network_security_config on Android)
- [ ] Certificate pinning active (Supabase, Plausible)
- [ ] No cleartext HTTP traffic (verified with proxy)
- [ ] API rate limiting configured
- [ ] Request/response headers don't leak sensitive info

### 3. Authentication & Authorization
- [ ] JWT token expiry (1h) verified
- [ ] Refresh token rotation works
- [ ] Biometric auth prevents bypass
- [ ] Row Level Security (RLS) — users can't access other users' data
- [ ] Edge Functions validate auth headers
- [ ] Service role key never exposed to client

### 4. Zero-Knowledge Architecture
- [ ] Server receives only encrypted blobs
- [ ] Server cannot derive plaintext from stored data
- [ ] Supabase admin cannot read user health data
- [ ] Encryption happens client-side before network calls
- [ ] Decryption happens client-side after receiving data

### 5. Privacy (GDPR/RGPD)
- [ ] Consent collected before data processing
- [ ] Data export (CSV) works correctly
- [ ] Account deletion cascades all user data
- [ ] Account deletion logs GDPR compliance event
- [ ] Analytics are privacy-safe (Plausible, no cookies)
- [ ] No third-party SDKs that track users
- [ ] Privacy policy accessible from app
- [ ] DPIA completed and reviewed

### 6. Secure Storage
- [ ] iOS Keychain used for sensitive keys
- [ ] Android Keystore used for sensitive keys
- [ ] SharedPreferences not used for secrets
- [ ] UserDefaults not used for secrets
- [ ] App data excluded from iCloud backup
- [ ] App data excluded from Android auto-backup

### 7. Input Validation
- [ ] All slider values clamped (flow 0-4, mood 1-10, etc.)
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented in notes/comments
- [ ] File size limits enforced (10MB export)
- [ ] Deep link scheme validated

### 8. Code Security
- [ ] No hardcoded API keys in source
- [ ] No hardcoded passwords or tokens
- [ ] ProGuard/R8 obfuscation enabled for release
- [ ] Debug logging disabled in release builds
- [ ] Source maps not shipped in production

### 9. Infrastructure
- [ ] Supabase hosted in EU region only
- [ ] Database backups configured
- [ ] Edge Function error handling doesn't leak stack traces
- [ ] CORS configured for API endpoints
- [ ] Storage bucket permissions verified

### 10. Incident Response
- [ ] Security contact email configured
- [ ] Vulnerability disclosure process documented
- [ ] Data breach notification procedure (72h GDPR requirement)
- [ ] Crash reporting configured (no PII in reports)

---

**Status**: ⏳ Pending third-party audit
**Target completion**: Before public release
