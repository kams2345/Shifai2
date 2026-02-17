# Compliance — ShifAI

## GDPR (RGPD) Compliance

ShifAI processes health data under **GDPR Article 9** (special category data). Compliance is built into the architecture.

### Legal Basis

| Data Type | Legal Basis | Article |
|-----------|-------------|---------|
| Health data (cycle, symptoms) | Explicit consent | Art. 9(2)(a) |
| Technical data (performance) | Legitimate interest | Art. 6(1)(f) |
| Analytics (anonymous) | Consent | Art. 6(1)(a) |

### Data Subject Rights

| Right | Implementation | Where |
|-------|---------------|-------|
| Access (Art. 15) | CSV/PDF export | Settings > My Data |
| Rectification (Art. 16) | Direct edit in app | All tracking screens |
| Erasure (Art. 17) | Account deletion | Settings > Delete Account |
| Portability (Art. 20) | CSV export | Settings > Export |
| Withdraw consent | Toggle per data type | Onboarding / Settings |
| Restriction (Art. 18) | Pause sync | Settings > Sync |

### Data Protection Impact Assessment (DPIA)

Completed per **GDPR Art. 35**. Full assessment in [DPIA.md](DPIA.md).

## Data Storage

| Location | Purpose | Encryption |
|----------|---------|------------|
| Device (SQLCipher) | Primary storage | AES-256 |
| Supabase (EU) | Sync backup | E2E encrypted |
| None exported | No third-party access | N/A |

- **EU-only hosting**: aws-eu-central-1
- **No data transfer** outside EU/EEA
- **Supabase DPA** signed (Data Processing Agreement)

## App Store Compliance

### Apple App Store
- Health data usage description provided
- HealthKit entitlement with required privacy strings
- App Privacy labels configured (see STORE_METADATA.md)
- No tracking (ATT not required)

### Google Play Store
- Health Connect permissions declared
- Data Safety section completed
- No advertising SDK

## Age Requirement

- Minimum age: **16 years** (GDPR Art. 8)
- No data collected from users under 16

## Retention Policy

| Data | Retention | Deletion |
|------|-----------|----------|
| User health data | Until account deletion | Immediate + 30-day backup purge |
| Share links | 72 hours | Automatic (cleanup-expired) |
| Performance logs | 30 days | Automatic |
| Error logs | 30 days | Automatic |
