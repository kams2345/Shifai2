# ShifAI — Beta Launch Checklist (S10-6 → S10-8)
# Status: 🔲 = Not started, 🔳 = In progress, ✅ = Done

## Pre-Launch Infrastructure

### App Store (iOS)
- 🔲 App Store Connect: create app
- 🔲 App Name: ShifAI — Ton cycle, ton intelligence
- 🔲 Category: Health & Fitness
- 🔲 Age Rating: 12+ (reproductive health)
- 🔲 Privacy Labels:
  - Data Used to Track You: NONE
  - Data Linked to You: Health (cycle data) — encrypted, optional sync
  - Data Not Linked to You: Diagnostics (Plausible, zero PII)
- 🔲 Screenshots: iPhone 15 Pro (6.7"), iPhone SE (4.7"), iPad
  - Onboarding screen
  - Dashboard with cycle day
  - Insights predictions
  - Export PDF preview
  - Settings privacy badges
- 🔲 App Review Info:
  - Demo account credentials
  - Notes: "Health data is self-reported. App does not provide medical advice."
  - Review guideline 5.1.1 compliance doc
- 🔲 TestFlight internal group created
- 🔲 TestFlight external group (300-500 beta users)

### Play Store (Android)
- 🔲 Play Console: create app
- 🔲 Store Listing: title, description, feature graphic
- 🔲 Data Safety Section:
  - Data collected: Health info (cycle, symptoms) — encrypted
  - Data shared: NONE
  - Data handling: encrypted at rest and in transit
- 🔲 Content Rating: IARC questionnaire
- 🔲 Internal Track for testing
- 🔲 Closed Beta track (300-500 users)

## Security & Compliance

### GDPR / DPIA
- 🔲 Data Protection Impact Assessment completed
- 🔲 Processors listed: Supabase, Plausible
- 🔲 DPAs signed with all processors
- 🔲 Incident Response Plan (72h CNIL notification)
- 🔲 Legal review approved

### Security Audit
- 🔲 Third-party audit planned (€10K-25K)
- 🔲 Dependency scanning CI/CD
- 🔲 Certificate pinning validated
- 🔲 Encryption peer-reviewed
- 🔲 Product liability insurance (€2M-5M)

## Quality Assurance

### Testing Coverage
- 🔲 Unit tests: >80% Domain layer
- 🔲 Integration: encryption round-trip
- 🔲 Integration: sync flow
- 🔲 Integration: export generation
- 🔲 UI tests: onboarding flow
- 🔲 UI tests: tracking flow
- 🔲 UI tests: export flow
- 🔲 Crash-free rate: 99.9%+ target

### Accessibility
- 🔲 iOS: VoiceOver 4 critical flows
- 🔲 iOS: Dynamic Type 100-200%
- 🔲 iOS: Color contrast WCAG AA
- 🔲 iOS: Touch targets 44×44pt
- 🔲 iOS: Reduce Motion
- 🔲 Android: TalkBack
- 🔲 Android: Font scaling
- 🔲 Android: Touch targets 48×48dp
- 🔲 Android: Contrast ratio WCAG AA

### Performance
- 🔲 Cold start: <4s (WiFi), <4s (4G)
- 🔲 Warm start: <1s
- 🔲 Screen transitions: <300ms
- 🔲 ML inference: <150ms
- 🔲 Sync upload: <2s
- 🔲 Battery: <5%/day (background)

## Beta Recruitment
- 🔲 Target: 300-500 users
- 🔲 Recruitment channels:
  - EndoFrance community
  - Sopk.fr forums
  - SOPK/Endo Facebook groups
  - Reddit r/PCOS r/endometriosis (French)
  - Instagram health communities
- 🔲 Feedback channels:
  - In-app bug report (S9-8)
  - Email: beta@shifai.app
  - NPS survey (in-app, Week 4)
- 🔲 Analytics dashboards:
  - D1 retention rate
  - Quick Win delivery rate
  - Crash rate
  - Daily active users
  - Feature adoption (export, sync)

## Go/No-Go (M6)
- 🔲 D1 Retention > 60%
- 🔲 Crash-free rate > 99.9%
- 🔲 Quick Win delivery 100%
- 🔲 NPS > 50
- 🔲 Security audit passed
- 🔲 DPIA approved
- 🔲 Legal review cleared
